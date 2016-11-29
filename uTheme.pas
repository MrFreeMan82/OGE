unit uTheme;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, ExtCtrls, uData, ActnList;

type
  TfrmTopics = class(TForm)
    pnlLinks: TPanel;
    lkNums: TLinkLabel;
    pnlTopic: TPanel;
    ScrollBox: TScrollBox;
    img: TImage;
    Panel4: TPanel;
    btPrevPage: TSpeedButton;
    btNextPage: TSpeedButton;
    Splitter1: TSplitter;
    btTest: TSpeedButton;
    procedure FormMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure FormDestroy(Sender: TObject);
    procedure linkClick(Sender: TObject);
    procedure btNextPageClick(Sender: TObject);
    procedure btPrevPageClick(Sender: TObject);
    procedure btTestClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    { Private declarations }
    topics: TTopicList;
    page:integer;
    links: array of TLinkLabel;
    fCurrentTopic: TTopicInfo;

    procedure clear;
    procedure createTopicLinks();
   // procedure loadPage(pageNo, topicNo: integer);overload;
    procedure loadPage(pageNo: integer);
    function isSetCurrentTopic(raiseException: boolean = true): boolean;
    function getItem(topicID: integer): TTopicInfo;
  public
    { Public declarations }
    procedure showTopics();
    property TopicList: TTopicList read topics;
    property Item[topicID: integer]: TTopicInfo read getItem;
  end;

implementation
uses FWZipReader, uOGE, GdiPlus, GdiPlusHelpers, ActiveX;

{$R *.dfm}

{ TfrmTheme }

function TfrmTopics.isSetCurrentTopic(raiseException: boolean = true): boolean;
begin
     if fCurrentTopic.id < 0 then
     begin
        if raiseException then
        begin
            messageBox(self.Handle, 'Выберите тему!', 'Ошибка', MB_OK or MB_ICONERROR);
            abort
        end
        else
           exit(false);
     end;
     result := true;
end;

procedure TfrmTopics.showTopics;
begin
    page := 1;
    fcurrentTopic.id := -1;
    topics := dm.loadTopics();
    if topics = nil then
    begin
        messageBox(self.Handle, 'Не удалось загузить темы', 'Ошибка', MB_OK or MB_ICONERROR);
        abort;
    end;
    createTopicLinks();
    show;
end;

procedure TfrmTopics.btNextPageClick(Sender: TObject);
begin
    isSetCurrentTopic();

    inc(page);
    if page > fcurrentTopic.pageCount then
    begin
       page := fcurrentTopic.pageCount;
       exit;
    end;

    loadPage(page);
end;

procedure TfrmTopics.btPrevPageClick(Sender: TObject);
begin
     isSetCurrentTopic();

     dec(page);
     if page < 1 then
     begin
         page := 1;
         exit;
     end;

     loadPage(page);
end;

procedure TfrmTopics.btTestClick(Sender: TObject);
var test: PTestInfo;
begin
     isSetCurrentTopic;

     test := getTestByTopic(fcurrentTopic.id, frmOGE.Tests.Tests);
     if test = nil then
     begin
          messageBox(self.Handle, 'По данной теме тестов нет', 'Ошибка', MB_OK or MB_ICONERROR);
          abort;
     end;

     frmOGE.Tests.setNewTopic(fcurrentTopic.id);
     frmOGE.Tests.SelectVariant(1);
     frmOGE.pgPages.ActivePage := frmOGE.tabTests;
end;

procedure TfrmTopics.clear;
begin
    img.Canvas.Brush.Color:=ClWhite;
    img.Canvas.FillRect(img.Canvas.ClipRect);
    //fcurrentTopic.id := -1;
    ScrollBox.HorzScrollBar.Range := 0;
    ScrollBox.VertScrollBar.Range := 0
end;

procedure TfrmTopics.createTopicLinks;
var i, l, t, m: integer;
begin
     l := 3;
     t := 5;
     m := 10;

     setLength(links, length(topics));

     for i := 0 to length(links) - 1 do
     begin
          links[i] := TLinkLabel.Create(pnlLinks);
          links[i].Parent := pnlLinks;
          links[i].OnClick := linkClick;
          links[i].Left := l;
          links[i].Top := t;
          links[i].Tag := i;
          links[i].Caption := '<a href="#">' + topics[i].displayLabel + '</a>';

          t := t + links[i].Height + m;
     end;
end;

procedure TfrmTopics.linkClick(Sender: TObject);
begin
    if not (Sender is TLinkLabel) then exit;

    page := 1;
    fcurrentTopic := topics[TLinkLabel(Sender).Tag];
    loadPage(page);
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

procedure TfrmTopics.loadPage(pageNo: integer);
var fileName: string;
    mem: TMemoryStream;
    marginLeft: integer;
    adptr: IStream;
    graphic: IGPGraphics;
    source, dest: TGPRectF;
    gdiBmp: IGPBitmap;
    bmp: TBitmap;
begin
     clear;
     isSetCurrentTopic();

     fileName := format('%s/%s/%d.jpg',
        [TOPIC_DIR, fcurrentTopic.dir, pageNo]);

     mem := TMemoryStream(FindData(dm.DataFile, fileName, tMemory));
     if mem = nil then exit;

     bmp := TBitMap.Create;
     adptr  := TStreamAdapter.Create(mem);
     try                        
        gdiBmp := TGPBitmap.Create(adptr);
       // gdBmp.GetPixel(gdBmp.Width - 1, gdBmp.Height - 1);

        source.InitializeFromLTRB(0, 0, gdiBmp.Width, gdiBmp.Height);
        dest.InitializeFromLTRB(0, 0, 1000, source.Height);
        streach(source, dest.Width, dest.Height, dest);        

        bmp.Width := trunc(dest.Width);
        bmp.Height := trunc(dest.Height);
        
        graphic := TGPGraphics.Create(bmp.Canvas.Handle);
        graphic.InterpolationMode := InterpolationModeHighQualityBicubic;
        graphic.DrawImage(gdiBmp, dest);

        marginLeft := (ScrollBox.ClientWidth - bmp.Width) div 2;
        img.SetBounds(marginLeft, 5, bmp.Width, bmp.Height);
        img.Picture.Bitmap.Assign(bmp);
        
        ScrollBox.HorzScrollBar.Range := img.Picture.Width;
        ScrollBox.VertScrollBar.Range := img.Picture.Height;        
     finally
       bmp.Free;
       mem.Free;
     end;
end;

procedure TfrmTopics.FormDestroy(Sender: TObject);
var i: integer;
begin
     for i := 0 to length(links) - 1 do freeAndNil(links[i]);
end;

procedure TfrmTopics.FormMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
    with scrollBox.VertScrollBar do
    begin
        if (wheelDelta < 0) and (position < range)
        then position := position + increment
        else if (position > 0) then position := position - increment
    end;
end;

procedure TfrmTopics.FormResize(Sender: TObject);
begin
  if isSetCurrentTopic(false) then loadPage(page)
end;

function TfrmTopics.getItem(topicID: integer): TTopicInfo;
var i: integer;

begin
    for i := 0 to length(self.topics) - 1 do
        if topics[i].id = topicID then exit(topics[i]);
end;

end.
