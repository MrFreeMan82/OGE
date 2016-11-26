unit uTestResult;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, ExtCtrls, StdCtrls, GdiPlus, GdiPlusHelpers, uData;

const
  MAX_GRADUATION = TASK_COUNT;

type

TLine = record
      p1, p2: TGPPointF;
      len: double;
end;

TLineGraduation = array[0..MAX_GRADUATION - 1] of Tline;

TaxisAngle = record
  axisindex: integer;
  angle: integer;
end;

TTopicResult = record
    topic: TTopicInfo;
    test: PTestInfo;
    labelRect:TGPRectF;
    Center: TGPPointF;
    MaxP1: TGPPointF;
    ResultP1, ResultP2: TGPPointF;
    DisplayLabel: string;
end;

TTopicResultList = array of TTopicResult;

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
    FontFamily: IGPFontFamily;
    Font: IGPFont;
    SolidBrush: IGPBrush;

    centerX, centerY: double;
    rect:TGPRectF;
    axis: array of TLine;
    axisAngle: array of TaxisAngle;
    scale : array of TLineGraduation;
    topicResultList: TTopicResultList;

    procedure createCircle();
    procedure createScale();
    procedure createResultList();
    procedure Render();
    function lineLen(line:TLine):double;
    function rotatePoint(angle:integer; p: TGPpointF): TGPPointF;
    function rotateLine(angle: integer; line: Tline): Tline;
  public
    { Public declarations }
    procedure showResults();
  end;

implementation

uses uOGE, math;

{$R *.dfm}
const
  colors: array[0..3] of cardinal = (TGPColor.Red, TGPColor.Green, TGPColor.Aqua, TGPColor.Lime);
  RECT_WIDTH = 350;
  AXIS_ANGLE = 45;

procedure TfrmTestResult.btExitClick(Sender: TObject);
begin
    close
end;

procedure TfrmTestResult.createCircle;
var i, angle: integer;
begin
     rect.X := (img.Width - RECT_WIDTH) / 2;
     rect.Y  := (img.Height - RECT_WIDTH) / 2;
     rect.Width := RECT_WIDTH;
     rect.Height := RECT_WIDTH;

              // Центр круга
     centerX := (rect.Left + rect.Right) / 2;
     centerY := (rect.Top + rect.Bottom) / 2;

     setLength(axis, length(topicResultList));
     setLength(axisAngle, length(axis));

     axis[0].p1.x := centerX;
     axis[0].p1.y := centerY;
     axis[0].p2.x := (rect.Left + rect.Right) / 2;
     axis[0].p2.y := rect.Top;
     axis[0].len  := lineLen(axis[0]);
     axisAngle[0].axisindex := 0;
     axisAngle[0].angle := 0;

     angle := AXIS_ANGLE;

     for i := 1 to high(axis) do
     begin
          // if (angle mod 90) = 0 then incLen := 40 else incLen := 0;
           axis[i] := rotateLine(angle, axis[0]);
           axisAngle[i].axisindex := i;
           axisAngle[i].angle := angle;
           angle := angle + AXIS_ANGLE;
     end;

end;

Procedure MeasureDisplayStringWidthAndHeight(Graphics: IGPGraphics; Text: String; Font: IGPFont; Var Width, Height: Extended);
Var
    StringFormat: IGPStringFormat;
    R: TGPRectF;
    CharRanges: IGPCharacterRanges;
    CharRange: TGPCharacterRange;
    Regions: IGPRegions;
Begin
    R.Initialize(0, 0, 1000, 1000);
    CharRanges := TGPArray<TGPCharacterRange>.Create(1);
    CharRange.Initialize(0, Length(Text));
    CharRanges[0] := CharRange;
    StringFormat:= TGPStringFormat.Create;
    StringFormat.SetMeasurableCharacterRanges(CharRanges);
    Regions := Graphics.MeasureCharacterRanges(Text, Font, R, StringFormat);
    Regions[0].GetBounds(R, Graphics);
    Width:=R.Width; //ширина без отступов, если нужно с отступами R.Right
    Height:=R.Height; //можно так же получить из IGPFont
End;

procedure TfrmTestResult.createResultList;
var i, angle: integer;
    k, l: double;
    txtH, txtW: extended;
    s: string;
begin
     for i := 0 to length(topicResultList) - 1 do
     begin
          topicResultList[i].topic := frmOGE.Topics.TopicList[i];
          topicResultList[i].test  :=
                getTestByTopic(topicResultList[i].topic.id, frmOGE.Tests.Tests);

          if chkRandom.Checked then
              topicResultList[i].test.points := random(10);

          l := (axis[i].len / MAX_GRADUATION) * topicResultList[i].test.points;
          k := l / axis[i].len;

          topicResultList[i].MaxP1 := axis[i].p2;

          topicResultList[i].ResultP1.X := centerX +
                (topicResultList[i].MaxP1.X - centerX) * k;
          topicResultList[i].ResultP1.Y := centerY +
                (topicResultList[i].MaxP1.Y - centerY) * k;

          topicResultList[i].ResultP2 := rotatePoint(AXIS_ANGLE, topicResultList[i].ResultP1);

          // define centerPoint
          angle := trunc(axisAngle[i].angle + (AXIS_ANGLE / 2));
          topicResultList[i].Center := rotatePoint(angle, topicResultList[0].MaxP1);

          // create labels

          s := format('%s - %f', [topicResultList[i].topic.displayLabel, topicResultList[i].test.points]);
          MeasureDisplayStringWidthAndHeight(graphic, s, font, txtW, txtH);
          topicResultList[i].DisplayLabel := s;

          if axisAngle[i].angle in [0..89] then
          begin
               topicResultList[i].labelRect.X := topicResultList[i].Center.X;
               topicResultList[i].labelRect.Y := topicResultlist[i].Center.Y - txtH;
          end
          else if axisAngle[i].angle in [90..179] then
          begin
               topicResultList[i].labelRect.X := topicResultList[i].Center.X;
               topicResultList[i].labelRect.Y := topicResultlist[i].Center.Y;
          end
          else if (axisAngle[i].angle >= 180) and (axisAngle[i].angle < 270) then
          begin
               topicResultList[i].labelRect.X := topicResultList[i].Center.X - txtW;
               topicResultList[i].labelRect.Y := topicResultList[i].Center.Y;
          end
          else if (axisAngle[i].angle >= 270) and (axisAngle[i].angle < 360) then
          begin
               topicResultList[i].labelRect.X := topicResultList[i].Center.X - txtW;
               topicResultList[i].labelRect.Y := topicResultlist[i].Center.Y - txtH;
          end;

          topicResultList[i].labelRect.Width := txtW;
          topicResultList[i].labelRect.Height := txtH;
     end;

end;

procedure TfrmTestResult.createScale;
var scalewidth, scaleHeight, len: double;
    i, j, angle: integer;
begin
     scaleWidth := 10;
     scaleHeight := axis[0].len / TASK_COUNT;

     setLength(scale, length(axis));

     scale[0][0].p1.X := centerX + (scaleWidth / 2);
     scale[0][0].p1.Y := centerY - scaleHeight;
     scale[0][0].p2.X := centerX - (scaleWidth / 2);
     scale[0][0].p2.Y := centerY - scaleHeight;
     scale[0][0].len := lineLen(scale[0][0]);
     len := scale[0][0].len;

     for i := 1 to MAX_GRADUATION - 1 do
     begin
          scale[0][i].p1.X := centerX + (scaleWidth / 2);
          scale[0][i].p1.Y := centerY - scaleHeight * i;
          scale[0][i].p2.X := centerX - (scaleWidth / 2);
          scale[0][i].p2.Y := centerY - scaleHeight * i;
          scale[0][i].len := len;
     end;

     for i := 1 to MAX_GRADUATION - 1  do
     begin
          angle := AXIS_ANGLE;
          for j := 1 to length(scale) - 1 do
          begin
              scale[j][i] := rotateLine(angle, scale[0][i]);
              angle := angle + AXIS_ANGLE;
          end;
     end;
end;

procedure TfrmTestResult.Render;
var i, j, tx, ty: integer;
    point: TGPPointF;
begin
  //  graphic.DrawRectangle(pen, rect);
    graphic.DrawEllipse(Pen, rect);

    for i := 0 to length(axis) - 1 do
    begin
          graphic.DrawLine(pen, axis[i].p1, axis[i].p2);
    end;

    for i := 0 to length(scale) - 1 do
        for j := 0 to MAX_GRADUATION - 1 do
            graphic.DrawLine(pen, scale[i][j].p1, scale[i][j].p2);


    point.X := centerX;
    point.Y := centerY;
    pen.Width := 2;
    for i := 0 to length(topicResultList) - 1 do
    begin

        { if topicResultList[i].Center.X > 0 then
            graphic.DrawLine(pen, point, topicResultList[i].Center); }

         graphic.DrawString(topicResultList[i].DisplayLabel,
                font, topicResultList[i].labelRect, nil, SolidBrush);
    end;


  //  tx := 10; ty := 0;
   // Point.Initialize(tx, ty);
   { for i := 0 to length(topicResultList) - 1 do
    begin
      //  ty := ty + 15;
       // Point.Initialize(tx, ty);
       point := topicResultList[i].MaxP1;

       Graphic.DrawString(topicResultList[i].topic.displayLabel + ' ' +
              floatToStr(topicResultList[i].test.points),Font, Point, SolidBrush);

        graphic.DrawLine(pen, topicResultList[i].ResultP1, topicResultList[i].ResultP2);
    end; }
end;

function TfrmTestResult.lineLen(line: TLine): double;
begin
    result := sqrt(sqr(line.p1.X - line.p2.X) + sqr(line.p1.Y - line.p2.Y));
end;

function TfrmTestResult.rotateLine(angle: integer; line: Tline): TLine;
begin
     result.p1 := rotatePoint(angle, line.p1);
     result.p2 := rotatePoint(angle, line.p2);
     result.len := line.len;
end;

function TfrmTestResult.rotatePoint(angle: integer;p: TGPpointF): TGPPointF;
var radAngle, at, len, s, c: extended;
begin
    radAngle := angle * pi / 180;
    len := Sqrt(sqr(p.X - centerX) + sqr(p.Y - centerY));
    at  := ArcTan2(p.Y - centerY, p.X - centerX);
    sinCos(radAngle + at, s, c);
    result.X := centerX + len * c;
    result.Y := centerY + len * s;
   { result.X := centerX + (p.X - centerX) * c - (p.Y - centerY) * s;
    result.Y := centerY + (p.X - centerX) * s - (p.Y - centerY) * c; }
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
    Graphic := TGPGraphics.Create(img.Canvas.Handle);
    Graphic.SmoothingMode := SmoothingModeAntiAlias;
    Pen := TGPPen.Create(TGPColor.Black, 1);
    FontFamily := TGPFontFamily.Create('Tahoma');
    Font := TGPFont.Create(FontFamily, 10, FontStyleRegular, UnitPoint);
    Graphic.TextRenderingHint := TextRenderingHintAntiAlias;
    SolidBrush := TGPSolidBrush.Create(TGPColor.Black);

    setLength(topicResultList, length(frmOGE.Topics.TopicList));

    createCircle();
    createScale();
    createResultList();
    Render();
    showModal;
end;

end.
