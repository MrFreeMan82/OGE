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
    labelPoint: TGPPointF;
    curvePoint: TGPPointF;
    MaxP1: TGPPointF;
    ResultP1, ResultP2: TGPPointF;
    pie: IGPGraphicsPath;
    DisplayLabel: string;
end;

TTopicResultList = array of TTopicResult;

TfrmTestResult = class(TForm)
    pnlTools: TPanel;
    btExit: TSpeedButton;
    btClearResults: TSpeedButton;
    chkRandom: TCheckBox;
    img: TImage;
    procedure btExitClick(Sender: TObject);
    procedure btClearResultsClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    { Private declarations }
    Graphic: IGPGraphics;
    Pen: IGPPen;
    FontFamily: IGPFontFamily;
    Font: IGPFont;
    SolidBrush: IGPBrush;
    ColorBrush: IGPBrush;
    bmp: TBitmap;

    center: TGPPointF;
   // centerX, centerY: double;
    rect:TGPRectF;
    axis: array of TLine;
    axisAngle: array of TaxisAngle;
    scale : array of TLineGraduation;
    topicResultList: TTopicResultList;

    procedure createNewBmp();
    procedure createCircle();
    procedure createScale();
    procedure createResultList();
    procedure createDisplayLabel(i: integer);
    procedure createCurvePoints(i: integer);
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
  AXIS_ANGLE = 45;

procedure TfrmTestResult.btExitClick(Sender: TObject);
begin
    close
end;

procedure TfrmTestResult.createCircle();
var i, angle, rect_width: integer;
begin
     rect_Width := bmp.Width div 2;

     rect.X := (bmp.Width - RECT_WIDTH) / 2;
     rect.Y  := (bmp.Height - RECT_WIDTH) / 2;
     rect.Width := RECT_WIDTH;
     rect.Height := RECT_WIDTH;

              // Центр круга
     center.X := (rect.Left + rect.Right) / 2;
     center.Y := (rect.Top + rect.Bottom) / 2;

     setLength(axis, length(topicResultList));
     setLength(axisAngle, length(axis));

     axis[0].p1.x := center.X;
     axis[0].p1.y := center.Y;
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

procedure TfrmTestResult.createCurvePoints(i: integer);
var angle: integer;
    points: array[0..2] of TGPPointF;
begin
     topicResultList[i].pie := TGPGraphicsPath.Create;
     angle := trunc(AXIS_ANGLE / 2);
     topicResultList[i].curvePoint := rotatePoint(angle, topicResultList[i].ResultP1);
     points[0] := topicResultList[i].ResultP1;
     points[1] := topicResultList[i].curvePoint;
     points[2] := topicResultList[i].ResultP2;
     topicResultList[i].pie.AddCurve(points);
     points[0] := center;
     points[1] := topicResultList[i].ResultP1;
     points[2] := topicResultList[i].ResultP2;
     topicResultList[i].pie.AddPolygon(points);
end;

procedure MeasureDisplayStringWidthAndHeight(Graphics: IGPGraphics; Text: String; Font: IGPFont; Var Width, Height: Extended);
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

procedure TfrmTestResult.createDisplayLabel(i: integer);
var s: string;
    txtH, txtW: extended;
    angle: integer;
begin
    s := format('%s - %f', [topicResultList[i].topic.displayLabel, topicResultList[i].test.points]);
    MeasureDisplayStringWidthAndHeight(graphic, s, font, txtW, txtH);
    topicResultList[i].DisplayLabel := s;

    txtH := txtH * 2;
    txtW := txtW - 10;
    angle := axisAngle[i].angle;
    if angle in [0..89] then
    begin
         topicResultList[i].labelRect.X := topicResultList[i].labelPoint.X;
         topicResultList[i].labelRect.Y := topicResultlist[i].labelPoint.Y - txtH;
    end
    else if angle in [90..179] then
    begin
         topicResultList[i].labelRect.X := topicResultList[i].labelPoint.X;
         topicResultList[i].labelRect.Y := topicResultlist[i].labelPoint.Y;
    end
    else if (angle >= 180) and (axisAngle[i].angle < 270) then
    begin
         topicResultList[i].labelRect.X := topicResultList[i].labelPoint.X - txtW;
         topicResultList[i].labelRect.Y := topicResultList[i].labelPoint.Y;
    end
    else if (angle >= 270) and (axisAngle[i].angle < 360) then
    begin
          topicResultList[i].labelRect.X := topicResultList[i].labelPoint.X - txtW;
          if topicResultList[i].labelRect.X < 0 then
                    topicResultList[i].labelRect.X := 0;
          topicResultList[i].labelRect.Y := topicResultlist[i].labelPoint.Y - txtH;
    end;
    topicResultList[i].labelRect.Width := txtW;
    topicResultList[i].labelRect.Height := txtH;

    if (topicResultList[i].labelRect.X < 0) then
    begin
         topicResultList[i].labelRect.Width :=
              topicResultList[i].labelRect.Width + topicResultList[i].labelRect.X;
         topicResultList[i].labelRect.X := 20;
    end;
end;

procedure TfrmTestResult.createResultList;
var i, angle: integer;
    k, l: double;
begin
     for i := 0 to length(topicResultList) - 1 do
     begin
          topicResultList[i].topic := frmOGE.Topics.TopicList[i];
          topicResultList[i].test  :=
                getTestByTopic(topicResultList[i].topic.id, frmOGE.Tests.Tests);

          if chkRandom.Checked then
              topicResultList[i].test.points := random(10);

              // define result points
          l := (axis[i].len / MAX_GRADUATION) * topicResultList[i].test.points;
          k := l / axis[i].len;

          topicResultList[i].MaxP1 := axis[i].p2;

          topicResultList[i].ResultP1.X := center.X +
                (topicResultList[i].MaxP1.X - center.X) * k;
          topicResultList[i].ResultP1.Y := center.Y +
                (topicResultList[i].MaxP1.Y - center.Y) * k;

          topicResultList[i].ResultP2 := rotatePoint(AXIS_ANGLE, topicResultList[i].ResultP1);

          // define labelPoint
          angle := trunc(axisAngle[i].angle + (AXIS_ANGLE / 2));
          topicResultList[i].labelPoint := rotatePoint(angle, topicResultList[0].MaxP1);

          // create labels
          createDisplayLabel(i);

          // define curve points
          createCurvePoints(i);
     end;

end;

procedure TfrmTestResult.createScale;
var scalewidth, scaleHeight, len: double;
    i, j, angle: integer;
begin
     scaleWidth := 10;
     scaleHeight := axis[0].len / TASK_COUNT;

     setLength(scale, length(axis));

     scale[0][0].p1.X := center.X + (scaleWidth / 2);
     scale[0][0].p1.Y := center.Y - scaleHeight;
     scale[0][0].p2.X := center.X - (scaleWidth / 2);
     scale[0][0].p2.Y := center.Y - scaleHeight;
     scale[0][0].len := lineLen(scale[0][0]);
     len := scale[0][0].len;

     for i := 1 to MAX_GRADUATION - 1 do
     begin
          scale[0][i].p1.X := center.X + (scaleWidth / 2);
          scale[0][i].p1.Y := center.Y - scaleHeight * i;
          scale[0][i].p2.X := center.X - (scaleWidth / 2);
          scale[0][i].p2.Y := center.Y - scaleHeight * i;
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
var i, j, c: integer;
begin
    graphic.DrawEllipse(Pen, rect);

    for i := 0 to length(axis) - 1 do
    begin
          graphic.DrawLine(pen, axis[i].p1, axis[i].p2);
    end;

    c := 0;
    for i := 0 to length(topicResultList) - 1 do
    begin
         ColorBrush := TGPSolidBrush.Create(colors[c]);
         graphic.FillPath(ColorBrush, topicResultList[i].pie);

         graphic.DrawString(topicResultList[i].DisplayLabel,
                font, topicResultList[i].labelRect, nil, SolidBrush);

         inc(c);
         if c > 3 then c := 0;
    end;

    for i := 0 to length(scale) - 1 do
        for j := 0 to MAX_GRADUATION - 1 do
            graphic.DrawLine(pen, scale[i][j].p1, scale[i][j].p2);

    img.Picture.Assign(bmp);
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
    len := Sqrt(sqr(p.X - center.X) + sqr(p.Y - center.Y));
    at  := ArcTan2(p.Y - center.Y, p.X - center.X);
    sinCos(radAngle + at, s, c);
    result.X := center.X + len * c;
    result.Y := center.Y + len * s;
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

procedure TfrmTestResult.createNewBmp;
begin
    if Assigned(bmp) then freeAndNil(bmp);

    bmp := TBitMap.Create;
    bmp.Width := self.Width;
    bmp.Height := self.Height - pnlTools.Height;

    Graphic := TGPGraphics.Create(bmp.Canvas.Handle);
    Graphic.SmoothingMode := SmoothingModeAntiAlias;
    Pen := TGPPen.Create(TGPColor.Black, 1);
    FontFamily := TGPFontFamily.Create('Tahoma');
    Font := TGPFont.Create(FontFamily, 10, FontStyleRegular, UnitPoint);
    Graphic.TextRenderingHint := TextRenderingHintAntiAlias;
    SolidBrush := TGPSolidBrush.Create(TGPColor.Black);
end;

procedure TfrmTestResult.showResults;
begin
    createNewBmp();
    setLength(topicResultList, length(frmOGE.Topics.TopicList));
    createCircle();
    createScale();
    createResultList();
    Render();
    showModal;
end;


procedure TfrmTestResult.FormDestroy(Sender: TObject);
begin
    freeAndNil(bmp)
end;

procedure TfrmTestResult.FormResize(Sender: TObject);
begin
    createNewBmp();
    setLength(topicResultList, length(frmOGE.Topics.TopicList));
    createCircle();
    createScale();
    createResultList();
    Render();
end;

end.
