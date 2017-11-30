object Form1: TForm1
  Left = 263
  Top = 186
  Width = 1006
  Height = 684
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 184
    Top = 72
    Width = 70
    Height = 13
    Caption = #25195#25551#25480#26435#30721
  end
  object Label2: TLabel
    Left = 184
    Top = 112
    Width = 42
    Height = 13
    Caption = #35746#21333#21495
  end
  object Label3: TLabel
    Left = 184
    Top = 152
    Width = 56
    Height = 13
    Caption = #25903#20184#37329#39069
  end
  object Label4: TLabel
    Left = 192
    Top = 253
    Width = 42
    Height = 13
    Caption = #35746#21333#21495
  end
  object Label5: TLabel
    Left = 192
    Top = 293
    Width = 42
    Height = 13
    Caption = #24635#37329#39069
  end
  object Label6: TLabel
    Left = 192
    Top = 333
    Width = 56
    Height = 13
    Caption = #36864#27454#37329#39069
  end
  object edtSMSQM: TEdit
    Left = 264
    Top = 72
    Width = 321
    Height = 21
    ImeName = #20013#25991'('#31616#20307') - '#19975#33021#20116#31508#36755#20837#27861
    TabOrder = 0
  end
  object edtDDH: TEdit
    Left = 264
    Top = 112
    Width = 321
    Height = 21
    ImeName = #20013#25991'('#31616#20307') - '#19975#33021#20116#31508#36755#20837#27861
    TabOrder = 1
    Text = 'CXJ_XP1608160015'
  end
  object edtJE: TEdit
    Left = 264
    Top = 144
    Width = 321
    Height = 21
    ImeName = #20013#25991'('#31616#20307') - '#19975#33021#20116#31508#36755#20837#27861
    TabOrder = 2
    Text = '0.01'
  end
  object btnPay: TButton
    Left = 272
    Top = 192
    Width = 75
    Height = 25
    Caption = #25903#20184
    TabOrder = 3
    OnClick = btnPayClick
  end
  object edtTHDDH: TEdit
    Left = 272
    Top = 253
    Width = 321
    Height = 21
    ImeName = #20013#25991'('#31616#20307') - '#19975#33021#20116#31508#36755#20837#27861
    TabOrder = 4
    Text = 'CXJ_XP1608160015'
  end
  object edtZJE: TEdit
    Left = 272
    Top = 293
    Width = 321
    Height = 21
    ImeName = #20013#25991'('#31616#20307') - '#19975#33021#20116#31508#36755#20837#27861
    TabOrder = 5
    Text = '0.01'
  end
  object edtTHJE: TEdit
    Left = 272
    Top = 325
    Width = 321
    Height = 21
    ImeName = #20013#25991'('#31616#20307') - '#19975#33021#20116#31508#36755#20837#27861
    TabOrder = 6
    Text = '0.01'
  end
  object btnRefud: TButton
    Left = 272
    Top = 368
    Width = 75
    Height = 25
    Caption = #36864#27454
    TabOrder = 7
    OnClick = btnRefudClick
  end
  object Memo1: TMemo
    Left = 560
    Top = 376
    Width = 393
    Height = 241
    ImeName = #20013#25991'('#31616#20307') - '#19975#33021#20116#31508#36755#20837#27861
    Lines.Strings = (
      '')
    TabOrder = 8
  end
  object Button1: TButton
    Left = 432
    Top = 480
    Width = 75
    Height = 25
    Caption = #26597#35810
    TabOrder = 9
    OnClick = Button1Click
  end
  object http: TIdHTTP
    AllowCookies = True
    ProxyParams.BasicAuthentication = False
    ProxyParams.ProxyPort = 0
    Request.ContentLength = -1
    Request.Accept = 'text/html, */*'
    Request.BasicAuthentication = False
    Request.UserAgent = 'Mozilla/3.0 (compatible; Indy Library)'
    HTTPOptions = [hoForceEncodeParams]
    Left = 728
    Top = 160
  end
end
