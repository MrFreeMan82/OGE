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

  TUserList = array of TUser;

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
  private
     mode: TUserModifyMode;
     usr: TUser;

     procedure updateFields(user: PUser);
    { Private declarations }
  public
    { Public declarations }
    class function addUser(): TModalResult;
    class function editUser(user: PUser): TModalResult;
    class procedure deleteUser(id: integer);
  end;

function getUserByID(id: integer; userList: TUserList): PUser;
function ut_idToString(ut_id: integer): string;

implementation

uses uOGE, uData;

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

function getUserByID(id: integer; userList: TUserList): PUser;
var i : integer;
begin
      result := nil;
      for i := 0 to length(userList) - 1 do
            if userList[i].id = id then exit(@userList[i]);
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

class procedure TfrmUser.deleteUser(id: integer);
begin
    dm.deleteUser(id);
end;

procedure TfrmUser.btSaveClick(Sender: TObject);
begin
    usr.ut_id := cboUSType.ItemIndex + 1;
    usr.fio := txtFIO.Text;
    usr.password := txtPassword.Text;

    case mode of
      mNone: ;
      mInsert: dm.addUser(@usr);
      mEdit: dm.editUser(@usr);
    end;
end;

procedure TfrmUser.UserChange(Sender: TObject);
begin
    if not btSave.Enabled then btSave.Enabled := true;
end;

end.



