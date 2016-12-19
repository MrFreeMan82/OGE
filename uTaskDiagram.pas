unit uTaskDiagram;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, uGlobals, GdiPlus, GdiPlusHelpers;

type
  TTasks = array of IGPGraphicsPath;

  TfrmTaskDiagram = class(TForm)
    img: TImage;
  private
    { Private declarations }
    Graphic: IGPGraphics;
    Pen: IGPPen;
    softPen: IGPPen;
    FontFamily: IGPFontFamily;
    gradFont: IGPFont;
    ColorBrush, BlackBrush: IGPBrush;

    bmp: TBitmap;
    AXIS_ANGLE: double;
    center: TGPPointF;
    CircleRect:TGPRectF;

    isRandom: boolean;

    axis: array of TLine;
    axisAngle: array of TaxisAngle;
    gradCircles: array of TGPrectF;
    gradPoints: array of array of TGPPointF;
    taskPoints: array of array of TGPPointF;

    tasks: TTasks;

    taskCount: integer;

    procedure createTasks();
    procedure createGradCircles();
    procedure createCircle(axisCount: integer);
    procedure initialize();
    procedure Render();
  public
    { Public declarations }
    procedure showDiagram();
    procedure refresh(useRandom: boolean);
  end;

implementation

uses uOGE;

{$R *.dfm}

const MAX_GRADUATION = 10;
      GRAD_AXIS_COUNT = 4;

      Colors: array [0..1] of cardinal = (TGPColor.Green, TGPColor.Orange);

{ TfrmTaskDiagram }

procedure TfrmTaskDiagram.createCircle(axisCount: integer);
var i, rect_width: integer;
    angle: double;
begin
    if axisCount = 0 then abort;

    rect_Width := bmp.height;

     CircleRect.X := (bmp.Width - RECT_WIDTH) / 2;
     CircleRect.Y  := ((bmp.Height - RECT_WIDTH) / 2) ;
     CircleRect.Width := RECT_WIDTH;
     CircleRect.Height := RECT_WIDTH;

                   // Центр круга
     center.X := (CircleRect.Left + CircleRect.Right) / 2;
     center.Y := (CircleRect.Top + CircleRect.Bottom) / 2;

     setLength(axis, axisCount);
     setLength(axisAngle, length(axis));
     AXIS_ANGLE := 360 div axisCount;

     axis[0].p1.x := center.X;
     axis[0].p1.y := center.Y;
     axis[0].p2.x := center.X;
     axis[0].p2.y := CircleRect.Top;
     axis[0].len  := lineLen(axis[0]);
     axisAngle[0] := 0;

     angle := AXIS_ANGLE;

     for i := 1 to high(axis) do
     begin
           axis[i] := rotateLine(angle, axis[0], center);
           axisAngle[i] := angle;
           angle := angle + AXIS_ANGLE;
     end;
end;

procedure TfrmTaskDiagram.createGradCircles;
var i,j: integer;
    w,r, angle, rad: double;
begin
     setLength(gradCircles, MAX_GRADUATION);
     setLength(gradPoints, GRAD_AXIS_COUNT, MAX_GRADUATION);
     setLength(taskPoints, length(axis), MAX_GRADUATION);

     w := CircleRect.Width;

     for i := 0 to MAX_GRADUATION - 1 do
     begin
          gradCircles[i].X := (bmp.Width - w) / 2;
          gradCircles[i].Y := (bmp.Height - w) / 2;
          gradCircles[i].Width := w;
          gradCircles[i].Height := w;

          angle := 90;
          for j := 0 to GRAD_AXIS_COUNT - 1 do
          begin
              r := w / 2;
              rad := angle * 2 * pi / 360;
              gradPoints[j, i].X := center.X + (r * cos(rad));
              gradPoints[j, i].Y := center.Y + (r * sin(rad));

              angle := angle + 90;
          end;

          angle := axis_angle;
          for j := 0 to length(axis) - 1 do
          begin
               r := w / 2;
               rad := angle * 2 * pi / 360;
               taskPoints[j, i].X := center.X + (r * cos(rad));
               taskPoints[j, i].Y := center.Y + (r * sin(rad));

               angle := angle + axis_angle;
          end;
          w := w - (CircleRect.Width / MAX_GRADUATION);
     end;
end;

procedure TfrmTaskDiagram.createTasks;
var i, j, k, offset: integer;
    points : array[0..2] of TGPPointF;
begin
     setLength(tasks, TASK_COUNT);

     offset := -4;

     for i := 0 to taskCount -  1 do
     begin
          if frmOGE.TaskTests.ResultMask[i] = true then
          begin
                tasks[i] := TGPGraphicsPath.Create();

                j := length(axis) + (i div MAX_GRADUATION) + offset;                // define axis; offset - Так как координаты начинаються с оси Х
                if j >= length(axis) then j := (i div MAX_GRADUATION) + offset;                // а нам нужно начинать с оси У то вводим смещение
                k := MAX_GRADUATION - 1 - (i mod MAX_GRADUATION);      // define task

                if (j + 1) < length(axis) then
                  tasks[i].AddArc(gradCircles[k], axisAngle[j + 1], axis_angle)
                else
                  tasks[i].AddArc(gradCircles[k], axisAngle[0], axis_angle);

                // if task between center and taskpoint
                // then make polygon
                if (k + 1) >= MAX_GRADUATION then
                begin
                     points[0] := center;
                     points[1] := taskPoints[j, k];
                     if (j + 1) < length(axis) then
                         points[2] := taskPoints[j + 1, k]
                     else
                         points[2] := taskPoints[0, k];
                     tasks[i].AddPolygon(points);
                end
                else begin
                    tasks[i].AddLine(taskPoints[j, k + 1], taskPoints[j, k]);

                    if (j + 1) < length(axis)then
                        tasks[i].AddLine(
                                taskPoints[j + 1, k + 1],
                                        taskPoints[j + 1, k])
                    else
                        tasks[i].AddLine(
                              taskPoints[0, k + 1],
                                    taskPoints[0, k])
                end;

                if ((k + 1) < MAX_GRADUATION) and
                    ((j + 1) <= length(axisAngle)) then
                        tasks[i].AddArc(gradCircles[k + 1],
                                    axisAngle[j + 1], axis_angle);
          end;
     end;
end;

procedure TfrmTaskDiagram.initialize;
begin
     taskCount := length(frmOGE.TaskTests.ResultMask);
     setLength(tasks, taskCount);
     createCircle(length(tasks) div MAX_GRADUATION);
     createGradCircles();
     createTasks();
end;

procedure TfrmTaskDiagram.Render;
var i, j, c: integer; rect: TGPRectF;
begin
  //  graphic.DrawEllipse(Pen, CircleRect);

    for i := 0 to length(tasks) - 1 do
    begin
        if odd(i div MAX_GRADUATION) then c := 0 else c := 1;
        if assigned(tasks[i]) then
        begin
            ColorBrush := TGPSolidBrush.Create(colors[c]);
            graphic.FillPath(ColorBrush, tasks[i]);
        end;
    end;

    for i := 0 to MAX_GRADUATION - 1 do
         graphic.DrawEllipse(softPen, gradCircles[i]);

    for j := 0 to MAX_GRADUATION - 1 do
    begin
         for i := 0 to GRAD_AXIS_COUNT - 1 do
         begin
              rect.X := gradPoints[i, j].X;
              rect.Y := gradPoints[i, j].Y;
              rect.Width := 15;
              rect.Height := 15;

              graphic.DrawString(intToStr(MAX_GRADUATION - j), gradFont, rect, nil, BlackBrush);
         end;
    end;

   for i := 0 to length(axis) - 1 do graphic.DrawLine(pen, axis[i].p1, axis[i].p2);

    img.Picture.Bitmap.Assign(bmp);
end;

procedure TfrmTaskDiagram.refresh(useRandom: boolean);
begin
    if Assigned(bmp) then freeAndNil(bmp);

    isRandom := useRandom;
    bmp := TBitMap.Create;
    bmp.Width := self.Width;
    bmp.Height := self.Height;

    Graphic := TGPGraphics.Create(bmp.Canvas.Handle);
    Graphic.SmoothingMode := SmoothingModeAntiAlias;
    Graphic.InterpolationMode := InterpolationModeHighQualityBicubic;
    Graphic.PixelOffsetMode := PixelOffsetModeHighQuality;
  //  Graphic.CompositingQuality := CompositingQualityHighQuality;
    Pen := TGPPen.Create(TGPColor.Black, 1.5);
    softPen := TGPPen.Create(TGPColor.Black, 1);
    FontFamily := TGPFontFamily.Create('Tahoma');
    gradFont := TGPFont.Create(FontFamily, 10, FontStyleRegular, UnitPixel);
    Graphic.TextRenderingHint := TextRenderingHintAntiAlias;
    BlackBrush := TGPSolidBrush.Create(TGPColor.Black);

    initialize();
    Render();
end;

procedure TfrmTaskDiagram.showDiagram();
begin
    show;
end;

end.
