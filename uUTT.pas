unit uUTT;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Buttons, uData;

type
  TfrmUTT = class(TForm)
    rgVariants: TRadioGroup;
    Panel3: TPanel;
    Label2: TLabel;
    btAnswear: TSpeedButton;
    btResults: TSpeedButton;
    txtAnswer: TEdit;
    ScrollBox: TScrollBox;
    img: TImage;
    btPrevTask: TSpeedButton;
    btNextTask: TSpeedButton;
    procedure rgVariantsClick(Sender: TObject);
    procedure btNextTaskClick(Sender: TObject);
    procedure btPrevTaskClick(Sender: TObject);
    procedure txtAnswerKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure btAnswearClick(Sender: TObject);
    procedure btResultsClick(Sender: TObject);
  private
    { Private declarations }
    mode: Tmode;
    fTask: integer;
    fUTTTest: TUTTInfo;
    answears: TAnswears;
    procedure loadTask(aVariant, aTask: integer);
    procedure clear;
    procedure fiilMask();
  public
    { Public declarations }
    procedure clearUserResults();
    property UTTTest: TUTTInfo read fUTTTest;
    function VisibleModuleCount(): integer;
    procedure ShowUTT();
  end;

implementation
uses uOGE, uTestResult, GdiPlus, GdiPlusHelpers, ActiveX;
{$R *.dfm}

{ TfrmUTT }

const e = 0.001;

procedure TfrmUTT.btAnswearClick(Sender: TObject);
var usrAnswear: double;
    TrueAnswear: boolean;
begin
     if (answears = nil) or
              not (fTask in [1..UTT_TASK_COUNT]) or
                    (trim(txtAnswer.Text) = '') then exit;

    usrAnswear := strToFloatEx(trim(txtAnswer.Text));

    trueAnswear := abs(usrAnswear - self.answears[fTask - 1]) < e;

    if trueAnswear then
    begin
         if self.fUTTTest.taskResultMask[fTask - 1] = false then
         begin
              fUTTTest.points := fUTTTest.points + 1;
              fUTTTest.taskResultMask[fTask - 1] := true;
         end
         else begin
                messageBox(self.Handle,
                   'Верно! Баллы за это задание уже были засчитаны.',
                                       'ОГЕ', MB_OK or MB_ICONINFORMATION);
         end;
         if fTask = UTT_TASK_COUNT then btResultsClick(Sender) else btNextTaskClick(Sender);
    end
    else begin
         btNextTaskClick(Sender);
    end;
    txtAnswer.Text := '';
end;

procedure TfrmUTT.btNextTaskClick(Sender: TObject);
var oldtask: integer;
begin
    if mode = mReTest then
    begin
       oldTask := fTask;
       fTask := getNextFalseTask(fTask, fUTTTest.taskResultMask);
       if fTask = ALL_TASK_COMPLETE then
       begin
            mode := mNormal;   // All tasks complete
            messageBox(handle, PWideChar('Поздравляем! Все задания варианта '+
                                intToStr(rgVariants.ItemIndex + 1) +' решены'),
                                                 'ОГЕ', MB_OK or MB_ICONINFORMATION);
            fTask := oldTask;
       end;
    end
    else inc(fTask);

    if fTask > UTT_TASK_COUNT then fTask := UTT_TASK_COUNT;
    loadTask(rgVariants.ItemIndex + 1, fTask);
end;

procedure TfrmUTT.btPrevTaskClick(Sender: TObject);
var oldTask: integer;
begin
    if mode = mRetest then
    begin
         oldTask := fTask;
         fTask := getPrevFalseTask(fTask, fUTTTest.taskResultMask);
         if fTask = ALL_TASK_COMPLETE then
         begin
              mode := mNormal;   // All tasks complete
              messageBox(handle, PWideChar('Поздравляем! Все задания варианта '+
                                intToStr(rgVariants.ItemIndex + 1) +' решены'),
                                                 'ОГЕ', MB_OK or MB_ICONINFORMATION);
              fTask := oldTask;
         end;
    end
    else dec(fTask);
    if fTask < 1 then fTask := 1;
    loadTask(rgVariants.ItemIndex + 1, fTask);
end;

procedure TfrmUTT.btResultsClick(Sender: TObject);
var mr: TmodalResult;
begin
    if rgVariants.ItemIndex < 0 then rgVariants.ItemIndex := 0;

    mr := TfrmTestResult.showUTTResults;
    case mr of
      mrYes: mode := mNormal;
      mrNo:
        begin
          // Перейдем в режим прохода теста заново
          // Найдем первый не пройденый тест
              mode := mReTest;

              ftask := getNextFalseTask(fTask, fUTTTest.taskResultMask, true);
              loadTask(rgVariants.ItemIndex + 1, fTask);
        end;
    end;
end;

procedure TfrmUTT.clear;
begin
    img.Canvas.Brush.Color:=ClWhite;
    img.Canvas.FillRect(img.Canvas.ClipRect);

    ScrollBox.HorzScrollBar.Range := 0;
    ScrollBox.VertScrollBar.Range := 0
end;

procedure TfrmUTT.loadTask(aVariant, aTask: integer);
var fileName, answearName: string;
    mem: TMemoryStream;
    adptr: IStream;
    gdiBmp: IGPBitmap;
    graphic: IGPGraphics;
    bmp: TBitmap;
    rect: TGPRectF;
begin
     clear;

     filename := format('%s/%d/%d.jpg', [UTT_DIR, aVariant, aTask]);

     mem := TMemoryStream.Create;
     bmp := TBitMap.Create;

     try
         if not FindData(dm.DataFile, fileName, mem) then
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
        answearName := format('%s/answ.xml', [UTT_DIR]);
        answears := dm.loadAnswears(answearName, aVariant);
     end;
end;

procedure TfrmUTT.clearUserResults;
var i: integer;
begin
     fUTTTest.points := 0;
     for i := 0 to UTT_TASK_COUNT - 1 do
           fUTTTest.taskResultMask[i] := false;
end;

procedure TfrmUTT.fiilMask;
var i: integer;
begin
     for i := 1 to length(self.UTTTest.taskResultMask) - 1 do
     begin
          self.UTTTest.taskResultMask[i] := true;
     end;
end;

procedure TfrmUTT.rgVariantsClick(Sender: TObject);
begin
     if rgVariants.ItemIndex < 0 then exit;
     answears := nil;
     setLength(fUTTTest.taskResultMask, UTT_TASK_COUNT);
     clearUserResults();
   //  fiilMask();
     fTask := 1;
     loadTask(rgVariants.ItemIndex + 1, fTask);
end;

procedure TfrmUTT.ShowUTT;
begin
    mode := mNormal;
    fUTTTest := dm.loadUTTTests();
    if (fUTTTest.modules = nil) then
    begin
      messageBox(self.Handle, 'Не удалось загузить тесты', 'Ошибка', MB_OK or MB_ICONERROR);
      abort;
    end;

    show;
end;

procedure TfrmUTT.txtAnswerKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
    if key = VK_RETURN then btAnswearClick(Sender);
end;

function TfrmUTT.VisibleModuleCount: integer;
var i: integer;
begin
     result := 0;
     for i:= 0 to length(self.UTTTest.modules) - 1 do
          if self.UTTTest.modules[i].visible then inc(result);
end;

end.
