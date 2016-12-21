unit uTestResult;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, ExtCtrls, StdCtrls, GdiPlus, GdiPlusHelpers, uData,
  uUTTDiagram, uTaskDiagram;

type

TfrmTestResult = class(TForm)
    pnlTools: TPanel;
    btExit: TSpeedButton;
    btClearResults: TSpeedButton;
    pnlOptions: TPanel;
    Label1: TLabel;
    btYes: TSpeedButton;
    btNo: TSpeedButton;
    chkRandom: TCheckBox;
    pnlDiagram: TPanel;
    btSaveresults: TSpeedButton;
    procedure btExitClick(Sender: TObject);
    procedure btClearResultsClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure chkRandomClick(Sender: TObject);
    procedure btNoClick(Sender: TObject);
    procedure btYesClick(Sender: TObject);
    procedure btSaveresultsClick(Sender: TObject);
  private
    { Private declarations }

    frmUTTDiagram: TfrmUTTDiagram;
    frmTaskDiagram: TfrmTaskDiagram;
  public
    { Public declarations }
    class function showUTTResults(): TModalResult;
    class function showTaskResults(): TModalResult;
  end;

implementation

uses uOGE, math;

{$R *.dfm}

procedure TfrmTestResult.btClearResultsClick(Sender: TObject);
begin
    if messageBox(handle,
         'Вы уверены что хотите сбросить результаты?',
              'ОГЕ', MB_YESNO or MB_ICONQUESTION) = mrYes then
    begin
         if Assigned(frmUTTDiagram) then
         begin
             frmOGE.UTT.clearUserResults();
             frmUTTDiagram.refresh(chkRandom.Checked);
             btClearResults.Enabled := false;
         end
         else if assigned(frmTaskDiagram) then
         begin
              frmOGE.Tasks.clearUserResults;
              frmTaskDiagram.Free;
              frmTaskDiagram := TfrmTaskDiagram.Create(self);
              frmTaskDiagram.Dock(pnlDiagram, pnlDiagram.ClientRect);
              frmTaskDiagram.showDiagram(chkRandom.Checked, true);
              btClearResults.Enabled := false;
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

procedure TfrmTestResult.btSaveresultsClick(Sender: TObject);
begin
     if Assigned(frmUTTDiagram) then
     begin
         frmOGE.UTT.saveResults();
         btSaveresults.Enabled := false;
     end
     else if assigned(frmTaskDiagram) then
     begin
          frmOGE.Tasks.saveResults;
          btSaveresults.Enabled := false;
     end;
end;

procedure TfrmTestResult.btYesClick(Sender: TObject);
begin
    modalResult := mrYes;
end;

procedure TfrmTestResult.chkRandomClick(Sender: TObject);
begin
     if Assigned(frmUTTDiagram) then
     begin
         frmUTTDiagram.refresh(chkRandom.Checked);
     end;
end;

class function TfrmTestResult.showTaskResults: TModalResult;
var frmTestResult: TfrmTestResult;
begin
   // if not assigned(frmTestResult) then
    frmTestResult := TFrmTestResult.Create(frmOGE);

    frmTestResult.frmTaskDiagram := TfrmTaskDiagram.Create(frmTestResult);
    try
       frmTestResult.frmTaskDiagram.Dock(
                       frmTestResult.pnlDiagram,
                            frmTestResult.pnlDiagram.ClientRect);

      frmTestResult.frmTaskDiagram.showDiagram(frmTestResult.chkRandom.Checked, false);
      result := frmTestResult.ShowModal;

    finally
        freeAndNil(frmTestResult.frmTaskDiagram);
        freeAndNil(frmTestResult);
    end;
end;

class function TfrmTestResult.showUTTResults: TModalResult;
var frmTestResult: TfrmTestResult;
begin
   // if not Assigned(frmTestResult) then
    frmTestResult := TFrmTestResult.Create(frmOGE);

    frmTestResult.frmUTTDiagram := TfrmUTTDiagram.Create(frmTestResult);
    try
        frmTestResult.frmUTTDiagram.Dock(
                frmTestResult.pnlDiagram,
                    frmTestResult.pnlDiagram.ClientRect);

        frmTestResult.frmUTTDiagram.showUTTDiagram(frmOGE.UTT);
        result := frmTestResult.showModal;

    finally
        freeAndNil(frmTestResult.frmUTTDiagram);
        freeAndNil(frmTestResult)
    end;
end;

procedure TfrmTestResult.FormResize(Sender: TObject);
begin
   pnlOptions.Left := (pnlTools.Width div 2) - (pnlOptions.Width div 2);

   if Assigned(frmUTTDiagram) then
   begin
       frmUTTDiagram.refresh(chkRandom.Checked);
   end
   else if assigned(frmTaskDiagram) then
   begin
       frmTaskDiagram.refresh(chkRandom.Checked);
   end;
end;

end.

