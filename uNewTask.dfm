object frmNewTask: TfrmNewTask
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = #1053#1086#1074#1086#1077' '#1079#1072#1076#1072#1085#1080#1077
  ClientHeight = 426
  ClientWidth = 651
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 16
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 651
    Height = 389
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object ToolBar2: TToolBar
      Left = 0
      Top = 273
      Width = 651
      Height = 27
      ButtonHeight = 25
      ButtonWidth = 8
      Caption = 'ToolBar1'
      TabOrder = 0
      object SpeedButton1: TSpeedButton
        Left = 0
        Top = 0
        Width = 25
        Height = 25
        Caption = '+'
      end
      object SpeedButton2: TSpeedButton
        Left = 25
        Top = 0
        Width = 23
        Height = 25
        Caption = '-'
      end
    end
    object memTask: TMemo
      Left = 0
      Top = 0
      Width = 651
      Height = 273
      Align = alTop
      Lines.Strings = (
        '<HTML>'
        '<HEAD>'
        
          '<META HTTP-EQUIV="CONTENT-TYPE" CONTENT="text/html; charset=wind' +
          'ows-1251">'
        '<STYLE TYPE="text/css">'
        #9'<!--'
        
          #9#9'P.western { font-family: "Liberation Serif", "Times New Roman"' +
          ', serif; font-size: 12pt; '
        'so-language: ru-RU }'
        #9'-->'
        #9'</STYLE>'
        '</HEAD>'
        '<BODY>'
        '<TABLE>'
        '<TR>'
        '<TD CLASS="western">'
        'PUT YOUR TEXT HERE'
        '</TD>'
        '<TD>'
        'PUT YOUR IMG HERE'
        '</TD>'
        '</TR>'
        '</TABLE>'
        '</BODY>'
        '</HTML>')
      ScrollBars = ssVertical
      TabOrder = 1
    end
    object DrawGrid1: TDrawGrid
      Left = 0
      Top = 300
      Width = 651
      Height = 89
      Align = alClient
      ColCount = 3
      FixedCols = 0
      RowCount = 2
      TabOrder = 2
      ColWidths = (
        169
        265
        73)
    end
  end
  object btSave: TButton
    Left = 487
    Top = 395
    Width = 75
    Height = 25
    Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
    ModalResult = 1
    TabOrder = 1
  end
  object Button2: TButton
    Left = 568
    Top = 395
    Width = 75
    Height = 25
    Caption = #1054#1090#1084#1077#1085#1072
    ModalResult = 2
    TabOrder = 2
  end
  object OpenPicture: TOpenPictureDialog
    Left = 248
    Top = 16
  end
end
