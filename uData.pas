unit uData;

interface

uses
  SysUtils, Classes, xmldom, XMLIntf, msxmldom, XMLDoc, uGlobals, uTheme,
  uUTT, uTasks, Graphics, uTopicModel;

type

  Tdm = class(TDataModule)
    xmlDoc: TXMLDocument;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
    fDataFile, fUTTDataFile, fTaskDataFile: string;
    function doLoadUTT(): TUTTModulesList;
    function doLoadTopicList():TTopicList;
  public
    { Public declarations }
    property  DataFile: string read fDataFile;
    property UTTDataFile: string read fUTTDataFile;
    property TaskDataFile: string read fTaskDataFile;

    function loadAnswears(const DBFile, fileName: string; aVariant: integer):TAnswears;
    function LoadPage(const path: string): TBitmap;
    function loadUTTTests(): TUTTModulesList;
    function loadTopicList(): TTopicList;
  end;

var
  dm: Tdm;

function FindData(const zipFile, name: string; outData: TStream): boolean;

implementation
uses FWZipModifier, FWZipReader, ActiveX, GdiPlus, GdiPlusHelpers;

{$R *.dfm}

{ Tdm }

procedure Tdm.DataModuleCreate(Sender: TObject);
begin
    fDataFile := exePath() + 'OGE.dat';
    fUTTDataFile := exePath() + 'OGE.dat';
    fTaskDataFile := exePath() + 'OGE.dat'
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

function Tdm.doLoadTopicList: TTopicList;
var i, j, cnt, scnt: integer;
    root, node, link, link_page, sections: IXMLNode;
begin
     result := nil;
     if not xmlDoc.Active then exit;

     root := xmlDoc.ChildNodes.FindNode('MODULES');

     cnt := root.ChildNodes.Count;
     setLength(result, cnt);

     for i := 0 to cnt - 1 do
     begin
          result[i] := TTopic.Create;
          node := root.ChildNodes.Get(i);
          result[i].id := strToInt(node.ChildNodes.FindNode('ID').Text);
          result[i].name := node.ChildNodes.FindNode('DIR').Text;
          result[i].Caption := node.ChildNodes.FindNode('DISPLAY_LABEL').Text;
          result[i].section := nil;

          sections := node.ChildNodes.FindNode('SECTIONS');
          scnt := sections.ChildNodes.Count;
          setLength(result[i].sections, scnt);

          for j := 0 to scnt - 1 do
          begin
               node := sections.ChildNodes.Get(j);
               result[i].sections[j].name := node.ChildNodes.FindNode('DIR').Text;
               result[i].sections[j].display_lable := node.ChildNodes.FindNode('DISPLAY_LABEL').Text;
               result[i].sections[j].topic_id := strToInt(node.ChildNodes.FindNode('TOPIC_ID').Text);
               result[i].sections[j].task_count := strToInt(node.ChildNodes.FindNode('TASK_COUNT').Text);
               result[i].sections[j].pages_count := strToInt(node.ChildNodes.FindNode('PAGES_COUNT').Text);
               result[i].sections[j].visible := node.ChildNodes.FindNode('VISIBLE').Text = '0';
               link := node.ChildNodes.FindNode('LINK');
               link_page := node.ChildNodes.FindNode('LINK_PAGE');

               if assigned(link) and assigned(link_page) then
               begin
                    result[i].sections[j].topic_link := strToInt(link.Text);
                    result[i].sections[j].page_link := strToInt(link_page.Text);
               end;

               result[i].sections[j].points := 0;
          end;
     end;
end;

function Tdm.loadTopicList: TTopicList;
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
