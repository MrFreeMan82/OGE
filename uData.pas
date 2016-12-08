unit uData;

interface

uses
  SysUtils, Classes, Forms, xmldom, XMLIntf, msxmldom, XMLDoc, dialogs;


const
      ALL_TASK_COMPLETE = 0;

      VARIANT_COUNT = 10;
      TASK_COUNT = 10;

      UTT_1_ALG_TASK_COUNT = 8;
      UTT_1_GEO_TASK_COUNT = 5;
      UTT_1_REAL_MATH_TASK_COUNT = 7;

      UTT_2_ALG_TASK_COUNT = 3;
      UTT_2_GEO_TASK_COUNT = 3;

      UTT_TASK_COUNT = UTT_1_ALG_TASK_COUNT + UTT_1_GEO_TASK_COUNT +
        UTT_1_REAL_MATH_TASK_COUNT + UTT_2_ALG_TASK_COUNT + UTT_2_GEO_TASK_COUNT;

const CALC_POINTS_FROM_V = 6;

const TOPIC_DIR = 'Topics';
      TEST_DIR = 'Tests';
      UTT_DIR = 'UTT';


type
  TMode = (mNormal, mReTest);

  TTopicInfo = record
      id: integer;
      pageCount: integer;
      dir: string;
      displayLabel: string;
  end;

  TTopicList = array of TTopicInfo;
  TResultMask = array of boolean;

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

  TAnswears = array of double;

  Tdm = class(TDataModule)
    xmlDoc: TXMLDocument;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
    fDataFile: string;
    function doLoadTests():TTEstList;
    function doLoadTopics(): TTopicList;
  public
    { Public declarations }
    property  DataFile: string read fDataFile;
    function loadAnswears(const fileName: string; aVariant: integer):TAnswears;
    function loadTests():TTestList;
    function LoadTopics(): TTopicList;
    function readPwd(): string;
  end;

var
  dm: Tdm;

function strToFloatEx(s: string): double;

function exePath(): string;
function getTestByTopic(topicID: integer; const tests: TTestList): PTestInfo;
function FindData(const zipFile, name: string; outData: TStream): boolean;

function getNextFalseTask(currentTask: integer; taskResultMask:TResultMask; fromBegin: boolean = false): integer;
function getPrevFalseTask(currentTask: integer; taskResultMask:TResultMask): integer;

implementation
uses FWZipModifier, FWZipReader;

{$R *.dfm}

{ Tdm }

function allComplete(taskResultMask:TResultMask): boolean;
var i: integer;
begin
     result := true;
     for i := 0 to length(taskResultMask) - 1 do
           if taskResultMask[i] = false then exit(false)
end;

function getPrevFalseTask(currentTask: integer; taskResultMask:TResultMask): integer;
begin
     if allComplete(taskResultMask) then exit(ALL_TASK_COMPLETE);

     result := currentTask - 1;

     while (result >= 1) do
     begin
         if taskResultMask[result - 1] = false then break;
         dec(result);
     end;

     if result < 1 then
          result := getNextFalseTask(result, taskResultMask);
end;

function getNextFalseTask(currentTask: integer; taskResultMask:TResultMask; fromBegin: boolean = false): integer;
begin
     if allComplete(taskResultMask) then exit(ALL_TASK_COMPLETE);

     if fromBegin then result := 1 else result := currentTask + 1;

     while result <= length(taskResultMask) do
     begin
         if taskResultMask[result - 1] = false then break;
         inc(result);
     end;

    if result > length(taskResultMask) then result := getPrevFalseTask(result, taskResultMask);
end;

procedure Tdm.DataModuleCreate(Sender: TObject);
begin
    fDataFile := exePath() + 'OGE.dat';
end;

function strToFloatEx(s: string): double;
var sett: TFormatSettings;
begin
    if pos(',', s) > 0 then sett.DecimalSeparator := ','
    else  sett.DecimalSeparator := '.';

    result := strToFloat(s, sett);
end;

function exePath: string;
begin
     result := ExtractFilePath(Application.ExeName);
end;

function getTestByTopic(topicID: integer; const tests: TTestList): PTestInfo;
var i: integer;
begin
    result := nil;

    for i := 0 to length(tests) - 1 do
          if tests[i].topicID = topicID then result := @tests[i];
end;

function Tdm.loadAnswears(const fileName: string; aVariant: integer): TAnswears;
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
       if not FindData(dataFile, fileName, s) then abort;
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

function Tdm.readPwd: string;
var s: TStringStream;
begin
     result := '';
     s := TStringStream.Create;
     try
       if not FindData(dm.DataFile,  '/pwd', s) then abort;
       result := trim(s.ToString);
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
          end;
      end;
    finally
        zip.Free;
    end;
end;

end.
