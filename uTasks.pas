unit uTasks;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, uGlobals, uTopicModel, uSavePoint, ComCtrls,
  Menus, ActnList, uSync;

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
    PopupMenu1: TPopupMenu;
    mnuGoToPage: TMenuItem;
    ActionList: TActionList;
    actGoToPage: TAction;
    actAnswearClick: TAction;
    actResultClick: TAction;
    actHelpClick: TAction;
    actNextClick: TAction;
    actPrevClick: TAction;
    procedure FormDestroy(Sender: TObject);
    procedure linkClick(Sender: TObject);
    procedure txtAnswerKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure FormResize(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure actGoToPageExecute(Sender: TObject);
    procedure actAnswearClickExecute(Sender: TObject);
    procedure actResultClickExecute(Sender: TObject);
    procedure actHelpClickExecute(Sender: TObject);
    procedure actNextClickExecute(Sender: TObject);
    procedure actPrevClickExecute(Sender: TObject);
  private
    savePoint: TSavePoint;
    mTask: TTopic;
    mTaskList: TTopicList;
    links: array of TLinkLabel;
    LoadedLink, CurrentLink: TLinkLabel;
    mParent: TTabSheet;
    taskResultMask: TResultMask;
    answears: TAnswears;

    procedure loadUserOptions();
    procedure createLinks();
    procedure AllTaskCompleate;
    procedure viewTask(aTopic: TTopic);
    procedure assignedTask();
    function LinkByName(const name: string): TLinkLabel;
    function getSectionLabel: string;
    procedure loadAnswears;
    procedure setResultMask(const Value: TResultMask);
    procedure UpdateButtons(value: boolean);
    { Private declarations }
  public
    { Public declarations }
    property ResultMask: TResultMask read taskResultMask write setResultMask;
    property Parent: TTabSheet read mParent;
    property SectionLabel: string read getSectionLabel;
    property TaskList: TTopicList read mTaskList;

    function Over80(us_id: integer): boolean;
    function Over80ByUserAndSection(us_id, topic_id: integer): boolean;
    procedure clearUserResults;
    procedure saveResults();
    procedure send();
    function totalTaskCount(): integer;
    function OverPercBySection(section: PSection; percent: integer): boolean;
    procedure ShowTasks(Parent: TTabSheet);

  end;

implementation

uses uData, uTestResult, uOGE;

{$R *.dfm}

{ TfrmTasks }

function TfrmTasks.Over80(us_id: integer): boolean;
var i,j,k, total_tasks, true_tasks: integer;
    sp: TSavePoint;
    rm: TResultMask;
    item : TTopic;
begin
     total_tasks := totalTaskCount; true_tasks := 0;

     sp := TSavePoint.Create(us_id, mParent.name);
     sp.Load;

     for i := 0 to mTaskList.Count - 1  do
     begin
          item := TTopic(mTaskList.Items[i]);
          for j :=  0 to length(item.sections) - 1 do
          begin
               rm := sp.asResultMask('MASK_' +
                        intTostr(item.sections[j].topic_id));

               if (rm = nil) then continue;

               for k := 0 to length(rm) - 1 do
                   if rm[k] = true then inc(true_tasks);
          end;
     end;

     sp.Free;
     result := true_tasks >= trunc(total_tasks * 0.8);
end;

function TfrmTasks.Over80ByUserAndSection(us_id, topic_id: integer): boolean;
var sp: TSavePoint;
    rm: TResultMask;
    i,total_tasks, true_tasks: integer;
begin
     result := false;
     sp := TSavePoint.Create(us_id, mParent.Name);
     sp.Load;
     rm := sp.asResultMask('MASK_' + intToStr(topic_id));
     if assigned(rm) then
     begin
          total_tasks := length(rm);
          true_tasks  := 0;
          for i := 0 to total_tasks - 1 do if rm[i] then inc(true_tasks);
          result := true_tasks >= (total_tasks * 0.8);
     end;
     sp.Free;
end;

function TfrmTasks.totalTaskCount: integer;
var i: Integer;
    item: TTopic;
begin
    result := 0;
    for i := 0 to mTaskList.Count - 1 do
    begin
        item := TTOpic(mTaskList.Items[i]);
        if (mParent.Name = frmOGe.tabTasks.Name) and
              (item.TopicType = tCollective) then continue;

        if (mParent.Name = frmOGE.tabCollectiveTask.Name) and
              (item.TopicType <> tCollective) then continue;

        result := result + item.TaskCount;
    end;

end;

function TfrmTasks.OverPercBySection(section: PSection; percent: integer): boolean;
var i: integer;
    total_tasks, true_tasks: integer;
    rm: TResultMask;
begin
    true_tasks := 0;
    rm := SavePoint.asResultMask('MASK_' + intToStr(section.topic_id));
    if (rm = nil) then exit(false);

    total_tasks := length(rm);

    for i := 0 to length(rm) - 1 do
        if rm[i] = true then inc(true_tasks);

    result := true_tasks >= trunc(total_tasks * percent / 100);
end;

procedure TfrmTasks.AllTaskCompleate;
begin
     if messageBox(handle, PWideChar(
          'Поздравляем! Все задания решены, Показать результаты?'),
                        'ОГЭ', MB_YESNO or MB_ICONINFORMATION) = mrYes then
     begin
         actResultClickExecute(self);
     end;
end;

procedure TfrmTasks.assignedTask;
begin
    if mTask = nil then
    begin
        messageBox(handle, 'Для продолжения выберите раздел.', 'ОГЭ', MB_OK or MB_ICONERROR);
        abort;
    end;
end;

procedure TfrmTasks.actAnswearClickExecute(Sender: TObject);
var usrAnswear: double;
    TrueAnswear: boolean;
    task: integer;
begin
     assignedTask();
     if trim(txtAnswer.Text) = '' then exit;

    task := mTask.Page;
    usrAnswear := strToFloatEx(trim(txtAnswer.Text));

    trueAnswear := abs(usrAnswear - answears[task - 1]) < e;

    if trueAnswear then
    begin
         taskResultMask[task - 1] := true;
         if task = mTask.section.task_count then
         begin
             if getNextFalseTask(Task,
                  taskResultMask, true) =
                      ALL_TASK_COMPLETE then
                            AllTaskCompleate()
                                else actResultClickExecute(self)

         end
         else actNextClickExecute(Sender);
    end
    else begin
         actNextClickExecute(Sender);
    end;
    txtAnswer.Text := '';
end;

procedure TfrmTasks.actGoToPageExecute(Sender: TObject);
var page: integer;
begin
     assignedTask();
     page := strToIntDef(InputBox('ОГЭ', 'Номер страницы', ''), 0);
     mTask.Page := page;
     viewTask(mTask);
end;

procedure TfrmTasks.actHelpClickExecute(Sender: TObject);
begin
    assignedTask();
    frmOGE.Topics.HelpWithTopic(mTask.section.topic_id, self);
end;

procedure TfrmTasks.actNextClickExecute(Sender: TObject);
begin
    assignedTask();
    mTask.NextPage;
    viewTask(mTask);
end;

procedure TfrmTasks.actPrevClickExecute(Sender: TObject);
begin
    assignedTask();
    mTask.PrevPage;
    viewTask(mTask);
end;

procedure TfrmTasks.actResultClickExecute(Sender: TObject);
var mr: TModalResult;
begin
    assignedTask;
    if mTask.content = nil then exit;

    mr := TfrmTestResult.showTaskResults(self);

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

procedure TfrmTasks.viewTask(aTopic: TTopic);
begin
     ScrollBox.HorzScrollBar.Range := 0;
     ScrollBox.VertScrollBar.Range := 0;

     img.Canvas.Brush.Color:=ClWhite;
     img.Canvas.FillRect(img.Canvas.ClipRect);

     if (aTopic.content = nil) then
     begin
         UpdateButtons(false);
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
     UpdateButtons(true)
end;

procedure TfrmTasks.loadUserOptions;
var id: integer; s: PSection;
begin
    id := savepoint.asInteger('TOPIC');
    if(id > 0) then
    begin
          mtask := mTaskList.getTopicByID(id);// getTopicByID(id, mTaskList);
          if mtask = nil then exit;
          id := savepoint.asInteger('SEC');
          if id < 0 then exit;
          s := mtask.sectionByID(id);
          if s = nil then exit;
          LoadedLink := linkByName(s.name);
          linkClick(LoadedLink);
    end;
end;

procedure TfrmTasks.ShowTasks(Parent: TTabSheet);
begin
    mParent := Parent;
    mTaskList := TTopicList.Create;
    if (mTaskList = nil) then
    begin
      messageBox(self.Handle, 'Не удалось загузить тесты', 'Ошибка', MB_OK or MB_ICONERROR);
      abort;
    end;
    UpdateButtons(false);
    savePoint := TsavePoint.Create(frmOGE.User.id, mParent.Name);
    savepoint.Load;
    createLinks();
    loadUserOptions();
    show;
end;

procedure TfrmTasks.send;
var key, value: string;
begin
     key := 'MASK';
     value := format('%d;%s;%s;MASK_%d;%s',
        [frmOGE.User.id, 'n/a', savepoint.Window,
                      mTask.Section.topic_id, savepoint.asString(
                            'MASK_' + intToStr(mTask.Section.topic_id))]
     );
     frmOGE.Sync.send(key, value);
end;

procedure TfrmTasks.linkClick(Sender: TObject);
var page: integer;
begin
    if (Sender = nil) or (not (Sender is TLinkLabel)) then exit;

    CurrentLink := TLinkLabel(Sender);

    mTask := mTaskList[TLinkLabel(Sender).Tag];
   // mTask.ContentType  := cntTask;
    mTask.OnAllTaskComplete := AllTaskCompleate;
    mTask.setSection(cntTask, mTask.sectionByName(TLinkLabel(Sender).Name));
    page := savePoint.asInteger('PAGE_' + intToStr(mTask.Section.topic_id));
    if (page >= 1) and
      (page <= mTask.Section.task_count)
          then mTask.Page := page else mTask.FirstPage;

    ResultMask := savepoint.asResultMask('MASK_' + intToStr(mTask.Section.topic_id));

    viewTask(mTask);
    loadAnswears();
    frmOGe.UpdateCaption(mTask.Section.display_lable);
end;

procedure TfrmTasks.saveResults;
begin
   if assigned(mTask) and assigned(mTask.Section)  then
   begin
       savepoint.addResultMask('MASK_' + intToStr(mTask.Section.topic_id), ResultMask);
       savepoint.Save;
   end;
end;

procedure TfrmTasks.setResultMask(const Value: TResultMask);
begin
    taskResultMask := Value;
    mTask.ResultMask := value;
end;

procedure TfrmTasks.clearUserResults;
var i: integer;
begin
    for i := 0 to length(taskResultMask) - 1 do taskResultMask[i] := false;
    if assigned(mTask) and assigned(mTask.section) then
        savepoint.Delete('MASK_' + intToStr(mTask.Section.topic_id));
end;

procedure TfrmTasks.createLinks;
var i, j, k, l, t, td, ld, cnt: integer;
    item: TTOpic;
begin
     k := -1;
     l := 2;
     t := 2;
     td := 10;
     ld := 10;

     cnt := 0;
     for i := 0 to mTaskList.Count - 1 do
          cnt := cnt + length(TTopic(mTaskList.Items[i]).sections) + 1;

     setLength(links, cnt);

     for i := 0 to mTaskList.Count - 1 do
     begin
          item := TTopic(mTaskList.Items[i]);
          if (mParent.Name = frmOGe.tabTasks.Name) and
                (item.TopicType = tCollective) then continue;

          if (mParent.Name = frmOGE.tabCollectiveTask.Name) and
                (item.TopicType <> tCOllective) then continue;

          inc(k);

          links[k] := TLinkLabel.Create(pnlLinks);
          links[k].Parent := pnlLinks;
          links[k].OnClick := nil;
          links[k].Left := l;
          links[k].Top := t;
          links[k].Caption := '<a href="#">' + item.Caption + '</a>';

          t := t + links[k].Height + td;

          if length(item.sections) = 1 then
          begin
               links[k].Name := item.name;
               links[k].OnClick := linkClick;
               links[k].Tag := i;
               continue;
          end;

          for j := 0 to length(item.sections) - 1 do
          begin
              inc(k);

              links[k] := TLinkLabel.Create(pnlLinks);
              links[k].Name := item.sections[j].name;
              links[k].Parent := pnlLinks;
              links[k].OnClick := linkClick;
              links[k].Left := l + ld;
              links[k].Top := t;
              links[k].Tag := i;
              links[k].Caption := '<a href="#">' + item.sections[j].display_lable + '</a>';

              t := t + links[k].Height + td;
          end;
     end;
end;

procedure TfrmTasks.loadAnswears;
var filename: string;
    i: integer;
begin
    filename := format('%s/%s/%s/answ.xml',[TOPIC_DIR, mTask.name, mTask.section.name]);
    answears := uGlobals.loadAnswears(dm.DataFile, filename, 1);
    if taskResultMask = nil then
    begin
         setLength(taskResultMask, length(answears));
         for i := 0 to length(taskResultMask) - 1 do taskResultMask[i] := false;
    end;
end;

procedure TfrmTasks.txtAnswerKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
    if key = VK_RETURN then actAnswearClickExecute(Sender);
end;

procedure TfrmTasks.UpdateButtons(value: boolean);
var i: integer;
begin
     for i := 0 to ActionList.ActionCount - 1 do
     begin
            TAction(ActionList.Actions[i]).Enabled := value
     end;
end;

procedure TfrmTasks.FormDestroy(Sender: TObject);
var i: integer;
begin
     if assigned(mTask) then
     begin
         savePoint.addIntValue('TOPIC', mTask.ID);
         if assigned(mTask.Section) then
         begin
              savepoint.addIntValue('SEC', mTask.Section.topic_id);
              savepoint.addIntValue('PAGE_' +  intToStr(mTask.Section.topic_id), mTask.Page);
         end;
         savepoint.Save;
     end;

     savePoint.Free;
     for i := 0 to length(links) - 1 do freeAndNil(links[i]);
     mTaskList.Free;
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

function TfrmTasks.getSectionLabel: string;
begin
    result := '';
    if assigned(mTask) and assigned(mTask.Section) then result := mTask.Section.display_lable;
end;

function TfrmTasks.LinkByName(const name: string): TLinkLabel;
var i: integer;
begin
     result := nil;
     for i := 0 to length(links) - 1 do
          if name = links[i].Name then exit(links[i]);

end;

end.
