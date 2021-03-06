unit uTests;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, OleCtrls, SHDocVw, Menus, uGlobals, Buttons;

type
  PtestInfo = ^TTestinfo;
  TTestInfo = record
      id: integer;
      topicID: integer;
      dir: string;
      displayLabel: string;
      taskResultMask: TResultMask;
      points: double;
  end;

  TTestList = array of TTestInfo;

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
    procedure txtAnswerKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
     mode: Tmode;
     fTask: integer;
     fTests: TTestList;
     currentTest: PTestInfo;
     answears: TAnswears;
   //  usrResults: TUserResultList;  // ���������� �� ������ ����
     procedure clear;
     procedure loadTest(test:TTestInfo; testVariant, taskNo: integer);
     procedure AllTaskCompleate;
  public
    { Public declarations }
    property Tests: TTEstList read fTests;
    procedure clearUserResults();
    procedure setNewTopic(newTopicID: integer);
    procedure SelectVariant(aVariant: integer);
    procedure ShowTests();
  end;

function getTestByTopic(topicID: integer; const tests: TTestList): PTestInfo;

implementation

uses uOGE, uTestResult, GdiPlus, GdiPlusHelpers, ActiveX, uData;

{$R *.dfm}

             // ���� ������ ������� � 6 - 10 �� ����������� ����� �� �������
const pointsByTask: array[0..9] of double = (0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 1, 2, 2, 2);
{ TfrmTests }

function getTestByTopic(topicID: integer; const tests: TTestList): PTestInfo;
var i: integer;
begin
    result := nil;

    for i := 0 to length(tests) - 1 do
          if tests[i].topicID = topicID then result := @tests[i];
end;

procedure TfrmTests.AllTaskCompleate;
begin
     mode := mNormal;   // All tasks complete
     if messageBox(handle, PWideChar(
          '�����������! ��� ������� �������� ' +
                intToStr(rgVariants.ItemIndex + 1) +
                        ' ������, �������� ����������?'),
                              '���', MB_YESNO or MB_ICONINFORMATION) = mrYes then
     begin
         btResultsClick(self);
     end;
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
    { if (rgVariants.ItemIndex + 1) >= CALC_POINTS_FROM_V then
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
                   '�����! ����� �� ��� ������� ��� ���� ���������.',
                                       '���', MB_OK or MB_ICONINFORMATION);
                     //exit;
              end;
          end;
          if fTask = TASK_COUNT then
          begin
              if getNextFalseTask(fTask,
                  currentTest.taskResultMask, true) =
                    ALL_TASK_COMPLETE then
                            AllTaskCompleate()
                                else btResultsClick(self)
          end
          else btNextTaskClick(Sender);
     end
     else begin }
        if trueAnswear then
        begin
           messageBox(Handle, '�����!', '���', MB_OK or MB_ICONINFORMATION);
           currentTest^.taskResultMask[fTask - 1] := true;
           btNextTaskClick(Sender);
        end
        else begin
             messageBox(Handle, '�������!', '���', MB_OK or MB_ICONINFORMATION);
             currentTest^.taskResultMask[fTask - 1] := false;
        end;
   //  end;
end;

procedure TfrmTests.btNextTaskClick(Sender: TObject);
begin
    if mode = mReTest then
    begin
       fTask := getNextFalseTask(fTask, currentTest.taskResultMask);
       if fTask = ALL_TASK_COMPLETE then
       begin
            AllTaskCompleate();
            exit;
       end;
    end
    else inc(fTask);

    if fTask > TASK_COUNT then fTask := TASK_COUNT;

    loadTest(currentTest^, rgVariants.ItemIndex + 1, fTask);
end;

procedure TfrmTests.btPrevTaskClick(Sender: TObject);
begin
    if mode = mRetest then
    begin
         fTask := getPrevFalseTask(fTask, currentTest.taskResultMask);
         if fTask = ALL_TASK_COMPLETE then
         begin
              AllTaskCompleate();
              exit
         end;
    end
    else dec(fTask);

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

          // �������� � ����� ������� ����� ������
          // ������ ������ �� ��������� ����
              mode := mReTest;
              ftask := getNextFalseTask(fTask, currentTest.taskResultMask, true);

              if fTask = ALL_TASK_COMPLETE then
              begin
                  mode := mNormal;   // All tasks complete
                  exit
              end;

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
var i: integer;
begin
     if assigned(currentTest) then
     begin
          currentTest^.points := 0;
          for i := 0 to TASK_COUNT - 1 do
              currentTest.taskResultMask[i] := false;
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
            '�� ������ ���� ����� �� ���������',
                   '������', MB_OK or MB_ICONERROR);
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
        answears := dm.loadAnswears(dm.DataFile, answearName, testVariant);
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

    if currentTest.taskResultMask = nil then setLength(currentTest.taskResultMask, TASK_COUNT);

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
      messageBox(self.Handle, '�� ������� �������� �����', '������', MB_OK or MB_ICONERROR);
      abort;
    end;

    with frmOGE.Topics do
        for i := 0 to length(TopicList) - 1 do
            cboTopics.Items.AddObject(TopicList[i].displayLabel, Tobject(TopicList[i].id));

    cboTopics.ItemIndex := 0;

    show;
end;


procedure TfrmTests.txtAnswerKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
    if key = VK_RETURN then btAnswearClick(Sender);
end;

end.
