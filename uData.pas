unit uData;

interface

uses
  SysUtils, Classes, xmldom, XMLIntf, msxmldom, XMLDoc, uGlobals, uTheme, uTests,
  uUTT, uTasks;

type

  Tdm = class(TDataModule)
    xmlDoc: TXMLDocument;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
    fDataFile, fUTTDataFile, fTaskDataFile: string;
    function doLoadTests():TTEstList;
    function doLoadTopics(): TTopicList;
    function doLoadUTT(): TUTTModulesList;
    function doLoadTasks(): TModuleList;
  public
    { Public declarations }
    property  DataFile: string read fDataFile;
    property UTTDataFile: string read fUTTDataFile;
    property TaskDataFile: string read fTaskDataFile;

    function loadAnswears(const DBFile, fileName: string; aVariant: integer):TAnswears;
    function loadTests():TTestList;
    function LoadTopics(): TTopicList;
    function loadUTTTests(): TUTTModulesList;
    function loadTaskModuleList():TModuleList;
  end;

var
  dm: Tdm;

function FindData(const zipFile, name: string; outData: TStream): boolean;

implementation
uses FWZipModifier, FWZipReader;

{$R *.dfm}

{ Tdm }

procedure Tdm.DataModuleCreate(Sender: TObject);
begin
    fDataFile := exePath() + 'OGE.dat';
    fUTTDataFile := exePath() + 'OGE.dat';
    fTaskDataFile := exePath() + 'OGE.dat'
end;

function Tdm.loadAnswears(const DBFile, fileName: string; aVariant: integer): TAnswears;
var s: TStringStream;
    j: integer;
    node: IXMLNode;
    lst: TStringList;
begin
     result := nil;

     lst := TStringList.Create;
     lst.StrictDelimiter := true;
     lst.Delimiter := ';';

     s := TStringStream.Create;
     try
       if not FindData(DBFile, fileName, s) then abort;
       xmlDoc.LoadFromStream(s);
       node := xmlDoc.ChildNodes.FindNode('ANSWEARS');
       if node = nil then abort;
       node := node.ChildNodes.FindNode('V_' + intToStr(aVariant));
       if node = nil then abort;

       lst.DelimitedText := trim(node.Text);
       setLength(result, lst.Count);

       for j := 0 to lst.Count - 1 do
            result[j] := strToFloatEx(lst.Strings[j]);

     finally
          lst.free;
          s.Free;
     end;
end;

function Tdm.doLoadTests: TTEstList;
var i, cnt: integer;
    root, node: IXMLNode;
begin
     result := nil;
     if not xmlDoc.Active then exit;

     root := xmlDoc.ChildNodes.FindNode('TESTS');

     cnt := root.ChildNodes.Count;
     setLength(result, cnt);

     for i := 0 to cnt - 1 do
     begin
          node := root.ChildNodes.Get(i);
          with node.ChildNodes do
          begin
              result[i].dir  := FindNode('DIR').Text;
              result[i].displayLabel := FindNode('DISPLAY_LABEL').Text;
              result[i].id := strToInt(FindNode('ID').Text);
              result[i].topicID := strToint(FindNode('TOPIC').Text);
          end;
     end;
end;

function Tdm.loadTests(): TTestList;
var info: string;
    s: TStringStream;
begin
     result := nil;
     info := TEST_DIR + '/info.xml';
     s := TStringStream.Create;
     try
          if not FindData(dataFile, info, s) then abort;
          xmlDoc.LoadFromStream(s);
          result := doLoadTests();
     finally
          s.Free;
     end;
end;

function Tdm.doLoadTasks: TModuleList;
var i, j, cnt, scnt: integer;
    root, node, sections: IXMLNode;
begin
     result := nil;
     if not xmlDoc.Active then exit;

     root := xmlDoc.ChildNodes.FindNode('MODULES');

     cnt := root.ChildNodes.Count;
     setLength(result, cnt);

     for i := 0 to cnt - 1 do
     begin
          node := root.ChildNodes.Get(i);
          result[i].id := strToInt(node.ChildNodes.FindNode('ID').Text);
          result[i].dir := node.ChildNodes.FindNode('DIR').Text;
          result[i].display_lable := node.ChildNodes.FindNode('DISPLAY_LABEL').Text;

          sections := node.ChildNodes.FindNode('SECTIONS');
          scnt := sections.ChildNodes.Count;
          setLength(result[i].sections, scnt);

          for j := 0 to scnt - 1 do
          begin
               node := sections.ChildNodes.Get(j);
               result[i].sections[j].dir := node.ChildNodes.FindNode('DIR').Text;
               result[i].sections[j].display_lable := node.ChildNodes.FindNode('DISPLAY_LABEL').Text;
               result[i].sections[j].topic_id := strToInt(node.ChildNodes.FindNode('TOPIC_ID').Text);
               result[i].sections[j].points := 0;
          end;
     end;

end;

function Tdm.loadTaskModuleList: TModuleList;
var info: string;
    s: TStringStream;
begin
     result := nil;
     info := TASK_DIR + '/info.xml';
     s := TStringStream.Create;
     try
        if not FindData(TaskDataFile, info, s) then abort;
        xmlDoc.LoadFromStream(s);
        result := doLoadTasks();

     finally
           s.Free;
     end;
end;

function Tdm.doLoadTopics():TTopicList;
var i, cnt: integer;
    root, node: IXMLNode;
begin
     result := nil;
     if not xmlDoc.Active then exit;

     root := xmlDoc.ChildNodes.FindNode('TOPICS');
     if root = nil then exit;

     cnt := root.ChildNodes.Count;
     setLength(result, cnt);

     for i := 0 to cnt - 1 do
     begin
          node := root.ChildNodes.Get(i);
          with node.ChildNodes do
          begin
              result[i].dir  := FindNode('DIR').Text;
              result[i].displayLabel := FindNode('DISPLAY_LABEL').Text;
              result[i].id := strToInt(FindNode('ID').Text);
              result[i].pageCount := strToInt(FindNode('PAGE_CNT').Text);
          end;
     end;
end;

function Tdm.loadTopics(): TTopicList;
var info: string;
    s: TStringStream;
begin
      result := nil;
      info := TOPIC_DIR + '/info.xml';
      s := TStringStream.Create;
      try
          if not FindData(dataFile, info, s) then abort;
          xmlDoc.LoadFromStream(s);
          result := doLoadTopics();
      finally
          s.Free;
      end;
end;

function Tdm.doLoadUTT: TUTTModulesList;
var i, id, cnt: integer;
    root, node: IXMLNode;
begin
     id := 1;
     result := nil;
     if not xmlDoc.Active then exit;

     root := xmlDoc.ChildNodes.FindNode('UTT');
     if root = nil then exit;

     cnt := root.ChildNodes.Count;
     setLength(result, cnt);

     for i := 0 to cnt - 1 do
     begin
         node := root.ChildNodes.Get(i);
         with node.ChildNodes do
         begin
            result[i].id := id;
            result[i].level := TUTTLevel(strToInt(FindNode('LEVEL').Text));
            result[i].lable := FindNode('DISPLAY_LABEL').Text;
            result[i].task_from := strToInt(FindNode('TASK_FROM').Text);
            result[i].task_to := strToInt(FindNode('TASK_TO').Text);
            result[i].visible := boolean(strToInt(FindNode('VISIBLE').Text));
            result[i].color := hexToColor(FindNode('COLOR').Text);
            inc(id);
         end;
     end;
end;

function Tdm.loadUTTTests: TUTTModulesList;
var info: string;
    s: TStringStream;
begin
     result := nil;
     info := UTT_DIR + '/info.xml';
     s := TStringStream.Create;
     try
         if not FindData(UTTDataFile, info, s) then abort;
         xmlDoc.LoadFromStream(s);
         result := doLoadUTT();
     finally
         s.Free;
     end;
end;

function FindData(const zipFile, name: string; outData: TStream): boolean;
var Zip: TFWZipReader;
    i: integer;
begin
    result := false;
    Zip := TFWZipReader.Create;
    try
      zip.LoadFromFile(zipFile);
      for i := 0 to zip.Count - 1 do
      begin
          if result then break;

          if (zip.Item[i].FileName = name) then
          begin
               zip[i].ExtractToStream(outData, '');
               outData.Position := 0;
               result := true;
               break
          end;
      end;
    finally
        zip.Free;
    end;
end;

end.
