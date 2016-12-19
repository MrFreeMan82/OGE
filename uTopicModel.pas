unit uTopicModel;

interface

uses uGlobals, Graphics;

type
  PSection = ^TSection;
  TSection = record
    topic_id: integer;
    topic_link, page_link: integer;
    task_count: integer;
    pages_count: integer;
    name: string;
    display_lable: string;
    points: double;
    visible: boolean;
  end;

  TSectionList = array of TSection;

  POnAllTaskComleteEvent = procedure of object;

  TTopic = class
  private
      mid: integer;
      mname: string;
      display_lable: string;
      mMode: Tmode;
      pageNo: integer;
      taskNo: integer;
      procedure doLoadPage();
      procedure doLoadTask();
    procedure setMode(const Value: TMode);
    function getResultMask: TResultMask;
    function getResultMaskValue(index: integer): boolean;
    procedure setResultMaskValue(index: integer; const Value: boolean);

  public
      sections: TSectionList;
      section: PSection;
      task: TBitmap;
      content: TBitmap;
      OnAllTaskComplete: POnAllTaskComleteEvent;
      procedure FirstTask;
      procedure NextTask;
      procedure PrevTask;

      procedure FirstPage;
      procedure NextPage;
      procedure PrevPage;

      function allTaskComplete(): boolean;

      property Mode: TMode read mMode write setMode;
      property Caption: string read display_lable write display_lable;
      property ID: integer read mid write mid;
      property Name: string read mname write mname;
      property ResultMask: TResultMask read getResultMask;
      property ResultMaskValue[index: integer]: boolean read getResultMaskValue write setResultMaskValue;
      property CurrentTask: integer read taskNo;

      function isTrueAnswear(answ: double): boolean;
      function sectionByName(const name: string): PSection;
      function sectionByID(topic_id: integer): PSection;
      procedure loadAnswears();
      procedure clearResults();

      constructor Create();
  end;

  TTopicList = array of TTopic;

var topic_model_list: TTopicList = nil;

procedure loadTopicList();
procedure freeTopicList();

implementation

uses uData, sysUtils;

{ TModule }

var filename: string;

    taskResultMask: TResultMask;
    answears: TAnswears;

procedure loadTopicList();
begin
    topic_model_list := dm.loadTopicList;
end;

procedure freeTopicList();
var i: integer;
begin
    for i := 0 to length(topic_model_list) - 1 do freeAndNil(topic_model_list[i]);
    topic_model_list := nil;
end;

function TTopic.allTaskComplete: boolean;
begin
   result := getNextFalseTask(taskNo, taskResultMask, true) = ALL_TASK_COMPLETE;
end;

procedure TTopic.doLoadPage;
begin
    fileName := format('%s/%s/%s/Content/%d.jpg', [TOPIC_DIR, name, section.name, pageNo]);
    if assigned(content) then freeAndNil(content);
    content := dm.LoadPage(fileName);
end;

procedure TTopic.doLoadTask;
begin
    filename := format('%s/%s/%s/Task/%d.jpg', [TOPIC_DIR, name, section.name, taskNo]);

    if assigned(task) then freeAndNil(task);
    task:= dm.LoadPage(filename);
end;

procedure TTopic.FirstPage;
begin
    pageNo := 1;
    if section.topic_link > 0 then
    begin
        pageNo := section.page_link;
        section := sectionByID(section.topic_link);
    end;
    doLoadPage();
end;

procedure TTopic.FirstTask;
begin
   taskNo := 1;
   doLoadTask();
end;

function TTopic.getResultMask: TResultMask;
begin
    result := taskResultMask
end;

function TTopic.getResultMaskValue(index: integer): boolean;
begin
     result := taskResultMask[index];
end;

function TTopic.isTrueAnswear(answ: double): boolean;
begin
    result := abs(answ - answears[taskNo - 1]) < e;
end;

procedure TTopic.NextPage;
begin
     inc(pageNo);
     if(pageNo > section.pages_count) then
     begin
          pageNo := section.pages_count;
          exit;
     end;
     doLoadPage();
end;

procedure TTopic.NextTask;
begin
   if mode = mReTest then
   begin
        taskNo := getNextFalseTask(taskNo, taskResultMask);
        if taskNo = ALL_TASK_COMPLETE then
        begin
            mode := mNormal;
            if assigned(OnAllTaskComplete) then OnAllTaskComplete();
            exit;
        end;
   end
   else inc(taskNo);

   if taskNo > section.task_count then
   begin
         taskNo := section.task_count;
         exit;
   end;

   doLoadTask();
end;

procedure TTopic.PrevPage;
begin
     dec(pageNo);
     if (pageNo < 1) then
     begin
          pageNo := 1;
          exit;
     end;
     doLoadPage();
end;

procedure TTopic.PrevTask;
begin
   if mode = mRetest then
   begin
      taskNo := getPrevFalseTask(taskNo, taskResultMask);
      if taskNo = ALL_TASK_COMPLETE then
      begin
           mode := mNormal;
           if assigned(OnAllTaskComplete) then OnAllTaskComplete();
           exit;
      end;
   end
   else dec(taskNo);

   if (taskNo < 1) then
   begin
        taskNo := 1;
        exit;
   end;

   doLoadTask();
end;

function TTopic.sectionByID(topic_id: integer): PSection;
var i: integer;
begin
      result := nil;

      for i := 0 to length(sections) - 1 do
            if (sections[i].topic_id = topic_id) then exit(@sections[i]);
end;

function TTopic.sectionByName(const name: string): PSection;
var i: integer;
begin
      result := nil;

      for i := 0 to length(sections) - 1 do
            if (sections[i].name = name) then exit(@sections[i]);
end;

procedure TTopic.setMode(const Value: TMode);
begin
    mMode := value;
    if mMode = mRetest then taskNo := 1;
end;

procedure TTopic.setResultMaskValue(index: integer; const Value: boolean);
begin
     taskResultMask[index] := value
end;

procedure TTopic.loadAnswears;
begin
    filename := format('%s/%s/%s/answ.xml',[TOPIC_DIR, name, section.name]);
    answears := dm.loadAnswears(dm.TaskDataFile, filename, 1);
    setLength(taskResultMask, length(answears));
end;

procedure TTopic.clearResults;
var i: integer;
begin
     for i := 0 to length(taskResultMask) - 1 do taskResultMask[i] := false;

     section.points := 0;
end;

constructor TTopic.Create();
begin

end;

end.
