unit uTheme;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, ExtCtrls, uGlobal, uData;

type
  TfrmTopics = class(TForm)
    pnlLinks: TPanel;
    lkNums: TLinkLabel;
    Panel5: TPanel;
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
  private
    { Private declarations }
    topics: TTopicList;
    topicIndex: integer;
    page:integer;
    links: array of TLinkLabel;
    procedure createTopicLinks();
    procedure loadPage(pageNo, topicNo: integer);
  public
    { Public declarations }
    procedure showTopics();
    property TopicList: TTopicList read topics;
  end;

implementation
uses jpeg, uOGE;

{$R *.dfm}

{ TfrmTheme }

procedure TfrmTopics.showTopics;
begin
    page := 1;
    topics := dm.loadTopics();
    createTopicLinks();
    show;
end;

procedure TfrmTopics.btNextPageClick(Sender: TObject);
begin
    inc(page);
    if page > topics[topicIndex].pageCount then page := topics[topicIndex].pageCount;

    loadPage(page, topicIndex);
end;

procedure TfrmTopics.btPrevPageClick(Sender: TObject);
begin
     dec(page);
     if page < 1 then page := 1;

     loadPage(page, topicIndex);
end;

procedure TfrmTopics.btTestClick(Sender: TObject);
begin
     frmOGE.pgPages.ActivePage := frmOGE.tabTests;
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

    page := 1;
    topicIndex := TLinkLabel(Sender).Tag;
    loadPage(page, topicIndex);
end;

procedure TfrmTopics.loadPage(pageNo, topicNo: integer);
var fileName: string;
    jpg: TJpegImage;
begin
    fileName := format('%s%s\%s\%d.jpg',
        [dm.exePath(), TOPIC_DIR, topics[topicNo].dir, pageNo]);

    if not FileExists(fileName) then exit;

    jpg := TJpegImage.Create;
    try
      jpg.LoadFromFile(fileName);
      img.Picture.Bitmap.Assign(jpg);
      ScrollBox.VertScrollBar.Range := img.Picture.Bitmap.Height;
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
    end;with scrollBox.VertScrollBar do
    begin
        if (wheelDelta < 0) and (position < range)
        then position := position + increment
        else if (position > 0) then position := position - increment
    end;
end;

end.
