unit uOGE;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, OleCtrls, SHDocVw, ComCtrls, StdCtrls, ExtCtrls, ExtDlgs, Grids,
  ToolWin, Buttons, PlatformDefaultStyleActnCtrls, ActnList, ActnMan,
  AppEvnts, uTheme, uUTT, uTasks, uWorkPlan, XPMan, ImgList,
  ShellAnimations, uUser, NiceGrid, uSavePoint;

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
    grdUserresult: TNiceGrid;
    grdUsers: TNiceGrid;
    grdVariants: TNiceGrid;
    ToolBar2: TToolBar;
    ToolButton1: TToolButton;
    btRefresh: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure WebBrowser1DocumentComplete(ASender: TObject;
      const pDisp: IDispatch; var URL: OleVariant);
    procedure pgPagesChange(Sender: TObject);
    procedure btAddUserClick(Sender: TObject);
    procedure btEditUserClick(Sender: TObject);
    procedure btDeleteUserClick(Sender: TObject);
    procedure grdUsersColRowChanged(Sender: TObject; Col, Row: Integer);
    procedure grdUserresultColRowChanged(Sender: TObject; Col, Row: Integer);
    procedure btRefreshClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    { Private declarations }
    frmTopics: TfrmTopics;
    frmUTT: TfrmUTT;
    frmTasks: TfrmTasks;
    frmWorkPlan: TfrmWorkPlan;
    frmCollectiveTask: TfrmTasks;

    saveOGE: TSavePoint;
    CurrentUser: TUser;
    usr: PUser;
    usrList: TUserList;
    path: string;

    ptsPerVariant: TPointsPerVariant;

    function Login(): TModalResult;
    procedure fillGrid();
    procedure refreshUserList();

    procedure totalResultUTTVariants(us_id: integer; mdl: PUTTModule);
    procedure totalResultUTT(us_id, i: integer);
    procedure totalResultIndividual(us_id, i: integer);
    procedure totalresultFillUsesrs();
    procedure totalResults();
    procedure suspendActions();
  public
    { Public declarations }
    property CollectiveTasks: TfrmTasks read frmCollectiveTask;
    property Tasks: TfrmTasks read frmTasks;
    property Topics: TfrmTopics read frmTopics;
    property UTT:TfrmUTT read frmUTT;
    property User: TUser read currentUser;
    procedure UpdateCaption(const suffix: string);
  end;

var
  frmOGE: TfrmOGE;

implementation
uses uGlobals, uData;

{$R *.dfm}



{$DEFINE TEST}

procedure TfrmOGE.UpdateCaption(const suffix: string);
begin
    Caption := format('ОГЕ - %s [%s]', [currentUser.fio, suffix]);
end;

procedure TfrmOGE.totalResults;
begin
    totalresultFillUsesrs();
end;

procedure TfrmOGE.totalResultUTT(us_id, i: integer);
var j, k, pts: integer;
begin
     k := 3;

     for j := 0 to length(frmUTT.UTTTModuleList) - 1 do
     begin
           if not frmUTT.UTTTModuleList[j].visible then continue;

           pts := frmUTT.pointByUserAndModule(us_id, @frmUTT.UTTTModuleList[j]);

           grdUserresult.Cells[k, i] := intToStr(pts);
           grdUserresult.Objects[k, i] := TObject(frmUTT.UTTTModuleList[j].id);

           inc(k)
     end;
end;

procedure TfrmOGE.totalResultUTTVariants(us_id: integer; mdl: PUTTModule);
var i: integer;
begin
     ptsPerVariant := frmUTT.pointsByUserAllVariant(us_id, mdl);

     if ptsPerVariant = nil then exit;

     for i := 0 to grdVariants.ColCount - 1 do
          grdVariants.Cells[i, 0] := intToStr(ptsPerVariant[i]);
end;

procedure TfrmOGE.totalResultIndividual(us_id, i: integer);
begin
     if frmWorkPlan.Stage1Result(us_id)
        then grdUserresult.Cells[1, i] := ZACHET
           else grdUserresult.Cells[1, i] := NOT_ZACHET;

     if frmWorkPlan.Stage2Result(Us_id)
       then grdUserResult.Cells[2, i] := ZACHET
            else grdUserResult.Cells[2, i] := NOT_ZACHET;
end;

procedure TfrmOGE.totalresultFillUsesrs;
var i,j: integer;
    item: PUser;
begin
     j := 0;
     grdUserresult.RowCount := 0;
     for i := 0 to usrList.Count - 1 do
     begin
          item := usrList.Items[i];
          if (item.ut_id = 1) then continue;
          grdUserresult.RowCount := grdUserresult.RowCount + 1;
          grdUserresult.Cells[0, j] := item.fio;
          grdUserresult.Objects[0, j] := TObject(item.id);
          totalResultIndividual(item.id, j);
          totalResultUTT(item.id, j);
          inc(j)
     end;
end;

function TfrmOGE.Login():TModalResult;
var s: string;
    i: integer;
begin
     s := '1';
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

procedure TfrmOGE.btRefreshClick(Sender: TObject);
begin
    totalResults()
end;

procedure TfrmOGE.fillGrid;
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
     fillGrid();
end;

procedure TfrmOGE.FormCreate(Sender: TObject);
begin
    {$IFDEF TEST}
    showMessage('Тестовый образец');
    {$ENDIF}

    usrList := TUserList.Create;

    if Login() = mrCancel then
    begin
        halt(0);
    end;
    Path := exePath();

    WebBrowser1.Navigate('res://' + Application.ExeName + '/HTML/FIRST_PAGE');
    WebBrowser1.OleObject.Document.bgColor := '#E0FFFF';

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

    saveOGE := TSavePoint.Create(user.id, self.ClassName);
end;

procedure TfrmOGE.FormShow(Sender: TObject);
var p: integer;
begin
    frmTopics.showTopics();
    frmUTT.ShowUTT();
    frmTasks.ShowTasks(tabTasks);
    frmWorkPlan.ShowWorkPlan();
    frmCollectiveTask.ShowTasks(tabCollectiveTask);
    fillGrid();
    totalResults();

    if currentUser.ut_id = 1
      then tabAdmin.TabVisible := true
          else tabAdmin.TabVisible := false;

    pgPages.ActivePage := tabInfo;    // Нужно иначе ошибка Access Violation ??

    saveOGE.Load;
    p := saveOGE.asInteger('TAB_INDEX');
    if p >= 0 then pgPages.ActivePageIndex := p;

    pgPagesChange(Sender)
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
end;

procedure TfrmOGE.grdUserresultColRowChanged(Sender: TObject; Col,Row: Integer);
var us_id, mdl_id: integer;
begin
    if (row >= 0) and (grdUserresult.Cells[0, row] <> '') and (Col in [3..5]) then
    begin
        us_id := integer(grdUserresult.Objects[0, row]);
        mdl_id := integer(grdUserresult.Objects[Col, row]);
        totalResultUTTVariants(us_id, frmUTT.getModuleByID(mdl_id));
    end;
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
      //       frmTasks.refreshLinkContent;  //   Так как  frmTasks и  frmCollectiveTask используют одну модель
                                          //    то REsultMask у них один, чтоб переключать Resultmask
                                          //    при смене вкладок нужно запускать эту проц.
             frmTasks.ActionList.State := asNormal;
             UpdateCaption(frmTasks.SectionLabel);
        end

    else if pgPages.ActivePage = tabCollectiveTask
        then begin
       //     frmCollectiveTask.refreshLinkContent;
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
