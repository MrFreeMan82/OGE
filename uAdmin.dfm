object frmAdmin: TfrmAdmin
  Left = 0
  Top = 0
  Align = alClient
  BorderStyle = bsNone
  ClientHeight = 396
  ClientWidth = 575
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  ExplicitWidth = 320
  ExplicitHeight = 240
  PixelsPerInch = 96
  TextHeight = 16
  object grModule: TGroupBox
    Left = 0
    Top = 0
    Width = 575
    Height = 169
    Align = alTop
    Caption = #1052#1086#1076#1091#1083#1100
    TabOrder = 0
    object grdModules: TStringGrid
      Left = 2
      Top = 45
      Width = 571
      Height = 122
      Align = alClient
      ColCount = 2
      FixedCols = 0
      RowCount = 2
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSizing, goColSizing]
      TabOrder = 0
      ColWidths = (
        37
        497)
    end
    object Panel2: TPanel
      Left = 2
      Top = 18
      Width = 571
      Height = 27
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 1
      object btAddModule: TSpeedButton
        Left = 217
        Top = 0
        Width = 32
        Height = 27
        Align = alLeft
        Caption = '+'
      end
      object txtNewModuleName: TEdit
        Left = 0
        Top = 0
        Width = 217
        Height = 27
        Align = alLeft
        TabOrder = 0
        ExplicitHeight = 24
      end
    end
  end
  object GroupBox1: TGroupBox
    Left = 0
    Top = 169
    Width = 575
    Height = 219
    Align = alTop
    Caption = #1047#1072#1076#1072#1095#1072
    TabOrder = 1
    object Panel1: TPanel
      Left = 2
      Top = 18
      Width = 571
      Height = 24
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 0
      object btAddTask: TSpeedButton
        Left = 0
        Top = 0
        Width = 25
        Height = 24
        Align = alLeft
        Caption = '+'
        OnClick = btAddTaskClick
      end
    end
    object grdTasks: TStringGrid
      Left = 2
      Top = 42
      Width = 571
      Height = 175
      Align = alClient
      ColCount = 2
      FixedCols = 0
      RowCount = 2
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSizing, goColSizing]
      TabOrder = 1
      ColWidths = (
        37
        497)
    end
  end
end
