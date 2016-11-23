unit uData;

interface

uses
  SysUtils, Classes, Forms, xmldom, XMLIntf, msxmldom, XMLDoc;

type
  PTopicInfo = ^TTopicInfo;
  TTopicInfo = record
      id: integer;
      pageCount: integer;
      name: string;
      dir: string;
      displayLabel: string;
  end;

  TTopicList = array of TTopicInfo;

  PTestInfo = ^TTestInfo;
  TTestInfo = record
      id: integer;
      topic: integer;
      name: string;
      dir: string;
      displayLabel: string;
  end;
  TTestList = array of TTestInfo;

  Tdm = class(TDataModule)
    xmlDoc: TXMLDocument;
  private
    { Private declarations }

  public
    { Public declarations }
    function loadTests(): TTestList;
    function loadTopics(): TTopicList;
    function exePath(): string;
  end;

var
  dm: Tdm;

const TOPIC_DIR = 'Topics';
      TEST_DIR = 'Tests';

implementation

{$R *.dfm}

{ Tdm }

function Tdm.exePath: string;
begin
     result := ExtractFilePath(Application.ExeName);
end;

function Tdm.loadTests: TTestList;
var xml: string;
    i, cnt: integer;
    root, node: IXMLNode;
begin
     xml := extractFilePath(Application.ExeName) + TEST_DIR + '\info.xml';
     xmlDoc.LoadFromFile(xml);
     root := xmlDoc.ChildNodes.FindNode('TESTS');

     cnt := root.ChildNodes.Count;
     setLength(result, cnt);

     for i := 0 to cnt - 1 do
     begin
          node := root.ChildNodes.Get(i);
          with node.ChildNodes do
          begin
              result[i].name := FindNode('NAME').Text;
              result[i].dir  := FindNode('DIR').Text;
              result[i].displayLabel := FindNode('DISPLAY_LABEL').Text;
              result[i].id := strToInt(FindNode('ID').Text);
              result[i].topic := strToint(FindNode('TOPIC').Text);
          end;
     end;
end;

function Tdm.loadTopics(): TTopicList;
var xml: string;
    i, cnt: integer;
    root, node: IXMLNode;
begin
     xml := extractFilePath(Application.ExeName) + TOPIC_DIR + '\info.xml';
     xmlDoc.LoadFromFile(xml);
     root := xmlDoc.ChildNodes.FindNode('TOPICS');
     if root = nil then exit;

     cnt := root.ChildNodes.Count;
     setLength(result, cnt);

     for i := 0 to cnt - 1 do
     begin
          node := root.ChildNodes.Get(i);
          with node.ChildNodes do
          begin
              result[i].name := FindNode('NAME').Text;
              result[i].dir  := FindNode('DIR').Text;
              result[i].displayLabel := FindNode('DISPLAY_LABEL').Text;
              result[i].id := strToInt(FindNode('ID').Text);
              result[i].pageCount := strToInt(FindNode('PAGE_CNT').Text);
          end;
     end;
end;

end.
