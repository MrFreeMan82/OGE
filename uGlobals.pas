unit uGlobals;

interface
uses GdiPlus, GdiPlusHelpers, Classes;

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
       points: integer;
       color: TGPColor;
  end;

  TUTTModulesList = array of TUTTModule;

  TUTTInfo = record
     modules : TUTTModulesList;
     taskResultMask: TResultMask;
  end;

  TLine = record
      p1, p2: TGPPointF;
      len: double;
  end;

function HexToColor(sColor: string): TGPColor;
function strToFloatEx(s: string): double;

function exePath(): string;
function getTestByTopic(topicID: integer; const tests: TTestList): PTestInfo;

function getNextFalseTask(currentTask: integer; taskResultMask:TResultMask; fromBegin: boolean = false): integer;
function getPrevFalseTask(currentTask: integer; taskResultMask:TResultMask): integer;

function lineLen(line:TLine):double;
function rotatePoint(angle:double; center, p: TGPpointF): TGPPointF;
function rotateLine(angle: double; line: Tline; center: TGPPointF): Tline;
procedure measureDisplayStringWidthAndHeight(Graphic: IGPGraphics; Font:IGPFont; text: string; var width, height: double);

implementation
uses SysUtils, math, Forms;

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

function allComplete(const taskResultMask:TResultMask): boolean;
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

function strToFloatEx(s: string): double;
var sett: TFormatSettings;
begin
    if pos(',', s) > 0 then sett.DecimalSeparator := ','
    else  sett.DecimalSeparator := '.';

    result := strToFloat(s, sett);
end;

end.
