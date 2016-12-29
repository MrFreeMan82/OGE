unit uGlobals;

interface
uses GdiPlus, GdiPlusHelpers, Classes, Graphics;

const
      e = 0.001;
      ALL_TASK_COMPLETE = 0;
      UTT_TASK_COUNT = 26;

const TOPIC_DIR = 'Topics';
      UTT_DIR = 'UTT';
      COLLECTIVE = 'Collective';
      ZACHET = 'зачтено';
      NOT_ZACHET = 'не зачтено';


//const COLLECTIVE_TASK_ID = 4;

const USR_FIELD_COUNT = 4;

type
  TTopicType = (tUnknown, tIndividual, tCollective);

  TaxisAngle = double;

  TMode = (mNormal, mReTest);

  PResultMask = ^TResultMask;
  TResultMask = array of boolean;

  TAnswears = array of double;

  TLine = record
      p1, p2: TGPPointF;
      len: double;
  end;

  POnAllTaskComleteEvent = procedure of object;

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

function LoadPage(const path: string): TBitmap;
function loadAnswears(const DBFile, fileName: string; aVariant: integer): TAnswears;

function FindData(const zipFile, name: string; outData: TStream): boolean;

procedure extract(fromList: TStringList; key: string; toList: TStringList);
procedure join(list: TStringList);

implementation
uses SysUtils, math, Forms, ActiveX, uData, XMLIntf, FWZipReader, dialogs;

procedure join(list: TStringList);
var i, len: integer;
    s: string;
begin
     for i := list.Count - 1 downto 0 do
     begin
           s := list.Strings[i];
           len := length(s);
           if s[len] = '=' then
           begin
                s[len] := #0;
                s := trim(s);
                list.Strings[i] := s + list.Strings[i + 1];
                list.Delete(i+1);
           end;
     end;
end;

procedure extract(fromList: TStringList; key: string; toList: TStringList);
var i: integer;
    b,e: string;
begin
     i := 0;
     b := '<' + key + '>';
     e := '</' + key + '>';

     while i <= (fromList.Count - 1) do
     begin
          while (i < fromList.Count) and (pos(b, fromList.Strings[i]) = 0) do inc(i);
          inc(i);

          while (i < fromList.Count) and (pos(e, fromList.Strings[i]) = 0) do
          begin
               toList.Add(trim(fromList.Strings[i]));
               inc(i);
          end;
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

function loadAnswears(const DBFile, fileName: string; aVariant: integer): TAnswears;
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
       dm.xmlDoc.LoadFromStream(s);
       node := dm.xmlDoc.ChildNodes.FindNode('ANSWEARS');
       if node = nil then abort;
       node := node.ChildNodes.FindNode('V_' + intToStr(aVariant));
       if node = nil then abort;

       lst.DelimitedText := trim(node.Text);
       setLength(result, lst.Count);


       for j := 0 to lst.Count - 1 do
       try
        result[j] := strToFloatEx(lst.Strings[j]);
       except
           showMessage('Ошибка загрузки ответа № ' + intTOStr(j + 1));
       end;

     finally
          lst.free;
          s.Free;
     end;
end;

function LoadPage(const path: string): TBitmap;
var mem: TMemoryStream;
    adptr: IStream;
    graphic: IGPGraphics;
    source, dest: TGPRectF;
    gdiBmp: IGPBitmap;
begin
     result := nil;
     mem := TMemoryStream.Create;

     try
        if FindData(dm.DataFile, path, mem) then
        begin
          adptr  := TStreamAdapter.Create(mem);
          gdiBmp := TGPBitmap.Create(adptr);

          source.InitializeFromLTRB(0, 0, gdiBmp.Width, gdiBmp.Height);
          dest.InitializeFromLTRB(0, 0, 900, source.Height);

          streach(source, dest.Width, dest.Height, dest);

          result := TBitMap.Create;
          result.Width := trunc(dest.Width);
          result.Height := trunc(dest.Height);

          graphic := TGPGraphics.Create(result.Canvas.Handle);
          graphic.InterpolationMode := InterpolationModeHighQualityBicubic;
          graphic.DrawImage(gdiBmp, dest);
        end;
     finally
         mem.Free;
     end;
end;

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
