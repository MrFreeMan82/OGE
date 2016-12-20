unit uGlobals;

interface
uses GdiPlus, GdiPlusHelpers, Classes;

const
      e = 0.001;
      ALL_TASK_COMPLETE = 0;
      UTT_TASK_COUNT = 26;

const TOPIC_DIR = 'Topics';
      UTT_DIR = 'UTT';

const USR_FIELD_COUNT = 4;

type
  TaxisAngle = double;

  TMode = (mNormal, mReTest);

  PResultMask = ^TResultMask;
  TResultMask = array of boolean;

  TAnswears = array of double;

  TLine = record
      p1, p2: TGPPointF;
      len: double;
  end;

procedure Streach(source: TGPRectF; destWidth, destHeight: single; out dest: TGPrectF);

function HexToColor(sColor: string): TGPColor;
function strToFloatEx(s: string): double;

function exePath(): string;

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

procedure Streach(source: TGPRectF; destWidth, destHeight: single; out dest: TGPrectF);
const e = 0.0001;
var x_ratio, y_ratio, ratio, w_or, h_or, w, h: single;
    use_x_ratio: boolean;
begin
     w := DestWidth;
     h := DestHeight ;
     w_or := source.Width;
     h_or := source.Height;

     x_ratio := w / w_or;
     y_ratio := h / h_or;

     if x_ratio < (y_ratio - e) then ratio := x_ratio else ratio := y_ratio;

     use_x_ratio := abs(x_ratio - e) < ratio;
     if use_x_ratio then dest.Width := w else dest.Width := trunc(w_or * ratio);
     if not use_x_ratio then dest.Height := h  else dest.Height := trunc(h_or * ratio);
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
