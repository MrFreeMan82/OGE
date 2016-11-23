program OGE;



uses
  Forms,
  uOGE in 'uOGE.pas' {frmOGE},
  uAdmin in 'uAdmin.pas' {frmAdmin},
  uData in 'uData.pas' {dm: TDataModule},
  uNewTask in 'uNewTask.pas' {frmNewTask},
  uTests in 'uTests.pas' {frmTests},
  uGlobal in 'uGlobal.pas',
  uTheme in 'uTheme.pas' {frmTopics};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(Tdm, dm);
  Application.CreateForm(TfrmOGE, frmOGE);
  Application.Run;
end.
