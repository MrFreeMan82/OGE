unit uTestResult;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, ExtCtrls, TeEngine, TeeProcs, Chart, Series, StdCtrls;

type
  TfrmTestResult = class(TForm)
    Chart: TChart;
    Panel1: TPanel;
    btExit: TSpeedButton;
    Series1: TPieSeries;
    btClearResults: TSpeedButton;
    chkRandom: TCheckBox;
    procedure btExitClick(Sender: TObject);
    procedure btClearResultsClick(Sender: TObject);
    procedure chkRandomClick(Sender: TObject);
  private
    { Private declarations }
    useRandom: boolean;
    procedure drawPie();
  public
    { Public declarations }
    procedure showResults();
  end;

implementation

uses uOGE;

{$R *.dfm}
const
  colors: array[0..3] of TColor = (clRed, clGreen, clAqua, clLime);

procedure TfrmTestResult.btExitClick(Sender: TObject);
begin
    close
end;

procedure TfrmTestResult.chkRandomClick(Sender: TObject);
begin
    drawPie();
end;

procedure TfrmTestResult.drawPie;
var i,c: integer;
begin
    c := 0;
  //  Series1.OtherSlice.Text := 'Другие';
    Series1.Clear;
    for i := 0 to length(frmOGE.Tests.UserResults) - 1 do
    begin
        if chkRandom.Checked then
              frmOGE.Tests.UserResults[i].points := random(10);

        if frmOGE.Tests.UserResults[i].points > 0 then
        begin

            Series1.AddPie(frmOGE.Tests.UserResults[i].points,
                           frmOGE.Tests.UserResults[i].topic.displayLabel,
                           colors[c]);
        inc(c);
        end;
        if c > 3 then c := 0;
    end;
end;

procedure TfrmTestResult.btClearResultsClick(Sender: TObject);
var i: integer;
begin
    if messageBox(handle,
         'Вы уверены что хотите сбросить результаты?',
              'ОГЕ', MB_YESNO or MB_ICONQUESTION) = mrYes then
                                             frmOGE.Tests.clearUserResults();

    drawPie();
end;

procedure TfrmTestResult.showResults;
begin
    drawPie();
    showModal;
end;

end.
