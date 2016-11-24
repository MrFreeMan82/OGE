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
    SpeedButton3: TSpeedButton;
    pnlTask: TPanel;
    img: TImage;
    btPrevTask: TSpeedButton;
    btNextTask: TSpeedButton;
    procedure rgVariantsClick(Sender: TObject);
    procedure btNextTaskClick(Sender: TObject);
    procedure btPrevTaskClick(Sender: TObject);
    procedure cboTopicsChange(Sender: TObject);
    procedure btAnswearClick(Sender: TObject);
  private
    { Private declarations }
     fTask: integer;
     fTests: TTestList;
     currentTest: TTestInfo;
     answears: TAnswears;
     procedure fillcboTopics(topics: TTopicList);
     procedure clear;
  public
    { Public declarations }
    property Tests: TTEstList read fTests;
    procedure setNewTopic(newTopicID: integer);
    procedure loadTest(test:TTestInfo; testVariant, taskNo: integer);
    procedure ShowTests();
  end;


implementation

uses uOGE, jpeg;

{$R *.dfm}

             // Если выбран вариант с 6 - 10 то насчитываем баллы по таблице
const userPoints: array[0..9] of double = (0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 1, 2, 2, 2);
      e = 0.01;

{ TfrmTests }
procedure TfrmTests.btAnswearClick(Sender: TObject);
var usrAnswear: double;
begin
     if (self.answears = nil) or (fTask = 0) then exit;
     usrAnswear := strToFloatEx(trim(txtAnswer.Text));

     if abs(usrAnswear - self.answears[fTask - 1]) < e then
     begin
        showMessage('Верно!')
     end
     else begin
        showMessage('Подумай.');
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

procedure TfrmTests.cboTopicsChange(Sender: TObject);
begin
    clear;
end;

procedure TfrmTests.clear;
begin
    img.Canvas.Brush.Color:=ClWhite;
    img.Canvas.FillRect(img.Canvas.ClipRect);

    rgVariants.ItemIndex := -1;
end;

procedure TfrmTests.fillcboTopics(topics: TTopicList);
var i: integer;
begin
     for i := 0 to length(topics) - 1 do
          cboTopics.Items.AddObject(topics[i].displayLabel, Tobject(topics[i].id));
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

     rgVariants.OnClick := nil;
     rgVariants.ItemIndex := testVariant - 1;
     rgVariants.OnClick := rgVariantsClick;

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
begin
    fTests := dm.loadTests();
    if fTests = nil then
    begin
      messageBox(self.Handle, 'Не удалось загузить тесты', 'Ошибка', MB_OK or MB_ICONERROR);
      abort;
    end;
    fillcboTopics(frmOGE.Topics.TopicList);
    cboTopics.ItemIndex := 0;
   // rgVariants.ItemIndex := 0;
    show;
end;

end.
