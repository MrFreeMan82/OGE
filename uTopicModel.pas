unit uTopicModel;

interface

uses uGlobals, Graphics;

type
  TContentType = (cntUnknown, cntInformation, cntTask);

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
      mContentPageCount: integer;
      mContentType: TContentType;
      mContentFolder: string;
      msection: PSection;

    procedure doLoadPage();
    procedure setMode(const Value: TMode);
    function getResultMask: TResultMask;
    function getResultMaskValue(index: integer): boolean;
    procedure setResultMaskValue(index: integer; const Value: boolean);
  public
      sections: TSectionList;
      content: TBitmap;
      OnAllTaskComplete: POnAllTaskComleteEvent;
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
      property CurrentTask: integer read pageNo;
      property ContentType: TContentType read mContentType;
      property Section : PSection read mSection;

      procedure setSection(ContentType: TContentType; const Value: PSection);
      function isTrueAnswear(answ: double): boolean;
      function sectionByName(const name: string): PSection;
      function sectionByID(topic_id: integer): PSection;
      procedure loadAnswears();
      procedure clearResults();

      constructor Create();
  end;

  TTopicList = array of TTopic;

procedure loadTopicList(out List: TTopicList);
procedure freeTopicList(List: TTopicList);

implementation

uses uData, sysUtils;

{ TModule }

var filename: string;

    taskResultMask: TResultMask;
    answears: TAnswears;

procedure loadTopicList(out List: TTopicList);
begin
    List := dm.loadTopicList;
end;

procedure freeTopicList(List: TTopicList);
var i: integer;
begin
    for i := 0 to length(List) - 1 do freeAndNil(List[i]);
    List := nil;
end;

function TTopic.allTaskComplete: boolean;
begin
   result := getNextFalseTask(pageNo, taskResultMask, true) = ALL_TASK_COMPLETE;
end;

procedure TTopic.doLoadPage;
begin
    filename := format('%s/%s/%s/%s/%d.jpg', [TOPIC_DIR, name, section.name, mContentFolder, pageNo]);

    if assigned(content) then freeAndNil(content);
    content := dm.LoadPage(filename);
end;

procedure TTopic.FirstPage;
begin
   pageNo := 1;
   if (mContentType = cntInformation) and (section.topic_link > 0) then
   begin
        pageNo := section.page_link;
        mSection := sectionByID(section.topic_link);
        if mContentPageCount = 0 then mContentPageCount := mSection.pages_count;
   end;
   doLoadPage();
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
    result := abs(answ - answears[pageNo - 1]) < e;
end;

procedure TTopic.NextPage;
begin
   if mode = mReTest then
   begin
        pageNo := getNextFalseTask(pageNo, taskResultMask);
        if pageNo = ALL_TASK_COMPLETE then
        begin
            mode := mNormal;
            if assigned(OnAllTaskComplete) then OnAllTaskComplete();
            exit;
        end;
   end
   else inc(pageNo);

   if pageNo > mContentPageCount then
   begin
         pageNo := mContentPageCount;
         exit;
   end;

   doLoadPage();
end;

procedure TTopic.PrevPage;
begin
   if mode = mRetest then
   begin
      pageNo := getPrevFalseTask(pageNo, taskResultMask);
      if pageNo = ALL_TASK_COMPLETE then
      begin
           mode := mNormal;
           if assigned(OnAllTaskComplete) then OnAllTaskComplete();
           exit;
      end;
   end
   else dec(pageNo);

   if (pageNo < 1) then
   begin
        pageNo := 1;
        exit;
   end;

   doLoadPage();
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
    if mMode = mRetest then pageNo := 1;
end;

procedure TTopic.setResultMaskValue(index: integer; const Value: boolean);
begin
     taskResultMask[index] := value
end;

procedure TTopic.setSection(ContentType: TContentType; const Value: PSection);
begin
    mSection := value;
    mContentType := ContentType;
    case ContentType of
      cntUnknown:begin mContentPageCount := 0; mContentFolder := ''; end;
      cntInformation: begin mContentPageCount := section.pages_count; mContentFolder := 'Content' end;
      cntTask: begin mContentPageCount := section.task_count; mContentFolder := 'Task' end;
    end;
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
