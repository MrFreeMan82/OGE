unit uTheme;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, ExtCtrls, uData;

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
  public
    { Public declarations }
    procedure showTopics();
    property TopicList: TTopicList read topics;
  end;

implementation
uses jpeg, FWZipReader, uOGE;

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
    if page > fcurrentTopic.pageCount then page := fcurrentTopic.pageCount;

    loadPage(page);
end;

procedure TfrmTopics.btPrevPageClick(Sender: TObject);
begin
     isSetCurrentTopic();
     dec(page);
     if page < 1 then page := 1;

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
    fcurrentTopic.id := -1;
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
          links[i] := TLinkLabel.Create(self);
          links[i].Parent := pnlLinks;
          links[i].OnClick := linkClick;
          links[i].Name := topics[i].name;
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

    clear;
    page := 1;
    fcurrentTopic := topics[TLinkLabel(Sender).Tag];
    loadPage(page);
end;

procedure TfrmTopics.loadPage(pageNo: integer);
var fileName: string;
    jpg: TJpegImage;
    mem: TMemoryStream;
begin
     isSetCurrentTopic();

     fileName := format('%s/%s/%d.jpg',
        [TOPIC_DIR, fcurrentTopic.dir, pageNo]);

     mem := TMemoryStream(FindData(dm.DataFile, fileName, tMemory));
     if mem = nil then exit;

     jpg := TJpegImage.Create;
     try
      //  mem.Position := 0;
        jpg.LoadFromStream(mem);
        img.Top := 5;
        img.Left := (ScrollBox.ClientWidth - jpg.Width) div 2;
        if img.Left < 0 then img.Left := 5;
        img.Width := jpg.Width;
        img.Height := jpg.Height;
        img.Picture.Bitmap.Assign(jpg);
        ScrollBox.HorzScrollBar.Range := img.Picture.Width;
        ScrollBox.VertScrollBar.Range := img.Picture.Height;
     finally
         jpg.Free;
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

end.
