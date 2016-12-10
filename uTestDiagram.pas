unit uTestDiagram;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, GdiPlus, GdiPlusHelpers, uData;

const
  MAX_GRADUATION = TASK_COUNT;

type

TLineGraduation = array[0..MAX_GRADUATION - 1] of Tline;

TaxisAngle = double;

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

TfrmTestDiagram = class(TForm)
    img: TImage;
  private
    Graphic: IGPGraphics;
    Pen: IGPPen;
    FontFamily: IGPFontFamily;
    Font: IGPFont;
    SolidBrush: IGPBrush;
    ColorBrush: IGPBrush;
    bmp: TBitmap;

    AXIS_ANGLE: double;
    center: TGPPointF;
   // centerX, centerY: double;
    CircleRect:TGPRectF;
    axis: array of TLine;
    axisAngle: array of TaxisAngle;
    scale : array of TLineGraduation;
    topicResultList: TTopicResultList;

    israndom: boolean;

    procedure createCircle(axisCount: integer);
    procedure createScale();
    procedure createResultList();
    procedure createDisplayLabel(pts: double; i: integer);
    procedure createCurvePoints(i: integer);
    procedure Render();
  public
    { Public declarations }
    procedure createNewBmp(useRandom: boolean);
    procedure showTestDiagram();
  end;

implementation

uses uOGE;

{$R *.dfm}

const
  colors: array[0..3] of cardinal = (TGPColor.Red, TGPColor.Green, TGPColor.Aqua, TGPColor.Lime);

{ TfrmTestDiagram }

procedure TfrmTestDiagram.createCircle(axisCount: integer);
var i, rect_width: integer;
    angle: double;
begin
     if axisCount = 0 then abort;

     setLength(axis, axisCount);
     setLength(axisAngle, length(axis));
     AXIS_ANGLE := 360 div length(axis);

     rect_Width := trunc(bmp.height / 1.2);

     CircleRect.X := (bmp.Width - RECT_WIDTH) / 2;
     CircleRect.Y  := ((bmp.Height - RECT_WIDTH) / 2);
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
           axis[i] := rotateLine(angle, axis[0], center);
           axisAngle[i] := angle;
           angle := angle + AXIS_ANGLE;
     end;
end;

procedure TfrmTestDiagram.createCurvePoints(i: integer);
var angle: integer;
    points: array[0..2] of TGPPointF;
begin
     topicResultList[i].pie := TGPGraphicsPath.Create;
     angle := trunc(AXIS_ANGLE / 2);
     topicResultList[i].curvePoint := rotatePoint(angle, center, topicResultList[i].ResultP1);
     points[0] := topicResultList[i].ResultP1;
     points[1] := topicResultList[i].curvePoint;
     points[2] := topicResultList[i].ResultP2;
     topicResultList[i].pie.AddCurve(points);
     points[0] := center;
     points[1] := topicResultList[i].ResultP1;
     points[2] := topicResultList[i].ResultP2;
     topicResultList[i].pie.AddPolygon(points);
end;

procedure TfrmTestDiagram.createDisplayLabel(pts: double; i: integer);
var s: string;
    txtH, txtW: double;
    angle: integer;
begin
    with topicResultList[i] do
        s := format('%s - %f', [topic.displayLabel, pts]);

    MeasureDisplayStringWidthAndHeight(Graphic, Font, s, txtW, txtH);
    topicResultList[i].DisplayLabel := s;

    txtH := txtH * 2;
    txtW := txtW - 10;
    angle := trunc(axisAngle[i]);
    with topicResultList[i] do
    begin
        if (angle >= 0) and (angle <= 79) then // in [0..79]
        begin
            labelRect.X := labelPoint.X;
            labelRect.Y := labelPoint.Y - txtH;
        end
        else if (angle >= 80) and (angle <= 179) then // in [80..179]
        begin
            labelRect.X := labelPoint.X;
            labelRect.Y := labelPoint.Y;
        end
        else if (angle >= 180) and (angle < 270) then
        begin
            labelRect.X := labelPoint.X - txtW;
            labelRect.Y := labelPoint.Y;
        end
        else if (angle >= 270) and (angle < 360) then
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

procedure TfrmTestDiagram.createNewBmp(useRandom: boolean);
begin
    if Assigned(bmp) then freeAndNil(bmp);

    isRandom := useRandom;
    bmp := TBitMap.Create;
    bmp.Width := self.Width;
    bmp.Height := self.Height;

    Graphic := TGPGraphics.Create(bmp.Canvas.Handle);
    Graphic.SmoothingMode := SmoothingModeAntiAlias;
    Pen := TGPPen.Create(TGPColor.Black, 1);
    FontFamily := TGPFontFamily.Create('Tahoma');
    Font := TGPFont.Create(FontFamily, 10, FontStyleRegular, UnitPoint);
    Graphic.TextRenderingHint := TextRenderingHintAntiAlias;
    SolidBrush := TGPSolidBrush.Create(TGPColor.Black);

    setLength(topicResultList, length(frmOGE.Topics.TopicList));
    createCircle(length(topicResultList));
    createScale();
    createResultList();
    Render();
end;

procedure TfrmTestDiagram.createResultList;
var i: integer;
    k, l, pts, angle: double;
begin
     for i := 0 to length(topicResultList) - 1 do
     begin
        with topicResultList[i] do
        begin
          topic := frmOGE.Topics.TopicList[i];
          test  := getTestByTopic(topic.id, frmOGE.Tests.Tests);

          if isRandom then pts := random(11)
          else if assigned(test) then pts := test.points
          else pts := 0;

              // define result points
          l := (axis[i].len / MAX_GRADUATION) * pts;
          k := l / axis[i].len;

          MaxP1 := axis[i].p2;

          ResultP1.X := center.X + (MaxP1.X - center.X) * k;
          ResultP1.Y := center.Y + (MaxP1.Y - center.Y) * k;

          ResultP2 := rotatePoint(AXIS_ANGLE, center, ResultP1);

          // define labelPoint
          angle := axisAngle[i] + (AXIS_ANGLE / 2);
          labelPoint := rotatePoint(angle, center, topicResultList[0].MaxP1);

          // create labels
          createDisplayLabel(pts, i);

          // define curve points
          createCurvePoints(i);
        end;
     end;
end;

procedure TfrmTestDiagram.createScale;
var scalewidth, scaleHeight, len: double;
    i, j: integer;
    angle: double;
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
              scale[j][i] := rotateLine(angle, scale[0][i], center);
              angle := angle + AXIS_ANGLE;
          end;
     end;
end;

procedure TfrmTestDiagram.Render;
var i, j, c: integer;
begin
    graphic.DrawEllipse(Pen, CircleRect);

    for i := 0 to length(axis) - 1 do
          graphic.DrawLine(pen, axis[i].p1, axis[i].p2);

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

procedure TfrmTestDiagram.showTestDiagram();
begin
    show;
end;

end.
