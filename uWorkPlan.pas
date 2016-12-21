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
    gradFont, stageLabelFont, noteFont, resultFont: IGPFont;
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
    noteRect: TGPRectF;
    center: TGPPointF;
    delta: double;

    procedure createNote();
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

resourcestring STAGE1 = 'Этап 1. Задания для самостоятельного выполнения';
               STAGE2 = 'Этап 2. Совместная работа';
               STAGE3 = 'Этап 3. Тренировочные варианты КИМов';
               NOTE   = 'Первый этап содержит тренировочные задания по всем темам курса математики 5-9 классов. Всего заданий 1440. '#13#10 +
                        'Второй этап  содержит текстовые задачи на числа и движение. Всего заданий 120. '#13#10 +
                        'Этапы программы необходимо выполнить в правильном порядке.'#13#10 +
                        'Оценка результатов выполнения заданий первого и второго этапа осуществляется по двухбалльной шкале: «зачтено» — «не зачтено».'#13#10 +
                        'Оценка «зачтено»  ставится, если ученик  верно выполнил не менее 80% заданий  в течение определенного промежутка времени. В противном случае выставляется оценка «не зачтено».';

procedure TfrmWorkPlan.createStages;
var len, len2, k: double;
    i: integer;
begin
     stageList[0].displayLabel := STAGE1;
     stageList[1].displayLabel := STAGE2;
     stageList[2].displayLabel := STAGE3;

     stageList[0].period := 5;
     stageList[1].period := 2;
     stageList[2].period := 3;

     stageList[0].resultLabel := 'РЕЗУЛЬТАТ: не зачтено';
     stageList[1].resultLabel := 'РЕЗУЛЬТАТ: не зачтено';

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
     stageList[0].resultRect.Height := len2 / 2;

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
           stageList[i].resultRect.Height := len2 / 2;
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

procedure TfrmWorkPlan.createNote;
begin
     noteRect.X := 5;
     noteRect.Y := bmp.Height - 150;
     noteRect.Width := mainRect.Width ;
     noteRect.Height := bmp.Height - noteRect.Y;
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
    createNote();
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

    noteFont := TGPFont.Create(FontFamily, 10, FontStyleRegular, UnitPoint);
    resultFont := TGPFont.Create(FontFamily, 12, FontStyleRegular, UnitPoint);

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

       graphic.DrawString(stageList[i].resultLabel, resultFont,
                       stageList[i].resultRect, resultAlign, BlackBrush);

      // graphic.DrawRectangle(pen, stageList[i].resultRect);
    end;

    for i := 1 to length(timeLabels) - 1 do
             graphic.DrawString(timeLabels[i].displayLabel,
                    gradFont, timeLabels[i].rect, gradFontAlign, BlackBrush);

     graphic.DrawString(NOTE, noteFont, noteRect, nil, BlackBrush);

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
