object frmTestResult: TfrmTestResult
  Left = 0
  Top = 0
  Caption = #1050#1086#1083#1077#1089#1086' '#1076#1086#1089#1090#1080#1078#1077#1085#1080#1071' '#1091#1089#1087#1077#1093#1072
  ClientHeight = 568
  ClientWidth = 792
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnDestroy = FormDestroy
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 16
  object img: TImage
    Left = 0
    Top = 30
    Width = 792
    Height = 538
    Align = alClient
    ExplicitWidth = 500
    ExplicitHeight = 400
  end
  object pnlTools: TPanel
    Left = 0
    Top = 0
    Width = 792
    Height = 30
    Align = alTop
    BevelOuter = bvNone
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
    DesignSize = (
      792
      30)
    object btExit: TSpeedButton
      Left = 757
      Top = 0
      Width = 35
      Height = 30
      Hint = #1042#1099#1093#1086#1076
      Align = alRight
      Glyph.Data = {
        36030000424D3603000000000000360000002800000010000000100000000100
        18000000000000030000C40E0000C40E00000000000000000000FFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFECF2F6CCDBE8A5C1D680A7
        C56394B8165E931D63979999997171715454545151514F4F4F4C4C4C4A4A4A47
        474745454525679D3274A83D7CAF4784B54E8ABA3E7EAD206598FFFFFFFFFFFF
        585858A2A2A2A2A2A2A3A3A3A4A4A4A4A4A4A5A5A52F6FA578ABD278ABD373A7
        D169A0CD407FAE23679AFFFFFFFFFFFF5C5C5CA1A1A13C7340A0A1A1A3A3A3A3
        A3A3A4A4A43674AA7DAFD45B9AC95495C75896C84180AE26699DFFFFFFFFFFFF
        606060A0A0A03D7641367139A2A2A2A2A2A2A3A3A33D79B082B3D7629FCC5A9A
        C95E9BCA4381AF2C6DA037823E347E3B3179372E7534499150468F4C39733DA1
        A1A1A2A2A2457EB488B7D967A3CF619ECC639FCC4583B13171A43B874289CB92
        84C88D80C6887BC38377C17F478F4D3B743FA1A1A14C84BA8DBBDB6EA8D166A6
        D15FB4DF4785B13775A93E8B468FCE997DC68778C38173C07C74C07C79C28149
        904F547F575489BF94BFDD75ADD463B8E14BD4FF428BB83D7AAD41904A94D29F
        91D09A8DCD9689CB9284C88D519858417C469F9F9F5A8EC498C3E07CB3D774AF
        D65EC4ED4B88B3457FB244944D42914B3F8D483D89455DA4655AA06145834B9E
        9E9E9E9E9E6092C99EC7E283B8DA7DB4D77EB3D74F89B44B84B7FFFFFFFFFFFF
        7777779A9A9A3D8A45498A4F9C9C9C9D9D9D9D9D9D6696CCA2CBE389BDDC83B9
        DA84B9DA518BB55289BCFFFFFFFFFFFF7A7A7A999999529159999A999B9B9B9C
        9C9C9C9C9C6C9AD0A7CEE58FC1DF89BDDC8BBDDC538DB65A8EC2FFFFFFFFFFFF
        7D7D7D9999999999999A9A9A9A9A9A9B9B9B9B9B9B6F9DD3AAD1E7ABD1E798C7
        E191C2DE568FB76093C6FFFFFFFFFFFF8080807E7E7E7C7C7C7A7A7A77777775
        7575727272719ED46F9ED687B2DCABD3E8A9D0E65890B86797CBFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF84ACDC6D9C
        D485B1DA5A91B96D9CCFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFB1CAE86C9CD3709ED2}
      OnClick = btExitClick
      ExplicitLeft = 520
      ExplicitHeight = 33
    end
    object btClearResults: TSpeedButton
      Left = 0
      Top = 0
      Width = 35
      Height = 30
      Hint = #1057#1073#1088#1086#1089#1080#1090#1100' '#1088#1077#1079#1091#1083#1100#1090#1072#1090#1099' '#1090#1077#1089#1090#1080#1088#1086#1074#1072#1085#1080#1103
      Align = alLeft
      Glyph.Data = {
        36030000424D3603000000000000360000002800000010000000100000000100
        18000000000000030000C40E0000C40E00000000000000000000FFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE5E8F79EA9E1546BC73F
        59C03A53BF4C67C297A7DCE1E6F5FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFC3C9ED5566CC3C52CC757AE88F92EE8F92EE7178E4334DC1405CBEB9C4
        E7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC5C9EF5160CD5C65E0A1A6F57E86EF5B
        63E9595DE77D84EE9EA0F4515DD73452BAB9C4E7FFFFFFFFFFFFFFFFFFE8EAF9
        6571D4616BE3A1ACF5545FEC505CEA4D59E94E59E64C56E65056E69EA2F45460
        D6405CBFE2E7F5FFFFFFFFFFFFACB0EA4B56DBA2ABF65664F05266EE4D59E94D
        59E94D59E94D59E94C58E6525AE69FA3F53450C496A6DCFFFFFFFFFFFF7378DD
        818CEE7E91F75D73F34D59E94D59E94D59E94D59E94D59E94D59E94F5BE97B83
        F0757BE24C64C4FFFFFFFFFFFF6569DBA1ABF77086F86882F6FFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFF4D59E95C66EA969CF13956BEFFFFFFFFFFFF696EDC
        AFB9F97F93FA7085F0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF4D59E95E6A
        EE969DF13D55C0FFFFFFFFFFFF7C7FE3A5AFF59DABFA778CF0545FEC545FEC54
        5FEC545FEC545FEC545FEC6377F2818EF4787FE9566BC9FFFFFFFFFFFFB5B5F0
        7D83EACDD4FC8B9DFA7E93F7758AEE6C84F66C84F66C84F66C84F66379F3A4AF
        F83E4FD0A0ABE1FFFFFFFFFFFFEBEBFB7978E3A3A7F3D4DBFD879AFA7F91F07A
        8EF17F94F87E92F9768CF8A8B6F8636EE35868CDE6E8F7FFFFFFFFFFFFFFFFFF
        CFCFF6706FE1AAADF2D8DCFDAEBAFA91A3FA8B9DFA9CA9FBBAC7FC707BE95462
        CEC3C9EEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFCFCFF67979E28E93EDBEC3F8CC
        D3F9C4CBF9AAB4F46670E2646ED6C6CAEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFEBEBFBB6B6F07D7FE26A6BDE686BDC7479DEAFB3EBE8E9F9FFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF}
      OnClick = btClearResultsClick
      ExplicitHeight = 27
    end
    object pnlOptions: TPanel
      Left = 256
      Top = 0
      Width = 270
      Height = 30
      Align = alCustom
      Anchors = []
      BevelOuter = bvNone
      Constraints.MaxWidth = 270
      TabOrder = 0
      object Label1: TLabel
        Left = 2
        Top = 6
        Width = 182
        Height = 16
        Caption = #1044#1086#1074#1086#1083#1100#1085#1099' '#1083#1080' '#1074#1099' '#1088#1077#1079#1091#1083#1100#1090#1072#1090#1086#1084'?'
        Layout = tlCenter
      end
      object btYes: TSpeedButton
        Left = 193
        Top = 0
        Width = 35
        Height = 30
        Constraints.MaxWidth = 35
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
        OnClick = btYesClick
      end
      object btNo: TSpeedButton
        Left = 228
        Top = 0
        Width = 35
        Height = 30
        Glyph.Data = {
          36030000424D3603000000000000360000002800000010000000100000000100
          18000000000000030000C40E0000C40E00000000000000000000FFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF1313F20000F10000F100
          00F10000EF0000EF0000ED1212EEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFF1313F61A20F53C4CF93A49F83847F83545F83443F73242F7141BF11717
          EFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF1313F81D23F94453FA2429F91212F70F
          0FF60C0CF50909F5161BF53343F7141BF11717EFFFFFFFFFFFFFFFFFFF1313F9
          1F25FA4A58FB4247FBC9C9FD3B3BF91313F71010F63333F7C5C5FD3035F73444
          F7141BF21717EFFFFFFFFFFFFF0000FB4F5DFD3237FBCBCBFEF2F2FFEBEBFE3B
          3BF93939F8EAEAFEF1F1FEC5C5FD181DF63343F70000EFFFFFFFFFFFFF0000FD
          525FFD2828FC4747FCECECFFF2F2FFECECFFECECFEF1F1FFEAEAFE3434F70B0B
          F53545F80000EFFFFFFFFFFFFF0000FD5562FE2C2CFD2929FC4848FCEDEDFFF2
          F2FFF2F2FFECECFE3A3AF91212F70F0FF63848F80000F1FFFFFFFFFFFF0000FD
          5764FE3030FD2D2DFD4B4BFCEDEDFFF2F2FFF2F2FFECECFF3D3DF91616F81313
          F73C4BF80000F1FFFFFFFFFFFF0000FF5A67FE3333FE5050FDEDEDFFF3F3FFED
          EDFFEDEDFFF2F2FFECECFE3E3EFA1717F83F4EF90000F1FFFFFFFFFFFF0000FF
          5B68FF4347FECFCFFFF3F3FFEDEDFF4C4CFC4A4AFCECECFFF2F2FFCACAFE2A2F
          FA4251FA0000F3FFFFFFFFFFFF1414FF262BFF5D6AFF585BFFCFCFFF5252FE2F
          2FFD2C2CFD4B4BFCCCCCFE484CFB4957FB1D23F91414F6FFFFFFFFFFFFFFFFFF
          1414FF262BFF5D6AFF4347FF3434FE3232FE3030FD2D2DFD383CFC4F5DFC1F25
          FA1414F8FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF1414FF262BFF5C69FF5B68FF5A
          67FE5865FE5663FE5461FE2227FC0D0DFBFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFF1313FF0000FF0000FF0000FF0000FD0000FD0000FD1313FDFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF}
        OnClick = btNoClick
      end
    end
    object chkRandom: TCheckBox
      Left = 619
      Top = 7
      Width = 129
      Height = 17
      Anchors = [akTop, akRight]
      Caption = #1057#1083#1091#1095#1072#1081#1085#1099#1077' '#1095#1080#1089#1083#1072
      TabOrder = 1
      Visible = False
      OnClick = chkRandomClick
    end
  end
end
