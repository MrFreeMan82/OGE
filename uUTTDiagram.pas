unit uUTTDiagram;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, uGlobals, GdiPlus, GdiPlusHelpers, StdCtrls, NiceGrid,
  ComCtrls, uUTT;

type

  TfrmUTTDiagram = class(TForm)
    grdResult: TNiceGrid;
  private
      frmUTT: TfrmUTT;
  public
    { Public declarations }
    procedure refresh(useRandom: boolean);
    procedure showUTTDiagram(Sender: TfrmUTT);
  end;

implementation

uses uOGE, math, uData;

{$R *.dfm}

{ TfrmUTTDiagram }


procedure TfrmUTTDiagram.refresh(useRandom: boolean);
var i,j: integer;
    pts: integer;
begin
    with frmUTT do
    for i := 0 to length(UTTTModuleList) - 1 do
    begin
         if not UTTTModuleList[i].visible then continue;
         pts := 0;

         for j := 0 to length(ResultMask) - 1 do
             if ((j + 1) >= UTTTModuleList[i].task_from) and
                      ((j + 1) <= UTTTModuleList[i].task_to) and
                                           ResultMask[j] then inc(pts);

         grdResult.Cells[i, 0] := intToStr(pts);
    end;
end;

procedure TfrmUTTDiagram.showUTTDiagram(Sender: TfrmUTT);
begin
    self.frmUTT := sender;
    refresh(false);
    show;
end;

end.
