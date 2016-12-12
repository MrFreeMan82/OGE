unit uUTTDiagram;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, uGlobals, GdiPlus, GdiPlusHelpers;

type

  TaxisAngle = double;

  TTask = record
      pie: IGPGraphicsPath;
      taskNo: integer;
      labelRect: TGPRectF;
      compleate: boolean;
  end;

  TModule = record
      id: integer;
      tasks: array of TTask;
      display_label: string;
      labelRect:TGPRectF;
      pie: IGPGraphicsPath;
      color: TGPColor;
      axisLable: string;
      axisLabelRect: TGPRectF;
      taskAxis: array of TLine;
      taskAxisAngle: array of TaxisAngle;
  end;

  TModuleList = array of TModule;

  TfrmUTTDiagram = class(TForm)
    img: TImage;
  private
    Graphic: IGPGraphics;
    Pen: IGPPen;
    BoldPen: IGPPen;
    FontFamily: IGPFontFamily;
    Font: IGPFont;
    TaskNoFont: IGPFont;
    pointsFont: IGPFont;
    WhiteBrush, ColorBrush, BlackBrush: IGPBrush;
    bmp: TBitmap;

    AXIS_ANGLE: double;
    center: TGPPointF;
   // centerX, centerY: double;
    CircleRect:TGPRectF;
    ModuleRect: TGPRectF;
    axis: array of TLine;
    axisAngle: array of TaxisAngle;

    modules:TModuleList;

    isRandom: boolean;
    procedure Render();
    procedure initModules();
    procedure createCircle(axisCount: integer);
    procedure fillModuleList();
    procedure fillTasks(var module: TModule; i, taskNo:integer);
  public
    { Public declarations }
    procedure refresh(useRandom: boolean);
    procedure showUTTDiagram();
  end;

implementation

uses uOGE, math, uData;

{$R *.dfm}

{ TfrmUTTDiagram }

procedure TfrmUTTDiagram.createCircle(axisCount: integer);
var i, rect_width, module_Rect_width: integer;
    angle: double;
begin
     if axisCount = 0 then abort;

     rect_Width := bmp.height - 50;
     module_Rect_width := trunc(rect_width / 30);

     CircleRect.X := (bmp.Width - RECT_WIDTH) / 2;
     CircleRect.Y  := ((bmp.Height - RECT_WIDTH) / 2) ;
     CircleRect.Width := RECT_WIDTH;
     CircleRect.Height := RECT_WIDTH;

     ModuleRect.X := (bmp.Width - module_Rect_width) / 2;
     ModuleRect.Y := ((bmp.Height - module_Rect_width) / 2) ;
     ModuleRect.Width := module_Rect_width;
     ModuleRect.Height := module_Rect_width;

                   // Центр круга
     center.X := (CircleRect.Left + CircleRect.Right) / 2;
     center.Y := (CircleRect.Top + CircleRect.Bottom) / 2;

     setLength(axis, axisCount);
     setLength(axisAngle, length(axis));
     AXIS_ANGLE := 360 div length(axis);

     axis[0].p1.x := center.X;
     axis[0].p1.y := center.Y;
     axis[0].p2.x := CircleRect.Right;
     axis[0].p2.y := (CircleRect.Top + CircleRect.Bottom) / 2;
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


procedure TfrmUTTDiagram.fillModuleList;
var i,j, cnt: integer;
    txtW, txtH, angle, r :double;
    s : string;
begin
     j := 0;
     for i := 0 to high(frmOGE.UTT.UTTTest.modules) do
     begin
           if not frmOGE.UTT.UTTTest.modules[i].visible then continue;

           modules[j].id := frmOGE.UTT.UTTTest.modules[i].id;
           modules[j].color := frmOGE.UTT.UTTTest.modules[i].color;

           cnt := frmOGE.UTT.UTTTest.modules[i].task_to -
                   frmOGE.UTT.UTTTest.modules[i].task_from + 1;

           setlength(modules[j].taskAxis, cnt);
           setLength(modules[j].taskAxisAngle, cnt);
           setlength(modules[j].tasks, cnt);

           fillTasks(modules[j], j, frmOGE.UTT.UTTTest.modules[i].task_from);

           modules[j].pie := TGPGraphicsPath.Create();
           modules[j].pie.AddPie(moduleRect, axisAngle[j], AXIS_ANGLE);

           s := format('%s - %f', [frmOGE.UTT.UTTTest.modules[i].lable,
                                      frmOGE.UTT.UTTTest.modules[i].points]);
           modules[j].display_label :=  s;
           MeasureDisplayStringWidthAndHeight(Graphic, Font, modules[j].display_label, txtW, txtH);

           txtH := txtH * 2;
           txtW := txtW + 10;

           angle := axisAngle[i] + (AXIS_ANGLE / 2);
           angle := angle * 2 * pi  / 360;
           r := (CircleRect.Width / 2);
           modules[j].labelRect.X := center.X + (r * cos(angle));
           modules[j].labelRect.Y := center.Y + (r * sin(angle));

           modules[j].labelRect.Width := txtW;
           modules[j].labelRect.Height := txtH;

           angle := angle * 360 / pi / 2;
           if (angle >= 90) and (angle <= 270) then
           begin
                modules[j].labelRect.X := modules[j].labelRect.X - txtW;
                if (modules[j].labelRect.X <= 0) then
                begin
                     modules[j].labelRect.Width :=
                          modules[j].labelRect.Width +
                                      modules[j].labelRect.X;

                     modules[j].labelRect.X := 5;
                end;

                modules[j].axisLabelRect.X := axis[j].p2.X -
                                    modules[j].axisLabelRect.Width;
           end
           else if (angle > 270) and (angle <= 360)then
           begin
                modules[j].labelRect.Y := modules[j].labelRect.Y - (txtH / 2)
           end;

           r := (CircleRect.Width / 2) + 15;
           angle := axisAngle[j] * 2 * pi / 360;
           modules[j].axisLabelRect.X := (center.X - 10) + (r * cos(angle));
           modules[j].axisLabelRect.Y := (center.Y - 10) + (r * sin(angle));

           modules[j].axisLable := '1';
           modules[j].axisLabelRect.Width := 20;
           modules[j].axisLabelRect.Height := 20;

           inc(j);
          // break
     end;
end;

procedure TfrmUTTDiagram.fillTasks(var module: TModule; i, taskNo: integer);
var j: integer;
    angle, angle2, delta, txtW, txtH, r: double;
begin
    delta := AXIS_ANGLE / length(module.tasks);
    angle := axisAngle[i] +  delta;

    for j := 0 to length(module.tasks) -  1 do
    begin
         module.tasks[j].taskNo := taskNo;
         module.taskAxis[j] := rotateLine(angle, axis[i], center);
         module.taskAxisAngle[j] := angle;
         angle := angle + delta;

         module.tasks[j].pie := TGPGraphicsPath.Create();
         module.tasks[j].pie.AddPie(CircleRect, module.taskAxisAngle[j] - delta, delta);

         MeasureDisplayStringWidthAndHeight(Graphic, Font, intToStr(module.tasks[j].taskNo), txtW, txtH);

         angle2 := module.taskAxisAngle[j] - (delta / 2);
         r := (CircleRect.Width / 2) - 20;
         angle2 := angle2 * 2 * pi / 360;
         module.tasks[j].labelRect.X := (center.X - 5) + (r * cos(angle2));
         module.tasks[j].labelRect.Y := (center.Y - 5) + (r * sin(angle2));

         module.tasks[j].labelRect.Width := txtW;
         module.tasks[j].labelRect.Height := txtH;
         inc(taskNo);
    end;
end;

procedure TfrmUTTDiagram.Render;
var i, j, taskNo: integer;
begin
    graphic.DrawEllipse(Pen, CircleRect);

    for i := 0 to length(axis) - 1 do
    begin
         for j := 0 to length(modules[i].tasks) - 1 do
         begin
             taskNo := modules[i].tasks[j].taskNo;

             if frmOGE.UTT.UTTTest.taskResultMask[taskNo - 1] then
             begin
                  ColorBrush := TGPSolidBrush.Create(modules[i].color);
                  graphic.FillPath(ColorBrush, modules[i].tasks[j].pie);
             end;
             graphic.DrawPath(pen, modules[i].tasks[j].pie);

             graphic.DrawString(intToStr(taskNo), taskNoFont, modules[i].tasks[j].labelRect, nil, BlackBrush);
         end;
        // graphic.FillPath(WhiteBrush, modules[i].pie);

         graphic.DrawString(modules[i].display_label, font, modules[i].labelRect, nil, BlackBrush);
         ColorBrush := TGPSolidBrush.Create(TGPColor.Red);
         graphic.DrawString(modules[i].axisLable, pointsFont, modules[i].axisLabelRect, nil, ColorBrush);
    end;

    for i := 0 to length(axis) - 1 do
      graphic.DrawLine(Boldpen, axis[i].p1, axis[i].p2);

//    graphic.FillEllipse(WhiteBrush, moduleRect);
  //  graphic.DrawEllipse(pen, moduleRect);


    img.Picture.Bitmap.Assign(bmp);
end;

procedure TfrmUTTDiagram.initModules;
begin
    setLength(modules, frmOGE.UTT.VisibleModuleCount());
    createCircle(length(modules));
    fillModuleList();
end;

procedure TfrmUTTDiagram.refresh(useRandom: boolean);
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
    Pen := TGPPen.Create(TGPColor.Black, 1);
    BoldPen := TGPPen.Create(TGPColor.Black, 3);
    FontFamily := TGPFontFamily.Create('Tahoma');
    Font := TGPFont.Create(FontFamily, 14, FontStyleRegular, UnitPixel);
    pointsFont := TGPFont.Create(FontFamily, 16, FontStyleRegular, UnitPixel);
    TaskNoFont := TGPFont.Create(FontFamily, 10, FontStyleRegular, UnitPixel);
    Graphic.TextRenderingHint := TextRenderingHintAntiAlias;
    WhiteBrush := TGPSolidBrush.Create(TGPColor.White);
    BlackBrush := TGPSolidBrush.Create(TGPColor.Black);

    initModules();
    Render();
end;

procedure TfrmUTTDiagram.showUTTDiagram;
begin
    show;
end;

end.
