unit uTaskResults;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, NiceGrid, ExtCtrls, Tabs, Buttons, ComCtrls, ToolWin, uUTT;

type
  TfrmTaskResults = class(TForm)
    ToolBar2: TToolBar;
    ToolButton1: TToolButton;
    btRefresh: TSpeedButton;
    TabSet: TTabSet;
    pnlUTT: TPanel;
    grdUserresult: TNiceGrid;
    pnlTasks: TPanel;
    grdTasks: TNiceGrid;
    grdVariants: TNiceGrid;
    procedure grdUserresultColRowChanged(Sender: TObject; Col, Row: Integer);
    procedure TabSetChange(Sender: TObject; NewTab: Integer;
      var AllowChange: Boolean);
    procedure grdTasksDrawCell(Sender: TObject; ACanvas: TCanvas; X, Y: Integer;
      Rc: TRect; var Handled: Boolean);
    procedure btRefreshClick(Sender: TObject);
  private
    { Private declarations }
    ptsPerVariant: TPointsPerVariant;
    procedure totalResultsUTT();
    procedure totalResultUTTVariants(us_id: integer; mdl: PUTTModule);
    procedure totalresultFillUTTUsesrs;
    procedure totalResultIndividual(us_id, i: integer);
    procedure totalResultUTT(us_id, i: integer);

    procedure totalResultsTasks();
    procedure totalresultFillTasksUsesrs();
    procedure totalresultFillColumns();
    procedure totalResultByUser(us_id, y: integer);
  public
    { Public declarations }
    procedure ShowTaskResults();
  end;

implementation

uses uOGE, uUser, uWorkPlan, uGlobals, uTopicModel;

{$R *.dfm}

procedure TfrmTaskResults.ShowTaskResults;
var allowChange: boolean;
begin
    allowChange := true;
    TabSetChange(self, 0, allowChange);
    show;
end;

procedure TfrmTaskResults.TabSetChange(Sender: TObject; NewTab: Integer;
  var AllowChange: Boolean);
begin
     if pnlUTT.Visible then pnlUTT.Visible := false;
     if pnlTasks.Visible then pnlTasks.Visible := false;
     case NewTab of
        0: totalResultsUTT();
        1: totalResultsTasks();
     end;
end;

procedure TfrmTaskResults.totalResultsTasks;
begin
    totalresultFillColumns();
    totalresultFillTasksUsesrs();
    pnlTasks.Align := alClient;
    pnlTasks.Visible := true;
    if self.Visible then grdTasks.SetFocus;
end;

procedure TfrmTaskResults.totalResultByUser(us_id, y: integer);
var j, id: integer;
   r: boolean;
begin
     for j := 1 to grdTasks.ColCount - 1 do
     begin
         id := integer(grdTasks.Objects[j, 0]);

         case TTopicType(grdTasks.Columns[j].Tag) of
             tIndividual:
                  r := frmOGE.tasks.Over80ByUserAndSection(us_id, id);

             tCollective:
                  r := frmOGE.CollectiveTasks.Over80ByUserAndSection(us_id, id);

             else r := false;
         end;

         if r then grdTasks.Objects[j, y] :=  TObject(integer(1))
       //  else grdTasks.Objects[j, y] := TObject(integer(0));
     end;
end;

procedure TfrmTaskResults.totalresultFillColumns;
var i, j, k: integer;
    sections: TSectionList;
begin
     k := 1;
     for i := 0 to frmOGE.Tasks.TaskList.Count - 1 do
     begin
          sections := TTopic(frmOGE.Tasks.TaskList[i]).sections;
          for j := 0 to length(sections) - 1 do
          begin
                if k >= grdTasks.ColCount then continue;
                grdTasks.Objects[k, 0] := Tobject(sections[j].topic_id);
                grdTasks.Columns[k].Title := sections[j].short;
                grdTasks.Columns[k].Tag := integer(sections[j].typeOf);
                inc(k);
          end;
     end;
end;

procedure TfrmTaskResults.totalresultFillTasksUsesrs;
var i,j: integer;
    item: PUser;
begin
     j := 0;
     grdTasks.RowCount := 0;
     for i := 0 to frmOGE.UserList.Count - 1 do
     begin
          item := frmOGe.UserList.Items[i];
          if (item.ut_id = 1) then continue;
          grdTasks.RowCount := grdTasks.RowCount + 1;
          grdTasks.Cells[0, j] := item.fio;
          grdTasks.Objects[0, j] := TObject(item.id);
          totalResultByUser(item.id, j);
          inc(j)
     end;
end;

procedure TfrmTaskResults.totalresultFillUTTUsesrs;
var i,j: integer;
    item: PUser;
begin
     j := 0;
     grdUserresult.RowCount := 0;
     for i := 0 to frmOGE.UserList.Count - 1 do
     begin
          item := frmOGe.UserList.Items[i];
          if (item.ut_id = 1) then continue;
          grdUserresult.RowCount := grdUserresult.RowCount + 1;
          grdUserresult.Cells[0, j] := item.fio;
          grdUserresult.Objects[0, j] := TObject(item.id);
          totalResultIndividual(item.id, j);
          totalResultUTT(item.id, j);
          inc(j)
     end;
end;

procedure TfrmTaskResults.totalResultIndividual(us_id, i: integer);
begin
     if frmOGe.WorkPlan.Stage1Result(us_id)
        then grdUserresult.Cells[1, i] := ZACHET
           else grdUserresult.Cells[1, i] := NOT_ZACHET;

     if frmOGe.WorkPlan.Stage2Result(Us_id)
       then grdUserResult.Cells[2, i] := ZACHET
            else grdUserResult.Cells[2, i] := NOT_ZACHET;
end;

procedure TfrmTaskResults.totalResultsUTT;
begin
    totalresultFillUTTUsesrs();
    pnlUTT.Align := alClient;
    pnlUTT.Visible := true;
    if self.Visible then grdUserresult.SetFocus;
end;

procedure TfrmTaskResults.totalResultUTT(us_id, i: integer);
var j, k, pts: integer;
begin
     k := 3;

     for j := 0 to length(frmOGE.UTT.UTTTModuleList) - 1 do
     begin
           if not frmOGE.UTT.UTTTModuleList[j].visible then continue;

           pts := frmOGE.UTT.pointByUserAndModule(us_id, @frmOGE.UTT.UTTTModuleList[j]);

           grdUserresult.Cells[k, i] := intToStr(pts);
           grdUserresult.Objects[k, i] := TObject(frmOGE.UTT.UTTTModuleList[j].id);

           inc(k)
     end;
end;

procedure TfrmTaskResults.totalResultUTTVariants(us_id: integer; mdl: PUTTModule);
var i: integer;
begin
     ptsPerVariant :=  frmOGE.UTT.pointsByUserAllVariant(us_id, mdl);

     if ptsPerVariant = nil then exit;

     for i := 0 to grdVariants.ColCount - 1 do
          grdVariants.Cells[i, 0] := intToStr(ptsPerVariant[i]);
end;

procedure TfrmTaskResults.btRefreshClick(Sender: TObject);
var allowChange: boolean;
begin
    allowChange := true;
    if frmOGE.User.ut_id = 1 then frmOGE.syncronize;
    TabSetChange(Sender, TabSet.TabIndex, allowChange);
end;

procedure TfrmTaskResults.grdTasksDrawCell(Sender: TObject; ACanvas: TCanvas; X,
  Y: Integer; Rc: TRect; var Handled: Boolean);
  var k: integer;
begin
      k := integer(grdTasks.Objects[x,y]);
      if k = 1 then
      begin
          ACanvas.Brush.Color := clGreen;
          Acanvas.FillRect(Rc);
         // showMessage('found');
      end;
end;

procedure TfrmTaskResults.grdUserresultColRowChanged(Sender: TObject; Col,Row: Integer);
var us_id, mdl_id: integer;
begin
    if (row >= 0) and (grdUserresult.Cells[0, row] <> '') and (Col in [3..5]) then
    begin
        us_id := integer(grdUserresult.Objects[0, row]);
        mdl_id := integer(grdUserresult.Objects[Col, row]);
        totalResultUTTVariants(us_id, frmOGE.UTT.getModuleByID(mdl_id));
    end;
end;

end.
