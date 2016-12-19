program OGE;

{$R 'html.res' 'html.rc'}

uses
  Forms,
  uOGE in 'uOGE.pas' {frmOGE},
  uData in 'uData.pas' {dm: TDataModule},
  uTheme in 'uTheme.pas' {frmTopics},
  uTestResult in 'uTestResult.pas' {frmTestResult},
  uUTT in 'uUTT.pas' {frmUTT},
  uUTTDiagram in 'uUTTDiagram.pas' {frmUTTDiagram},
  uGlobals in 'uGlobals.pas',
  uTasks in 'uTasks.pas' {frmTasks},
  uTaskDiagram in 'uTaskDiagram.pas' {frmTaskDiagram},
  uWorkPlan in 'uWorkPlan.pas' {frmWorkPlan},
  uTopicModel in 'uTopicModel.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(Tdm, dm);
  Application.CreateForm(TfrmOGE, frmOGE);
  Application.Run;
end.
