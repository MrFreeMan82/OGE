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
      result: boolean;
  end;

  TDecade = record
      rect: TGPRectF;
      result: boolean;
  end;

  TDecadeList = array of TDecade;

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
    header1Font, header2Font: IGPFont;
    header1Align, header2Align: IGPStringFormat;
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
    header1, header2: TGPRectF;
    center: TGPPointF;
    delta: double;
    decadeStage1, decadeStage2: TDecadeList;

    procedure header();
    procedure createNote();
    procedure createStages();
    procedure createGradLines();
    procedure createTimeLine();
    procedure createMainRect();
    procedure createDacadesStage1();
    procedure createDacadesStage2();
    procedure initialize();
    procedure render();
    { Private declarations }
  public
    { Public declarations }
    procedure refreshWorkPlan();
    procedure ShowWorkPlan();
    function Stage1Result(us_id: integer): boolean;
    function Stage2Result(us_id: integer): boolean;
  end;

implementation

uses uOGE, dateUtils, uTopicModel;

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
              HEADER1STR = 'План работы по подготовке учащихся к ОГЭ';
              HEADER2STR = 'Линия времени';


procedure TfrmWorkPlan.createDacadesStage1();
var i,j,k: integer;
    sections: TSectionList;
    over80: boolean;
    expire: TDate;
    y,m,d: Word;
begin
     k := 0;

     for i := 0 to frmOGE.Tasks.TaskList.Count - 1 do
     begin
          if TTOpic(frmOGE.CollectiveTasks.
              TaskList.Items[i]).ID = COLLECTIVE_TASK_ID then continue;

          sections := TTopic(frmOGE.Tasks.TaskList.Items[i]).sections;

          for j := 0 to length(sections) - 1 do
          begin
              over80 := frmOGE.Tasks.OverPercBySection(@sections[j], 80);

               y := YearOf(Date);
               m := MonthOf(sections[j].expire);
               d := DayOf(sections[j].expire);

               expire := EncodeDate(y, m, d);

               if (k >= 0) and (k < length(decadeStage1)) then
                    decadeStage1[k].result := over80 and (Date <= expire);
               inc(k);
          end;
     end;
end;

procedure TfrmWorkPlan.createDacadesStage2;
var i,j,k, dl: integer;
    sections: TSectionList;
    over, over80: boolean;
    expire: TDate;
    y,m,d: Word;
begin
     for i := 0 to frmOGE.CollectiveTasks.TaskList.Count - 1 do
     begin
          if TTOpic(frmOGE.CollectiveTasks.
              TaskList.Items[i]).ID <> COLLECTIVE_TASK_ID then continue;

          sections := TTopic(frmOGE.CollectiveTasks.TaskList.Items[i]).sections;

          for j := 0 to length(sections) - 1 do
          begin
              dl := 1; over80 := false;
              for k := 1 to length(decadeStage2) - 1 do
              begin
                   over := frmOGE.CollectiveTasks.OverPercBySection(@sections[j], 20 * dl);

                   if (dl = 4) and over then over80 := true;
                   if over80 then over := true;

                   y := YearOf(Date);
                   m := MonthOf(sections[j].expire);
                   d := DayOf(sections[j].expire);
                   if MonthOf(Date) in [9..12] then inc(y);

                   expire := EncodeDate(y, m, d);

                   if (k >= 0) and (k < length(decadeStage2)) then
                        decadeStage2[k].result := over and (Date <= expire);

                   inc(dl);
              end;
          end;
     end;
end;

function TfrmWorkPlan.Stage1Result(us_id: integer): boolean;
var y,m,d: Word;
    expire: TDate;
begin
    y := YearOf(Date);
    m := 12;
    d := 31;
    expire := EncodeDate(y, m, d);

    result := frmOGE.Tasks.Over80(us_id) and (Date <= expire);
end;

function TfrmWorkPlan.Stage2Result(us_id: integer): boolean;
var y,m,d: Word;
    expire: TDate;
begin
    y := YearOf(Date);
    if MonthOf(Date) in [9..12] then inc(y);
    m := 2;
    d := 28;
    expire := EncodeDate(y, m, d);

    result := frmOGE.CollectiveTasks.Over80(us_id) and (Date <= expire);
end;

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

     if Stage1Result(frmOGE.User.id) then
          stageList[0].resultLabel := 'РЕЗУЛЬТАТ: ' + ZACHET
     else
          stageList[0].resultLabel := 'РЕЗУЛЬТАТ: ' + NOT_ZACHET;

     if Stage2Result(frmOGE.User.id) then
         stageList[1].resultLabel := 'РЕЗУЛЬТАТ: ' + ZACHET
     else
         stageList[1].resultLabel := 'РЕЗУЛЬТАТ: ' + NOT_ZACHET;

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
var i,j, k:integer;
    scaleWidth, x, y: double;
    cp: TGPPointF;
    ln: TLine;
begin
    setLength(decadeStage1, 12);
    setLength(decadeStage2, 6);

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

    k := 0;
    for i := 1 to length(timeLabels) - 1 do
    begin
        x := timeLabels[i].rect.X; y := timeLabels[i].rect.Y - 40;
        for j := 0 to 2 do
        begin
            if k >= length(decadeStage1) then break;

            decadeStage1[k].result := false;
            decadeStage1[k].rect.X := x;
            decadeStage1[k].rect.Y := y;
            decadeStage1[k].rect.Width := delta / 3;
            decadeStage1[k].rect.Height := 30;

            x := x + (delta / 3);
            inc(k);
        end;
    end;

    k := 0;
    for i := 5 to length(timeLabels) - 1 do
    begin
        x := timeLabels[i].rect.X; y := timeLabels[i].rect.Y - 40;
        for j := 0 to 2 do
        begin
            if k >= length(decadeStage1) then break;

            decadeStage2[k].result := false;
            decadeStage2[k].rect.X := x;
            decadeStage2[k].rect.Y := y;
            decadeStage2[k].rect.Width := delta / 3;
            decadeStage2[k].rect.Height := 30;

            x := x + (delta / 3);
            inc(k);
        end;
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

procedure TfrmWorkPlan.header;
begin
     header1.X := 0;
     header1.Y := 0;
     header1.Width := mainrect.Width;
     header1.Height := mainrect.Height / 10;

     header2.X := 0;
     header2.Y := header1.Height;
     header2.Width := mainrect.Width;
     header2.Height := header1.Height;
end;

procedure TfrmWorkPlan.initialize;
begin
    createMainRect();
    createTimeLine();
    createGradLines();
    createStages();
    createNote();
    header();
  //  createDacadesStage1;
  //  createDacadesStage2;
end;

procedure TfrmWorkPlan.refreshWorkPlan;
begin
    if Assigned(bmp) then freeAndNil(bmp);

    bmp := TBitMap.Create;
    bmp.Width :=  self.Width;
    bmp.Height := self.Height;

    Graphic := TGPGraphics.Create(bmp.Canvas.Handle);
    Graphic.SmoothingMode := SmoothingModeAntiAlias;
    Graphic.InterpolationMode := InterpolationModeHighQualityBicubic;
    Graphic.PixelOffsetMode := PixelOffsetModeHighQuality;
  //  Graphic.CompositingQuality := CompositingQualityHighQuality;

    Pen := TGPPen.Create(TGPColor.Black, 5);
    softPen := TGPPen.Create(TGPColor.Black, 1);

    FontFamily := TGPFontFamily.Create('Tahoma');

    header1Font := TGPFont.Create(FontFamily, 12, FontStyleRegular, UnitPoint);
    header1Align := TGPStringFormat.Create;
    header1Align.Alignment := StringAlignmentCenter;

    header2Font := TGPFont.Create(FontFamily, 20, FontStyleRegular, UnitPoint);
    header2Align := TGPStringFormat.Create;
    header2Align.Alignment := StringAlignmentCenter;

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
   ColorPen: IGPPen;
   RedBrush, GreenBrush: IGPBrush;
begin
    graphic.DrawString(HEADER1STR, header1Font, header1, header1Align, BlackBrush);
    graphic.DrawString(HEADER2STR, header2Font, header2, header2Align, BlackBrush);

    ColorPen := TGPPen.Create(TGPColor.Turquoise, 5);
    RedBrush := TGPSolidBrush.Create(TGPColor.Red);
    GreenBrush := TGPSolidBrush.Create(TGPColor.Green);

    graphic.DrawLine(ColorPen, timeLine.p1, timeLine.p2);

    for i := 1 to length(timeGrad) - 1 do
         graphic.DrawLine(ColorPen, timeGrad[i].p1, timeGrad[i].p2);


    for i := 0 to length(stageList) - 1 do
    begin
        graphic.DrawString(stageList[i].displayLabel,
              stageLabelFont, stageList[i].rect, nil, BlackBrush);

        graphic.DrawLine(ColorPen,
              TGPPointF.Create(stageList[i].rect.Right + 2, stageList[i].rect.Top),
                 TGPPointF.Create(stageList[i].rect.Right + 2, stageList[i].rect.Bottom));

       graphic.DrawString(stageList[i].resultLabel, resultFont,
                       stageList[i].resultRect, resultAlign, BlackBrush);

      // graphic.DrawRectangle(pen, stageList[i].resultRect);
    end;

    for i := 1 to length(timeLabels) - 1 do
             graphic.DrawString(timeLabels[i].displayLabel,
                    gradFont, timeLabels[i].rect, gradFontAlign, BlackBrush);

  {  d := 1;
    for i := 0 to length(decadeStage1) - 1 do
    begin
          if decadeStage1[i].result = false then
              graphic.DrawString(intToStr(d),
                      gradFont, decadeStage1[i].rect, gradFontAlign, RedBrush)
          else
              graphic.DrawString(intToStr(d),
                      gradFont, decadeStage1[i].rect, gradFontAlign, GreenBrush);

          inc(d);
          if d > 3 then d := 1;
    end;

    d := 1;
    for i := 0 to length(decadeStage2) - 1 do
    begin
          if decadeStage2[i].result = false then
              graphic.DrawString(intToStr(d),
                      gradFont, decadeStage2[i].rect, gradFontAlign, RedBrush)
          else
              graphic.DrawString(intToStr(d),
                      gradFont, decadeStage2[i].rect, gradFontAlign, GreenBrush);

          inc(d);
          if d > 3 then d := 1;
    end; }

     graphic.DrawString(NOTE, noteFont, noteRect, nil, BlackBrush);

    img.Picture.Assign(bmp);
end;

procedure TfrmWorkPlan.ShowWorkPlan;
begin
  //  refreshWorkPlan;
    show;
end;

procedure TfrmWorkPlan.btRefreshWorkPlanClick(Sender: TObject);
begin
    refreshWorkPlan
end;

end.
