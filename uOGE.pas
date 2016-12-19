unit uOGE;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, OleCtrls, SHDocVw, ComCtrls, StdCtrls, ExtCtrls, ExtDlgs, Grids,
  ToolWin, Buttons, PlatformDefaultStyleActnCtrls, ActnList, ActnMan,
  AppEvnts, uTheme, uUTT, uTasks, uWorkPlan;

type
  TfrmOGE = class(TForm)
    pgPages: TPageControl;
    tabInfo: TTabSheet;
    tabThemes: TTabSheet;
    tabTests: TTabSheet;
    WebBrowser1: TWebBrowser;
    tabUTT: TTabSheet;
    tabTasks: TTabSheet;
    TabSheet1: TTabSheet;
    tabPlan: TTabSheet;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure WebBrowser1DocumentComplete(ASender: TObject;
      const pDisp: IDispatch; var URL: OleVariant);
    procedure pgPagesChange(Sender: TObject);
  private
    { Private declarations }
    frmTopics: TfrmTopics;
    frmUTT: TfrmUTT;
    frmTasks: TfrmTasks;
    frmWorkPlan: TfrmWorkPlan;
    path: string;
    function Login(): TModalResult;
  public
    { Public declarations }
    property TaskTests: TfrmTasks read frmTasks;
    property Topics: TfrmTopics read frmTopics;
    property UTT:TfrmUTT read frmUTT;
  end;

var
  frmOGE: TfrmOGE;

implementation
uses uGlobals;

{$R *.dfm}

resourcestring password = '1';

{$DEFINE TEST}

function TfrmOGE.Login():TModalResult;
var s: string;
begin
     s := '1';
     repeat
          if InputQuery('OГЭ', 'Введите паоль:', s)
                then result := mrOK else result := mrCancel;

          if (s = password) then break;

          if result = mrOK then
              messageBox(handle, 'Пароль не верен',
                          'ОГЭ', MB_OK or MB_ICONWARNING);

     until result = mrCancel;
end;

procedure TfrmOGE.pgPagesChange(Sender: TObject);
begin
    if pgPages.ActivePage = tabPlan then frmWorkPlan.refreshWorkPlan;

end;

procedure TfrmOGE.FormCreate(Sender: TObject);
begin
    {$IFDEF TEST}
    showMessage('Тестовый образец');
    {$ENDIF}

    if Login() = mrCancel then
    begin
        Application.Terminate;
        exit;
    end;

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
end;

procedure TfrmOGE.FormDestroy(Sender: TObject);
begin
   // freeAndNil(frmTests);
    freeAndNil(frmTopics);
    freeAndNil(frmUTT);
    freeAndNil(frmTasks);
    freeAndNil(frmWorkPlan)
end;

procedure TfrmOGE.WebBrowser1DocumentComplete(ASender: TObject;
  const pDisp: IDispatch; var URL: OleVariant);
begin
    while WebBrowser1.ReadyState <> 4 do Application.ProcessMessages;
    WebBrowser1.OleObject.Document.bgColor := '#E0FFFF';
end;

end.
