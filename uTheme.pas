unit uTheme;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, ExtCtrls, uTopicModel;

type

  TfrmTopics = class(TForm)
    pnlLinks: TPanel;
    pnlTopic: TPanel;
    ScrollBox: TScrollBox;
    img: TImage;
    Panel4: TPanel;
    btPrevPage: TSpeedButton;
    btNextPage: TSpeedButton;
    Splitter1: TSplitter;
    btTest: TSpeedButton;
    procedure linkClick(Sender: TObject);
    procedure btNextPageClick(Sender: TObject);
    procedure btPrevPageClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure btTestClick(Sender: TObject);
  private
    { Private declarations }
    fTopic: TTopic;
    fTopicList: TTopicList;
    needer: TObject;
    links: array of TLinkLabel;
    procedure createLinks();
    procedure viewTopic();
    procedure assignedCurrent;
  public
    { Public declarations }
    procedure showTopics();
    procedure HelpWithTopic(topic_id: integer; Sender: TObject);
  end;

implementation
uses uGlobals, uOGE;

{$R *.dfm}


{ TfrmTopics }

procedure TfrmTopics.assignedCurrent;
begin
    if fTopic = nil then
    begin
        messageBox(handle, '��� ����������� �������� ������.', '���', MB_OK or MB_ICONERROR);
        abort;
    end;
end;

procedure TfrmTopics.btNextPageClick(Sender: TObject);
begin
   assignedCurrent();
   fTopic.NextPage;
   viewTopic();
end;

procedure TfrmTopics.btPrevPageClick(Sender: TObject);
begin
    assignedCurrent();
    fTopic.PrevPage;
    viewTopic();
end;

procedure TfrmTopics.btTestClick(Sender: TObject);
begin
    btTest.Visible := false;
    frmOGE.pgPages.ActivePage := frmOGE.tabTasks;
end;

procedure TfrmTopics.viewTopic;
var marginLeft: integer;
begin
    if  fTopic.content = nil then
    begin
      // messageBox(handle, '������ �� ��������.', '���', MB_OK or MB_ICONERROR);
       abort;
    end;

    img.Canvas.Brush.Color:=ClWhite;
    img.Canvas.FillRect(img.Canvas.ClipRect);

    ScrollBox.HorzScrollBar.Range := 0;
    ScrollBox.VertScrollBar.Range := 0;

    marginLeft := (ScrollBox.ClientWidth - fTopic.content.Width) div 2;
    if marginLeft < 0 then marginLeft := 0;
    img.SetBounds(marginLeft, 5, fTopic.content.Width, fTopic.content.Height);
    img.Picture.Bitmap.Assign(fTopic.content);

    ScrollBox.HorzScrollBar.Range := img.Picture.Width;
    ScrollBox.VertScrollBar.Range := img.Picture.Height;
end;

procedure TfrmTopics.linkClick(Sender: TObject);
begin
    if not (Sender is TLinkLabel) then exit;

    fTopic := fTopicList[TLinkLabel(Sender).Tag];
    fTopic.setSection(cntInformation, fTopic.sectionByName(TLinkLabel(Sender).Name));
    fTopic.FirstPage;
    viewTopic();
end;

procedure TfrmTopics.showTopics;
begin
    loadTopicList(ftopicList);
    if ftopicList = nil then
    begin
        messageBox(self.Handle, '�� ������� �������� ������', '������', MB_OK or MB_ICONERROR);
        abort;
    end;

    createLinks;
    show;
end;

procedure TfrmTopics.createLinks;
var i, j, k, l, t, td, ld, cnt: integer;
begin
     k := -1;
     l := 2;
     t := 2;
     td := 10;
     ld := 10;

     cnt := 0;
     for i := 0 to length(ftopicList) - 1 do
          cnt := cnt + length(ftopicList[i].sections) + 1;

     setLength(links, cnt);

     for i := 0 to length(ftopicList) - 1 do
     begin
          inc(k);

          links[k] := TLinkLabel.Create(pnlLinks);
          links[k].Parent := pnlLinks;
          links[k].OnClick := nil;
          links[k].Left := l;
          links[k].Top := t;
          links[k].Caption := '<a href="#">' + ftopicList[i].Caption + '</a>';

          t := t + links[k].Height + td;

          for j := 0 to length(ftopicList[i].sections) - 1 do
          begin
              inc(k);

              links[k] := TLinkLabel.Create(pnlLinks);
              links[k].Name := ftopicList[i].sections[j].name;
              links[k].Parent := pnlLinks;
              links[k].OnClick := linkClick;
              links[k].Left := l + ld;
              links[k].Top := t;
              links[k].Tag := i;
              links[k].Caption := '<a href="#">' + ftopicList[i].sections[j].display_lable + '</a>';

              t := t + links[k].Height + td;
          end;
     end;
end;

procedure TfrmTopics.FormDestroy(Sender: TObject);
var i: integer;
begin
    for i := 0 to length(links) - 1 do freeAndNil(links[i]);
    freeTopicList(ftopicList);
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

procedure TfrmTopics.HelpWithTopic(topic_id: integer; Sender: TObject);
var i, j : integer;
begin
     for i := 0 to length(ftopicList) - 1 do
     begin
        for j := 0 to length(ftopicList[i].sections) - 1 do
        begin
            if ftopicList[i].sections[j].topic_id = topic_id then
            begin
                btTest.Visible := true;
                needer := sender;
                fTopic := ftopicList[i];
                fTopic.setSection(cntInformation, @ftopicList[i].sections[j]);
                fTopic.FirstPage;
                viewTopic();
                frmOGE.pgPages.ActivePage := frmOGE.tabThemes;
            end;
        end;
     end;
end;

end.
