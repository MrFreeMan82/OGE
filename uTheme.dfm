object frmTopics: TfrmTopics
  Left = 0
  Top = 0
  Align = alClient
  BorderStyle = bsNone
  ClientHeight = 281
  ClientWidth = 491
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnDestroy = FormDestroy
  OnMouseWheel = FormMouseWheel
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 16
  object Splitter1: TSplitter
    Left = 201
    Top = 0
    Width = 5
    Height = 281
    Color = clGray
    ParentColor = False
    ExplicitLeft = 169
  end
  object pnlLinks: TPanel
    Left = 0
    Top = 0
    Width = 201
    Height = 281
    Align = alLeft
    BevelOuter = bvNone
    TabOrder = 0
    object lkNums: TLinkLabel
      Left = 5
      Top = 51
      Width = 129
      Height = 20
      Caption = '<a href="#"> '#1063#1080#1089#1083#1072' '#1080' '#1074#1099#1095#1080#1089#1083#1077#1085#1080#1103'</a>'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsUnderline]
      ParentFont = False
      TabOrder = 0
      Visible = False
    end
  end
  object pnlTopic: TPanel
    Left = 206
    Top = 0
    Width = 285
    Height = 281
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    object ScrollBox: TScrollBox
      AlignWithMargins = True
      Left = 20
      Top = 29
      Width = 262
      Height = 249
      Margins.Left = 20
      VertScrollBar.Increment = 2
      Align = alClient
      AutoScroll = False
      BevelEdges = []
      BevelInner = bvNone
      BevelOuter = bvNone
      BorderStyle = bsNone
      TabOrder = 0
      object img: TImage
        Left = 3
        Top = 3
        Width = 262
        Height = 249
        Align = alCustom
      end
    end
    object Panel4: TPanel
      Left = 0
      Top = 0
      Width = 285
      Height = 26
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 1
      object btPrevPage: TSpeedButton
        Left = 205
        Top = 0
        Width = 40
        Height = 26
        Align = alRight
        Glyph.Data = {
          36030000424D3603000000000000360000002800000010000000100000000100
          18000000000000030000C40E0000C40E00000000000000000000FFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFBFDFB7AB580FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF6DB67453A45BD7E9D8FFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          7BC58471BE7B7AC1835BAA6447994F4191493B884235803B2F78352A702F2569
          292163241D5E20FFFFFFFFFFFF89D1927BC8869CD5A598D3A194D09D90CE988B
          CB9387C98E82C6897EC3847AC18076BE7C72BD78216324FFFFFFFFFFFF88D391
          7FCC8AA2D8AB9ED6A79AD4A396D29F93CF9A8ECC9589CA9085C78B81C5877DC2
          8278C07E256929FFFFFFFFFFFFFFFFFF83D18D80CD8B7CC9875DB86858B16253
          A95C4DA15647994F4191493B884235803B2F78352A702FFFFFFFFFFFFFFFFFFF
          FFFFFF7DCF886AC575FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFBFEFC90D699FFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF}
        OnClick = btPrevPageClick
        ExplicitLeft = 211
      end
      object btNextPage: TSpeedButton
        Left = 245
        Top = 0
        Width = 40
        Height = 26
        Align = alRight
        Glyph.Data = {
          36030000424D3603000000000000360000002800000010000000100000000100
          18000000000000030000C40E0000C40E00000000000000000000FFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5F8E61FAFB
          FAFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFD0E0D12C6E30427A45FFFFFFFFFFFFFFFFFFFFFFFF61BE6D
          5DB86858B16253A95C4DA15647994F4191493B884235803B3F884559A15E448B
          494B804DFFFFFFFFFFFFFFFFFF65C371A0D7A99CD5A598D3A194D09D90CE988B
          CB9387C98E82C6897EC3847AC18076BE7C458C4A548757FFFFFFFFFFFF68C774
          A5DAAEA2D8AB9ED6A79AD4A396D29F93CF9A8ECC9589CA9085C78B81C5877DC2
          824A9150538956FFFFFFFFFFFF68C77468C77465C37161BE6D5DB86858B16253
          A95C4DA15647994F4191495AA362559D5C559059FFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF47944F5799
          5DFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFF78B47EFBFCFBFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF}
        OnClick = btNextPageClick
        ExplicitLeft = 248
      end
      object btTest: TSpeedButton
        Left = 0
        Top = 0
        Width = 40
        Height = 26
        Hint = #1055#1088#1086#1081#1090#1080' '#1090#1077#1089#1090
        Align = alLeft
        Glyph.Data = {
          36030000424D3603000000000000360000002800000010000000100000000100
          18000000000000030000C40E0000C40E00000000000000000000FFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF148732037B1EFBFD
          FBFFFFFFFFFFFFFFFFFFFFFFFF13405815425E25699C2C76B47AB0D0FFFFFFFF
          FFFFFFFFFFFFFFFF158D3C43A15F33954CF9FCFAFFFFFFFFFFFFFFFFFF124259
          5D9CD4A6CFF5A9CFEC488BC12197521D924A179044118C3D3A9F5E80C19646A3
          622E9447F8FBF9FFFFFFFFFFFF1E6D93CBE3F961AAEC4098E81567C2299B5B90
          CAA98DC8A58AC6A188C59E6AB68582C29748A566289144F6FAF7FFFFFF1E6D93
          C8E1F2D1E7FA347DB53199C3319F6394CDAD6FBA8E6BB88966B68561B38067B5
          8283C2983CA05C06822AFFFFFFE3EBF22689B9B0CBE167A9C860DCF537A36B96
          CEB094CDAD91CBAA90CBA874BC908AC7A146A5680B8938FEFFFEFFFFFFFFFFFF
          FFFFFF2689B9BEE6F2B3F4FC3DA56F37A46F34A269309D6355AF7C91CBAA4FAB
          741B9148FEFFFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF2790BFC3EDF8B3F4FC60
          DCF544D6F48EEEFA34A16D5AB381289857FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFF2FBAE4C3EDF8B3F4FC60DCF544D6F43EA976319F653B8F
          D9FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF2FBAE4C3
          EDF8B3F4FC60DCF544D6F48EEEFA5DB4E63B8FD9FFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF2FBAE4C3EDF8B3F4FC68D9F56FCFF3599D
          D073ABDD4F91C9FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFF2FBAE4C3EDF8A8E2F86CAEDDA5CFF4A5CFF4BDDBF75896CDFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF2FBAE4A7D4F4C5E1F8CCE3
          F9CCE3F9BDDBF75091C9FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFF50A8D96AA5D8C9E1F7CBE3F84295CA72AAD5FFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF8FDFE5DB1DE5194
          CA4E90C849A9D8EBF6FCFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF}
        ParentShowHint = False
        ShowHint = True
        OnClick = btTestClick
      end
    end
  end
end
