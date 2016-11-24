unit uOGE;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, OleCtrls, SHDocVw, ComCtrls, StdCtrls, ExtCtrls, ExtDlgs, Grids,
  ToolWin, Buttons, PlatformDefaultStyleActnCtrls, ActnList, ActnMan,
  AppEvnts, uTests, uTheme, uData;

type
  TfrmOGE = class(TForm)
    pgPages: TPageControl;
    tabInfo: TTabSheet;
    tabAdmin: TTabSheet;
    ActionList: TActionList;
    Action1: TAction;
    tabThemes: TTabSheet;
    tabTests: TTabSheet;
    WebBrowser1: TWebBrowser;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure WebBrowser1DocumentComplete(ASender: TObject;
      const pDisp: IDispatch; var URL: OleVariant);
  private
    { Private declarations }
    frmTests: TfrmTests;
    frmTopics: TfrmTopics;
    path: string;
  public
    { Public declarations }

    property Tests: TfrmTests read frmTests;
    property Topics: TfrmTopics read frmTopics;
  end;

var
  frmOGE: TfrmOGE;

implementation

{$R *.dfm}
{$DEFINE TEST}

procedure TfrmOGE.FormCreate(Sender: TObject);
begin
    {$IFDEF TEST}
    showMessage('Тестовый образец');
    {$ENDIF}
    Path := exePath();
    WebBrowser1.Navigate(path + '1.html');
    WebBrowser1.OleObject.Document.bgColor := '#E0FFFF';
    pgPages.ActivePage := tabInfo;

    if not Assigned(frmTopics) then frmTopics := TfrmTopics.Create(self);
    frmTopics.Dock(tabThemes, tabThemes.ClientRect);
    frmTopics.showTopics();

    if not Assigned(frmTests) then frmTests := TfrmTests.Create(self);
    frmTests.Dock(tabTests, tabTests.ClientRect);
    frmTests.ShowTests();
end;

procedure TfrmOGE.FormDestroy(Sender: TObject);
begin
    freeAndNil(frmTests);
    freeAndNil(frmTopics);
end;

procedure TfrmOGE.WebBrowser1DocumentComplete(ASender: TObject;
  const pDisp: IDispatch; var URL: OleVariant);
begin
    while WebBrowser1.ReadyState <> 4 do Application.ProcessMessages;
    WebBrowser1.OleObject.Document.bgColor := '#E0FFFF';
end;

end.
