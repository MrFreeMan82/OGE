unit uSavePoint;

interface
uses uGlobals;

type
  TRecord = record
      key: string;
      value: string;
      deleted: boolean;
  end;

  TRecords = array of TRecord;

  TSavePoint = class
    private
      us_id: integer;
      window: string;
      rec: TRecords;

      function exists(const key : string): boolean;
    public
      procedure addValue(const key, value: string);
      procedure addFloatValue(const key: string; value: double);
      procedure addIntValue(const key: string; value: integer);
      procedure addResultMask(const key: string; value: TResultMask);
      function  asString(const key: string): string;
      function  asInteger(const key: string): integer;
      function  asFloat(const key: string): double;
      function  asResultMask(const key: string): TResultMask;
      function count(): integer;

      procedure Delete(const key: string);
      procedure Save;
      procedure Load();

      constructor Create(user: integer; AWindow: string);
end;

implementation
uses SysUtils, uData;

{ TSavePoint }

procedure TSavePoint.addResultMask(const key: string; value: TResultMask);
var i : integer;
    s: string;
begin
     s := '';
     for i := 0 to length(value) - 1 do
        s := s + intToStr(integer(value[i]));

     addValue(key, s);
end;

procedure TSavePoint.addFloatValue(const key: string; value: double);
begin
    addValue(key, formatFloat('0.00000', value));
end;

procedure TSavePoint.addIntValue(const key: string; value: integer);
begin
    addValue(key, intToStr(value));
end;

procedure TSavePoint.addValue(const key, value: string);
begin
     if not exists(key) then setLength(rec, length(rec) + 1);

     rec[high(rec)].key := key;
     rec[high(rec)].value := value;
     rec[high(rec)].deleted := false;
end;

function TSavePoint.asResultMask(const key: string):TResultMask;
var i,j: integer;
begin
      result := nil;
      for i := 0 to length(rec) - 1 do
      begin
          if (key = rec[i].key) then
          begin
              setLength(result, length(rec[i].value));

              for j := 0 to length(result) - 1 do
                  result[j] := boolean(strToInt(rec[i].value[j + 1]));

              exit;
          end;
      end;
end;

function TSavePoint.asFloat(const key: string): double;
var i: integer;
begin
    result := 0;
    for i := 0 to length(rec) - 1 do
        if (key = rec[i].key) then exit(strToFloatEx((rec[i].value)))
end;

function TSavePoint.asInteger(const key: string): integer;
var i: integer;
begin
    result := -1;
    for i := 0 to length(rec) - 1 do
        if (key = rec[i].key) then exit(strToInt(rec[i].value))
end;

function TSavePoint.asString(const key: string): string;
var i: integer;
begin
    result := '';
    for i := 0 to length(rec) - 1 do
        if (key = rec[i].key) then exit(rec[i].value)
end;

function TSavePoint.count: integer;
begin
    result := length(rec);
end;

constructor TSavePoint.Create(user: integer; AWindow: string);
begin
    us_id := user;
    window := AWindow;
end;

procedure TSavePoint.Delete(const key: string);
var i: integer;
begin
     for i := 0 to length(rec) - 1 do
     begin
        if(rec[i].key = key) then
        begin
            rec[i].deleted := true;
            dm.deleteSavePoint(us_id, window, key);
            exit
        end;
     end;
end;

function TSavePoint.exists(const key: string): boolean;
var i: integer;
begin
    result := false;
    for i := 0 to length(rec)- 1 do
        if(rec[i].key = key) then exit(true)
end;

procedure TSavePoint.Load();
begin
    dm.LoadSavePoint(us_id, window, rec);
end;

procedure TSavePoint.Save;
begin
    dm.CreateSavePoint(us_id, window, rec);
end;

end.
