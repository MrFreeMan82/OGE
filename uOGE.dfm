object frmOGE: TfrmOGE
  Left = 0
  Top = 0
  Caption = #1054#1043#1069
  ClientHeight = 425
  ClientWidth = 892
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  WindowState = wsMaximized
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 16
  object pgPages: TPageControl
    Left = 0
    Top = 0
    Width = 892
    Height = 425
    ActivePage = tabInfo
    Align = alClient
    MultiLine = True
    TabOrder = 0
    object tabInfo: TTabSheet
      Caption = #1048#1085#1092#1086#1088#1084#1072#1094#1080#1103
      object WebBrowser1: TWebBrowser
        Left = 0
        Top = 0
        Width = 884
        Height = 394
        Align = alClient
        TabOrder = 0
        ExplicitLeft = 168
        ExplicitTop = 120
        ExplicitWidth = 300
        ExplicitHeight = 150
        ControlData = {
          4C0000005D5B0000B92800000000000000000000000000000000000000000000
          000000004C000000000000000000000001000000E0D057007335CF11AE690800
          2B2E126209000000000000004C0000000114020000000000C000000000000046
          8000000000000000000000000000000000000000000000000000000000000000
          00000000000000000100000000000000000000000000000000000000}
      end
    end
    object tabThemes: TTabSheet
      Caption = #1058#1077#1084#1099
      ImageIndex = 3
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 784
      ExplicitHeight = 0
    end
    object tabTests: TTabSheet
      Caption = #1059#1095#1077#1073#1085#1086'-'#1090#1088#1077#1085#1080#1088#1086#1074#1086#1095#1085#1099#1077' '#1090#1077#1089#1090#1099
      ImageIndex = 4
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 784
      ExplicitHeight = 0
    end
    object tabAdmin: TTabSheet
      Caption = 'Admin'
      ImageIndex = 2
      TabVisible = False
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 784
      ExplicitHeight = 0
    end
  end
  object ActionList: TActionList
    Left = 40
    Top = 312
    object Action1: TAction
      Caption = 'Action1'
      ShortCut = 49217
    end
  end
end
