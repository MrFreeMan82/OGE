unit uUTT;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Buttons, uGlobals, GdiPlus, GdiPlusHelpers;

type
  TUTTLevel = (lvlLow, lvlHigh);

  PUTTModule = ^TUTTModule;
  TUTTModule = record
       id:integer;
       level: TUTTLevel;
       lable: string;
       task_from, task_to: integer;
       visible: boolean;
       points: integer;
       color: TGPColor;
  end;

  TUTTModulesList = array of TUTTModule;

  TfrmUTT = class(TForm)
    rgVariants: TRadioGroup;
    Panel3: TPanel;
    Label2: TLabel;
    btAnswear: TSpeedButton;
    btResults: TSpeedButton;
    txtAnswer: TEdit;
    ScrollBox: TScrollBox;
    img: TImage;
    btPrevTask: TSpeedButton;
    btNextTask: TSpeedButton;
    procedure rgVariantsClick(Sender: TObject);
    procedure btNextTaskClick(Sender: TObject);
    procedure btPrevTaskClick(Sender: TObject);
    procedure txtAnswerKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure btAnswearClick(Sender: TObject);
    procedure btResultsClick(Sender: TObject);
    procedure FormMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
  private
    { Private declarations }
    mode: Tmode;
    fTask: integer;
    fUTTTest: TUTTModulesList;
    answears: TAnswears;
    taskResultMask: TResultMask;
    procedure loadTask(aVariant, aTask: integer);
    procedure AllTaskCompleate();
    procedure setPoints(pts: integer);
  public
    { Public declarations }
    property ResultMask: TResultMask read taskResultMask;
    procedure clearUserResults();
    procedure saveResults();
    property UTTTModuleList: TUTTModulesList read fUTTTest;
    procedure ShowUTT();
  end;

implementation
uses uOGE, uTestResult, ActiveX, uData;

{$R *.dfm}

{ TfrmUTT }

procedure TfrmUTT.AllTaskCompleate;
begin
     mode := mNormal;   // All tasks complete
     if messageBox(handle, PWideChar(
          'Поздравляем! Все задания варианта ' +
                intToStr(rgVariants.ItemIndex + 1) +
                        ' решены, Показать результаты?'),
                              'ОГЕ', MB_YESNO or MB_ICONINFORMATION) = mrYes then
     begin
         btResultsClick(self);
     end;
end;

procedure TfrmUTT.saveResults;
begin

end;

procedure TfrmUTT.setPoints(pts: integer);
var i: integer;
begin
    for i := 0 to length(fUTTTest) - 1 do
       if (fTask >= fUTTTest[i].task_from) and
                 (fTask <= fUTTTest[i].task_to) then
                   fUTTTest[i].points := fUTTTest[i].points + pts;
end;

procedure TfrmUTT.btAnswearClick(Sender: TObject);
var usrAnswear: double;
    TrueAnswear: boolean;
begin
     if (answears = nil) or
              not (fTask in [1..UTT_TASK_COUNT]) or
                    (trim(txtAnswer.Text) = '') then exit;

    usrAnswear := strToFloatEx(trim(txtAnswer.Text));

    trueAnswear := abs(usrAnswear - self.answears[fTask - 1]) < e;

    if trueAnswear then
    begin
         if taskResultMask[fTask - 1] = false then
         begin
              setPoints(1);
              taskResultMask[fTask - 1] := true;
         end
         else begin
                messageBox(self.Handle,
                   'Верно! Баллы за это задание уже были засчитаны.',
                                       'ОГЕ', MB_OK or MB_ICONINFORMATION);
         end;
         if fTask = UTT_TASK_COUNT then
         begin
             if getNextFalseTask(fTask,
                  taskResultMask, true) =
                      ALL_TASK_COMPLETE then
                            AllTaskCompleate()
                                else btResultsClick(self)
         end
         else btNextTaskClick(Sender);
    end
    else begin
         btNextTaskClick(Sender);
    end;
    txtAnswer.Text := '';
end;

procedure TfrmUTT.btNextTaskClick(Sender: TObject);
begin
    if mode = mReTest then
    begin
       fTask := getNextFalseTask(fTask, taskResultMask);
       if fTask = ALL_TASK_COMPLETE then
       begin
            AllTaskCompleate();
            exit;
       end;
    end
    else inc(fTask);

    if fTask > UTT_TASK_COUNT then fTask := UTT_TASK_COUNT;
    loadTask(rgVariants.ItemIndex + 1, fTask);
end;

procedure TfrmUTT.btPrevTaskClick(Sender: TObject);
begin
    if mode = mRetest then
    begin
         fTask := getPrevFalseTask(fTask, taskResultMask);
         if fTask = ALL_TASK_COMPLETE then
         begin
              AllTaskCompleate();
              exit
         end;
    end
    else dec(fTask);
    if fTask < 1 then fTask := 1;
    loadTask(rgVariants.ItemIndex + 1, fTask);
end;

procedure TfrmUTT.btResultsClick(Sender: TObject);
var mr: TmodalResult;
begin
    mr := TfrmTestResult.showUTTResults;
    case mr of
      mrYes: mode := mNormal;

      mrNo:
        begin
          // Перейдем в режим прохода теста заново
          // Найдем первый не пройденый тест
              mode := mReTest;
              ftask := getNextFalseTask(fTask, taskResultMask, true);

              if fTask = ALL_TASK_COMPLETE then
              begin
                  mode := mNormal;   // All tasks complete
                  exit
              end;
              loadTask(rgVariants.ItemIndex + 1, fTask);
        end;
    end;
end;

procedure TfrmUTT.loadTask(aVariant, aTask: integer);
var fileName, answearName: string;
    mem: TMemoryStream;
    adptr: IStream;
    gdiBmp: IGPBitmap;
    graphic: IGPGraphics;
    bmp: TBitmap;
    rect: TGPRectF;
begin
     img.Canvas.Brush.Color:=ClWhite;
     img.Canvas.FillRect(img.Canvas.ClipRect);

     ScrollBox.HorzScrollBar.Range := 0;
     ScrollBox.VertScrollBar.Range := 0;

     filename := format('%s/%d/%d.jpg', [UTT_DIR, aVariant, aTask]);

     mem := TMemoryStream.Create;
     bmp := TBitMap.Create;

     try
         if not FindData(dm.UTTDataFile, fileName, mem) then
         begin
              messageBox(self.Handle,
                  'По данному варианту тесты не загружены',
                               'Ошибка', MB_OK or MB_ICONERROR);
              abort;
         end;

         adptr  := TStreamAdapter.Create(mem);
         gdiBmp := TGPBitmap.Create(adptr);

         rect.InitializeFromLTRB(0, 0, gdiBMP.Width, gdiBmp.Height);

         bmp.Width := trunc(rect.Width);
         bmp.Height := trunc(rect.Height);

         graphic := TGPGraphics.Create(bmp.Canvas.Handle);
         graphic.InterpolationMode := InterpolationModeHighQualityBicubic;
         graphic.DrawImage(gdiBmp, rect);

         img.SetBounds(0, 0, bmp.Width, bmp.Height);
         img.Picture.Assign(bmp);

         ScrollBox.HorzScrollBar.Range := img.Picture.Width;
         ScrollBox.VertScrollBar.Range := img.Picture.Height;
     finally
         mem.Free;
         bmp.Free;
     end;

     if answears = nil then
     begin
        answearName := format('%s/answ.xml', [UTT_DIR]);
        answears := dm.loadAnswears(dm.UTTDataFile, answearName, aVariant);
     end;
end;

procedure TfrmUTT.clearUserResults;
var i: integer;
begin
     for i := 0 to UTT_TASK_COUNT - 1 do taskResultMask[i] := false;

     for i := 0 to length(fUTTTest) - 1 do fUTTTest[i].points := 0;
end;

procedure TfrmUTT.FormMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
    with scrollBox.VertScrollBar do
    begin
        if (wheelDelta < 0) and (position < range)
        then position := position + increment
        else if (position > 0) then position := position - increment
    end;
end;

procedure TfrmUTT.rgVariantsClick(Sender: TObject);
begin
     if rgVariants.ItemIndex < 0 then exit;
     answears := nil;
     setLength(taskResultMask, UTT_TASK_COUNT);
     clearUserResults();
   //  fiilMask();
     fTask := 1;
     loadTask(rgVariants.ItemIndex + 1, fTask);
end;

procedure TfrmUTT.ShowUTT;
begin
    mode := mNormal;
    fUTTTest := dm.loadUTTTests();
    if (fUTTTest = nil) then
    begin
      messageBox(self.Handle, 'Не удалось загузить тесты', 'Ошибка', MB_OK or MB_ICONERROR);
      abort;
    end;

    show;
end;

procedure TfrmUTT.txtAnswerKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
    if key = VK_RETURN then btAnswearClick(Sender);
end;

end.
