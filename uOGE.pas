unit uOGE;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, OleCtrls, SHDocVw, ComCtrls, StdCtrls, ExtCtrls, ExtDlgs, Grids,
  ToolWin, Buttons, PlatformDefaultStyleActnCtrls, ActnList, ActnMan,
  AppEvnts, uTheme, uUTT, uTasks, uWorkPlan, XPMan, ImgList,
  ShellAnimations, uUser, NiceGrid, uSavePoint, uSync, uTaskResults;

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
    tabResults: TTabSheet;
    grdUsers: TNiceGrid;
    GroupBox2: TGroupBox;
    txtSMTPPort: TEdit;
    Label5: TLabel;
    Label4: TLabel;
    txtSMTP: TEdit;
    txtPassword: TEdit;
    Label3: TLabel;
    Label2: TLabel;
    txtUser: TEdit;
    txtGate: TEdit;
    Label1: TLabel;
    btsaveSync: TButton;
    txtIMAP: TEdit;
    Label6: TLabel;
    Label7: TLabel;
    txtIMAPPort: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure WebBrowser1DocumentComplete(ASender: TObject;
      const pDisp: IDispatch; var URL: OleVariant);
    procedure pgPagesChange(Sender: TObject);
    procedure btAddUserClick(Sender: TObject);
    procedure btEditUserClick(Sender: TObject);
    procedure btDeleteUserClick(Sender: TObject);
    procedure grdUsersColRowChanged(Sender: TObject; Col, Row: Integer);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure btsaveSyncClick(Sender: TObject);
  private
    { Private declarations }
    frmTopics: TfrmTopics;
    frmUTT: TfrmUTT;
    frmTasks: TfrmTasks;
    frmWorkPlan: TfrmWorkPlan;
    frmCollectiveTask: TfrmTasks;
    frmTaskResults: TfrmTaskResults;

    syncParams: TSyncParams;
    syncro: TSync;
    saveOGE: TSavePoint;
    CurrentUser: TUser;
    usr: PUser;
    usrList: TUserList;
    path: string;

    function Login(): TModalResult;
    procedure fillUserGrid();
    procedure refreshUserList();

    procedure suspendActions();
    procedure loadSyncParams();
    procedure setAccessWindow();
  public
    { Public declarations }
    property UserList: TUserList read usrList;
    property CollectiveTasks: TfrmTasks read frmCollectiveTask;
    property Tasks: TfrmTasks read frmTasks;
    property Topics: TfrmTopics read frmTopics;
    property WorkPlan: TfrmWorkPlan read frmWorkPlan;
    property UTT:TfrmUTT read frmUTT;
    property User: TUser read currentUser;
    property Sync: TSync read syncro;
    procedure syncronize();
    procedure UpdateCaption(const suffix: string);
  end;

var
  frmOGE: TfrmOGE;

implementation
uses uGlobals, uData, uStress, uWait;

{$R *.dfm}



{$DEFINE TEST}

//ToDo: Перенести результаты в отдельную форму.
//ToDo: Сделать подробный вариант результатов по индивид. и коллект тестам

procedure TfrmOGE.UpdateCaption(const suffix: string);
begin
    Caption := format('ОГЭ - %s [%s]', [currentUser.fio, suffix]);
end;

function TfrmOGE.Login():TModalResult;
var s: string;
    i: integer;
begin
     s := '';
     repeat
          if InputQuery('OГЭ', 'Введите паоль:', s)
                then result := mrOK else result := mrCancel;

          for i := 0 to usrList.Count - 1 do
          begin
              if (s = Puser(usrList[i]).password) then
              begin
                   currentUser := PUser(usrList[i])^;
                   exit;
              end;
          end;

          if result = mrOK then
              messageBox(handle, 'Пароль не верен',
                          'ОГЭ', MB_OK or MB_ICONWARNING);

     until result = mrCancel;
end;

procedure TfrmOGE.btsaveSyncClick(Sender: TObject);
begin
    syncParams.Gate := txtGate.Text;
    syncParams.UserName := txtUser.Text;
    syncParams.Password := txtPassword.Text;
    syncParams.SMTPHost := txtSMTP.Text;
    syncParams.SMTPPort := txtSMTPPort.Text;
    syncParams.IMAPHost := txtIMAP.Text;
    syncParams.IMAPPort := txtIMAPPort.Text;
    messageBox(handle, 'Настройки успешно сохранены.', 'ОГЭ', MB_OK or MB_ICONINFORMATION);
end;

procedure TfrmOGE.loadSyncParams;
begin
     txtGate.Text := syncParams.Gate;
     txtUser.Text := syncParams.UserName;
     txtPassword.Text := syncParams.Password;
     txtSMTP.Text := syncParams.SMTPHost;
     txtSMTPPort.Text :=  syncParams.SMTPPort;
     txtIMAP.Text := syncParams.IMAPHost;
     txtIMAPPort.Text := syncParams.IMAPPort;
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
            'Удалить пользователя?','ОГЭ',
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

procedure TfrmOGE.syncronize;
var body: TStringList;
    dataList: TStringList;
begin
     frmWait.Show;
     Application.ProcessMessages;

     body := TStringList.Create;
     dataList := TStringList.Create;
     try try
             syncro.reciev(body);
             extract(body, 'MASK', dataList);
             join(dataList);
             TSavePoint.fromCSV(';', dataList);
        finally
            frmWait.Hide;
            Application.ProcessMessages;
            freeAndNil(body);
            freeAndNil(dataList);
        end;
     except
          messageBox(handle, 'Во время отправления произошла ошибка. '#13 +
                'Попробуйте снова через несколько минут.', 'ОГЭ', MB_OK or MB_ICONERROR);
     end;
end;

procedure TfrmOGE.fillUserGrid;
var i: integer;
    item: PUser;
begin
     grdUsers.RowCount := UsrList.Count;
     grdUsers.ColCount := USR_FIELD_COUNT;

     grdUsers.ColWidths[1] := 300;
     grdUsers.ColWidths[2] := 500;

     for i := 0 to UsrList.Count - 1 do
     begin
          item := UsrList.Items[i];
          grdUsers.Cells[0, i] := intToStr(item.id);
          grdUsers.Cells[1, i] := ut_idToString(item.ut_id);
          grdUsers.Cells[2, i] := item.fio;
          grdUsers.Cells[3, i] := item.password;
     end;
end;

procedure TfrmOGE.refreshUserList;
begin
     usrList.Free;
     usrList := TUserList.Create;
     fillUserGrid();
end;

procedure TfrmOGE.FormCreate(Sender: TObject);
begin
    {$IFDEF TEST}
    showMessage('Тестовый образец');
  //  addUsersMasksAllSections();
 //   halt(0);
    {$ENDIF}

    usrList := TUserList.Create;

    if Login() = mrCancel then
    begin
        halt(0);
    end;
    Path := exePath();

    if not Assigned(frmTopics) then frmTopics := TfrmTopics.Create(self);
    frmTopics.Dock(tabThemes, tabThemes.ClientRect);

    if not assigned(frmUTT) then frmUTT := TfrmUTT.Create(self);
    frmUTT.Dock(tabUTT, tabUTT.ClientRect);

    if not assigned(frmTasks) then frmTasks := TfrmTasks.Create(self);
    frmTasks.Dock(tabTasks, tabTasks.ClientRect);

    if not assigned(frmWorkPlan) then frmWorkPlan := TfrmWorkPlan.Create(self);
    frmWorkPlan.Dock(tabPlan, tabPlan.ClientRect);

    if not assigned(frmCollectiveTask) then frmCollectiveTask := TfrmTasks.Create(self);
    frmCollectiveTask.Dock(tabCollectiveTask, tabCollectiveTask.ClientRect);

    if not assigned(frmTaskResults) then frmTaskResults := TfrmTaskResults.Create(self);
    frmTaskResults.Dock(tabResults, tabResults.ClientRect);

    saveOGE := TSavePoint.Create(user.id, self.ClassName);
    syncParams := TSyncParams.Create;
    syncro := TSync.Create;
end;

procedure TfrmOGE.FormShow(Sender: TObject);
var p: integer;
begin
    syncro.SyncParams := syncParams;
    loadSyncParams();
    WebBrowser1.Navigate('res://' + Application.ExeName + '/HTML/FIRST_PAGE');
    WebBrowser1.OleObject.Document.bgColor := '#E0FFFF';

    setAccessWindow();

    frmTopics.showTopics();
    frmUTT.ShowUTT();
    frmTasks.ShowTasks(tabTasks);
    frmWorkPlan.ShowWorkPlan();
    frmCollectiveTask.ShowTasks(tabCollectiveTask);
    frmTaskResults.ShowTaskResults();
    fillUserGrid();

    pgPages.ActivePage := tabInfo;    // Нужно иначе ошибка Access Violation ??

    saveOGE.Load;
    p := saveOGE.asInteger('TAB_INDEX');
    if p >= 0 then pgPages.ActivePageIndex := p;

    pgPagesChange(Sender)
end;

procedure TfrmOGE.setAccessWindow;
begin
    if currentUser.ut_id = 1 then
    begin
        tabAdmin.TabVisible := true;
        tabResults.TabVisible := true;
    end
    else begin
        tabAdmin.TabVisible := false;
        tabResults.TabVisible := false;
    end;
end;

procedure TfrmOGE.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    saveOGE.addIntValue('TAB_INDEX', pgPages.ActivePageIndex);
    saveOGE.Save;
end;

procedure TfrmOGE.FormDestroy(Sender: TObject);
begin
    freeAndNil(frmTopics);
    freeAndNil(frmUTT);
    freeAndNil(frmTasks);
    freeAndNil(frmWorkPlan);
    freeAndNil(frmCollectiveTask);
    freeAndNil(saveOGE);
    freeAndNil(syncro);
end;

procedure TfrmOGE.grdUsersColRowChanged(Sender: TObject; Col, Row: Integer);
begin
      if (row >= 0) and (grdUsers.Cells[0, row] <> '') then
        usr := usrList.getUserByID(strToInt(grdUsers.Cells[0, Row]))
end;

procedure TfrmOGE.suspendActions;
begin
    frmTasks.ActionList.State := asSuspendedEnabled;
    frmCollectiveTask.ActionList.State := asSuspendedEnabled;
    frmTopics.ActionList.State := asSuspendedEnabled;
    frmUTT.ActionList.State := asSuspendedEnabled;
end;

procedure TfrmOGE.pgPagesChange(Sender: TObject);
begin
    suspendActions();
    if pgPages.ActivePage = tabPlan
        then begin
             frmWorkPlan.refreshWorkPlan;
             UpdateCaption(pgPages.ActivePage.Caption);
        end

    else if pgPages.ActivePage = tabTasks
        then begin
             frmTasks.ActionList.State := asNormal;
             UpdateCaption(frmTasks.SectionLabel);
        end

    else if pgPages.ActivePage = tabCollectiveTask
        then begin
            frmCollectiveTask.ActionList.State := asNormal;
            UpdateCaption(frmCollectiveTask.SectionLabel);
        end
    else if pgPages.ActivePage = tabUTT then
      begin
          frmUTT.ActionList.State := asNormal;
          UpdateCaption(pgPages.ActivePage.Caption);
      end
    else if pgPages.ActivePage = tabThemes then
         begin
            frmTopics.ActionList.State := asNormal;
            UpdateCaption(pgPages.ActivePage.Caption);
         end
    else
    UpdateCaption(pgPages.ActivePage.Caption);
end;

procedure TfrmOGE.FormResize(Sender: TObject);
begin
    pgPagesChange(Sender);
end;

procedure TfrmOGE.WebBrowser1DocumentComplete(ASender: TObject;
  const pDisp: IDispatch; var URL: OleVariant);
begin
    while WebBrowser1.ReadyState <> 4 do Application.ProcessMessages;
    WebBrowser1.OleObject.Document.bgColor := '#E0FFFF';
end;

end.
