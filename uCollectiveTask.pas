unit uCollectiveTask;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, Buttons, ExtCtrls;

type
  TfrmCollectiveTask = class(TForm)
    pnlLinks: TPanel;
    Panel3: TPanel;
    Label2: TLabel;
    btAnswear: TSpeedButton;
    btResults: TSpeedButton;
    btPrevTask: TSpeedButton;
    btNextTask: TSpeedButton;
    btHelp: TSpeedButton;
    txtAnswer: TEdit;
    RichEdit1: TRichEdit;
  private
    { Private declarations }
  public
    { Public declarations }
    procedure showCollectiveTask();
  end;

implementation

{$R *.dfm}

{ TfrmCollectiveTask }

procedure TfrmCollectiveTask.showCollectiveTask;
begin
    show
end;

end.
