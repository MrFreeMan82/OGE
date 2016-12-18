unit uWorkPlan;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, Grids, GdiPlus, GdiPlusHelpers, uGlobals, Buttons, ToolWin,
  ComCtrls;

type
  TTimeLabel = record
      displayLabel: string;
      rect: TGPRectF;
  end;

  TStage = record
      period: integer;
      displayLabel, resultLabel: string;
      rect: TGPRectF;
      resultRect: TGPRectF;
      passPercent: double;
      result: double;
  end;

  TfrmWorkPlan = class(TForm)
    img: TImage;
    ToolBar1: TToolBar;
    btRefreshWorkPlan: TSpeedButton;
    ToolButton1: TToolButton;
    procedure btRefreshWorkPlanClick(Sender: TObject);
  private
    Graphic: IGPGraphics;
    Pen: IGPPen;
    softPen: IGPPen;

    FontFamily: IGPFontFamily;
    gradFont, stageLabelFont: IGPFont;
    gradFontAlign: IGPStringFormat;
    resultAlign: IGPStringFormat;
    BlackBrush: IGPBrush;

    bmp: TBitmap;
    mainRect: TGPRectF;
    mainRectLeftLine: TLine;
    timeLine: TLine;
    timeGrad: array of TLine;
    timeLabels: array of TTimeLabel;
    stageList: array[0..2] of TStage;
    center: TGPPointF;
    delta: double;

    procedure createStages();
    procedure createGradLines();
    procedure createTimeLine();
    procedure createMainRect();
    procedure initialize();
    procedure render();
    { Private declarations }
  public
    { Public declarations }
    procedure refreshWorkPlan();
    procedure ShowWorkPlan();
  end;

implementation

{$R *.dfm}

{ TfrmWorkPlan }

const
      MAX_TIMELINE_GRAD = 11;
      months: array[0..MAX_TIMELINE_GRAD - 1] of string =
            ('', 'Сентябрь', 'Октябрь', 'Ноябрь','Декабрь', 'Январь', 'Февраль', 'Март', 'Апрель', 'Май', '');



procedure TfrmWorkPlan.createStages;
var len, len2, k: double;
    i: integer;
begin
     stageList[0].displayLabel := 'Этап 1. Задания для самостоятельного выполнения';
     stageList[1].displayLabel := 'Этап 2. Задания для коллективного выполнения';
     stageList[2].displayLabel := 'Этап 3. Тренировочные варианты КИМов';

     stageList[0].period := 5;
     stageList[1].period := 2;
     stageList[2].period := 3;

     stageList[0].resultLabel := format('%s%f', ['РЕЗУЛЬТАТ: ', stageList[0].result]);
     stageList[1].resultLabel := format('%s%f', ['РЕЗУЛЬТАТ: ', stageList[1].result]);

     len := lineLen(mainRectLeftLine);
     len2 := len / 3;
     k := len2 / len;

     stageList[0].rect.X := center.X + (mainRectLeftLine.p2.X - center.X) * k;
     stageList[0].rect.Y := center.Y + (mainRectLeftLine.p2.Y - center.Y) * k;
     stageList[0].rect.Width := (delta * stageList[0].period);
     stageList[0].rect.Height := len2;

     stageList[0].resultRect.X := timeline.p1.X;
     stageList[0].resultRect.Y := timeLine.p1.Y;
     stageList[0].resultRect.Width := stageList[0].rect.Width;
     stageList[0].resultRect.Height := len2;

     for i := 1 to length(stageList) - 1 do
     begin
           stageList[i].rect.X := stageList[i - 1].rect.Right + 5;
           stageList[i].rect.Y := stageList[i - 1].rect.Y;
           stageList[i].rect.Width := (delta * stageList[i].period) - 5;
           stageList[i].rect.Height := len2;

           if i = length(stageList) - 1 then continue;
           stageList[i].resultRect.X := stageList[i - 1].resultRect.Right;
           stageList[i].resultRect.Y := stageList[i - 1].resultRect.Top;
           stageList[i].resultRect.Width := stageList[i].rect.Width;
           stageList[i].resultRect.Height := len2;
     end;
end;

procedure TfrmWorkPlan.createGradLines;
var i:integer;
    scaleWidth: double;
    cp: TGPPointF;
    ln: TLine;
begin
    setLength(timeGrad, MAX_TIMELINE_GRAD);
    setLength(timeLabels, MAX_TIMELINE_GRAD);

    delta := lineLen(timeLine) / MAX_TIMELINE_GRAD;
    scaleWidth := 30;

    cp := timeLine.p1;

    for i := 1 to length(timeGrad) - 1 do
    begin
        ln.p1.X := cp.X + (scaleWidth / 2);
        ln.p1.Y := cp.Y - delta * i;
        ln.p2.X := cp.X - (scaleWidth / 2);
        ln.p2.Y := cp.Y - delta * i;

        timeGrad[i] := rotateLine(90, ln, cp);

        timeLabels[i].displayLabel := months[i];
        timeLabels[i].rect.X := timeGrad[i].p1.X;
        timeLabels[i].rect.Y := timeGrad[i].p1.Y;
        timeLabels[i].rect.Width := delta;
        timeLabels[i].rect.Height := 30;
    end;

end;

procedure TfrmWorkPlan.createMainRect;
var ml, mr: integer;
begin
    ml := 5; mr := 5;
    center.X := 0;
    center.Y := 0;

    mainRect.X := center.X + ml;
    mainrect.Y := center.Y;
    mainRect.Width := bmp.Width - mr;
    mainRect.Height := bmp.Height;
end;

procedure TfrmWorkPlan.createTimeLine;
var len, len2, k: double;
begin
    mainRectLeftLine.p1.X := mainRect.X;
    mainRectLeftLine.p1.Y := mainRect.Y;
    mainRectLeftLine.p2.X := mainRect.X;
    mainRectLeftLine.p2.Y := mainRect.Height;

    len := lineLen(mainRectLeftLine);
    len2 := len / 1.5;
    k := len2 / len;

    timeLine.p1.X := center.X + (mainRectLeftLine.p2.X - center.X) * k;
    timeLine.p1.Y := center.Y + (mainRectLeftLine.p2.Y - center.Y) * k;
    timeLine.p2.X := timeLine.p1.X + mainRect.Width;
    timeLine.p2.Y := timeLine.p1.Y;
end;

procedure TfrmWorkPlan.initialize;
begin
    createMainRect();
    createTimeLine();
    createGradLines();
    createStages();
end;

procedure TfrmWorkPlan.refreshWorkPlan;
begin
    if Assigned(bmp) then freeAndNil(bmp);

    bmp := TBitMap.Create;
    bmp.Width := self.Width;
    bmp.Height := self.Height;

    Graphic := TGPGraphics.Create(bmp.Canvas.Handle);
    Graphic.SmoothingMode := SmoothingModeAntiAlias;
    Graphic.InterpolationMode := InterpolationModeHighQualityBicubic;
    Graphic.PixelOffsetMode := PixelOffsetModeHighQuality;
  //  Graphic.CompositingQuality := CompositingQualityHighQuality;

    Pen := TGPPen.Create(TGPColor.Black, 5);
    softPen := TGPPen.Create(TGPColor.Black, 1);

    FontFamily := TGPFontFamily.Create('Tahoma');
    gradFont := TGPFont.Create(FontFamily, 14, FontStyleRegular, UnitPoint);
    gradFontAlign := TGPStringFormat.Create;
    gradFontAlign.Alignment := StringAlignmentCenter;

    resultAlign := TGPStringFormat.Create;
    resultAlign.LineAlignment := StringAlignmentCenter;

    stageLabelFont := TGPFont.Create(FontFamily, 16, FontStyleRegular, UnitPoint);

    Graphic.TextRenderingHint := TextRenderingHintAntiAlias;
    BlackBrush := TGPSolidBrush.Create(TGPColor.Black);

    initialize();
    render();
end;

procedure TfrmWorkPlan.render;
var i: integer;
begin
  //  graphic.DrawRectangle(softPen, mainRect);

    graphic.DrawLine(pen, timeLine.p1, timeLine.p2);

    for i := 1 to length(timeGrad) - 1 do
         graphic.DrawLine(pen, timeGrad[i].p1, timeGrad[i].p2);


    for i := 0 to length(stageList) - 1 do
    begin
        graphic.DrawString(stageList[i].displayLabel,
              stageLabelFont, stageList[i].rect, nil, BlackBrush);

        graphic.DrawLine(pen,
              TGPPointF.Create(stageList[i].rect.Right + 2, stageList[i].rect.Top),
                 TGPPointF.Create(stageList[i].rect.Right + 2, stageList[i].rect.Bottom));

       graphic.DrawString(stageList[i].resultLabel, stageLabelFont,
                       stageList[i].resultRect, resultAlign, BlackBrush);
    end;

    for i := 1 to length(timeLabels) - 1 do
             graphic.DrawString(timeLabels[i].displayLabel,
                    gradFont, timeLabels[i].rect, gradFontAlign, BlackBrush);

    img.Picture.Assign(bmp);
end;

procedure TfrmWorkPlan.ShowWorkPlan;
begin
    show;
end;

procedure TfrmWorkPlan.btRefreshWorkPlanClick(Sender: TObject);
begin
    refreshWorkPlan
end;

end.
