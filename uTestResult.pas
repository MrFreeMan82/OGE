unit uTestResult;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, ExtCtrls, StdCtrls, GdiPlus, GdiPlusHelpers;


type

TLine = record
      cp, p: TGPPointF;
end;

TfrmTestResult = class(TForm)
    Panel1: TPanel;
    btExit: TSpeedButton;
    btClearResults: TSpeedButton;
    chkRandom: TCheckBox;
    img: TImage;
    procedure btExitClick(Sender: TObject);
    procedure btClearResultsClick(Sender: TObject);
  private
    { Private declarations }
    Graphic: IGPGraphics;
    Pen: IGPPen;
    centerX, centerY: double;
    rect:TGPRectF;
    lines: array[0..8] of TLine;

    useRandom: boolean;
    procedure drawCircle();
  public
    { Public declarations }
    procedure showResults();
  end;

implementation

uses uOGE, math;

{$R *.dfm}
const
  colors: array[0..3] of cardinal = (TGPColor.Red, TGPColor.Green, TGPColor.Aqua, TGPColor.Lime);
  RECT_WIDTH = 400;

procedure TfrmTestResult.btExitClick(Sender: TObject);
begin
    close
end;

procedure TfrmTestResult.drawCircle;
var i, angle: integer;
    radAngle, len, at, s, c: extended;
begin
     Graphic := TGPGraphics.Create(img.Canvas.Handle);
     Graphic.SmoothingMode := SmoothingModeAntiAlias;
     Pen := TGPPen.Create(TGPColor.Black, 1);

     rect.X := (img.Width - RECT_WIDTH) / 2;
     rect.Y  := (img.Height - RECT_WIDTH) / 2;
     rect.Width := RECT_WIDTH;
     rect.Height := RECT_WIDTH;

              // Центр круга
     centerX := (rect.Left + rect.Right) / 2;
     centerY := (rect.Top + rect.Bottom) / 2;

     lines[0].cp.x := centerX;
     lines[0].cp.y := centerY;
     lines[0].p.x := (rect.Left + rect.Right) / 2;
     lines[0].p.y := rect.Top;

     angle := 45;

     for i := 1 to high(lines) do
     begin
           radAngle := angle * pi / 180;
           len := sqrt(sqr(lines[0].cp.x - lines[0].p.x) + sqr(lines[0].cp.y - lines[0].p.y));
           if (angle mod 90) = 0 then len := len + 40;

           at := -arcTan2(lines[0].cp.y - lines[0].p.y, lines[0].cp.x - lines[0].p.x);
           sinCos(radAngle + at, s, c);

           lines[i].cp.X := centerX;
           lines[i].cp.Y := centerY;
           lines[i].p.X  := trunc(centerX + len * c);
           lines[i].p.Y  := trunc(centerY + len * s);
           angle := angle + 45;
     end;

    graphic.DrawRectangle(pen, rect);
    graphic.DrawEllipse(Pen, rect);

    for i := 0 to length(lines) - 1 do
          graphic.DrawLine(pen, lines[i].cp, lines[i].p);

end;

procedure TfrmTestResult.btClearResultsClick(Sender: TObject);
begin
    if messageBox(handle,
         'Вы уверены что хотите сбросить результаты?',
              'ОГЕ', MB_YESNO or MB_ICONQUESTION) = mrYes then
                                             frmOGE.Tests.clearUserResults();

end;

procedure TfrmTestResult.showResults;
begin
    drawCircle();
    showModal;
end;

end.
