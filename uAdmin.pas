unit uAdmin;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, ToolWin, ComCtrls, Grids, StdCtrls, ExtCtrls, uData,
  uNewTask;

type
  TfrmAdmin = class(TForm)
    grModule: TGroupBox;
    GroupBox1: TGroupBox;
    grdModules: TStringGrid;
    Panel1: TPanel;
    grdTasks: TStringGrid;
    btAddTask: TSpeedButton;
    Panel2: TPanel;
    txtNewModuleName: TEdit;
    btAddModule: TSpeedButton;
    procedure btAddTaskClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure ShowAdmin();
  end;

implementation

{$R *.dfm}

{ TfrmAdmin }

procedure TfrmAdmin.btAddTaskClick(Sender: TObject);
begin
   { if not Assigned(frmNewTask) then frmNewTAsk := TfrmNewTask.Create(self);
    frmNewTask.Add();
    freeAndNil(frmNewTask); }
end;


procedure TfrmAdmin.ShowAdmin;
begin
   // LoadModules();
    show;
end;

end.
