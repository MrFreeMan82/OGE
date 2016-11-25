unit uTests;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, uData, OleCtrls, SHDocVw, Menus,
  Buttons;

type
  TfrmTests = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    txtAnswer: TEdit;
    Panel3: TPanel;
    cboTopics: TComboBox;
    rgVariants: TRadioGroup;
    btAnswear: TSpeedButton;
    SpeedButton2: TSpeedButton;
    btResults: TSpeedButton;
    pnlTask: TPanel;
    img: TImage;
    btPrevTask: TSpeedButton;
    btNextTask: TSpeedButton;
    procedure rgVariantsClick(Sender: TObject);
    procedure btNextTaskClick(Sender: TObject);
    procedure btPrevTaskClick(Sender: TObject);
    procedure cboTopicsChange(Sender: TObject);
    procedure btAnswearClick(Sender: TObject);
    procedure btResultsClick(Sender: TObject);
  private
    { Private declarations }
     fTask: integer;
     fTests: TTestList;
     currentTest: TTestInfo;
     answears: TAnswears;
     usrResults: TUserResultList;  // Результаты по данной теме
     procedure clear;
     procedure loadTest(test:TTestInfo; testVariant, taskNo: integer);
  public
    { Public declarations }
    property Tests: TTEstList read fTests;
    property UserResults: TUserResultList read usrResults;
    procedure clearUserResults();
    procedure setNewTopic(newTopicID: integer);
    procedure SelectVariant(aVariant: integer);
    procedure ShowTests();
  end;

implementation

uses uOGE, jpeg;

{$R *.dfm}

             // Если выбран вариант с 6 - 10 то насчитываем баллы по таблице
const pointsByTask: array[0..9] of double = (0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 1, 2, 2, 2);
      e = 0.001;

{ TfrmTests }
procedure TfrmTests.btAnswearClick(Sender: TObject);
var usrAnswear: double;
    TrueAnswear: boolean;
begin
     if (self.answears = nil) or
        not (fTask in [1..TASK_COUNT]) or
            (trim(txtAnswer.Text) = '') then exit;

     usrAnswear := strToFloatEx(trim(txtAnswer.Text));

     trueAnswear := abs(usrAnswear - self.answears[fTask - 1]) < e;
     if (rgVariants.ItemIndex + 1) >= CALC_POINTS_FROM_V then
     begin
        with usrResults[cboTopics.ItemIndex] do
        begin
            if trueAnswear then
            begin
                 if (taskResult[rgVariants.ItemIndex, fTask - 1] = false) then
                 begin
                      points := points + pointsByTask[fTask - 1];
                      taskResult[rgVariants.ItemIndex, fTask - 1] := true;
                 end
                 else begin
                     messageBox(self.Handle,
                          'Верно! Баллы за это задание уже были засчитаны.',
                                           'ОГЕ', MB_OK or MB_ICONINFORMATION);
                     //exit;
                 end;
                 btNextTaskClick(Sender);
            end
        end;
     end
     else begin
        if trueAnswear then
        begin
           messageBox(Handle, 'Верно!', 'ОГЕ', MB_OK or MB_ICONINFORMATION);
           usrResults[cboTopics.ItemIndex].
                taskResult[rgVariants.ItemIndex, fTask - 1] := true;
           btNextTaskClick(Sender);
        end
        else begin
             messageBox(Handle, 'Подумай!', 'ОГЕ', MB_OK or MB_ICONINFORMATION);
             usrResults[cboTopics.ItemIndex].
                  taskResult[rgVariants.ItemIndex, fTask - 1] := false;
        end;
     end;
end;

procedure TfrmTests.btNextTaskClick(Sender: TObject);
begin
    inc(fTask);
    if fTask > TASK_COUNT then fTask := TASK_COUNT;

    loadTest(currentTest, rgVariants.ItemIndex + 1, fTask);
end;

procedure TfrmTests.btPrevTaskClick(Sender: TObject);
begin
    dec(fTask);
    if fTask < 1 then fTask := 1;

    loadTest(currentTest, rgVariants.ItemIndex + 1, fTask);
end;

procedure TfrmTests.btResultsClick(Sender: TObject);
begin
    frmOGE.TestResults.showResults();
    frmOGE.TestResults := nil;
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
end;

procedure TfrmTests.clearUserResults;
var i: integer;
begin
     for i := 0 to length(usrResults) - 1 do
     begin
         fillchar(usrResults[i].taskResult, sizeof(usrResults[i].taskResult), 0);
         usrResults[i].points := 0;
     end;
end;

procedure TfrmTests.loadTest(test: TTestInfo; testVariant, taskNo: integer);
var fileName, answearName: string;
    jpg: TJpegImage;
    mem: TMemoryStream;
begin
     clear;

     fileName := format('%s/%s/%d/%d.jpg',
        [TEST_DIR, test.dir, testVariant, taskNo]);

     mem := TMemoryStream(FindData(dm.DataFile, fileName, tMemory));

     if mem = nil then
     begin
         messageBox(self.Handle, 'По данной теме тесты не загружены', 'Ошибка', MB_OK or MB_ICONERROR);
         abort;
     end;

     fTask := taskNo;
     currentTest := test;

     if answears = nil then
     begin
          answearName := format('%s/%s/answ.xml', [TEST_DIR, currentTest.dir]);
          answears := dm.loadAnswears(answearName, testVariant);
     end;

     jpg := TJpegImage.Create;
     try
        jpg.LoadFromStream(mem);
        img.Top   := 10;
        img.Left  := 10;
        img.Width := jpg.Width;
        img.Height := jpg.Height;
        img.Picture.Bitmap.Assign(jpg);
     finally
        jpg.Free;
     end;

     rgVariants.OnClick := nil;
     rgVariants.ItemIndex := testVariant - 1;
     rgVariants.OnClick := rgVariantsClick;
end;

procedure TfrmTests.rgVariantsClick(Sender: TObject);
var topicTestList: TTestList;
begin
    if rgVariants.ItemIndex < 0 then exit;

    answears := nil;

    topicTestList := getTestListByTopic(
        integer(cboTopics.Items.Objects[cboTopics.ItemIndex]), fTests
        );
    if topicTestList = nil then exit;

    fTask := 1;
    loadTest(topicTestList[0], rgVariants.ItemIndex + 1, fTask);
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

procedure TfrmTests.ShowTests;
var i: integer;
begin
    fTests := dm.loadTests();
    if fTests = nil then
    begin
      messageBox(self.Handle, 'Не удалось загузить тесты', 'Ошибка', MB_OK or MB_ICONERROR);
      abort;
    end;

    with frmOGE.Topics do
    begin
        setLength(usrResults, length(TopicList));
        for i := 0 to length(TopicList) - 1 do
        begin
            cboTopics.Items.AddObject(TopicList[i].displayLabel, Tobject(TopicList[i].id));
            usrResults[i].topic := TopicList[i];
            usrResults[i].points := 0;
        end;
    end;
    cboTopics.ItemIndex := 0;

    fillchar(usrResults[cboTopics.ItemIndex].taskResult,
        sizeof(usrResults[cboTopics.ItemIndex].taskResult), 0);

    show;
end;

end.
