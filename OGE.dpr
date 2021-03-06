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
  uTopicModel in 'uTopicModel.pas',
  uUser in 'uUser.pas' {frmUser},
  uSavePoint in 'uSavePoint.pas',
  uStress in 'uStress.pas',
  uSync in 'uSync.pas',
  uWait in 'uWait.pas' {frmWait},
  uTaskResults in 'uTaskResults.pas' {frmTaskResults};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(Tdm, dm);
  Application.CreateForm(TfrmOGE, frmOGE);
  Application.CreateForm(TfrmWait, frmWait);
  Application.Run;
end.
