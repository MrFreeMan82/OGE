unit uTasks;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, uGlobals;

type
  TSection = record
    topic_id: integer;
    dir: string;
    display_lable: string;
    points: double;
  end;

  TSectionList = array of TSection;

  TModule = record
      id: integer;
      dir: string;
      display_lable: string;
      sections: TSectionList;
  end;

  TModuleList = array of TModule;

  TfrmTasks = class(TForm)
    pnlLinks: TPanel;
    Splitter1: TSplitter;
    ScrollBox: TScrollBox;
    img: TImage;
    Panel3: TPanel;
    Label2: TLabel;
    btAnswear: TSpeedButton;
    btResults: TSpeedButton;
    btPrevTask: TSpeedButton;
    btNextTask: TSpeedButton;
    txtAnswer: TEdit;
    btHelp: TSpeedButton;
    procedure FormDestroy(Sender: TObject);
    procedure linkClick(Sender: TObject);
    procedure btAnswearClick(Sender: TObject);
    procedure btResultsClick(Sender: TObject);
    procedure btPrevTaskClick(Sender: TObject);
    procedure btNextTaskClick(Sender: TObject);
    procedure txtAnswerKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure btHelpClick(Sender: TObject);
  private
    mode: Tmode;
    fModule, fSection, fTask: integer;
    fmoduleList: TModuleList;
    answears: TAnswears;
    taskResultMask: TResultMask;
    links: array of TLinkLabel;
    procedure createLinks();
    procedure AllTaskCompleate;
    procedure loadTask(aCurrentModule, aCurrentSection, atask: integer);
    { Private declarations }
  public
    { Public declarations }
    property ModuleList : TModuleList read fModuleList;
    property ResultMask: TResultMask read taskResultMask;
    procedure clearUserResults;
    procedure ShowTasks();
  end;

implementation

uses uData, ActiveX, GdiPlus, GdiPlusHelpers, strUtils, uTestResult, uOGE;

{$R *.dfm}

{ TfrmTasks }

procedure TfrmTasks.AllTaskCompleate;
begin
     mode := mNormal;   // All tasks complete
     if messageBox(handle, PWideChar(
          'Поздравляем! Все задания решены, Показать результаты?'),
                        'ОГЕ', MB_YESNO or MB_ICONINFORMATION) = mrYes then
     begin
         btResultsClick(self);
     end;
end;

procedure TfrmTasks.btAnswearClick(Sender: TObject);
var usrAnswear: double;
    TrueAnswear: boolean;
begin
     if (answears = nil) or
              not (fTask in [1..MODULE_TASK_COUNT]) or
                    (trim(txtAnswer.Text) = '') then exit;

    usrAnswear := strToFloatEx(trim(txtAnswer.Text));

    trueAnswear := abs(usrAnswear - self.answears[fTask - 1]) < e;

    if trueAnswear then
    begin
         if taskResultMask[fTask - 1] = false then
         begin
              moduleList[fModule - 1].sections[fSection - 1].points :=
                  moduleList[fModule - 1].sections[fSection - 1].points + 1;

              taskResultMask[fTask - 1] := true;
         end
         else begin
                messageBox(self.Handle,
                   'Верно! Баллы за это задание уже были засчитаны.',
                                       'ОГЕ', MB_OK or MB_ICONINFORMATION);
         end;
         if fTask = MODULE_TASK_COUNT then
         begin
             if getNextFalseTask(fTask,
                  taskResultMask, true) =
                      ALL_TASK_COMPLETE then
                            AllTaskCompleate()
                                else btResultsClick(self)
         end
         else btNextTaskClick(Sender);
    end
    else begin
         btNextTaskClick(Sender);
    end;
    txtAnswer.Text := '';
end;

procedure TfrmTasks.btHelpClick(Sender: TObject);
begin
    frmOGE.Topics.HelpWithTopic(
      moduleList[fModule - 1].sections[fSection - 1].topic_id, self);
end;

procedure TfrmTasks.btNextTaskClick(Sender: TObject);
begin
    if mode = mReTest then
    begin
       fTask := getNextFalseTask(fTask, taskResultMask);
       if fTask = ALL_TASK_COMPLETE then
       begin
            AllTaskCompleate();
            exit;
       end;
    end
    else inc(fTask);

    if fTask > MODULE_TASK_COUNT then fTask := MODULE_TASK_COUNT;
    loadTask(fModule, fSection, fTask);
end;

procedure TfrmTasks.btPrevTaskClick(Sender: TObject);
begin
    if mode = mRetest then
    begin
         fTask := getPrevFalseTask(fTask, taskResultMask);
         if fTask = ALL_TASK_COMPLETE then
         begin
              AllTaskCompleate();
              exit
         end;
    end
    else dec(fTask);
    if fTask < 1 then fTask := 1;
    loadTask(fModule, fSection, fTask);
end;

procedure TfrmTasks.btResultsClick(Sender: TObject);
var mr: TModalResult;
begin
    mr := TfrmTestResult.showTaskResults;
    case mr of
      mrYes: mode := mNormal;
      mrNo:
        begin
          // Перейдем в режим прохода теста заново
          // Найдем первый не пройденый тест
              mode := mReTest;
              ftask := getNextFalseTask(fTask, taskResultMask, true);

              if fTask = ALL_TASK_COMPLETE then
              begin
                  mode := mNormal;   // All tasks complete
                  exit
              end;
              loadTask(fModule, fSection, fTask);
        end;
    end;
end;

procedure TfrmTasks.loadTask(aCurrentModule, aCurrentSection, atask: integer);
var fileName, answearName: string;
    mem: TMemoryStream;
    adptr: IStream;
    gdiBmp: IGPBitmap;
    graphic: IGPGraphics;
    bmp: TBitmap;
    rect: TGPRectF;
begin
     img.Canvas.Brush.Color:=ClWhite;
     img.Canvas.FillRect(img.Canvas.ClipRect);

     ScrollBox.HorzScrollBar.Range := 0;
     ScrollBox.VertScrollBar.Range := 0;

     filename := format('%s/%s/%s/%d.jpg',
      [TASK_DIR, moduleList[aCurrentModule - 1].dir,
            moduleList[aCurrentModule - 1].sections[aCurrentSection - 1].dir, aTask]);

     mem := TMemoryStream.Create;
     bmp := TBitMap.Create;

     try
         if not FindData(dm.TaskDataFile, fileName, mem) then
         begin
              messageBox(self.Handle,
                  'По данному варианту тесты не загружены',
                               'Ошибка', MB_OK or MB_ICONERROR);
              abort;
         end;

         adptr  := TStreamAdapter.Create(mem);
         gdiBmp := TGPBitmap.Create(adptr);

         rect.InitializeFromLTRB(0, 0, gdiBMP.Width, gdiBmp.Height);

         bmp.Width := trunc(rect.Width);
         bmp.Height := trunc(rect.Height);

         graphic := TGPGraphics.Create(bmp.Canvas.Handle);
         graphic.InterpolationMode := InterpolationModeHighQualityBicubic;
         graphic.DrawImage(gdiBmp, rect);

         img.SetBounds(0, 0, bmp.Width, bmp.Height);
         img.Picture.Assign(bmp);

         ScrollBox.HorzScrollBar.Range := img.Picture.Width;
         ScrollBox.VertScrollBar.Range := img.Picture.Height;
     finally
          mem.Free;
          bmp.Free;
     end;

     if answears = nil then
     begin
        answearName := format('%s/%s/%s/answ.xml',
           [TASK_DIR, moduleList[aCurrentModule - 1].dir,
                moduleList[aCurrentModule - 1].sections[aCurrentSection - 1].dir]);

        answears := dm.loadAnswears(dm.TaskDataFile, answearName, 1);
     end;
end;

procedure TfrmTasks.ShowTasks;
begin
    mode := mNormal;
    fmoduleList := dm.loadTaskModuleList();
    if (moduleList = nil) then
    begin
      messageBox(self.Handle, 'Не удалось загузить тесты', 'Ошибка', MB_OK or MB_ICONERROR);
      abort;
    end;

    createLinks();
    show;
end;

procedure TfrmTasks.clearUserResults;
var i,j: integer;
begin
     for i := 0 to length(taskResultMask) - 1 do taskResultMask[i] := false;

     for i := 0 to length(moduleList) - 1 do
          for j := 0 to length(moduleList[i].sections) - 1 do
                            moduleList[i].sections[j].points := 0;
end;

procedure TfrmTasks.linkClick(Sender: TObject);
var s: string;
begin
    if not (Sender is TLinkLabel) then exit;
    with TLinkLabel(Sender) do
    begin
        fModule := Tag + 1;
        s := rightStr(Name, length(Name) - pos('_', Name));
        fSection := strToInt(s) + 1;
        fTask := 1;
    end;
    setLength(taskResultMask, MODULE_TASK_COUNT);
    loadTask(fModule, fSection, fTask);
end;

procedure TfrmTasks.createLinks;
var i, j, k, l, t, td, ld, cnt: integer;
begin
     k := -1;
     l := 2;
     t := 2;
     td := 10;
     ld := 10;

     cnt := 0;
     for i := 0 to length(moduleList) - 1 do
          cnt := cnt + length(moduleList[i].sections) + 1;

     setLength(links, cnt);

     for i := 0 to length(moduleList) - 1 do
     begin
          inc(k);

          links[k] := TLinkLabel.Create(pnlLinks);
          links[k].Parent := pnlLinks;
          links[k].OnClick := nil;
          links[k].Left := l;
          links[k].Top := t;
          links[k].Caption := '<a href="#">' + moduleList[i].display_lable + '</a>';

          t := t + links[k].Height + td;

          for j := 0 to length(moduleList[i].sections) - 1 do
          begin
              inc(k);

              links[k] := TLinkLabel.Create(pnlLinks);
              links[k].Name := format('%s%d%s_%d', ['module', i, 'sec', j]);
              links[k].Parent := pnlLinks;
              links[k].OnClick := linkClick;
              links[k].Left := l + ld;
              links[k].Top := t;
              links[k].Tag := i;
              links[k].Caption := '<a href="#">' + moduleList[i].sections[j].display_lable + '</a>';

              t := t + links[k].Height + td;
          end;
     end;
end;

procedure TfrmTasks.txtAnswerKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
    if key = VK_RETURN then btAnswearClick(Sender);
end;

procedure TfrmTasks.FormDestroy(Sender: TObject);
var i: integer;
begin
     for i := 0 to length(links) - 1 do freeAndNil(links[i]);
end;

procedure TfrmTasks.FormMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
    with scrollBox.VertScrollBar do
    begin
        if (wheelDelta < 0) and (position < range)
        then position := position + increment
        else if (position > 0) then position := position - increment
    end;
end;

end.
