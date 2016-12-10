unit uTestResult;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, ExtCtrls, StdCtrls, GdiPlus, GdiPlusHelpers, uData,
  uTestDiagram, uUTTDiagram;

type

TfrmTestResult = class(TForm)
    pnlTools: TPanel;
    btExit: TSpeedButton;
    btClearResults: TSpeedButton;
    img: TImage;
    pnlOptions: TPanel;
    Label1: TLabel;
    btYes: TSpeedButton;
    btNo: TSpeedButton;
    chkRandom: TCheckBox;
    pnlDiagram: TPanel;
    procedure btExitClick(Sender: TObject);
    procedure btClearResultsClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure chkRandomClick(Sender: TObject);
    procedure btNoClick(Sender: TObject);
    procedure btYesClick(Sender: TObject);
  private
    { Private declarations }

    frmTestDiagram: TfrmTestDiagram;
    frmUTTDiagram: TfrmUTTDiagram;
  public
    { Public declarations }
    class function showResults(): TModalResult;
    class function showUTTResults(): TModalResult;
  end;

implementation

uses uOGE, math;

{$R *.dfm}

var frmTestResult: TfrmTestResult;

procedure TfrmTestResult.btClearResultsClick(Sender: TObject);
begin
    if messageBox(handle,
         'Вы уверены что хотите сбросить результаты?',
              'ОГЕ', MB_YESNO or MB_ICONQUESTION) = mrYes then
    begin
         if Assigned(frmTestDiagram) then
         begin
             frmOGE.Tests.clearUserResults();
             frmTestDiagram.createNewBmp(chkRandom.Checked);
         end
         else if Assigned(frmUTTDiagram) then
         begin
             frmOGE.UTT.clearUserResults();
             frmUTTDiagram.createNewBMP(chkRandom.Checked);
         end;
    end;
end;

procedure TfrmTestResult.btExitClick(Sender: TObject);
begin
    modalResult := mrCancel
end;

procedure TfrmTestResult.btNoClick(Sender: TObject);
begin
    modalResult := mrNo;
end;

procedure TfrmTestResult.btYesClick(Sender: TObject);
begin
    modalResult := mrYes;
end;

procedure TfrmTestResult.chkRandomClick(Sender: TObject);
begin
     if Assigned(frmTestDiagram) then
     begin
         frmTestDiagram.createNewBmp(chkRandom.Checked);
     end
     else if Assigned(frmUTTDiagram) then
     begin
         frmUTTDiagram.createNewBMP(chkRandom.Checked);
     end;
end;

class function TfrmTestResult.showResults(): TModalResult;
begin
    if not Assigned(frmTestResult) then frmTestResult := TFrmTestResult.Create(frmOGE);
    frmTestResult.frmtestDiagram := TfrmTestDiagram.Create(frmTestResult);
    try
      frmTestResult.frmTestDiagram.Dock(frmtestResult.pnlDiagram, frmtestResult.pnlDiagram.ClientRect);
      frmTestResult.frmTestDiagram.showTestDiagram();
      result := frmTestResult.showModal;
    finally
        freeAndNil(frmTestResult.frmTestDiagram);
        freeAndNil(frmTestResult)
    end;
end;

class function TfrmTestResult.showUTTResults: TModalResult;
begin
    if not Assigned(frmTestResult) then frmTestResult := TFrmTestResult.Create(frmOGE);
    frmTestResult.frmUTTDiagram := TfrmUTTDiagram.Create(frmTestResult);
    try
        frmTestResult.frmUTTDiagram.Dock(frmTestResult.pnlDiagram, frmTestResult.pnlDiagram.ClientRect);
        frmTestResult.frmUTTDiagram.showUTTDiagram();
        result := frmTestResult.showModal;
    finally
        freeAndNil(frmTestResult.frmUTTDiagram);
        freeAndNil(frmTestResult)
    end;
end;

procedure TfrmTestResult.FormResize(Sender: TObject);
begin
   pnlOptions.Left := (pnlTools.Width div 2) - (pnlOptions.Width div 2);

   if Assigned(frmTestDiagram) then
   begin
       frmTestDiagram.createNewBmp(chkRandom.Checked);
   end
   else if Assigned(frmUTTDiagram) then
   begin
       frmUTTDiagram.createNewBMP(chkRandom.Checked);
   end;
end;

end.
