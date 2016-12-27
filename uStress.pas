unit uStress;

interface

procedure addUsersMasksAllSections();
implementation

uses uUser, uTopicModel, uSavePoint, uGlobals, sysUtils;

var usrList: TUserList;
    windows : array[0..2] of string = ('frmTasks', 'frmCollective', 'frmUTT');

procedure addUsersMasksAllSections();
var i,j,k, s: integer;
    usr: PUser;
    sp: TSavePoint;
    TaskList: TTopicList;
    rm: TResultMask;
    sections: TSectionList;
begin
    usrList := TUserList.Create;
    TaskList := TTopicList.Create;
    setLength(rm, 120);

    for k := 0 to 2 do
    begin
        for i := 0 to usrList.Count - 1 do
        begin
              usr := PUser(usrList.Items[i]);
              sp := TSavePoint.Create(usr.id, windows[k]);

              for j := 0 to TaskList.Count - 1 do
              begin
                  sections := TTopic(TaskList.Items[j]).sections;
                  for s := 0 to length(sections) - 1 do
                  begin
                      sp.addResultMask('MASK_' + intToStr(sections[s].topic_id), rm);
                  end;
                  sp.Save;
              end;
              sp.Free;
        end;
    end;
    TaskList.Free;
    usrList.Free;
end;
end.
