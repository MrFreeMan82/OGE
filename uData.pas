unit uData;

interface

uses
  SysUtils, Classes, xmldom, XMLIntf, msxmldom, XMLDoc, uGlobals, uTheme,
  uUTT, uTasks, Graphics, uTopicModel, SQLite3, SQLiteTable3, uUser, uSavePoint;

type

  Tdm = class(TDataModule)
    xmlDoc: TXMLDocument;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    { Private declarations }
    sqlite : TSQLiteDatabase;
    fDataFile, fUTTDataFile, fTaskDataFile, sqliteFile: string;
    sql: TStringList;

    function doLoadUTT(): TUTTModulesList;
    function doLoadTopicList():TTopicList;

    procedure createTableUser();
    procedure createTableSavePoints();
    procedure dropTable(const tableName: string);

    procedure loadUserFromFile(fl: string);
  public
    { Public declarations }
    property  DataFile: string read fDataFile;
    property UTTDataFile: string read fUTTDataFile;
    property TaskDataFile: string read fTaskDataFile;

    function loadAnswears(const DBFile, fileName: string; aVariant: integer):TAnswears;
    function LoadPage(const path: string): TBitmap;
    function loadUTTTests(): TUTTModulesList;
    function loadTopicList(): TTopicList;

    function loadUserList(): TUserList;
    procedure addUser(usr: PUser);
    procedure editUser(usr: Puser);
    procedure deleteUser(id: integer);

    procedure CreateSavePoint(us_id: integer; window: string; records: TRecords);
    procedure LoadSavePoint(us_id: integer; window: string; out records: TRecords);
    procedure deleteSavePoint(us_id: integer; window, key: string);

  end;

var
  dm: Tdm;

function FindData(const zipFile, name: string; outData: TStream): boolean;

implementation
uses FWZipModifier, FWZipReader, ActiveX, GdiPlus, GdiPlusHelpers, uOGE;

{$R *.dfm}

{ Tdm }

procedure Tdm.addUser(usr: PUser);
begin
     sql.Clear;
     sql.Add('INSERT INTO USER(UT_ID, FIO, PASSWORD)');
     sql.Add(format('VALUES(%d, "%s", "%s")', [usr.ut_id, usr.fio, usr.password]));
     sqlite.ExecSQL(ansiString(sql.Text));
end;

procedure Tdm.editUser(usr: Puser);
begin
     sql.Clear;
     sql.Add('UPDATE USER ');
     sql.Add(format(
        'SET UT_ID = %d, FIO = "%s", PASSWORD = "%s" WHERE ID = %d',
                [usr.ut_id, usr.fio, usr.password, usr.id])
     );

     sqlite.ExecSQL(ansiString(sql.Text));
end;

procedure Tdm.deleteUser(id: integer);
begin
     sql.Clear;
     sql.Add('DELETE FROM USER WHERE ID = ' + intToStr(id));
     sqlite.ExecSQL(ansiString(sql.Text));

     sql.Clear;
     sql.Add('DELETE FROM SAVEPOINT WHERE US_ID = ' + intToStr(id));
     sqlite.ExecSQL(ansistring(sql.Text));
end;

procedure Tdm.deleteSavePoint(us_id: integer; window, key: string);
begin
    sql.Clear;
    sql.Add(format(
      'DELETE FROM SAVEPOINT WHERE US_ID = %d AND WINDOW = "%s" AND KEY_FIELD = "%s"',
        [us_id, window, key]));
    sqlite.ExecSQL(ansistring(sql.Text));
end;
               // create or edit existing savepoint
procedure Tdm.CreateSavePoint(us_id: integer; window: string; records: TRecords);
var i, cnt: integer; table: TSQLiteUniTable;
begin
    for i := 0 to length(records) - 1 do
    begin
        if records[i].deleted then continue;

        sql.Clear;
        sql.Add(format(
            'SELECT COUNT(*)FROM SAVEPOINT ' +
                'WHERE US_ID = %d AND WINDOW = "%s" AND KEY_FIELD = "%s"',
                [us_id, window, records[i].key])
        );
        try
          table := TSQLiteUniTable.Create(sqlite, ansiString(sql.Text));
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
                      [us_id, window, records[i].key, records[i].value])
             );

        end
        else begin
            sql.Add(format(
                'UPDATE SAVEPOINT ' +
                'SET VALUE_FIELD = "%s" ' +
                'WHERE US_ID = %d AND WINDOW = "%s" AND KEY_FIELD = "%s"',
                [records[i].value, us_id, window, records[i].key])
            );
        end;
        sqlite.ExecSQL(ansistring(sql.Text));
    end;
end;

procedure Tdm.LoadSavePoint(us_id: integer; window: string; out records: TRecords);
var i, cnt: integer; table: TSQLiteUniTable;
begin
    records := nil;
    sql.Clear;
    sql.Add(format(
        'SELECT COUNT(*)FROM SAVEPOINT ' +
            'WHERE US_ID = %d AND WINDOW = "%s"', [us_id, window])
    );
    try
      table := TSQLiteUniTable.Create(sqlite, ansiString(sql.Text));
      cnt := table.FieldAsInteger(0);
    finally
        freeAndNil(table);
    end;

    if (cnt = 0) then exit;
    setLength(records, cnt);

    sql.Clear;
    sql.Add(format(
        'SELECT KEY_FIELD, VALUE_FIELD FROM SAVEPOINT ' +
            'WHERE US_ID = %d AND WINDOW = "%s"', [us_id, window]));

    try
      table := TSQLiteUniTable.Create(sqlite, ansiString(sql.Text));

      for i := 0 to cnt - 1 do
      begin
           records[i].key := table.FieldAsString(0);
           records[i].value := table.FieldAsString(1);

           table.Next;
      end;
    finally
          freeAndNil(table)
    end;
end;

procedure Tdm.createTableSavePoints;
begin
    if sqlite.TableExists('SAVEPOINT') then exit;

    sql.Clear;
    sql.Add('CREATE TABLE SAVEPOINT');
    sql.Add('(ID INTEGER PRIMARY KEY AUTOINCREMENT,');
    sql.Add('US_ID INTEGER,');
    sql.Add('WINDOW TEXT,');
    sql.Add('KEY_FIELD TEXT,');
    sql.Add('VALUE_FIELD TEXT)');
    sqlite.ExecSQL(ansistring(sql.Text));

    sql.Clear;
    sql.Add('CREATE INDEX US_ID_INDEX ON [SAVEPOINT] (US_ID)');
    sqlite.ExecSQL(ansistring(sql.Text));
end;

procedure Tdm.createTableUser;
var defaultUser: TUser;
begin
   if sqlite.TableExists('USER') then exit;

   sql.Clear;
   sql.Add('CREATE TABLE USER ');
   sql.Add('(ID INTEGER PRIMARY KEY AUTOINCREMENT,');
   sql.Add('UT_ID INTEGER,');
   sql.Add('FIO TEXT,');
   sql.Add('PASSWORD TEXT)');
   sqlite.ExecSQL(ansiString(sql.Text));

   defaultUser.ut_id := 1;
   defaultUser.fio := 'Администратор';
   defaultUser.password := '1';
   addUser(@defaultUser);

   if FileExists('usr.sql') then loadUserFromFile('usr.sql');
end;

procedure Tdm.dropTable(const tableName: string);
begin
     sql.Clear;
     sql.Add('DROP TABLE ' + tablename);
     sqlite.ExecSQL(ansiString(sql.Text));
end;


procedure Tdm.DataModuleCreate(Sender: TObject);
begin
    sql := TStringList.Create;
    fDataFile := exePath() + 'OGE.dat';
    fUTTDataFile := exePath() + 'OGE.dat';
    fTaskDataFile := exePath() + 'OGE.dat';
    sqliteFile := exePath() + 'sqlite.dat';

    sqlite := TSQLiteDatabase.Create(sqliteFile);
    createTableUser();
    createTableSavePoints();
//  dropTable('RESULTS')
end;

procedure Tdm.loadUserFromFile(fl: string);
var l: TStringList;
    i: integer;
begin
     l := TStringList.Create;
     l.LoadFromFile(fl);

     for i := 0 to l.Count - 1 do
     begin
          sql.Clear;
          sql.Add(l.Strings[i]);
          if trim(sql.Text) = '' then continue;
          
          sqlite.ExecSQL(ansistring(sql.Text));
     end;
end;

function Tdm.loadUserList: TUserList;
var cnt, i: integer;
    table: TSQLiteUniTable;
begin
     table := nil;
     sql.Clear;
     sql.Add('SELECT COUNT(*) FROM USER');

     try
         table := sqlite.GetUniTable(ansiString(sql.Text));
         cnt := table.FieldAsInteger(0);
         freeAndNil(table);

         sql.Clear;
         sql.Add('SELECT ID, UT_ID, FIO, PASSWORD FROM USER');
         table := sqlite.GetUniTable(ansistring(sql.Text));

         setLength(result, cnt);

         for i := 0 to cnt - 1 do
         begin
              result[i].id := table.FieldAsInteger(0);
              result[i].ut_id := table.FieldAsInteger(1);
              result[i].fio := table.FieldAsString(2);
              result[i].password := table.FieldAsString(3);

              table.Next;
         end;
     finally
          freeAndNil(table);
     end;
end;

function Tdm.loadAnswears(const DBFile, fileName: string; aVariant: integer): TAnswears;
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
       xmlDoc.LoadFromStream(s);
       node := xmlDoc.ChildNodes.FindNode('ANSWEARS');
       if node = nil then abort;
       node := node.ChildNodes.FindNode('V_' + intToStr(aVariant));
       if node = nil then abort;

       lst.DelimitedText := trim(node.Text);
       setLength(result, lst.Count);


       for j := 0 to lst.Count - 1 do
       try
        result[j] := strToFloatEx(lst.Strings[j]);
       except
           raise Exception.Create('Ошибка загрузки ответа № ' + intTOStr(j + 1));
       end;

     finally
          lst.free;
          s.Free;
     end;
end;

procedure Tdm.DataModuleDestroy(Sender: TObject);
begin
    sql.Free;
    sqlite.Free;
end;

function Tdm.doLoadTopicList(): TTopicList;
var i, j, cnt, scnt: integer;
    root, node, sectionNodes: IXMLNode;
begin
     result := nil;
     if not xmlDoc.Active then exit;

     root := xmlDoc.ChildNodes.FindNode('MODULES');

     cnt := root.ChildNodes.Count;
     setLength(result, cnt);

     for i := 0 to cnt - 1 do
     begin
          result[i] := TTopic.Create();
          node := root.ChildNodes.Get(i);
          result[i].id := strToInt(node.ChildNodes.FindNode('ID').Text);
          result[i].name := node.ChildNodes.FindNode('DIR').Text;
          result[i].Caption := node.ChildNodes.FindNode('DISPLAY_LABEL').Text;

          sectionNodes := node.ChildNodes.FindNode('SECTIONS');
          scnt := sectionNodes.ChildNodes.Count;
          setLength(result[i].sections, scnt);

          for j := 0 to scnt - 1 do
          with result[i] do
          begin
               node := sectionNodes.ChildNodes.Get(j);
                with node.ChildNodes do
                begin
                   sections[j].name := FindNode('DIR').Text;
                   sections[j].display_lable := FindNode('DISPLAY_LABEL').Text;
                   sections[j].topic_id := strToInt(FindNode('TOPIC_ID').Text);
                   sections[j].task_count := strToInt(FindNode('TASK_COUNT').Text);
                   sections[j].pages_count := strToInt(FindNode('PAGES_COUNT').Text);
                   sections[j].visible := FindNode('VISIBLE').Text = '0';
                end;
          end;
     end;
end;

function Tdm.loadTopicList(): TTopicList;
var info: string;
    s: TStringStream;
begin
     result := nil;
     info := TOPIC_DIR + '/info.xml';
     s := TStringStream.Create;
     try
        if not FindData(TaskDataFile, info, s) then abort;
        xmlDoc.LoadFromStream(s);
        result := doLoadTopicList();
     finally
          s.Free;
     end;
end;

function TDm.LoadPage(const path: string): TBitmap;
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

function Tdm.doLoadUTT: TUTTModulesList;
var i, id, cnt: integer;
    root, node: IXMLNode;
begin
     id := 1;
     result := nil;
     if not xmlDoc.Active then exit;

     root := xmlDoc.ChildNodes.FindNode('UTT');
     if root = nil then exit;

     cnt := root.ChildNodes.Count;
     setLength(result, cnt);

     for i := 0 to cnt - 1 do
     begin
         node := root.ChildNodes.Get(i);
         with node.ChildNodes do
         begin
            result[i].id := id;
            result[i].level := TUTTLevel(strToInt(FindNode('LEVEL').Text));
            result[i].lable := FindNode('DISPLAY_LABEL').Text;
            result[i].task_from := strToInt(FindNode('TASK_FROM').Text);
            result[i].task_to := strToInt(FindNode('TASK_TO').Text);
            result[i].visible := boolean(strToInt(FindNode('VISIBLE').Text));
            result[i].color := hexToColor(FindNode('COLOR').Text);
            inc(id);
         end;
     end;
end;

function Tdm.loadUTTTests: TUTTModulesList;
var info: string;
    s: TStringStream;
begin
     result := nil;
     info := UTT_DIR + '/info.xml';
     s := TStringStream.Create;
     try
         if not FindData(UTTDataFile, info, s) then abort;
         xmlDoc.LoadFromStream(s);
         result := doLoadUTT();
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
               break
          end;
      end;
    finally
        zip.Free;
    end;
end;

end.
