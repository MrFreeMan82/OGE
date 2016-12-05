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

TaxisAngle = integer;

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
    img: TImage;
    pnlOptions: TPanel;
    Label1: TLabel;
    btYes: TSpeedButton;
    btNo: TSpeedButton;
    chkRandom: TCheckBox;
    procedure btExitClick(Sender: TObject);
    procedure btClearResultsClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure chkRandomClick(Sender: TObject);
    procedure btNoClick(Sender: TObject);
    procedure btYesClick(Sender: TObject);
  private
    { Private declarations }
    Graphic: IGPGraphics;
    Pen: IGPPen;
    FontFamily: IGPFontFamily;
    Font: IGPFont;
    SolidBrush: IGPBrush;
    ColorBrush: IGPBrush;
    bmp: TBitmap;

    AXIS_ANGLE: integer;
    center: TGPPointF;
   // centerX, centerY: double;
    CircleRect:TGPRectF;
    axis: array of TLine;
    axisAngle: array of TaxisAngle;
    scale : array of TLineGraduation;
    topicResultList: TTopicResultList;

    procedure createNewBmp();
    procedure createCircle();
    procedure createScale();
    procedure createResultList();
    procedure createDisplayLabel(pts: double; i: integer);
    procedure createCurvePoints(i: integer);
    procedure Render();
    function lineLen(line:TLine):double;
    function rotatePoint(angle:integer; p: TGPpointF): TGPPointF;
    function rotateLine(angle: integer; line: Tline): Tline;
    procedure measureDisplayStringWidthAndHeight(text: string; var width, height: double);
  public
    { Public declarations }
    class function showResults(): TModalResult;
  end;

implementation

uses uOGE, math;

{$R *.dfm}

var frmTestResult: TfrmTestResult;

const
  colors: array[0..3] of cardinal = (TGPColor.Red, TGPColor.Green, TGPColor.Aqua, TGPColor.Lime);
 // AXIS_ANGLE = 45;

procedure TfrmTestResult.createCircle();
var i, angle, rect_width: integer;
begin
     if length(topicResultList) = 0 then abort;

     setLength(axis, length(topicResultList));
     setLength(axisAngle, length(axis));
     AXIS_ANGLE := 360 div length(axis);

     rect_Width := bmp.Width div 2;

     CircleRect.X := (bmp.Width - RECT_WIDTH) / 2;
     CircleRect.Y  := (bmp.Height - RECT_WIDTH) / 2;
     CircleRect.Width := RECT_WIDTH;
     CircleRect.Height := RECT_WIDTH;

              // Центр круга
     center.X := (CircleRect.Left + CircleRect.Right) / 2;
     center.Y := (CircleRect.Top + CircleRect.Bottom) / 2;

     axis[0].p1.x := center.X;
     axis[0].p1.y := center.Y;
     axis[0].p2.x := (CircleRect.Left + CircleRect.Right) / 2;
     axis[0].p2.y := CircleRect.Top;
     axis[0].len  := lineLen(axis[0]);
     axisAngle[0] := 0;

     angle := AXIS_ANGLE;

     for i := 1 to high(axis) do
     begin
          // if (angle mod 90) = 0 then incLen := 40 else incLen := 0;
           axis[i] := rotateLine(angle, axis[0]);
           axisAngle[i] := angle;
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

procedure TfrmTestResult.measureDisplayStringWidthAndHeight(text: string; var width, height: double);
var StringFormat: IGPStringFormat;
    R: TGPRectF;
    CharRanges: IGPCharacterRanges;
    CharRange: TGPCharacterRange;
    Regions: IGPRegions;
begin
    R.Initialize(0, 0, 1000, 1000);
    CharRanges := TGPArray<TGPCharacterRange>.Create(1);
    CharRange.Initialize(0, Length(Text));
    CharRanges[0] := CharRange;
    StringFormat:= TGPStringFormat.Create;
    StringFormat.SetMeasurableCharacterRanges(CharRanges);
    Regions := Graphic.MeasureCharacterRanges(Text, Font, R, StringFormat);
    Regions[0].GetBounds(R, Graphic);
    Width:=R.Right; //ширина без отступов, если нужно с отступами R.Right
    Height:=R.Height; //можно так же получить из IGPFont
end;

procedure TfrmTestResult.createDisplayLabel(pts: double; i: integer);
var s: string;
    txtH, txtW: double;
    angle: integer;
begin
    with topicResultList[i] do
        s := format('%s - %f', [topic.displayLabel, pts]);

    MeasureDisplayStringWidthAndHeight(s, txtW, txtH);
    topicResultList[i].DisplayLabel := s;

    txtH := txtH * 2;
    txtW := txtW - 10;
    angle := axisAngle[i];
    with topicResultList[i] do
    begin
        if angle in [0..79] then
        begin
            labelRect.X := labelPoint.X;
            labelRect.Y := labelPoint.Y - txtH;
        end
        else if angle in [80..179] then
        begin
            labelRect.X := labelPoint.X;
            labelRect.Y := labelPoint.Y;
        end
        else if (angle >= 180) and (axisAngle[i] < 270) then
        begin
            labelRect.X := labelPoint.X - txtW;
            labelRect.Y := labelPoint.Y;
        end
        else if (angle >= 270) and (axisAngle[i] < 360) then
        begin
            labelRect.X := labelPoint.X - txtW;
            labelRect.Y := labelPoint.Y - txtH;
        end;
        labelRect.Width := txtW;
        labelRect.Height := txtH;

        if (labelRect.X < 0) then
        begin
            labelRect.Width := labelRect.Width + labelRect.X;
            labelRect.X := 20;
        end;
    end;
end;

procedure TfrmTestResult.createResultList;
var i, angle: integer;
    k, l, pts: double;
begin
     for i := 0 to length(topicResultList) - 1 do
     begin
        with topicResultList[i] do
        begin
          topic := frmOGE.Topics.TopicList[i];
          test  := getTestByTopic(topic.id, frmOGE.Tests.Tests);

          if chkRandom.Checked then pts := random(11)
          else if assigned(test) then pts := test.points
          else pts := 0;

              // define result points
          l := (axis[i].len / MAX_GRADUATION) * pts;
          k := l / axis[i].len;

          MaxP1 := axis[i].p2;

          ResultP1.X := center.X + (MaxP1.X - center.X) * k;
          ResultP1.Y := center.Y + (MaxP1.Y - center.Y) * k;

          ResultP2 := rotatePoint(AXIS_ANGLE, ResultP1);

          // define labelPoint
          angle := trunc(axisAngle[i] + (AXIS_ANGLE / 2));
          labelPoint := rotatePoint(angle, topicResultList[0].MaxP1);

          // create labels
          createDisplayLabel(pts, i);

          // define curve points
          createCurvePoints(i);
        end;
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
    graphic.DrawEllipse(Pen, CircleRect);

    for i := 0 to length(axis) - 1 do
    begin
          graphic.DrawLine(pen, axis[i].p1, axis[i].p2);
    end;

    c := 0;
    for i := 0 to length(topicResultList) - 1 do
    begin
         graphic.DrawString(topicResultList[i].DisplayLabel,
                font, topicResultList[i].labelRect, nil, SolidBrush);

         if assigned(topicResultList[i].pie) then
         begin
             ColorBrush := TGPSolidBrush.Create(colors[c]);
             graphic.FillPath(ColorBrush, topicResultList[i].pie);

             inc(c);
             if c > 3 then c := 0;
         end;
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
    begin
         frmOGE.Tests.clearUserResults();
         createNewBMP;
    end;
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

    setLength(topicResultList, length(frmOGE.Topics.TopicList));
    createCircle();
    createScale();
    createResultList();
    Render();
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
    createNewBmp();
end;

class function TfrmTestResult.showResults(): TModalResult;
begin
    if not Assigned(frmTestResult) then frmTestResult := TFrmTestResult.Create(frmOGE);
    result := frmTestResult.showModal;
    freeAndNil(frmTestResult)
end;


procedure TfrmTestResult.FormDestroy(Sender: TObject);
begin
    freeAndNil(bmp)
end;

procedure TfrmTestResult.FormResize(Sender: TObject);
begin
    pnlOptions.Left := (pnlTools.Width div 2) - (pnlOptions.Width div 2);

    createNewBmp();
end;

end.
