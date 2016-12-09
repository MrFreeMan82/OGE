unit uUTTDiagram;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, uData, GdiPlus, GdiPlusHelpers;

type

  TaxisAngle = double;

  TTask = record
      pie: IGPGraphicsPath;
      taskNo: integer;
      labelRect: TGPRectF;
  end;

  TModule = record
      tasks: array of TTask;
      display_label: string;
      labelRect:TGPRectF;
      pie: IGPGraphicsPath;
      color: TGPColor;

      axis: array of TLine;
      axisAngle: array of TaxisAngle;
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
    SolidBrush: IGPBrush;
    ColorBrush: IGPBrush;
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
    procedure createCircle(axisCount: integer);
    procedure fillModuleList();
    procedure fillTasks(var module: TModule; i, taskNo:integer);
  public
    { Public declarations }
    procedure createNewBMP(useRandom: boolean);
    procedure showUTTDiagram();
  end;

implementation

uses uOGE;

{$R *.dfm}

const colors: array[0..2] of cardinal = (TGPColor.Green, TGPColor.Blue, TGPColor.Orange);

{ TfrmUTTDiagram }

procedure TfrmUTTDiagram.createCircle(axisCount: integer);
var i, rect_width, module_Rect_width: integer;
    angle: double;
begin
     if axisCount = 0 then abort;

     rect_Width := bmp.height;
     module_Rect_width := trunc(rect_width / 2.5);

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
var i, taskNo: integer;
begin
     taskNo := 1;
     for i := 0 to high(frmOGE.UTT.UTTTest.modules) do
     begin
           if not frmOGE.UTT.UTTTest.modules[i].visible then continue;

           modules[i].pie := TGPGraphicsPath.Create();
           modules[i].pie.AddPie(moduleRect, axisAngle[i], AXIS_ANGLE);
           modules[i].display_label := frmOGE.UTT.UTTTest.modules[i].lable;

           case frmOGE.UTT.UTTTest.modules[i].task_to of
             UTT_1_ALG_TASK_COUNT :
                                    begin
                                         setlength(modules[i].axis, UTT_1_ALG_TASK_COUNT);
                                         setLength(modules[i].axisAngle, UTT_1_ALG_TASK_COUNT);
                                         setlength(modules[i].tasks, UTT_1_ALG_TASK_COUNT);
                                         modules[i].color := colors[0];
                                    end;

             UTT_1_ALG_TASK_COUNT +
             UTT_1_GEO_TASK_COUNT:
                                    begin
                                        setLength(modules[i].axis, UTT_1_GEO_TASK_COUNT);
                                        setLength(modules[i].axisAngle, UTT_1_GEO_TASK_COUNT);
                                        setLength(modules[i].tasks, UTT_1_GEO_TASK_COUNT);
                                        modules[i].color := colors[1];
                                    end;

             UTT_1_ALG_TASK_COUNT +
             UTT_1_GEO_TASK_COUNT +
             UTT_1_REAL_MATH_TASK_COUNT:
                                       begin
                                            setLength(modules[i].axis, UTT_1_REAL_MATH_TASK_COUNT);
                                            setLength(modules[i].axisAngle, UTT_1_REAL_MATH_TASK_COUNT);
                                            setLength(modules[i].tasks, UTT_1_REAL_MATH_TASK_COUNT);
                                            modules[i].color := colors[2];
                                       end;
           end;
           fillTasks(modules[i], i, taskNo);
           inc(taskNo)
         //  break
     end;
end;

procedure TfrmUTTDiagram.fillTasks(var module: TModule; i, taskNo: integer);
var j: integer;
    angle, delta: double;
begin
    delta := AXIS_ANGLE / length(module.tasks);
    angle := axisAngle[i] +  delta;

    for j := 0 to length(module.tasks) -  1 do
    begin
         module.tasks[j].taskNo := taskNo;
         module.axis[j] := rotateLine(angle, axis[i], center);
         module.axisAngle[j] := angle;
         angle := angle + delta;

         if j = 2 then continue;      // if false answear
         module.tasks[j].pie := TGPGraphicsPath.Create();
         module.tasks[j].pie.AddPie(CircleRect, module.axisAngle[j] - delta, delta);
    end;
end;

procedure TfrmUTTDiagram.Render;
var i, j: integer;
begin
    graphic.DrawEllipse(Pen, CircleRect);

    for i := 0 to length(axis) - 1 do
    begin
         for j := 0 to length(modules[i].tasks) - 1 do
         begin
             if not assigned(modules[i].tasks[j].pie) then continue;

             ColorBrush := TGPSolidBrush.Create(modules[i].color);
             graphic.FillPath(ColorBrush, modules[i].tasks[j].pie);
            // graphic.DrawLine(Pen, modules[i].axis[j].p1, modules[i].axis[j].p2);
         end;
         ColorBrush := TGPSolidBrush.Create(TGPColor.White);
         graphic.FillPath(ColorBrush, modules[i].pie);
       //  break
    end;

    graphic.DrawEllipse(pen, moduleRect);

    for i := 0 to length(axis) - 1 do
      graphic.DrawLine(Boldpen, axis[i].p1, axis[i].p2);


    img.Picture.Bitmap.Assign(bmp);
end;

procedure TfrmUTTDiagram.createNewBMP(useRandom: boolean);
begin
    if Assigned(bmp) then freeAndNil(bmp);

    isRandom := useRandom;
    bmp := TBitMap.Create;
    bmp.Width := self.Width;
    bmp.Height := self.Height;

    Graphic := TGPGraphics.Create(bmp.Canvas.Handle);
    Graphic.SmoothingMode := SmoothingModeAntiAlias;
    Pen := TGPPen.Create(TGPColor.Black, 1);
    BoldPen := TGPPen.Create(TGPColor.Black, 3);
    FontFamily := TGPFontFamily.Create('Tahoma');
    Font := TGPFont.Create(FontFamily, 10, FontStyleRegular, UnitPoint);
    Graphic.TextRenderingHint := TextRenderingHintAntiAlias;
    SolidBrush := TGPSolidBrush.Create(TGPColor.Black);

    setLength(modules, frmOGE.UTT.VisibleModuleCount());
    createCircle(length(modules));
    fillModuleList();
  //  createScale();
  //  createResultList();
    Render();
end;

procedure TfrmUTTDiagram.showUTTDiagram;
begin
    show;
end;

end.
