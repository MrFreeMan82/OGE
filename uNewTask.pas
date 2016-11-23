unit uNewTask;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Buttons, ToolWin, ComCtrls, ExtDlgs, Grids, uData;

type
  TfrmNewTask = class(TForm)
    OpenPicture: TOpenPictureDialog;
    Panel1: TPanel;
    ToolBar2: TToolBar;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    memTask: TMemo;
    DrawGrid1: TDrawGrid;
    btSave: TButton;
    Button2: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

uses uGlobal;

{$R *.dfm}

{ TfrmNewTask }

end.
