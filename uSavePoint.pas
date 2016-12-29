unit uSavePoint;

interface
uses uGlobals, Classes;

type
  TRecord = record
      key: string;
      value: string;
      deleted: boolean;
      sync_record: boolean;
  end;

  TRecords = array of TRecord;

  TSavePoint = class
    private
      us_id: integer;
      mwindow: string;
      rec: TRecords;
      sql: TStringList;

      function exists(const key : string; out index: integer): boolean;
    public
      property Window: string read mWindow;

      procedure addValue(const key, value: string);
      procedure addFloatValue(const key: string; value: double);
      procedure addIntValue(const key: string; value: integer);
      procedure addResultMask(const key: string; value: TResultMask);
      function  asString(const key: string): string;
      function  asInteger(const key: string): integer;
      function  asFloat(const key: string): double;
      function  asResultMask(const key: string): TResultMask;
      function count(): integer;
      class procedure fromCSV(delimChar: Char; const dataList: TStringList);

      procedure Clear;
      procedure Delete(const key: string);
      procedure Save;
      procedure Load();


      constructor Create(user: integer; AWindow: string);
      procedure Free;

end;

implementation
uses SysUtils, uData, SQLite3, SQLiteTable3, uUser;

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
var i: integer;
begin
     if exists(key, i) then
     begin
         rec[i].key := key;
         rec[i].value := value;
         rec[i].deleted := false;
     end
     else begin
          setLength(rec, length(rec) + 1);
          rec[high(rec)].key := key;
          rec[high(rec)].value := value;
          rec[high(rec)].deleted := false;
     end;
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

procedure TSavePoint.Clear;
begin
    us_id := 0;
    mWindow := '';
    rec := nil;
end;

function TSavePoint.count: integer;
begin
    result := length(rec);
end;

constructor TSavePoint.Create(user: integer; AWindow: string);
begin
    sql := TStringList.Create;
    us_id := user;
    mwindow := AWindow;
end;

procedure TSavePoint.Delete(const key: string);
var i: integer;
begin
     for i := 0 to length(rec) - 1 do
     begin
        if(rec[i].key = key) then
        begin
            rec[i].deleted := true;
            sql.Clear;
            sql.Add(format(
             'DELETE FROM SAVEPOINT WHERE ' +
                'US_ID = %d AND WINDOW = "%s" AND ' +
                      'KEY_FIELD = "%s"', [us_id, mwindow, key])
             );

            dm.sqlite.ExecSQL(ansistring(sql.Text));
            exit
        end;
     end;
end;

function TSavePoint.exists(const key: string; out index: integer): boolean;
var i: integer;
begin
    result := false;
    for i := 0 to length(rec)- 1 do
        if(rec[i].key = key) then
            begin index := i; exit(true) end;
end;

procedure TSavePoint.Free;
begin
    sql.Free;
end;

class procedure TSavePoint.fromCSV(delimChar: Char; const dataList: TStringList);
var i: integer;
    csvList: TStringList;
    sp: TSavePoint;
    key, value: string;
begin
     sp := nil;
     csvList := TStringList.Create;
     sp := TSavePoint.Create(0, '');
     try
         csvList.Delimiter := delimChar;
         csvList.StrictDelimiter := true;

         for i := 0 to dataList.Count - 1 do
         begin
             sp.Clear;
             csvList.Clear;
             csvList.DelimitedText := trim(dataList.Strings[i]);

             key := trim(csvList.Strings[3]);
             value := trim(csvList.Strings[4]);
             sp.us_id := strToInt(trim(csvList.Strings[0]));
             sp.mWindow := trim(csvList.Strings[2]);
             sp.addValue(key, value);
             sp.Save;
         end;
     finally
         freeAndNil(sp);
         csvList.Free;
     end;
end;

procedure TSavePoint.Load();
var i, cnt: integer; table: TSQLiteUniTable;
begin
    sql.Clear;
    sql.Add(format(
        'SELECT COUNT(*)FROM SAVEPOINT ' +
            'WHERE US_ID = %d AND WINDOW = "%s"', [us_id, mwindow])
    );
    try
      table := TSQLiteUniTable.Create(dm.sqlite, ansiString(sql.Text));
      cnt := table.FieldAsInteger(0);
    finally
        freeAndNil(table);
    end;

    if (cnt = 0) then exit;
    setLength(rec, cnt);

    sql.Clear;
    sql.Add(format(
        'SELECT KEY_FIELD, VALUE_FIELD FROM SAVEPOINT ' +
            'WHERE US_ID = %d AND WINDOW = "%s"', [us_id, mwindow]));

    try
      table := TSQLiteUniTable.Create(dm.sqlite, ansiString(sql.Text));

      for i := 0 to cnt - 1 do
      begin
           rec[i].key := table.FieldAsString(0);
           rec[i].value := table.FieldAsString(1);

           table.Next;
      end;
    finally
          freeAndNil(table)
    end;
  //  dm.LoadSavePoint(us_id, window, rec);
end;

procedure TSavePoint.Save;
var i, cnt: integer; table: TSQLiteUniTable;
begin
    for i := 0 to length(rec) - 1 do
    begin
        if rec[i].deleted then continue;

        sql.Clear;
        sql.Add(format(
            'SELECT COUNT(*)FROM SAVEPOINT ' +
                'WHERE US_ID = %d AND WINDOW = "%s" AND KEY_FIELD = "%s"',
                [us_id, mwindow, rec[i].key])
        );
        try
          table := TSQLiteUniTable.Create(dm.sqlite, ansiString(sql.Text));
          cnt := table.FieldAsInteger(0);
        finally
              freeAndNil(table)
        end;

        sql.Clear;
        if cnt = 0 then
        begin
             sql.Add(format(
                'INSERT INTO SAVEPOINT(US_ID, WINDOW, KEY_FIELD, VALUE_FIELD) ' +
                  'VALUES(%d, "%s", "%s", "%s")',
                      [us_id, mwindow, rec[i].key, rec[i].value])
             );

        end
        else begin
            sql.Add(format(
                'UPDATE SAVEPOINT ' +
                'SET VALUE_FIELD = "%s" ' +
                'WHERE US_ID = %d AND WINDOW = "%s" AND KEY_FIELD = "%s"',
                [rec[i].value, us_id, mwindow, rec[i].key])
            );
        end;
        dm.sqlite.ExecSQL(ansistring(sql.Text));
    end;
end;

end.
