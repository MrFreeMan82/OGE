unit uSync;

interface
uses Forms, Classes, Windows, Messages, SysUtils, imapsend, mimemess,
      mimepart, smtpsend, ssl_openssl;

type TSyncParams = class
  private
      mGate: string;
      mUserName: string;
      mPassword: string;
      mSMTP: string;
      mSMTPPort: string;
      mIMAP: string;
      mIMAPPort: string;
    procedure setGate(const Value: string);
    procedure setIMAP(const Value: string);
    procedure setIMAPPort(const Value: string);
    procedure setPassword(const Value: string);
    procedure setSMTP(const Value: string);
    procedure setSMTPPort(const Value: string);
    procedure setUserName(const Value: string);
  public
    property Gate: string read mGate write setGate;
    property UserName: string read mUserName write setUserName;
    property Password: string read mPassword write setPassword;
    property SMTPHost: string read mSMTP write setSMTP;
    property SMTPPort: string read mSMTPPort write setSMTPPort;
    property IMAPHost: string read mIMAP write setIMAP;
    property IMAPPort: string read mIMAPPort write setIMAPPort;

    constructor Create();
end;

type TSync = class
     private
        log: TStringList;
        msyncParams: TSyncParams;
        mimap: TIMAPSend;
        msmtp: TSMTPSend;

        function getBody(msg: TStringList): string;
        procedure OnReadFilter(Sender: TObject; var Value: AnsiString);
    procedure setsyncParams(const Value: TSyncParams);
     public
        property SyncParams: TSyncParams read msyncParams write setsyncParams;
        function send(const key, value: string): boolean;
        function reciev(body: TStringList): boolean;
        procedure saveLog();
        constructor Create;
        procedure Free;
end;

implementation

uses uData, SQLite3, SQLiteTable3;

{ TSync }

constructor TSync.Create;
begin
     log := TStringList.Create;
     mimap := TIMAPSend.Create;
     msmtp := TSMTPSend.Create;
     mimap.Timeout := 5000;
     mimap.FullSSL := true;
     mimap.Sock.OnReadFilter := OnReadFilter;
     msmtp.Timeout := 5000;
     msmtp.FullSSL := true;
     msmtp.Sock.OnReadFilter := OnReadFilter;
end;

procedure TSync.Free;
begin
     log.Free;
     freeAndNil(msyncParams);
     mimap.Free;
     msmtp.Free;
end;

procedure TSync.OnReadFilter(Sender: TObject; var Value: AnsiString);
begin
    log.Add(string(Value));
end;

procedure TSync.saveLog;
begin
    log.SaveToFile('log.log');
end;

function TSync.getBody(msg: TStringList): string;
var i,k, eq: integer;
begin
     result := '';

     i := 0;
     while  i < Msg.Count do
     begin
          while (i < Msg.Count) and
                     (pos('<OGE_SYNC>', Msg.Strings[i]) = 0) do inc(i);

          inc(i);

          while (i < Msg.Count) and
                (pos('</OGE_SYNC>', Msg.Strings[i]) = 0) do
          begin
               result := result + trim(Msg.Strings[i]);
               eq := pos('=', result);
               if eq > 0 then
               begin
                    result[eq] := #0;
                    result := trim(result)
               end;
               inc(i);
          end;
          break;
     end;
end;

function TSync.reciev(body: TStringList): boolean;
var i,id: integer;
    msgID, msg: TStringList;
    flag: string;
begin
    msgID := TStringList.Create;
    msg := TstringList.Create;
    body := TstringList.Create;
    try
        if not mimap.Login then abort;
        if not mimap.SelectFolder('INBOX') then abort;
        mimap.SearchMess('UNSEEN SUBJECT SYNC', msgID);

        for i := 0 to msgID.Count - 1 do
        begin
            id := strToInt(msgID.Strings[i]);
            flag := '';
            mimap.GetFlagsMess(id, flag);

            if (pos('RECENT', flag) > 0) then
            begin
                 msg.clear;
                 mimap.FetchMess(id, msg);
                 body.Add(getBody(msg));
                 mimap.DeleteMess(id);
            end;
        end;
        mimap.CloseFolder;
        mimap.Logout;
    finally
        msgID.Free;
        msg.Free;
        body.Free;
    end;
    result := true;
end;

function TSync.send(const key, value: string): boolean;
var Msg : TMimeMess;
    MIMEPart : TMimePart;
    list: TStringList;
begin
    list := TStringList.Create;
    Msg := TMimeMess.Create;
    try
        list.Add('<OGE_SYNC>');
        list.Add(key); list.Add(value); list.Add(key);
        list.Add('</OGE_SYNC>');

        Msg.Header.Subject := 'SYNC';
        Msg.Header.From := msyncParams.mGate;
        Msg.Header.ToList.Add(msyncParams.mGate);
        MIMEPart := Msg.AddPartMultipart('alternative', nil);
        Msg.AddPartText(list, MIMEPart);
        Msg.EncodeMessage;

        if not msmtp.Login then abort;
        if not msmtp.MailFrom(msyncParams.mGate, Length(Msg.Lines.Text)) then abort;
        if not msmtp.MailTo(msyncParams.mGate) then abort;
        if not msmtp.MailData(Msg.Lines) then abort;
    finally
      msmtp.Logout;
      list.Free;
      msg.Free;
    end;
    result := true;
end;

procedure TSync.setsyncParams(const Value: TSyncParams);
begin
     msyncParams := Value;
     msmtp.TargetHost := msyncParams.SMTPHost;
     msmtp.TargetPort := msyncParams.SMTPPort;
     msmtp.Username := msyncParams.UserName;
     msmtp.Password := msyncParams.Password;

     mimap.TargetHost := msyncParams.IMAPHost;
     mimap.TargetPort := msyncParams.IMAPPort;
     mimap.UserName :=  msyncParams.UserName;
     mimap.Password := msyncParams.Password;
end;

{ TSyncParams }

constructor TSyncParams.Create;
var sql: TSTringList;
    table: TSQLiteUniTable;
    key: string;
begin
     sql := TStringList.Create;
     sql.Add('SELECT KEY_FIELD, VALUE_FIELD FROM PARAMS WHERE KEY_FIELD LIKE "%SYNC_%"');
     table := TSQLiteUniTable.Create(dm.sqlite, ansistring(sql.Text));

     while not table.EOF do
     begin
         key := table.FieldAsString(0);
         if key = 'SYNC_GATE' then mGate := table.FieldAsString(1);
         if key = 'SYNC_USERNAME' then mUserName := table.FieldAsString(1);
         if key = 'SYNC_PASSWORD' then mPassword := table.FieldAsString(1);
         if key = 'SYNC_SMTP' then mSMTP := table.FieldAsString(1);
         if key = 'SYNC_SMTP_PORT' then mSMTPPort := table.FieldAsString(1);
         if key = 'SYNC_IMAP' then mIMAP := table.FieldAsString(1);
         if key = 'SYNC_IMAP_PORT' then mIMAPPort := table.FieldAsString(1);

         table.Next;
     end;
     sql.Free;
     table.Free;

     if mGate = '' then mGate := 'OGESYNC@yandex.ru';
     if mUserName = '' then mUserName := 'OGESYNC';
     if mPassword = '' then mPassword := 'SYNCOGE';
     if mSMTP = '' then mSMTP := 'smtp.yandex.ru';
     if mSMTPPort = '' then mSMTPPort := '465';
     if mIMAP = '' then mIMAP := 'imap.yandex.ru';
     if mIMAPPort = '' then mIMAPPort := '993';
end;

procedure TSyncParams.setGate(const Value: string);
begin
    mGate := Value;
    dm.SaveParam('SYNC_GATE', mGate);
end;

procedure TSyncParams.setIMAP(const Value: string);
begin
     mIMAP := Value;
     dm.SaveParam('SYNC_IMAP', mIMAP);
end;

procedure TSyncParams.setIMAPPort(const Value: string);
begin
    mIMAPPort := Value;
    dm.SaveParam('SYNC_IMAP_PORT', mIMAPPort);
end;

procedure TSyncParams.setPassword(const Value: string);
begin
     mPassword := Value;
     dm.SaveParam('SYNC_PASSWORD', mPassword);
end;

procedure TSyncParams.setSMTP(const Value: string);
begin
    mSMTP := Value;
    dm.SaveParam('SYNC_SMTP', mSMTP);
end;

procedure TSyncParams.setSMTPPort(const Value: string);
begin
    mSMTPPort := Value;
    dm.SaveParam('SYNC_SMTP_PORT', mSMTPPort);
end;

procedure TSyncParams.setUserName(const Value: string);
begin
     mUsername := Value;
     dm.SaveParam('SYNC_USERNAME', mUsername);
end;

end.
