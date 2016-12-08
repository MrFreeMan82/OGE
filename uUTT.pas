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
    answears: TAnswears;
    currentTest: TTestInfo;
    procedure loadTask(aVariant, aTask: integer);
    procedure clear;
    procedure clearUserResults();
  public
    { Public declarations }
    procedure ShowUTT();
  end;

implementation
uses uOGE, uTestResult, GdiPlus, GdiPlusHelpers, ActiveX;
{$R *.dfm}

{ TfrmUTT }

procedure TfrmUTT.btAnswearClick(Sender: TObject);
begin
//
end;

procedure TfrmUTT.btNextTaskClick(Sender: TObject);
var oldtask: integer;
begin
    if mode = mReTest then
    begin
       oldTask := fTask;
       fTask := getNextFalseTask(fTask, currentTest.taskResultMask);
       if fTask = ALL_TASK_COMPLETE then
       begin
            mode := mNormal;   // All tasks complete
            messageBox(handle, PWideChar('�����������! ��� ������� �������� '+
                                intToStr(rgVariants.ItemIndex + 1) +' ������'),
                                                 '���', MB_OK or MB_ICONINFORMATION);
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
         fTask := getPrevFalseTask(fTask, currentTest.taskResultMask);
         if fTask = ALL_TASK_COMPLETE then
         begin
              mode := mNormal;   // All tasks complete
              messageBox(handle, PWideChar('�����������! ��� ������� �������� '+
                                intToStr(rgVariants.ItemIndex + 1) +' ������'),
                                                 '���', MB_OK or MB_ICONINFORMATION);
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
    mr := TfrmTestResult.showResults;
    case mr of
      mrYes: mode := mNormal;
      mrNo:
        begin
          // �������� � ����� ������� ����� ������
          // ������ ������ �� ��������� ����
              mode := mReTest;

              ftask := getNextFalseTask(fTask, currentTest.taskResultMask, true);
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
                  '�� ������� �������� ����� �� ���������',
                               '������', MB_OK or MB_ICONERROR);
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
     currentTest.points := 0;
     for i := 0 to UTT_TASK_COUNT - 1 do
           currentTest.taskResultMask[i] := false;
end;

procedure TfrmUTT.rgVariantsClick(Sender: TObject);
begin
     if rgVariants.ItemIndex < 0 then exit;
     answears := nil;
     if currentTest.taskResultMask = nil then setLength(currentTest.taskResultMask, UTT_TASK_COUNT);
     clearUserResults();
     fTask := 1;
     loadTask(rgVariants.ItemIndex + 1, fTask);
end;

procedure TfrmUTT.ShowUTT;
begin
    mode := mNormal;
    show;
end;

procedure TfrmUTT.txtAnswerKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
    if key = VK_RETURN then btAnswearClick(Sender);
end;

end.
