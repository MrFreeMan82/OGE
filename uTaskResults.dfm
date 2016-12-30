object frmTaskResults: TfrmTaskResults
  Left = 0
  Top = 0
  Align = alClient
  BorderStyle = bsNone
  ClientHeight = 438
  ClientWidth = 951
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 16
  object ToolBar2: TToolBar
    Left = 0
    Top = 0
    Width = 951
    Height = 29
    ButtonHeight = 29
    ButtonWidth = 33
    Caption = 'ToolBar1'
    Color = clBtnFace
    EdgeInner = esNone
    EdgeOuter = esNone
    ParentColor = False
    TabOrder = 0
    Transparent = True
    object ToolButton1: TToolButton
      Left = 0
      Top = 0
      Width = 17
      Caption = 'ToolButton1'
      Style = tbsSeparator
    end
    object btRefresh: TSpeedButton
      Left = 17
      Top = 0
      Width = 41
      Height = 29
      Align = alLeft
      Glyph.Data = {
        36030000424D3603000000000000360000002800000010000000100000000100
        18000000000000030000C40E0000C40E00000000000000000000FFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFDFEFD9FC2A2FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF8BBC905E9D63FF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFF9BCBA066B06E61AA683D8B4437833E327B373D7F436496689EBC
        A0E6EDE6FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFAAD8AF73BD7C96D19F94CF9C8F
        CD968ACA9185C78B7ABE8165AD6C4B925168976BCDDCCEFFFFFFFFFFFFFFFFFF
        FFFFFFA9DBAF79C4839ED7A79BD4A497D29F92CF9A8DCC9588CA907AC2827EC4
        855DA46369996CE6EDE6FFFFFFFFFFFFFFFFFFFFFFFFA4DAAB7BC78577C28154
        AB5E4EA357499B5163AC6B83C38B87C98F82C689509756A0BFA2FFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFF9ED8A57BC784FFFFFFFFFFFFFFFFFF9BC9A05BA26286C6
        8E88C98F6FB376699D6DB8D7BBB6D4B9B4D1B6B2CEB4AFCBB1FDFEFDB4E2BAFF
        FFFFFFFFFFFFFFFFFFFFFFA4CFA854A05B48954F408B47478B4E5DA9644C9C54
        48954F49904F97BE9BFFFFFFFFFFFFFFFFFFFFFFFF92B294FCFDFCBEDFC2BCDC
        BFBAD9BDB7D6BBB5D3B884C38B80C3898DCC9583C48A54995A90BA94FFFFFFFF
        FFFFFFFFFF4A814D739C76FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFB7DEBB75BF7E
        98D2A194CF9C86C78D5EA765398640347E3A2E763349904F458B4A7EA581FFFF
        FFFFFFFFFFFFFFFFFFFFEDF7EE8ECD9685C98E9BD4A48FCE9892CF9A8DCC9588
        CA9083C68B7EC48579C17F478D4C87AC89FFFFFFFFFFFFFFFFFFFFFFFFDCF0DE
        90CF9779C38389CA9294D09C95D19E90CF998CCB9487C98F80C4874E95548FB3
        92FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEDF8EFB9E1BE89C99064B46C50A65A4B
        9E5345964D60A8685BA2628CB690FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF67AB6E8BBC90FFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFACD4B0FDFEFDFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF}
      OnClick = btRefreshClick
    end
  end
  object TabSet: TTabSet
    Left = 0
    Top = 29
    Width = 951
    Height = 20
    Align = alTop
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    SoftTop = True
    Tabs.Strings = (
      #1058#1088#1077#1085#1080#1088#1086#1074#1086#1095#1085#1099#1077' '#1074#1072#1088#1080#1072#1085#1090#1099' '#1050#1048#1052#1086#1074
      #1048#1085#1076#1080#1074#1080#1076#1091#1072#1083#1100#1085#1099#1077' '#1080' '#1082#1086#1083#1083#1077#1082#1090#1080#1074#1085#1099#1077' '#1079#1072#1076#1072#1095#1080)
    TabIndex = 0
    OnChange = TabSetChange
  end
  object pnlUTT: TPanel
    Left = 8
    Top = 81
    Width = 609
    Height = 312
    TabOrder = 2
    Visible = False
    object grdUserresult: TNiceGrid
      Left = 1
      Top = 1
      Width = 607
      Height = 235
      Cursor = 101
      ColCount = 6
      DefRowHeight = 25
      HeaderLine = 3
      HeaderFont.Charset = DEFAULT_CHARSET
      HeaderFont.Color = clWindowText
      HeaderFont.Height = -11
      HeaderFont.Name = 'Tahoma'
      HeaderFont.Style = []
      FooterFont.Charset = DEFAULT_CHARSET
      FooterFont.Color = clWindowText
      FooterFont.Height = -11
      FooterFont.Name = 'Tahoma'
      FooterFont.Style = []
      SelectionColor = clSkyBlue
      FitToWidth = True
      ReadOnly = True
      Columns = <
        item
          Title = #1060#1048#1054';'
          Width = 104
        end
        item
          Title = #1054#1094#1077#1085#1082#1072' '#1088#1077#1079#1091#1083#1100#1090#1072#1090#1086#1074'|'#1057#1072#1084#1086#1089#1090#1086#1103#1090#1077#1083#1100#1085#1086#1077' '#1074#1099#1087#1086#1083#1085#1077#1085#1080#1077
          Width = 119
        end
        item
          Title = #1054#1094#1077#1085#1082#1072' '#1088#1077#1079#1091#1083#1100#1090#1072#1090#1086#1074'|'#1057#1086#1074#1084#1077#1089#1090#1085#1072#1103' '#1088#1072#1073#1086#1090#1072
          Width = 98
        end
        item
          Title = #1054#1094#1077#1085#1082#1072' '#1088#1077#1079#1091#1083#1100#1090#1072#1090#1086#1074'|'#1058#1088#1077#1085#1080#1088#1086#1074#1086#1095#1085#1099#1077' '#1074#1072#1088#1080#1072#1085#1090#1099' '#1050#1048#1052#1086#1074'|'#1052#1086#1076#1091#1083#1100' '#171#1040#1083#1075#1077#1073#1088#1072#187
          Width = 98
        end
        item
          Title = 
            #1054#1094#1077#1085#1082#1072' '#1088#1077#1079#1091#1083#1100#1090#1072#1090#1086#1074'|'#1058#1088#1077#1085#1080#1088#1086#1074#1086#1095#1085#1099#1077' '#1074#1072#1088#1080#1072#1085#1090#1099' '#1050#1048#1052#1086#1074'|'#1052#1086#1076#1091#1083#1100' '#171#1043#1077#1086#1084#1077#1090#1088#1080 +
            #1103#187
          Width = 101
        end
        item
          Title = 
            #1054#1094#1077#1085#1082#1072' '#1088#1077#1079#1091#1083#1100#1090#1072#1090#1086#1074'|'#1058#1088#1077#1085#1080#1088#1086#1074#1086#1095#1085#1099#1077' '#1074#1072#1088#1080#1072#1085#1090#1099' '#1050#1048#1052#1086#1074'|'#1052#1086#1076#1091#1083#1100' '#171#1056#1077#1072#1083#1100#1085#1072#1103 +
            ' '#1084#1072#1090#1077#1084#1072#1090#1080#1082#1072#187
          Width = 87
        end>
      GutterKind = gkNone
      GutterFont.Charset = DEFAULT_CHARSET
      GutterFont.Color = clWindowText
      GutterFont.Height = -11
      GutterFont.Name = 'Tahoma'
      GutterFont.Style = []
      ShowFooter = False
      OnColRowChanged = grdUserresultColRowChanged
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      Align = alClient
      BorderStyle = bsNone
      TabOrder = 0
    end
    object grdVariants: TNiceGrid
      Left = 1
      Top = 236
      Width = 607
      Height = 75
      Cursor = 101
      ColCount = 30
      RowCount = 1
      HeaderFont.Charset = DEFAULT_CHARSET
      HeaderFont.Color = clWindowText
      HeaderFont.Height = -11
      HeaderFont.Name = 'Tahoma'
      HeaderFont.Style = []
      FooterFont.Charset = DEFAULT_CHARSET
      FooterFont.Color = clWindowText
      FooterFont.Height = -11
      FooterFont.Name = 'Tahoma'
      FooterFont.Style = []
      SelectionColor = clSkyBlue
      FitToWidth = True
      ReadOnly = True
      Columns = <
        item
          Title = '1'
          Width = 21
        end
        item
          Title = '2'
          Width = 21
        end
        item
          Title = '3'
          Width = 21
        end
        item
          Title = '4'
          Width = 21
        end
        item
          Title = '5'
          Width = 21
        end
        item
          Title = '6'
          Width = 21
        end
        item
          Title = '7'
          Width = 21
        end
        item
          Title = '8'
          Width = 21
        end
        item
          Title = '9'
          Width = 21
        end
        item
          Title = '10'
          Width = 21
        end
        item
          Title = '11'
          Width = 21
        end
        item
          Title = '12'
          Width = 21
        end
        item
          Title = '13'
          Width = 21
        end
        item
          Title = '14'
          Width = 33
        end
        item
          Title = '15'
          Width = 33
        end
        item
          Title = '16'
          Width = 33
        end
        item
          Title = '17'
          Width = 32
        end
        item
          Title = '18'
          Width = 20
        end
        item
          Title = '19'
          Width = 20
        end
        item
          Title = '20'
          Width = 20
        end
        item
          Title = '21'
          Width = 7
        end
        item
          Title = '22'
          Width = 7
        end
        item
          Title = '23'
          Width = 7
        end
        item
          Title = '24'
          Width = 7
        end
        item
          Title = '25'
          Width = 19
        end
        item
          Title = '26'
          Width = 19
        end
        item
          Title = '27'
          Width = 19
        end
        item
          Title = '28'
          Width = 19
        end
        item
          Title = '29'
          Width = 19
        end
        item
          Title = '30'
          Width = 20
        end>
      GutterKind = gkNone
      GutterFont.Charset = DEFAULT_CHARSET
      GutterFont.Color = clWindowText
      GutterFont.Height = -11
      GutterFont.Name = 'Tahoma'
      GutterFont.Style = []
      ShowFooter = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      Align = alBottom
      BorderStyle = bsNone
      TabOrder = 1
    end
  end
  object pnlTasks: TPanel
    Left = 304
    Top = 81
    Width = 647
    Height = 320
    TabOrder = 3
    Visible = False
    object grdTasks: TNiceGrid
      Left = 1
      Top = 1
      Width = 645
      Height = 318
      Cursor = 101
      ColCount = 14
      DefRowHeight = 25
      HeaderFont.Charset = DEFAULT_CHARSET
      HeaderFont.Color = clWindowText
      HeaderFont.Height = -11
      HeaderFont.Name = 'Tahoma'
      HeaderFont.Style = []
      FooterFont.Charset = DEFAULT_CHARSET
      FooterFont.Color = clWindowText
      FooterFont.Height = -11
      FooterFont.Name = 'Tahoma'
      FooterFont.Style = []
      SelectionColor = clSkyBlue
      FitToWidth = True
      ReadOnly = True
      Columns = <
        item
          Title = #1060#1048#1054
          Width = 98
        end
        item
          Width = 42
        end
        item
          Width = 42
        end
        item
          Width = 42
        end
        item
          Width = 42
        end
        item
          Width = 42
        end
        item
          Width = 41
        end
        item
          Width = 41
        end
        item
          Width = 41
        end
        item
          Width = 42
        end
        item
          Width = 42
        end
        item
          Width = 42
        end
        item
          Width = 42
        end
        item
          Width = 42
        end>
      GutterKind = gkNone
      GutterFont.Charset = DEFAULT_CHARSET
      GutterFont.Color = clWindowText
      GutterFont.Height = -11
      GutterFont.Name = 'Tahoma'
      GutterFont.Style = []
      ShowFooter = False
      OnDrawCell = grdTasksDrawCell
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      Align = alClient
      TabOrder = 0
    end
  end
end
