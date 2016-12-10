unit uData;

interface

uses
  SysUtils, Classes, Forms, xmldom, XMLIntf, msxmldom, XMLDoc, dialogs, GdiPlus, GdiPlusHelpers;

const
      ALL_TASK_COMPLETE = 0;

      VARIANT_COUNT = 10;
      TASK_COUNT = 10;
      UTT_TASK_COUNT = 26;

const CALC_POINTS_FROM_V = 6;

const TOPIC_DIR = 'Topics';
      TEST_DIR = 'Tests';
      UTT_DIR = 'UTT';


type
  TUTTLevel = (lvlLow, lvlHigh);

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

  PUTTModule = ^TUTTModule;
  TUTTModule = record
       id:integer;
       level: TUTTLevel;
       lable: string;
       task_from, task_to: integer;
       visible: boolean;
       color: TGPColor;
  end;

  TUTTModulesList = array of TUTTModule;

  TUTTInfo = record
     modules : TUTTModulesList;
     taskResultMask: TResultMask;
     points: double;
  end;

  TLine = record
      p1, p2: TGPPointF;
      len: double;
  end;

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

function strToFloatEx(s: string): double;

function exePath(): string;
function getTestByTopic(topicID: integer; const tests: TTestList): PTestInfo;
function FindData(const zipFile, name: string; outData: TStream): boolean;

function getNextFalseTask(currentTask: integer; taskResultMask:TResultMask; fromBegin: boolean = false): integer;
function getPrevFalseTask(currentTask: integer; taskResultMask:TResultMask): integer;

function lineLen(line:TLine):double;
function rotatePoint(angle:double; center, p: TGPpointF): TGPPointF;
function rotateLine(angle: double; line: Tline; center: TGPPointF): Tline;
procedure measureDisplayStringWidthAndHeight(Graphic: IGPGraphics; Font:IGPFont; text: string; var width, height: double);

implementation
uses FWZipModifier, FWZipReader, math, windows;

{$R *.dfm}

{ Tdm }

function HexToColor(sColor: string): TGPColor;
begin
   result.A := $FF;
   result.R := strToInt('$' + copy(sColor, 1, 2));
   result.G := strToInt('$' + copy(sColor, 3, 2));
   result.B := strToInt('$' + copy(sColor, 5, 2));
end;

function lineLen(line: TLine): double;
begin
    result := sqrt(sqr(line.p1.X - line.p2.X) + sqr(line.p1.Y - line.p2.Y));
end;

function rotateLine(angle: double; line: Tline; center: TGPPointF): TLine;
begin
     result.p1 := rotatePoint(angle, center, line.p1);
     result.p2 := rotatePoint(angle, center, line.p2);
     result.len := line.len;
end;

function rotatePoint(angle: double; center, p: TGPpointF): TGPPointF;
var radAngle, at, len, s, c: extended;
begin
    radAngle := angle * pi / 180;
    len := Sqrt(sqr(p.X - center.X) + sqr(p.Y - center.Y));
    at  := ArcTan2(p.Y - center.Y, p.X - center.X);
    sinCos(radAngle + at, s, c);
    result.X := center.X + len * c;
    result.Y := center.Y + len * s;
   { result.X := centerX + (p.X - centerX) * c - (p.Y - centerY) * s;
    result.Y := centerY + (p.X - centerX) * s - (p.Y - centerY) * c; }
end;

procedure measureDisplayStringWidthAndHeight(Graphic: IGPGraphics; Font:IGPFont; text: string; var width, height: double);
var StringFormat: IGPStringFormat;
    R: TGPRectF;
    CharRanges: IGPCharacterRanges;
    CharRange: TGPCharacterRange;
    Regions: IGPRegions;
begin
    R.Initialize(0, 0, 1000, 1000);
    CharRanges := TGPArray<TGPCharacterRange>.Create(1);
    CharRange.Initialize(0, Length(Text));
    CharRanges[0] := CharRange;
    StringFormat:= TGPStringFormat.Create;
    StringFormat.SetMeasurableCharacterRanges(CharRanges);
    Regions := Graphic.MeasureCharacterRanges(Text, Font, R, StringFormat);
    Regions[0].GetBounds(R, Graphic);
    Width:=R.Right; //ширина без отступов, если нужно с отступами R.Right
    Height:=R.Height; //можно так же получить из IGPFont
end;

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

function Tdm.doLoadUTT: TUTTInfo;
var i, id, cnt: integer;
    root, node: IXMLNode;
begin
     id := 1;
     result.modules := nil;
     result.points := 0;
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
     result.points := 0;
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
