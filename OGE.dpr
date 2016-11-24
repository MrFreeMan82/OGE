program OGE;

uses
  Forms,
  uOGE in 'uOGE.pas' {frmOGE},
  uData in 'uData.pas' {dm: TDataModule},
  uTests in 'uTests.pas' {frmTests},
  uTheme in 'uTheme.pas' {frmTopics};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(Tdm, dm);
  Application.CreateForm(TfrmOGE, frmOGE);
  Application.Run;
end.
