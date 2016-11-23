unit uTests;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, uGlobal, uData, OleCtrls, SHDocVw, Menus,
  uNewTask, Buttons;

type
  TfrmTests = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    txtAnswer: TEdit;
    Panel3: TPanel;
    cboTopics: TComboBox;
    rgVariants: TRadioGroup;
    PopupMenu1: TPopupMenu;
    mNewTask: TMenuItem;
    btNextTest: TSpeedButton;
    btPrevTest: TSpeedButton;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    Panel2: TPanel;
    img: TImage;
    procedure rgVariantsClick(Sender: TObject);
  private
    { Private declarations }
     task: integer;
     tests: TTestList;
     procedure fillcboTopics(topics: TTopicList);
     procedure loadTest(test:TTestInfo; testVariant, taskNo: integer);
     function getTestListByTopic(topicID: integer): TTestList;
  public
    { Public declarations }
    procedure ShowTests();
  end;

implementation

uses uOGE, jpeg;

{$R *.dfm}
             // Если выбран вариант с 6 - 10 то насчитываем баллы по таблице
const userPoints: array[0..9] of double = (0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 1, 2, 2, 2);

{ TfrmTests }
procedure TfrmTests.fillcboTopics(topics: TTopicList);
var i: integer;
begin
     for i := 0 to length(topics) - 1 do
          cboTopics.Items.AddObject(topics[i].displayLabel, Tobject(topics[i].id));
end;

function TfrmTests.getTestListByTopic(topicID: integer): TTestList;
var i: integer;
begin
    result := nil;

    for i := 0 to length(tests) - 1 do
    begin
          if tests[i].topic = topicID then
          begin
                setLength(result, length(result) + 1);
                result[high(result)] := tests[i];
          end;
    end;
end;

procedure TfrmTests.loadTest(test: TTestInfo; testVariant, taskNo: integer);
var fileName: string;
    jpg: TJpegImage;
begin
    fileName := format('%s%s\%s\%d\%d.jpg',
        [dm.exePath(), TEST_DIR, test.dir, testVariant, taskNo]);

    if not FileExists(fileName) then exit;

    jpg := TJpegImage.Create;
    try
      jpg.LoadFromFile(fileName);
      img.Picture.Bitmap.Assign(jpg);
    finally
       jpg.Free;
    end;
end;

procedure TfrmTests.rgVariantsClick(Sender: TObject);
var test: TTestList;
begin
    test := getTestListByTopic(integer(cboTopics.Items.Objects[cboTopics.ItemIndex]));
    if test = nil then exit;

    task := 1;
    loadTest(test[0], rgVariants.ItemIndex + 1, task);
end;

procedure TfrmTests.ShowTests;
begin
    tests := dm.loadTests();
    fillcboTopics(frmOGE.TopicList);
    cboTopics.ItemIndex := 0;
    rgVariants.ItemIndex := 0;
    show;
end;

end.
