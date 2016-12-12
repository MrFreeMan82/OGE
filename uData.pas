unit uData;

interface

uses
  SysUtils, Classes, xmldom, XMLIntf, msxmldom, XMLDoc, uGlobals;

type

  Tdm = class(TDataModule)
    xmlDoc: TXMLDocument;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
    fDataFile: string;
    function doLoadTests():TTEstList;
    function doLoadTopics(): TTopicList;
    function doLoadUTT(): TUTTInfo;
  public
    { Public declarations }
    property  DataFile: string read fDataFile;
    function loadAnswears(const fileName: string; aVariant: integer):TAnswears;
    function loadTests():TTestList;
    function LoadTopics(): TTopicList;
    function loadUTTTests(): TUTTInfo;
    function readPwd(): string;
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

function Tdm.doLoadUTT: TUTTInfo;
var i, id, cnt: integer;
    root, node: IXMLNode;
begin
     id := 1;
     result.modules := nil;
     if not xmlDoc.Active then exit;

     root := xmlDoc.ChildNodes.FindNode('UTT');
     if root = nil then exit;

     cnt := root.ChildNodes.Count;
     setLength(result.modules, cnt);

     for i := 0 to cnt - 1 do
     begin
         node := root.ChildNodes.Get(i);
         with node.ChildNodes do
         begin
            result.modules[i].id := id;
            result.modules[i].level := TUTTLevel(strToInt(FindNode('LEVEL').Text));
            result.modules[i].lable := FindNode('DISPLAY_LABEL').Text;
            result.modules[i].task_from := strToInt(FindNode('TASK_FROM').Text);
            result.modules[i].task_to := strToInt(FindNode('TASK_TO').Text);
            result.modules[i].visible := boolean(strToInt(FindNode('VISIBLE').Text));
            result.modules[i].color := hexToColor(FindNode('COLOR').Text);
            inc(id);
         end;
     end;
end;

function Tdm.loadUTTTests: TUTTInfo;
var info: string;
    s: TStringStream;
begin
     result.modules := nil;
     info := UTT_DIR + '/info.xml';
     s := TStringStream.Create;
     try
         if not FindData(dataFile, info, s) then abort;
         xmlDoc.LoadFromStream(s);
         result := doLoadUTT();
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
