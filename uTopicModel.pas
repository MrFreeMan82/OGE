unit uTopicModel;

interface

uses uGlobals, Graphics, uSavePoint, Classes;

type
  TContentFolder = (cntUnknown, cntContent, cntTask);

  PSection = ^TSection;
  TSection = record
    topic_id: integer;
    task_count: integer;
    pages_count: integer;
    name: string;
    display_lable: string;
    visible: boolean;
  end;

  TSectionList = array of TSection;

  TTopic = class
 private
      mid: integer;
      mname: string;
      display_lable: string;
      mMode: Tmode;
      pageNo: integer;
      mContentPageCount: integer;
      mContentFolderType: TContentFolder;
      mContentFolder: string;
      msection: PSection;

    procedure doLoadPage();
    procedure setMode(const Value: TMode);
    function getResultMask: TResultMask;
    function getResultMaskValue(index: integer): boolean;
    procedure setResultMask(const Value: TResultMask);
    procedure setPage(const Value: integer);
    function getTaskCount: integer;
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
      property ID: integer read mid;
      property Name: string read mname;
      property ResultMask: TResultMask read getResultMask write setResultMask;
      property ResultMaskValue[index: integer]: boolean read getResultMaskValue;
      property ContentType: TContentFolder read mContentFolderType;
      property Section : PSection read mSection;
      property Page: integer read PageNo write setPage;
      property TaskCount: integer read getTaskCount;

      procedure setSection(ContentType: TContentFolder; const Value: PSection);
      function isTrueAnswear(answ: double; taskNo: integer): boolean;
      function sectionByName(const name: string): PSection;
      function sectionByID(topic_id: integer): PSection;
      procedure loadAnswears();
      procedure clearResults();
  end;

  TTopicList = class(TList)
    public
       procedure Free;
       function getTopicByID(id: integer): TTopic;
       constructor Create();
  end;

implementation

uses uData, sysUtils, uOGE, XMLIntf;

var filename: string;

    taskResultMask: TResultMask;
    answears: TAnswears;

{ TTopicList }

constructor TTopicList.Create;
var info: string;
    s: TStringStream;
    i, j, scnt: integer;
    item:TTopic;
    root, node, sectionNodes: IXMLNode;
begin
     inherited Create;

     info := TOPIC_DIR + '/info.xml';
     s := TStringStream.Create;
     try
        if not FindData(dm.DataFile, info, s) then abort;
        dm.xmlDoc.LoadFromStream(s);
        root := dm.xmlDoc.ChildNodes.FindNode('MODULES');

        Capacity := root.ChildNodes.Count;

        for i := 0 to Capacity - 1 do
        begin
          item := TTopic.Create;
          Add(item);
          node := root.ChildNodes.Get(i);
          item.mid := strToInt(node.ChildNodes.FindNode('ID').Text);
          item.mname := node.ChildNodes.FindNode('DIR').Text;
          item.Caption := node.ChildNodes.FindNode('DISPLAY_LABEL').Text;

          sectionNodes := node.ChildNodes.FindNode('SECTIONS');
          scnt := sectionNodes.ChildNodes.Count;
          setLength(item.sections, scnt);

          for j := 0 to scnt - 1 do
          with item do
          begin
                node := sectionNodes.ChildNodes.Get(j);
                with node.ChildNodes do
                begin
                   sections[j].name := FindNode('DIR').Text;
                   sections[j].display_lable := FindNode('DISPLAY_LABEL').Text;
                   sections[j].topic_id := strToInt(FindNode('TOPIC_ID').Text);
                   sections[j].task_count := strToInt(FindNode('TASK_COUNT').Text);
                   sections[j].pages_count := strToInt(FindNode('PAGES_COUNT').Text);
                   sections[j].visible := FindNode('VISIBLE').Text = '0';
                end;
          end;
        end;
     finally
          s.Free;
     end;
end;

procedure TTopicList.Free;
var i: integer;
begin
   for i := 0 to Count - 1 do freeAndNil(List[i]);
   inherited Free;
end;

function TTopicList.getTopicByID(id: integer): TTopic;
var i: integer;
begin
     result := nil;
     for i := 0 to Count - 1 do
        if(id = TTopic(Items[i]).ID) then exit(TTopic(Items[i]));
end;

{ TModule }

function TTopic.allTaskComplete: boolean;
begin
   result := getNextFalseTask(pageNo, taskResultMask, true) = ALL_TASK_COMPLETE;
end;

procedure TTopic.doLoadPage;
begin
    filename := format('%s/%s/%s/%s/%d.jpg', [TOPIC_DIR, name, section.name, mContentFolder, pageNo]);

    if assigned(content) then freeAndNil(content);
    content := LoadPage(filename);
end;

procedure TTopic.FirstPage;
begin
   pageNo := 1;
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

function TTopic.getTaskCount: integer;
var i: Integer;
begin
    result := 0;
    if not assigned(sections) then exit;

    for i := 0 to length(sections) - 1 do
        result := result + sections[i].task_count;
end;

function TTopic.isTrueAnswear(answ: double; taskNo: integer): boolean;
begin
    result := abs(answ - answears[pageNo - 1]) < e;
    taskResultMask[taskNo - 1] := result;
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

procedure TTopic.setPage(const Value: integer);
begin
    if(value >= 1) and (value <= mContentPageCount) then
    begin
        pageNo := value - 1;
        NextPage;
    end;

end;

procedure TTopic.setResultMask(const Value: TResultMask);
begin
     taskResultMask := value;
end;

procedure TTopic.setSection(ContentType: TContentFolder; const Value: PSection);
begin
    mMode := mNormal;
    mSection := value;
    mContentFolderType := ContentType;

    case ContentType of
      cntUnknown:begin mContentPageCount := 0; mContentFolder := ''; end;
      cntContent: begin mContentPageCount := section.pages_count; mContentFolder := 'Content' end;
      cntTask: begin mContentPageCount := section.task_count; mContentFolder := 'Task' end;
    end;
end;

procedure TTopic.loadAnswears;
begin
    filename := format('%s/%s/%s/answ.xml',[TOPIC_DIR, name, section.name]);
    answears := uGlobals.loadAnswears(dm.DataFile, filename, 1);
    if taskResultMask = nil then
    begin
         setLength(taskResultMask, length(answears));
         clearResults();
    end;
end;

procedure TTopic.clearResults;
var i: integer;
begin
     for i := 0 to length(taskResultMask) - 1 do taskResultMask[i] := false;
end;

end.
