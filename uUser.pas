unit uUser;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  PUser = ^TUser;
  TUser = record
      id: integer;
      ut_id: integer;
      fio: string;
      password: string;
  end;

  TUserList = class(TList)
    private
          sql:TStringList;
    public
      constructor Create;
      procedure Free;
      function getUserByID(id: integer): PUser;
  end;

  TUserModifyMode = (mNone, mInsert, mEdit, mDelete);

  TfrmUser = class(TForm)
    Label1: TLabel;
    txtFIO: TEdit;
    Label2: TLabel;
    cboUsType: TComboBox;
    btSave: TButton;
    Button2: TButton;
    Label3: TLabel;
    txtPassword: TEdit;
    procedure btSaveClick(Sender: TObject);
    procedure UserChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
     mode: TUserModifyMode;
     usr: TUser;
     sql: TStringList;

     procedure updateFields(user: PUser);
     procedure insertUser();
     procedure updateUser();
    { Private declarations }
  public
    { Public declarations }
    class function addUser(): TModalResult;
    class function editUser(user: PUser): TModalResult;
    class procedure deleteUser(id: integer);
  end;

function ut_idToString(ut_id: integer): string;

implementation

uses uOGE, uData, SQLite3, SQLiteTable3;

function ut_idToString(ut_id: integer): string;
begin
      case ut_id of
          1: result := 'Администратор';
          2: result := 'Пользователь';
          else result := 'N/A';
      end;
end;

{$R *.dfm}

{ TfrmUser }

class function TfrmUser.addUser(): TModalResult;
var frmUser: TfrmUser;
begin
      frmUser := TfrmUser.Create(frmOGE);
      try
          frmUser.Caption := 'Новый пользователь';
          frmUser.mode := mInsert;
          result := frmUser.ShowModal;
      finally
            freeAndNil(frmUser);
      end;
end;

class function TfrmUser.editUser(user: PUser): TModalResult;
var frmUser: TfrmUser;
begin
     frmUser := TfrmUser.Create(frmOGE);
     try
        frmUser.Caption := 'Редактировать пользователя';
        frmUser.mode := mEdit;
        frmUser.updateFields(user);
        result := frmUser.ShowModal;
     finally
         freeAndNil(frmUser);
     end;
end;

procedure TfrmUser.FormCreate(Sender: TObject);
begin
    sql := TStringList.Create;
end;

procedure TfrmUser.FormDestroy(Sender: TObject);
begin
    freeAndNil(sql)
end;

procedure TfrmUser.updateFields(user: Puser);
begin
     txtFIO.OnChange := nil;
     txtFIO.Text := user.fio;
     txtFIO.OnChange := UserChange;

     cboUsType.OnChange := nil;
     cboUsType.ItemIndex := user.ut_id - 1;
     cboUsType.OnChange := UserChange;

     txtPassword.OnChange := nil;
     txtPassword.Text := user.password;
     txtPassword.OnChange := UserChange;

     usr := user^;
end;

procedure TfrmUser.insertUser;
begin
     sql.Clear;
     sql.Add('INSERT INTO USER(UT_ID, FIO, PASSWORD)');
     sql.Add(format('VALUES(%d, "%s", "%s")', [usr.ut_id, usr.fio, usr.password]));
     dm.sqlite.ExecSQL(ansiString(sql.Text));
end;

procedure TfrmUser.updateUser;
begin
     sql.Clear;
     sql.Add('UPDATE USER ');
     sql.Add(format(
        'SET UT_ID = %d, FIO = "%s", PASSWORD = "%s" WHERE ID = %d',
                [usr.ut_id, usr.fio, usr.password, usr.id])
     );

     dm.sqlite.ExecSQL(ansiString(sql.Text));
end;

class procedure TfrmUser.deleteUser(id: integer);
var sql: TStringList;
begin
     sql := TStringList.Create;
     sql.Add('DELETE FROM USER WHERE ID = ' + intToStr(id));
     dm.sqlite.ExecSQL(ansiString(sql.Text));

     sql.Clear;
     sql.Add('DELETE FROM SAVEPOINT WHERE US_ID = ' + intToStr(id));
     dm.sqlite.ExecSQL(ansistring(sql.Text));
     sql.Free;
end;

procedure TfrmUser.btSaveClick(Sender: TObject);
begin
    usr.ut_id := cboUSType.ItemIndex + 1;
    usr.fio := txtFIO.Text;
    usr.password := txtPassword.Text;

    case mode of
      mNone: ;
      mInsert: insertUser;
      mEdit: updateUser;
    end;
end;

procedure TfrmUser.UserChange(Sender: TObject);
begin
    if not btSave.Enabled then btSave.Enabled := true;
end;

{ TUserList }

constructor TUserList.Create;
var i: integer;
    table: TSQLiteUniTable;
    item : PUser;
begin
     inherited Create;
     sql := TStringList.Create;
     sql.Clear;
     sql.Add('SELECT COUNT(*) FROM USER');

     try
         table := dm.sqlite.GetUniTable(ansiString(sql.Text));
         Capacity := table.FieldAsInteger(0);
         freeAndNil(table);

         sql.Clear;
         sql.Add('SELECT ID, UT_ID, FIO, PASSWORD FROM USER');
         table := dm.sqlite.GetUniTable(ansistring(sql.Text));

         for i := 0 to Capacity - 1 do
         begin
              New(item);
              item.id := table.FieldAsInteger(0);
              item.ut_id := table.FieldAsInteger(1);
              item.fio := table.FieldAsString(2);
              item.password := table.FieldAsString(3);
              Add(item);
              table.Next;
         end;
     finally
          freeAndNil(table);
     end;
end;

procedure TUserList.Free;
var i: integer;
begin
   for i := 0 to Count - 1 do dispose(List[i]);
   sql.Free;
   inherited Free;
end;

function TUserList.getUserByID(id: integer): PUser;
var i : integer;
begin
      result := nil;
      for i := 0 to Count - 1 do
            if PUser(Items[i]).id = id then exit(Items[i]);
end;

end.



