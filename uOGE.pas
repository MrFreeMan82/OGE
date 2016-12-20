unit uOGE;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, OleCtrls, SHDocVw, ComCtrls, StdCtrls, ExtCtrls, ExtDlgs, Grids,
  ToolWin, Buttons, PlatformDefaultStyleActnCtrls, ActnList, ActnMan,
  AppEvnts, uTheme, uUTT, uTasks, uWorkPlan, XPMan, uCollectiveTask, ImgList,
  ShellAnimations, uUser;

type
  TfrmOGE = class(TForm)
    pgPages: TPageControl;
    tabInfo: TTabSheet;
    tabThemes: TTabSheet;
    tabTests: TTabSheet;
    WebBrowser1: TWebBrowser;
    tabUTT: TTabSheet;
    tabTasks: TTabSheet;
    tabCollectiveTask: TTabSheet;
    tabPlan: TTabSheet;
    XPManifest1: TXPManifest;
    tabAdmin: TTabSheet;
    GroupBox1: TGroupBox;
    ToolBar1: TToolBar;
    btAddUser: TToolButton;
    btEditUser: TToolButton;
    btDeleteUser: TToolButton;
    ImageList1: TImageList;
    ShellResources1: TShellResources;
    grdUsers: TStringGrid;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure WebBrowser1DocumentComplete(ASender: TObject;
      const pDisp: IDispatch; var URL: OleVariant);
    procedure pgPagesChange(Sender: TObject);
    procedure btAddUserClick(Sender: TObject);
    procedure btEditUserClick(Sender: TObject);
    procedure btDeleteUserClick(Sender: TObject);
    procedure grdUsersSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
  private
    { Private declarations }
    frmTopics: TfrmTopics;
    frmUTT: TfrmUTT;
    frmTasks: TfrmTasks;
    frmWorkPlan: TfrmWorkPlan;
    frmCollectiveTask: TfrmCollectiveTask;

    currentUser: PUser;
    usr: PUser;
    usrList: TUserList;
    path: string;
    function Login(): TModalResult;
    procedure fillGrid();
    procedure refreshUserList();
  public
    { Public declarations }
    property TaskTests: TfrmTasks read frmTasks;
    property Topics: TfrmTopics read frmTopics;
    property UTT:TfrmUTT read frmUTT;
  end;

var
  frmOGE: TfrmOGE;

implementation
uses uGlobals, uData;

{$R *.dfm}



{$DEFINE TEST}

function TfrmOGE.Login():TModalResult;
var s: string;
    i: integer;
begin
     s := '1';
     repeat
          if InputQuery('OГЭ', 'Введите паоль:', s)
                then result := mrOK else result := mrCancel;

          for i := 0 to length(usrList) - 1 do
          begin
              if (s = usrList[i].password) then
              begin
                   currentUser := @usrList[i];
                   exit;
              end;
          end;

          if result = mrOK then
              messageBox(handle, 'Пароль не верен',
                          'ОГЭ', MB_OK or MB_ICONWARNING);

     until result = mrCancel;
end;

procedure TfrmOGE.btAddUserClick(Sender: TObject);
begin
    TfrmUser.addUser();
    refreshUserList();
end;

procedure TfrmOGE.btDeleteUserClick(Sender: TObject);
begin
    if assigned(usr) then
    begin
        if messageBox(handle,
            'Удалить пользователя?','ОГЕ',
                MB_YESNO or MB_ICONQUESTION) = mrYes then
        begin
             TfrmUser.deleteUser(usr.id);
             refreshUserList();
        end;
    end;
end;

procedure TfrmOGE.btEditUserClick(Sender: TObject);
begin
   if assigned(usr) then
   begin
       TfrmUser.editUser(usr);
       refreshUserList();
   end;
end;

procedure TfrmOGE.fillGrid;
var i, j: integer;
begin
     grdUsers.RowCount := length(UsrList) + 1;
     grdUsers.ColCount := USR_FIELD_COUNT;
    // grdUsers.FixedRows := 1;
     grdUsers.FixedCols := 0;

     grdUsers.Cells[0, 0] := 'ИД';
     grdUsers.Cells[1, 0] := 'Тип';
     grdUsers.Cells[2, 0] := 'ФИО';
     grdUsers.Cells[3, 0] := 'Пароль';

     grdUsers.ColWidths[1] := 300;
     grdUsers.ColWidths[2] := 500;

     for i := 0 to length(UsrList) - 1 do
     begin
          j := i + 1;
          grdUsers.Cells[0, j] := intToStr(UsrList[i].id);
          grdUsers.Cells[1, j] := ut_idToString(usrList[i].ut_id);
          grdUsers.Cells[2, j] := usrList[i].fio;
          grdUsers.Cells[3, j] := usrList[i].password;
     end;
end;

procedure TfrmOGE.refreshUserList;
begin
     usrList := dm.loadUserList();
     fillGrid();
end;

procedure TfrmOGE.FormCreate(Sender: TObject);
begin
    {$IFDEF TEST}
    showMessage('Тестовый образец');
    {$ENDIF}

    usrList := dm.loadUserList();

    if Login() = mrCancel then
    begin
        Application.Terminate;
        exit;
    end;

    if currentUser.ut_id = 1 then tabAdmin.TabVisible := true;

    Path := exePath();
    WebBrowser1.Navigate('res://' + Application.ExeName + '/HTML/FIRST_PAGE');
    WebBrowser1.OleObject.Document.bgColor := '#E0FFFF';
    pgPages.ActivePage := tabInfo;

    if not Assigned(frmTopics) then frmTopics := TfrmTopics.Create(self);
    frmTopics.Dock(tabThemes, tabThemes.ClientRect);
    frmTopics.showTopics();

    if not assigned(frmUTT) then frmUTT := TfrmUTT.Create(self);
    frmUTT.Dock(tabUTT, tabUTT.ClientRect);
    frmUTT.ShowUTT();

    if not assigned(frmTasks) then frmTasks := TfrmTasks.Create(self);
    frmTasks.Dock(tabTasks, tabTasks.ClientRect);
    frmTasks.ShowTasks();

    if not assigned(frmWorkPlan) then frmWorkPlan := TfrmWorkPlan.Create(self);
    frmWorkPlan.Dock(tabPlan, tabPlan.ClientRect);
    frmWorkPlan.ShowWorkPlan();

    if not assigned(frmCollectiveTask) then frmCollectiveTask := TfrmCollectiveTask.Create(self);
    frmCollectiveTask.Dock(tabCollectiveTask, tabCollectiveTask.ClientRect);
    frmCollectiveTask.showCollectiveTask();

    fillGrid();
end;

procedure TfrmOGE.FormDestroy(Sender: TObject);
begin
   // freeAndNil(frmTests);
    freeAndNil(frmTopics);
    freeAndNil(frmUTT);
    freeAndNil(frmTasks);
    freeAndNil(frmWorkPlan);
    freeAndNil(frmCollectiveTask)
end;

procedure TfrmOGE.grdUsersSelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
begin
      if (grdUsers.Cells[0, Arow] <> '') then
        usr := getUserByID(strToInt(grdUsers.Cells[0, ARow]), usrList)
end;

procedure TfrmOGE.pgPagesChange(Sender: TObject);
begin
    if pgPages.ActivePage = tabPlan then frmWorkPlan.refreshWorkPlan;
end;

procedure TfrmOGE.WebBrowser1DocumentComplete(ASender: TObject;
  const pDisp: IDispatch; var URL: OleVariant);
begin
    while WebBrowser1.ReadyState <> 4 do Application.ProcessMessages;
    WebBrowser1.OleObject.Document.bgColor := '#E0FFFF';
end;

end.
