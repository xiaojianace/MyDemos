object Form1: TForm1
  Left = 263
  Top = 186
  Width = 849
  Height = 519
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
    Width = 60
    Height = 13
    Caption = #25195#25551#25480#26435#30721
  end
  object Label2: TLabel
    Left = 184
    Top = 112
    Width = 36
    Height = 13
    Caption = #35746#21333#21495
  end
  object Label3: TLabel
    Left = 184
    Top = 152
    Width = 48
    Height = 13
    Caption = #25903#20184#37329#39069
  end
  object Label4: TLabel
    Left = 192
    Top = 253
    Width = 36
    Height = 13
    Caption = #35746#21333#21495
  end
  object Label5: TLabel
    Left = 192
    Top = 293
    Width = 36
    Height = 13
    Caption = #24635#37329#39069
  end
  object Label6: TLabel
    Left = 192
    Top = 333
    Width = 48
    Height = 13
    Caption = #36864#27454#37329#39069
  end
  object Label7: TLabel
    Left = 616
    Top = 144
    Width = 36
    Height = 13
    Caption = #65288#20998#65289
  end
  object edtSMSQM: TEdit
    Left = 264
    Top = 72
    Width = 321
    Height = 21
    TabOrder = 0
  end
  object edtDDH: TEdit
    Left = 264
    Top = 112
    Width = 321
    Height = 21
    TabOrder = 1
    Text = 'CXJ_XP1608180037'
  end
  object edtJE: TEdit
    Left = 264
    Top = 144
    Width = 321
    Height = 21
    TabOrder = 2
    Text = '1'
  end
  object btnPay: TButton
    Left = 272
    Top = 200
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
    TabOrder = 4
    Text = 'CXJ_XP1608060015'
  end
  object edtZJE: TEdit
    Left = 272
    Top = 293
    Width = 321
    Height = 21
    TabOrder = 5
    Text = '1'
  end
  object edtTHJE: TEdit
    Left = 272
    Top = 325
    Width = 321
    Height = 21
    TabOrder = 6
    Text = '1'
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
  object Button1: TButton
    Left = 560
    Top = 400
    Width = 75
    Height = 25
    Caption = #26597#35810#35746#21333
    TabOrder = 8
    OnClick = Button1Click
  end
  object http: TIdHTTP
    IOHandler = ssl
    AllowCookies = True
    ProxyParams.BasicAuthentication = False
    ProxyParams.ProxyPort = 0
    Request.ContentLength = -1
    Request.Accept = 'text/html, */*'
    Request.BasicAuthentication = False
    Request.UserAgent = 'Mozilla/3.0 (compatible; Indy Library)'
    HTTPOptions = [hoForceEncodeParams]
    Left = 504
    Top = 184
  end
  object ssl: TIdSSLIOHandlerSocketOpenSSL
    MaxLineAction = maException
    Port = 0
    DefaultPort = 0
    SSLOptions.CertFile = 'apiclient_cert.pem'
    SSLOptions.KeyFile = 'apiclient_key.pem'
    SSLOptions.Mode = sslmUnassigned
    SSLOptions.VerifyMode = []
    SSLOptions.VerifyDepth = 0
    Left = 600
    Top = 184
  end
  object Timer1: TTimer
    Interval = 5000
    OnTimer = Timer1Timer
    Left = 648
    Top = 272
  end
end
