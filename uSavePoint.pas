unit uSavePoint;

interface

type
  TRecord = record
      key: string;
      value: string;
  end;

  TRecords = array of TRecord;

  TSavePoint = class
    private
      us_id: integer;
      window: string;
      rec: TRecords;

    public
      procedure addValue(const key, value: string);
      procedure addFloatValue(const key: string; value: double);
      procedure addIntValue(const key: string; value: integer);
      procedure addArrayOfBool(const key: string; value: array of boolean);
      procedure Save;
      procedure Load(us_id: integer; window: string);
end;

implementation
uses SysUtils, uGlobals, uData;

{ TSavePoint }

procedure TSavePoint.addArrayOfBool(const key: string; value: array of boolean);
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
     setLength(rec, length(rec) + 1);
     rec[high(rec)].key := key;
     rec[high(rec)].value := value;
end;

procedure TSavePoint.Load(us_id: integer; window: string);
begin
    dm.LoadSavePoint(us_id, window, rec);
end;

procedure TSavePoint.Save;
begin
    dm.CreateSavePoint(rec);
end;

end.
