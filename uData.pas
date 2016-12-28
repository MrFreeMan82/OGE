unit uData;

interface

uses
  SysUtils, Classes, xmldom, msxmldom, XMLDoc, Graphics, SQLite3, SQLiteTable3,
  XMLIntf;

type

  Tdm = class(TDataModule)
    xmlDoc: TXMLDocument;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    { Private declarations }

    fDataFile, sqliteFile: string;
    sql: TStringList;

    procedure createTableUser();
    procedure createTableSavePoints();
    procedure createTableParams();
    procedure dropTable(const tableName: string);

    procedure loadUserFromFile(fl: string);
  public
    { Public declarations }
    sqlite : TSQLiteDatabase;

    property DataFile: string read fDataFile;
    procedure SaveParam(const paramName, paramValue: string);
    function LoadParam(const paramName: string): string;
  end;

var
  dm: Tdm;

implementation
uses uOGE, uUser, uGlobals, Windows;

{$R *.dfm}

{ Tdm }

procedure Tdm.createTableParams;
begin
    if sqlite.TableExists('PARAMS') then exit;

    sql.Clear;
    sql.Add('CREATE TABLE PARAMS');
    sql.Add('(ID INTEGER PRIMARY KEY AUTOINCREMENT,');
    sql.Add('KEY_FIELD TEXT,');
    sql.Add('VALUE_FIELD TEXT)');
    sqlite.ExecSQL(ansistring(sql.Text));
end;

procedure Tdm.createTableSavePoints;
begin
    if sqlite.TableExists('SAVEPOINT') then exit;

    sql.Clear;
    sql.Add('CREATE TABLE SAVEPOINT');
    sql.Add('(ID INTEGER PRIMARY KEY AUTOINCREMENT,');
    sql.Add('US_ID INTEGER,');
    sql.Add('WINDOW TEXT,');
    sql.Add('KEY_FIELD TEXT,');
    sql.Add('VALUE_FIELD TEXT)');
    sqlite.ExecSQL(ansistring(sql.Text));

    sql.Clear;
    sql.Add('CREATE INDEX US_ID_INDEX ON [SAVEPOINT] (US_ID)');
    sqlite.ExecSQL(ansistring(sql.Text));
end;

procedure Tdm.createTableUser;
var defaultUser: TUser;
begin
   if sqlite.TableExists('USER') then exit;

   sql.Clear;
   sql.Add('CREATE TABLE USER ');
   sql.Add('(ID INTEGER PRIMARY KEY AUTOINCREMENT,');
   sql.Add('UT_ID INTEGER,');
   sql.Add('FIO TEXT,');
   sql.Add('PASSWORD TEXT)');
   sqlite.ExecSQL(ansiString(sql.Text));

   defaultUser.ut_id := 1;
   defaultUser.fio := 'Administrator';
   defaultUser.password := 'saidov1986';

   sql.Clear;
   sql.Add('INSERT INTO USER(UT_ID, FIO, PASSWORD)');
   sql.Add(format('VALUES(%d, "%s", "%s")',
        [defaultUser.ut_id, defaultUser.fio, defaultUser.password]));
   sqlite.ExecSQL(ansiString(sql.Text));

   if FileExists('usr.sql') then loadUserFromFile('usr.sql');
end;

procedure Tdm.dropTable(const tableName: string);
begin
     sql.Clear;
     sql.Add('DROP TABLE ' + tablename);
     sqlite.ExecSQL(ansiString(sql.Text));
end;

procedure Tdm.DataModuleCreate(Sender: TObject);
begin
    fDataFile := exePath() + 'OGE.dat';
    sqliteFile := exePath() + 'sqlite.dat';
    if not FileExists(fDataFile) then
    begin
        messageBox(0, PWideChar('‘‡ÈÎ ' + fDataFile + ' ÌÂ Ì‡È‰ÂÌ!'), 'Œ√≈', MB_OK or MB_ICONERROR);
        halt(0);
    end;

    sql := TStringList.Create;
    sqlite := TSQLiteDatabase.Create(sqliteFile);
    createTableUser();
    createTableSavePoints();
    createTableParams();
//  dropTable('RESULTS')
end;

procedure Tdm.loadUserFromFile(fl: string);
var l: TStringList;
    i: integer;
begin
     l := TStringList.Create;
     l.LoadFromFile(fl);

     for i := 0 to l.Count - 1 do
     begin
          sql.Clear;
          sql.Add(l.Strings[i]);
          if trim(sql.Text) = '' then continue;
          
          sqlite.ExecSQL(ansistring(sql.Text));
     end;
end;

procedure Tdm.SaveParam(const paramName, paramValue: string);
var table: TSQLiteUniTable;
    cnt: integer;
begin
     sql.Clear;
     sql.Add(format('SELECT COUNT(*) FROM PARAMS WHERE KEY_FIELD = "%s"', [paramName]));

     try
        table := TSQLiteUniTable.Create(dm.sqlite, ansiString(sql.Text));
        cnt := table.FieldAsInteger(0);
     finally
         freeAndNil(table);
     end;

     sql.Clear;
     if cnt = 0 then
     begin
          sql.Add(format(
            'INSERT INTO PARAMS(KEY_FIELD, VALUE_FIELD)' +
              'VALUES("%s", "%s")', [paramName, paramValue]))
     end
     else begin
            sql.Add(format(
              'UPDATE PARAMS ' +
              'SET VALUE_FIELD = "%s" ' +
              'WHERE KEY_FIELD = "%s"', [paramValue, paramName]));
     end;

     sqlite.ExecSQL(ansistring(sql.Text));
end;

function Tdm.LoadParam(const paramName: string): string;
var table: TSQLiteUniTable;
begin
    sql.Clear;
    sql.Add(format('SELECT VALUE_FIELD FROM PARAMS WHERE KEY_FIELD = "%s"', [paramName]));
    try
        table := TSQLiteUniTable.Create(sqlite, ansiString(sql.Text));
        result := table.FieldAsString(0);
    finally
        freeAndNil(table);
    end;
end;

procedure Tdm.DataModuleDestroy(Sender: TObject);
begin
    sql.Free;
    sqlite.Free;
end;

end.
