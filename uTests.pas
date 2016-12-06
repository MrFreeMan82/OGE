unit uTests;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, uData, OleCtrls, SHDocVw, Menus,
  Buttons;

type
  TMode = (mNormal, mReTest);

  TfrmTests = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    txtAnswer: TEdit;
    Panel3: TPanel;
    cboTopics: TComboBox;
    rgVariants: TRadioGroup;
    btAnswear: TSpeedButton;
    btResults: TSpeedButton;
    img: TImage;
    btPrevTask: TSpeedButton;
    btNextTask: TSpeedButton;
    ScrollBox: TScrollBox;
    procedure rgVariantsClick(Sender: TObject);
    procedure btNextTaskClick(Sender: TObject);
    procedure btPrevTaskClick(Sender: TObject);
    procedure cboTopicsChange(Sender: TObject);
    procedure btAnswearClick(Sender: TObject);
    procedure btResultsClick(Sender: TObject);
    procedure FormMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
  private
    { Private declarations }
     mode: Tmode;
     fTask: integer;
     fTests: TTestList;
     currentTest: PTestInfo;
     answears: TAnswears;
   //  usrResults: TUserResultList;  // Результаты по данной теме
     procedure clear;
     procedure loadTest(test:TTestInfo; testVariant, taskNo: integer);
     function getNextFalseTask(fromBegin: boolean = false): integer;
     function getPrevFalseTask(): integer;
     function AllComplete(): boolean;
   //  function nextFalseTask(): integer;
  public
    { Public declarations }
    property Tests: TTEstList read fTests;
    procedure clearUserResults();
    procedure setNewTopic(newTopicID: integer);
    procedure SelectVariant(aVariant: integer);
    procedure ShowTests();
  end;

implementation

uses uOGE, uTestResult, GdiPlus, GdiPlusHelpers, ActiveX;

{$R *.dfm}

             // Если выбран вариант с 6 - 10 то насчитываем баллы по таблице
const pointsByTask: array[0..9] of double = (0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 1, 2, 2, 2);
      e = 0.001;

{ TfrmTests }
function TfrmTests.AllComplete: boolean;
var i: integer;
begin
     if currentTest = nil then exit(false);

     result := true;
     for i := 0 to length(currentTest.taskResultMask) - 1 do
           if currentTest.taskResultMask[i] = false then exit(false)
end;

procedure TfrmTests.btAnswearClick(Sender: TObject);
var usrAnswear: double;
    TrueAnswear: boolean;
begin
     if (answears = nil) or
           (currentTest = nil) or
              not (fTask in [1..TASK_COUNT]) or
                    (trim(txtAnswer.Text) = '') then exit;

     usrAnswear := strToFloatEx(trim(txtAnswer.Text));

     trueAnswear := abs(usrAnswear - self.answears[fTask - 1]) < e;
     if (rgVariants.ItemIndex + 1) >= CALC_POINTS_FROM_V then
     begin
          if trueAnswear then
          with currentTest^ do
          begin
              if (taskResultMask[fTask - 1] = false) then
              begin
                   points := points + pointsByTask[fTask - 1];
                   taskResultMask[fTask - 1] := true;
              end
              else begin
                messageBox(self.Handle,
                   'Верно! Баллы за это задание уже были засчитаны.',
                                       'ОГЕ', MB_OK or MB_ICONINFORMATION);
                     //exit;
              end;
          end;
          btNextTaskClick(Sender);
     end
     else begin
        if trueAnswear then
        begin
           messageBox(Handle, 'Верно!', 'ОГЕ', MB_OK or MB_ICONINFORMATION);
           currentTest^.taskResultMask[fTask - 1] := true;
           btNextTaskClick(Sender);
        end
        else begin
             messageBox(Handle, 'Подумай!', 'ОГЕ', MB_OK or MB_ICONINFORMATION);
             currentTest^.taskResultMask[fTask - 1] := false;
        end;
     end;
end;

function TfrmTests.getNextFalseTask(fromBegin: boolean = false): integer;
begin
     if allComplete then
     begin
         mode := mNormal;   // All tasks complete
         messageBox(handle, PWideChar('Поздравляем! Все задания варианта '+
                                intToStr(rgVariants.ItemIndex + 1) +' решены'),
                                                 'ОГЕ', MB_OK or MB_ICONINFORMATION);
         exit(fTask)
     end;

     if fromBegin then fTask := 1 else inc(fTask);

     while fTask <= TASK_COUNT do
     begin
         if currentTest.taskResultMask[fTask - 1] = false then break;;
         inc(fTask);
     end;

    if fTask > TASK_COUNT then
         fTask := getPrevFalseTask();

    result := fTask;
end;

function TfrmTests.getPrevFalseTask: integer;
begin
     if allComplete then
     begin
         mode := mNormal;   // All tasks complete
         messageBox(handle, PWideChar('Поздравляем! Все задания варианта '+
                                  intToStr(rgVariants.ItemIndex + 1) +' решены'),
                                                  'ОГЕ', MB_OK or MB_ICONINFORMATION);
         exit(fTask)
     end;

     dec(fTask);
     while (fTask >= 1) do
     begin
         if currentTest.taskResultMask[fTask - 1] = false then break;
         dec(fTask);
     end;

     if fTask < 1 then
          fTask := getNextFalseTask();

     result := fTask;
end;

procedure TfrmTests.btNextTaskClick(Sender: TObject);
begin
    if mode = mReTest then fTask := getNextFalseTask() else inc(fTask);
    if fTask > TASK_COUNT then fTask := TASK_COUNT;

    loadTest(currentTest^, rgVariants.ItemIndex + 1, fTask);
end;

procedure TfrmTests.btPrevTaskClick(Sender: TObject);
begin
    if mode = mRetest then fTask := getPrevFalseTask() else dec(fTask);
    if fTask < 1 then fTask := 1;

    loadTest(currentTest^, rgVariants.ItemIndex + 1, fTask);
end;

procedure TfrmTests.btResultsClick(Sender: TObject);
var mr: TmodalResult;
begin
    mr := TfrmTestResult.showResults;
    case mr of
      mrYes: mode := mNormal;
      mrNo:
        begin
              if not assigned(currentTest) then exit;

          // Перейдем в режим прохода теста заново
          // Найдем первый не пройденый тест
              mode := mReTest;

              ftask := getNextFalseTask(true);
              loadTest(currentTest^, rgVariants.ItemIndex + 1, fTask);
        end;
    end;
end;

procedure TfrmTests.cboTopicsChange(Sender: TObject);
begin
    clear;
end;

procedure TfrmTests.clear;
begin
    img.Canvas.Brush.Color:=ClWhite;
    img.Canvas.FillRect(img.Canvas.ClipRect);
    txtAnswer.Text := '';

    rgVariants.ItemIndex := -1;

    ScrollBox.HorzScrollBar.Range := 0;
    ScrollBox.VertScrollBar.Range := 0
end;

procedure TfrmTests.clearUserResults;
begin
     if assigned(currentTest) then
     begin
          currentTest^.points := 0;
          fillchar(currentTest^.taskResultMask,
                sizeOf(currentTest^.taskResultMask), 0);
     end;
end;

procedure TfrmTests.loadTest(test: TTestInfo; testVariant, taskNo: integer);
var fileName, answearName: string;
    mem: TMemoryStream;
    adptr: IStream;
    gdiBmp: IGPBitmap;
    graphic: IGPGraphics;
    bmp: TBitmap;
    rect: TGPRectF;
begin
   clear;

   fileName := format('%s/%s/%d/%d.jpg',
        [TEST_DIR, test.dir, testVariant, taskNo]);

   mem := TMemoryStream.Create;
   bmp := TBitMap.Create;

   try
     if not FindData(dm.DataFile, fileName, mem) then
     begin
        messageBox(self.Handle,
            'По данной теме тесты не загружены',
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

     fTask := taskNo;
   finally
        mem.Free;
        bmp.Free;
   end;

   if answears = nil then
   begin
        answearName := format('%s/%s/answ.xml', [TEST_DIR, currentTest.dir]);
        answears := dm.loadAnswears(answearName, testVariant);
   end;

   rgVariants.OnClick := nil;
   rgVariants.ItemIndex := testVariant - 1;
   rgVariants.OnClick := rgVariantsClick;
end;

procedure TfrmTests.rgVariantsClick(Sender: TObject);
begin
    if rgVariants.ItemIndex < 0 then exit;

    mode := mNormal;

    answears := nil;

    currentTest := getTestByTopic(
        integer(cboTopics.Items.Objects[cboTopics.ItemIndex]), fTests
        );
    if currentTest = nil then exit;

    clearUserResults();

    fTask := 1;
    loadTest(currentTest^, rgVariants.ItemIndex + 1, fTask);
end;

procedure TfrmTests.SelectVariant(aVariant: integer);
begin
     rgVariants.ItemIndex := aVariant - 1;
end;

procedure TfrmTests.setNewTopic(newTopicID: integer);
var i: integer;
begin
     for i := 0 to cboTopics.Items.Count - 1 do
     begin
          if integer(cboTopics.Items.Objects[i]) = newTopicID then
          begin
              cboTopics.ItemIndex := i;
              exit;
          end;
     end;
end;

procedure TfrmTests.FormMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
    with scrollBox.VertScrollBar do
    begin
        if (wheelDelta < 0) and (position < range)
        then position := position + increment
        else if (position > 0) then position := position - increment
    end;
end;

procedure TfrmTests.ShowTests;
var i: integer;
begin
    currentTest := nil;
    fTests := dm.loadTests();
    if fTests = nil then
    begin
      messageBox(self.Handle, 'Не удалось загузить тесты', 'Ошибка', MB_OK or MB_ICONERROR);
      abort;
    end;

    with frmOGE.Topics do
        for i := 0 to length(TopicList) - 1 do
            cboTopics.Items.AddObject(TopicList[i].displayLabel, Tobject(TopicList[i].id));

    cboTopics.ItemIndex := 0;

    show;
end;


end.
