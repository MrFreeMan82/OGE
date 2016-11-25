unit uData;

interface

uses
  SysUtils, Classes, Forms, xmldom, XMLIntf, msxmldom, XMLDoc, FWZipReader, dialogs;


const VARIANT_COUNT = 10;
      TASK_COUNT = 10;

const CALC_POINTS_FROM_V = 6;

const TOPIC_DIR = 'Topics';
      TEST_DIR = 'Tests';


type
  TStreamType = (tString, tMemory);

  TTopicInfo = record
      id: integer;
      pageCount: integer;
      name: string;
      dir: string;
      displayLabel: string;
  end;

  TTopicList = array of TTopicInfo;

  TTestInfo = record
      id: integer;
      topic: integer;
      name: string;
      dir: string;
      displayLabel: string;
  end;
  TTestList = array of TTestInfo;

  TUserResult = record
      topic: TTopicInfo;
      taskResult: array[0..VARIANT_COUNT - 1, 0..TASK_COUNT - 1] of boolean;
      points: double;
  end;

  TUserResultList = array of TUserResult;

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
  end;

var
  dm: Tdm;

function strToFloatEx(s: string): double;

function exePath(): string;
function getTestListByTopic(topicID: integer; const tests: TTestList): TTestList;
function FindData(const zipFile, name: string; dataType: TStreamType): TStream;

implementation

{$R *.dfm}

{ Tdm }

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

function getTestListByTopic(topicID: integer; const tests: TTestList): TTestList;
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
     s := TStringStream(FindData(dataFile, fileName, tString));
     try
       if s = nil then abort;
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
              result[i].name := FindNode('NAME').Text;
              result[i].dir  := FindNode('DIR').Text;
              result[i].displayLabel := FindNode('DISPLAY_LABEL').Text;
              result[i].id := strToInt(FindNode('ID').Text);
              result[i].topic := strToint(FindNode('TOPIC').Text);
          end;
     end;
end;

function Tdm.loadTests(): TTestList;
var info: string;
    s: TStringStream;
begin
     result := nil;
     info := TEST_DIR + '/info.xml';
     s := TStringStream(FindData(dataFile, info, tString));
     try
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
              result[i].name := FindNode('NAME').Text;
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
      s := TStringStream(FindData(dataFile, info, tString));
      try
          xmlDoc.LoadFromStream(s);
          result := doLoadTopics();
      finally
          s.Free;
      end;
end;

function FindData(const zipFile, name: string; dataType: TStreamType): TStream;
var Zip: TFWZipReader;
    i: integer;
begin
    result := nil;
    Zip := TFWZipReader.Create;
    try
      zip.LoadFromFile(zipFile);
      for i := 0 to zip.Count - 1 do
      begin
          if assigned(result) then break;

          if (zip.Item[i].FileName = name) then
          begin
               case dataType of
                 tString: result := TStringStream.Create('');
                 tMemory: result := TMemoryStream.Create;
                 else exit;
               end;
               zip[i].ExtractToStream(result, '');
               result.Position := 0;
          end;
      end;
    finally
        zip.Free;
    end;
end;

end.
