object frmTasks: TfrmTasks
  Left = 0
  Top = 0
  Align = alClient
  BorderStyle = bsNone
  ClientHeight = 338
  ClientWidth = 936
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnDestroy = FormDestroy
  OnMouseWheel = FormMouseWheel
  OnPaint = FormPaint
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 16
  object Splitter1: TSplitter
    Left = 261
    Top = 0
    Width = 5
    Height = 308
    Color = clGray
    ParentColor = False
    ExplicitLeft = 169
    ExplicitHeight = 281
  end
  object pnlLinks: TPanel
    Left = 0
    Top = 0
    Width = 261
    Height = 308
    Align = alLeft
    BevelOuter = bvNone
    TabOrder = 0
  end
  object ScrollBox: TScrollBox
    Left = 266
    Top = 0
    Width = 670
    Height = 308
    Align = alClient
    BevelInner = bvNone
    BevelOuter = bvNone
    BorderStyle = bsNone
    DoubleBuffered = True
    Color = clWhite
    ParentColor = False
    ParentDoubleBuffered = False
    PopupMenu = PopupMenu1
    TabOrder = 1
    object img: TImage
      Left = 6
      Top = 36
      Width = 591
      Height = 169
      Align = alCustom
      PopupMenu = PopupMenu1
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 308
    Width = 936
    Height = 30
    Align = alBottom
    BevelOuter = bvNone
    ParentShowHint = False
    ShowHint = True
    TabOrder = 2
    object pnlTools: TPanel
      Left = 272
      Top = 0
      Width = 416
      Height = 30
      BevelOuter = bvNone
      TabOrder = 0
      DesignSize = (
        416
        30)
      object btNext: TSpeedButton
        Left = 376
        Top = 0
        Width = 40
        Height = 30
        Action = actNextClick
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
        ExplicitLeft = 382
        ExplicitTop = 6
      end
      object btPrev: TSpeedButton
        Left = 336
        Top = 0
        Width = 40
        Height = 30
        Action = actPrevClick
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
        ExplicitLeft = 342
        ExplicitTop = 6
      end
      object btHelp: TSpeedButton
        Left = 271
        Top = 0
        Width = 40
        Height = 30
        Action = actHelpClick
        Align = alRight
        Glyph.Data = {
          36030000424D3603000000000000360000002800000010000000100000000100
          18000000000000030000C40E0000C40E00000000000000000000FFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF4ECE5D6BAA2B6845AAC
          7445AB7243B27E53D2B59CF2EAE3FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFE7D5C6BA895FD7BBA3E9DACAECE0D1ECE0D1E8D8C8D3B59CB07A4DE2CF
          BEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEAD9CBBE8C62E7D5C4E5D2BFC9A685B8
          8E67B68A65C5A180E0CCBAE3D0BEAF7648E3D0C0FFFFFFFFFFFFFFFFFFF7F1EC
          C99D79EAD8C9E3CDBAC0946BBA8C62CFB094CFB094B7895FB28761DAC0AAE4D1
          C0B68359F4ECE6FFFFFFFFFFFFE6CFBCE4CCB9EAD6C5C79971BF9066BF9066F7
          F1ECF6F0EAB7895FB7895FB58963E2CEBBD9BDA6D9BEA7FFFFFFFFFFFFD9B395
          EFE1D3D9B595C7986CC39569C19367BF9066BF9066BB8B63B98A63B88A62CBA7
          86EADCCCC2956FFFFFFFFFFFFFDAB393F2E4D9D1A57AC5996BC4976AC49669FA
          F6F2F3EAE1C2956DBE8F65BE8F64C0956DEFE3D5C19067FFFFFFFFFFFFE1BB9D
          F2E5DAD1A67ECC9D71C79A6CC5986BE2CCB6F8F3EEF6EEE8D9BDA1C29468C59B
          71F0E2D6C79971FFFFFFFFFFFFEACAB0F3E5D9DFBB9ECFA075CD9E72F5EBE3E4
          CBB4E7D3BFFBF8F6E5D3BFC4986BD6B491EEE0D2D3AC8BFFFFFFFFFFFFF5E4D6
          F4E3D4EFDCCDD5A87ED0A077FBF8F5FCF8F5FCF8F5FBF8F5D1A881CFA47BEAD5
          C3EAD4C2E9D4C2FFFFFFFFFFFFFDF9F5F1D3BBF6E9DDECD8C6D7AC81DCBB9AF6
          ECE3F5ECE2E4C8AED2A77BE6CEBAF1E2D5DFBB9CFAF4F0FFFFFFFFFFFFFFFFFF
          FBF1E9F3D4BBF7EADFEEDED0E3C1A7D8AE89D7AC86DDBB9CEBD6C7F3E6D9E4C1
          A3F5E9DFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFCF2EAF6DAC3F9E9DCF6E8DDF3
          E5DAF3E5DAF5E7DCF5E4D6EDCDB4F8ECE3FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFEFAF7FCEDE1F8DEC9F6D9C1F5D7BFF5D9C3F8E8DCFDF8F5FFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF}
        ExplicitLeft = 260
        ExplicitHeight = 26
      end
      object btResults: TSpeedButton
        Left = 231
        Top = 0
        Width = 40
        Height = 30
        Action = actResultClick
        Align = alRight
        Glyph.Data = {
          36030000424D3603000000000000360000002800000010000000100000000100
          18000000000000030000C40E0000C40E00000000000000000000FFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5F5FE928FF5514BEE1D15E8D6
          D5FBFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          CBCAFB524DF35856EB6C6DE7332DE9D7D6FBAA6B47A86C4DC49F8BF9F6F4FFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFC7C6FC6262F37D7FEE9499EB8D91E93B37ECD9
          D7FBB2704DD68E62B866439C5A38DDC8BDFFFFFFFFFFFFFFFFFFF3F3FF6767F8
          9599F2A5AAEE7B81E6979AEB4440EFDAD9FCB87752DB9970E6A47FCB8057A655
          31D8BFB3FFFFFFFFFFFFF6F6FFA6A7FC6666F98485F4A3A8EFA0A5ED4F4CF1DC
          DBFDC07E58DEA179DE895BE6A67FD0875C954E27F5EFECFFFFFFABD1AEB1D3B4
          EEF0FAAAAAFC6464F87C7EF35958F4DEDDFDC6865EE1A881E09264D9794CE7A8
          84BE704AC69F8AFFFFFF6FB67690BF934F9C55A6CBA9ECEFF7B2B2FC6261F8E0
          DFFDCE8D65E4B08BE39C6DDD8554E29667DA976DAD6E4CFFFFFF60B469CAE8C8
          AFD9AB92BF9448954D9BC19DF5F4F9F6F2F5D4966BE7B793E7A677E0905DDE8E
          5CE6AD88A75B32FFFFFF64BA6EB6E0B17BCC6F92D289ADD9A989B88B83B386F2
          DAC8D38D5AEFC8A9E6A673E29B67E29866E7B38FB0663AFFFFFF84CD8FBADFB8
          7ACC6D66C65972C866A8DAA368A86DD0E3D1E1AC83E6B58EF0CCACE5A671E9B1
          84E3AF88C2815BFFFFFFB7E3BDB3DAB5A2D89A6DCA5F66C65880CC75A3CEA363
          A769F7EBE0D99460F2D1B2EBB98DF0C9AAD89C70DCB39BFFFFFFF6FCF77BCC88
          BEE1BE94D4896ECA626EC9609ED69793C196B1D4B3ECC5A5E7B48EF3D3B5E9BB
          98CD8653FBF5F2FFFFFFFFFFFFD5F0DAA0D5A8BAE0BBA7DAA07DCE707FCD73B0
          D9AD57A85EF1F2E8E1A573EBC29EDDA273F0DAC9FFFFFFFFFFFFFFFFFFFFFFFF
          DFF4E389D395B4DCB7BCE0BAB9E1B5CEEACBA4CEA695C99AF3DAC4E3AB7CF6E6
          D8FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF9FDFABDE7C492D49C6CC37965
          BD7180C689ACD7B0FEFEFDFEFCF9FFFFFFFFFFFFFFFFFFFFFFFF}
        ExplicitLeft = 225
      end
      object btAnswear: TSpeedButton
        Left = 191
        Top = 0
        Width = 40
        Height = 30
        Action = actAnswearClick
        Align = alRight
        Glyph.Data = {
          36030000424D3603000000000000360000002800000010000000100000000100
          18000000000000030000C40E0000C40E00000000000000000000FFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE0EEE08FC0913B8D3F25
          7A292577293B853F8FB991E0EBE0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFB5D9B7318F3542A05287CA9A9BD3AB9BD2AB83C7963D974C307C34B5D0
          B6FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFB5DBBA258F2A6DBE83A8DBB587CC9866
          BC7D64BA7C86CB98A5D9B466B77D247227B5D1B6FFFFFFFFFFFFFFFFFFE1F2E4
          33A14472C287A8DBB260BC775CBA7359B87059B56F58B56F5BB774A5D9B369B8
          7F317F35E1ECE1FFFFFFFFFFFF90D29F4CB064AADDB464C1795FBE7175C585D4
          ECD98ACD9956B66C58B56E5CB774A6DAB4419B4E8EBC90FFFFFFFFFFFF3FB55D
          91D29F8DD49A64C37479C987F2FAF4FFFFFFFDFEFD86CB9657B76D5BB97285CC
          9787C79A3B8B3FFFFFFFFFFFFF27B049A6DCAF70CA7F73CA80F0F9F1FFFFFFEB
          F7EDFFFFFFFBFDFC88CD965BB97167BE7DA0D7AF237F26FFFFFFFFFFFF2EB751
          A7DDB172CC8066C773B0E1B7D2EED663C170B8E3BFFFFFFFFBFDFC8CD09969C1
          7EA1D7AE238426FFFFFFFFFFFF4BC56C95D7A191D79B69C97664C66F61C46E61
          C36F61C26FB9E4C0FFFFFFE3F4E68BD1998BCE9D3C993FFFFFFFFFFFFF9BDFAD
          57BF70AFE1B76DCC7A68C87265C77063C56E62C46E63C471B6E3BE6FC77EACDF
          B548A95E8FC894FFFFFFFFFFFFE5F7E949C5667FCE90AEE1B56DCC7A6ACA7668
          C87268C87468C8756BC979ACDFB476C48933A142E1F1E3FFFFFFFFFFFFFFFFFF
          BFECCB3DC35C7FCE90AFE1B792D89D77CE8377CE8392D89DAEE1B578C88B27A1
          3BB5DFBEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC0EDCB4AC86959C27496D7A3A5
          DCAEA5DCAE95D6A150B96A35B355B6E3C1FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFE5F8E99FE3B055CB723BC05C37BE5A49C36A97DCAAE1F5E7FFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF}
        ExplicitLeft = 247
        ExplicitTop = -1
      end
      object Label3: TLabel
        Left = 7
        Top = 7
        Width = 40
        Height = 16
        Align = alCustom
        Caption = #1054#1090#1074#1077#1090':'
      end
      object txtAnswer: TEdit
        Left = 47
        Top = 4
        Width = 137
        Height = 24
        Anchors = [akLeft, akBottom]
        TabOrder = 0
        OnKeyDown = txtAnswerKeyDown
      end
      object Panel1: TPanel
        Left = 311
        Top = 0
        Width = 25
        Height = 30
        Align = alRight
        BevelOuter = bvNone
        TabOrder = 1
      end
    end
  end
  object PopupMenu1: TPopupMenu
    Left = 336
    Top = 112
    object mnuGoToPage: TMenuItem
      Action = actGoToPage
    end
  end
  object ActionList: TActionList
    Left = 432
    Top = 120
    object actGoToPage: TAction
      Caption = #1055#1077#1088#1077#1081#1090#1080' '#1085#1072' '#1089#1090#1088#1072#1085#1080#1094#1091
      ShortCut = 16455
      OnExecute = actGoToPageExecute
    end
    object actAnswearClick: TAction
      OnExecute = actAnswearClickExecute
    end
    object actResultClick: TAction
      OnExecute = actResultClickExecute
    end
    object actHelpClick: TAction
      OnExecute = actHelpClickExecute
    end
    object actNextClick: TAction
      ShortCut = 39
      OnExecute = actNextClickExecute
    end
    object actPrevClick: TAction
      ShortCut = 37
      OnExecute = actPrevClickExecute
    end
  end
end
