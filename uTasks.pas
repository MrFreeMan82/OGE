unit uTasks;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, uGlobals, uTopicModel, uSavePoint;

type
  TfrmTasks = class(TForm)
    pnlLinks: TPanel;
    Splitter1: TSplitter;
    ScrollBox: TScrollBox;
    img: TImage;
    Panel3: TPanel;
    pnlTools: TPanel;
    btNext: TSpeedButton;
    btPrev: TSpeedButton;
    btHelp: TSpeedButton;
    btResults: TSpeedButton;
    btAnswear: TSpeedButton;
    Label3: TLabel;
    txtAnswer: TEdit;
    Panel1: TPanel;
    procedure FormDestroy(Sender: TObject);
    procedure linkClick(Sender: TObject);
    procedure btAnswearClick(Sender: TObject);
    procedure btResultsClick(Sender: TObject);
    procedure btPrevTaskClick(Sender: TObject);
    procedure btNextTaskClick(Sender: TObject);
    procedure txtAnswerKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure btHelpClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormPaint(Sender: TObject);
  private
    savePoint: TSavePoint;
    mTask: TTopic;
    mTaskList: TTopicList;
    links: array of TLinkLabel;
    LoadedLink: TLinkLabel;
    mOwner: TComponent;

    procedure createLinks();
    procedure AllTaskCompleate;
    procedure viewTask(aTopic: TTopic; silent: boolean = true);
    function gettaskResultMask: TResultMask;
    procedure assignedCurrent();
    function LinkByName(const name: string): TLinkLabel;
    { Private declarations }
  public
    { Public declarations }
    property ResultMask: TResultMask read gettaskResultMask;
    function Over80(us_id: integer): boolean;
    procedure clearUserResults;
    procedure saveResults();
    procedure ShowTasks(Owner: TComponent);
  end;

implementation

uses uData, uTestResult, uOGE;

{$R *.dfm}

{ TfrmTasks }

const COLLECTIVE_TASK_ID = 4;

function TfrmTasks.Over80(us_id: integer): boolean;
var i,j,k, total_tasks, true_tasks: integer;
    sp: TSavePoint;
    rm: TResultMask;
begin
     total_tasks := 0; true_tasks := 0;

     sp := TSavePoint.Create(us_id, mOwner.name);
     sp.Load;

     for i := 0 to length(mTaskList) - 1  do
     begin
          for j :=  0 to length(mTaskList[i].sections) - 1 do
          begin
               inc(total_tasks);
               rm := sp.asResultMask('MASK_' +
                        intTostr(mTaskList[i].sections[j].topic_id));

               if (rm = nil) then continue;

               for k := 0 to length(rm) - 1 do
                   if rm[k] = true then inc(true_tasks);
          end;
     end;

     sp.Free;
     result := true_tasks >= trunc(total_tasks * 0.8);
end;

procedure TfrmTasks.AllTaskCompleate;
begin
     if messageBox(handle, PWideChar(
          'Поздравляем! Все задания решены, Показать результаты?'),
                        'ОГЕ', MB_YESNO or MB_ICONINFORMATION) = mrYes then
     begin
         btResultsClick(self);
     end;
end;

procedure TfrmTasks.assignedCurrent;
begin
    if mTask = nil then
    begin
        messageBox(handle, 'Для продолжения выберите раздел.', 'ОГЕ', MB_OK or MB_ICONERROR);
        abort;
    end;
end;

procedure TfrmTasks.btAnswearClick(Sender: TObject);
var usrAnswear: double;
    TrueAnswear: boolean;
    task: integer;
begin
     assignedCurrent();
     if trim(txtAnswer.Text) = '' then exit;

    task := mTask.CurrentTask;
    usrAnswear := strToFloatEx(trim(txtAnswer.Text));

    trueAnswear := mTask.isTrueAnswear(usrAnswear);

    if trueAnswear then
    begin
         if mTask.ResultMaskValue[task - 1] = false then
         begin
              mTask.ResultMaskValue[task - 1] := true;
         end
         else begin
                messageBox(self.Handle,
                   'Верно! Баллы за это задание уже были засчитаны.',
                                       'ОГЕ', MB_OK or MB_ICONINFORMATION);
         end;
         if task = mTask.section.task_count then
         begin
             if mTask.
                  allTaskComplete()
                       then AllTaskCompleate()
                            else btResultsClick(self);

         end
         else btNextTaskClick(Sender);
    end
    else begin
         btNextTaskClick(Sender);
    end;
    txtAnswer.Text := '';
end;

procedure TfrmTasks.btHelpClick(Sender: TObject);
begin
    assignedCurrent();
    frmOGE.Topics.HelpWithTopic(mTask.section.topic_id, self);
end;

procedure TfrmTasks.btNextTaskClick(Sender: TObject);
begin
    assignedCurrent();
    mTask.NextPage;
    viewTask(mTask);
end;

procedure TfrmTasks.btPrevTaskClick(Sender: TObject);
begin
    assignedCurrent();
    mTask.PrevPage;
    viewTask(mTask);
end;

procedure TfrmTasks.btResultsClick(Sender: TObject);
var mr: TModalResult;
begin
    mr := TfrmTestResult.showTaskResults(mOwner);

    case mr of
      mrYes: mTask.mode := mNormal;
      mrNo:
        begin
          // Перейдем в режим прохода теста заново
          // Найдем первый не пройденый тест
              mTask.mode := mReTest;
              mTask.NextPage;
              viewTask(mTask);
        end;
    end;
end;

procedure TfrmTasks.viewTask(aTopic: TTopic; silent: boolean = true);
begin
     ScrollBox.HorzScrollBar.Range := 0;
     ScrollBox.VertScrollBar.Range := 0;

     img.Canvas.Brush.Color:=ClWhite;
     img.Canvas.FillRect(img.Canvas.ClipRect);

     if (aTopic.content = nil) then
     begin
          if not silent then
              messageBox(self.Handle,
                  'По данному разделу тесты не загружены',
                               'Ошибка', MB_OK or MB_ICONERROR);
          exit;
     end;

     ScrollBox.HorzScrollBar.Range := 0;
     ScrollBox.VertScrollBar.Range := 0;

     with aTopic do
     begin
         img.SetBounds(0, 0, content.Width, content.Height);
         img.Picture.Assign(content);
     end;

     ScrollBox.HorzScrollBar.Range := img.Picture.Width;
     ScrollBox.VertScrollBar.Range := img.Picture.Height;
end;

procedure TfrmTasks.ShowTasks(Owner: TComponent);
var id: integer;
begin
    loadTopicList(self, mTaskList);
    if (mTaskList = nil) then
    begin
      messageBox(self.Handle, 'Не удалось загузить тесты', 'Ошибка', MB_OK or MB_ICONERROR);
      abort;
    end;
    mOwner := Owner;
    createLinks();
    savePoint := TsavePoint.Create(frmOGE.User.id, mOwner.Name);
    savepoint.Load;
    id := savepoint.asInteger('TOPIC');
    if(id > 0) then
    begin
          mtask := getTopicByID(id, mTaskList);
          if mtask = nil then exit;
          id := savepoint.asInteger('SEC');
          if id < 0 then exit;
          LoadedLink := linkByName(mtask.sectionByID(id).name);
          linkClick(LoadedLink);
    end;
    show;
end;

procedure TfrmTasks.linkClick(Sender: TObject);
var page: integer;
begin
    if (Sender = nil) or (not (Sender is TLinkLabel)) then exit;

    mTask := mTaskList[TLinkLabel(Sender).Tag];
   // mTask.ContentType  := cntTask;
    mTask.OnAllTaskComplete := AllTaskCompleate;
    mTask.setSection(cntTask, mTask.sectionByName(TLinkLabel(Sender).Name));
    page := savePoint.asInteger('PAGE_' + intToStr(mTask.Section.topic_id));

    if (page >= 1) and
      (page <= mTask.Section.task_count)
          then mTask.Page := page else mTask.FirstPage;

    mTask.ResultMask := savepoint.asResultMask('MASK_' + intToStr(mTask.Section.topic_id));

    viewTask(mTask, false);
    mTask.loadAnswears();
end;

procedure TfrmTasks.saveResults;
begin
   if assigned(mTask) then
   begin
       savePoint.addIntValue('TOPIC', mTask.ID);
       if assigned(mTask.Section) then
       begin
          savepoint.addIntValue('SEC', mTask.Section.topic_id);
          savepoint.addIntValue('PAGE_' +  intToStr(mTask.Section.topic_id), mTask.Page);
          savepoint.addResultMask('MASK_' + intToStr(mTask.Section.topic_id), mtask.ResultMask);
       end;
       savepoint.Save;
   end;
end;

procedure TfrmTasks.clearUserResults;
begin
    mTask.clearResults;
    if assigned(mTask) and assigned(mTask.section) then
        savepoint.Delete('MASK_' + intToStr(mTask.Section.topic_id));
end;

procedure TfrmTasks.createLinks;
var i, j, k, l, t, td, ld, cnt: integer;
begin
     k := -1;
     l := 2;
     t := 2;
     td := 10;
     ld := 10;

     cnt := 0;
     for i := 0 to length(mTaskList) - 1 do
          cnt := cnt + length(mTaskList[i].sections) + 1;

     setLength(links, cnt);

     for i := 0 to length(mTaskList) - 1 do
     begin
          if (mOwner.Name = frmOGe.tabTasks.Name) and
                (mTaskList[i].ID = COLLECTIVE_TASK_ID) then continue;

          if (mOwner.Name = frmOGE.tabCollectiveTask.Name) and
                (mTaskList[i].ID <> COLLECTIVE_TASK_ID) then continue;

          inc(k);

          links[k] := TLinkLabel.Create(pnlLinks);
          links[k].Parent := pnlLinks;
          links[k].OnClick := nil;
          links[k].Left := l;
          links[k].Top := t;
          links[k].Caption := '<a href="#">' + mTaskList[i].Caption + '</a>';

          t := t + links[k].Height + td;

          if length(mTaskList[i].sections) = 1 then
          begin
               links[k].Name := mTaskList[i].name;
               links[k].OnClick := linkClick;
               links[k].Tag := i;
               continue;
          end;

          for j := 0 to length(mTaskList[i].sections) - 1 do
          begin
              inc(k);

              links[k] := TLinkLabel.Create(pnlLinks);
              links[k].Name := mTaskList[i].sections[j].name;
              links[k].Parent := pnlLinks;
              links[k].OnClick := linkClick;
              links[k].Left := l + ld;
              links[k].Top := t;
              links[k].Tag := i;
              links[k].Caption := '<a href="#">' + mTaskList[i].sections[j].display_lable + '</a>';

              t := t + links[k].Height + td;
          end;
     end;
end;

procedure TfrmTasks.txtAnswerKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
    if key = VK_RETURN then btAnswearClick(Sender);
end;

procedure TfrmTasks.FormDestroy(Sender: TObject);
var i: integer;
begin
     savePoint.Free;
     for i := 0 to length(links) - 1 do freeAndNil(links[i]);
     freeTopicList(mTaskList);
end;

procedure TfrmTasks.FormMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
    with scrollBox.VertScrollBar do
    begin
        if (wheelDelta < 0) and (position < range)
        then position := position + increment
        else if (position > 0) then position := position - increment
    end;
end;

procedure TfrmTasks.FormPaint(Sender: TObject);
begin
    if assigned(LoadedLink) then
    begin
        LoadedLink.SetFocus;
        LoadedLink := nil;
    end;
end;

procedure TfrmTasks.FormResize(Sender: TObject);
begin
      pnlTools.Left := (Panel3.Width div 2) - (pnlTools.Width div 2);
end;

function TfrmTasks.gettaskResultMask: TResultMask;
begin
    result := mtask.ResultMask;
end;

function TfrmTasks.LinkByName(const name: string): TLinkLabel;
var i: integer;
begin
     result := nil;
     for i := 0 to length(links) - 1 do
          if name = links[i].Name then exit(links[i]);

end;

end.
