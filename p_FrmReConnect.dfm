object frmReConnect: TfrmReConnect
  Left = 0
  Top = 0
  BorderIcons = [biMinimize, biMaximize]
  BorderStyle = bsDialog
  Caption = #37325#26032#36830#25509#25968#25454#24211
  ClientHeight = 166
  ClientWidth = 360
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object lblStatus: TLabel
    Left = 39
    Top = 5
    Width = 283
    Height = 21
    Alignment = taCenter
    AutoSize = False
    Caption = #23458#25143#31471#24050#22833#21435#19982#26381#21153#22120#30340#36830#25509
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -17
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    Layout = tlCenter
  end
  object lblDosth: TLabel
    Left = 27
    Top = 31
    Width = 307
    Height = 21
    Alignment = taCenter
    AutoSize = False
    Caption = #27491#22312#27979#35797#26159#21542#21487#36830#25509#25968#25454#24211#26381#21153#22120'...'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -17
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object lblHidden: TLabel
    Left = 8
    Top = 8
    Width = 87
    Height = 13
    Caption = '                             '
    Transparent = True
    OnClick = lblHiddenClick
  end
  object lstInfo: TListBox
    Left = 6
    Top = 81
    Width = 349
    Height = 78
    Ctl3D = False
    ItemHeight = 13
    ParentCtl3D = False
    TabOrder = 0
    OnClick = lstInfoClick
  end
  object btnCloseAll: TBitBtn
    Left = 328
    Top = 0
    Width = 31
    Height = 25
    Caption = 'X'
    TabOrder = 1
    Visible = False
    OnClick = btnCloseAllClick
  end
  object tmrHint: TTimer
    Left = 79
    Top = 88
  end
  object Icmp: TIdIcmpClient
    ReceiveTimeout = 1000
    Protocol = 1
    ProtocolIPv6 = 58
    IPVersion = Id_IPv4
    PacketSize = 1024
    OnReply = IcmpReply
    Left = 243
    Top = 88
  end
  object tmrPIng: TTimer
    Interval = 3000
    OnTimer = tmrPIngTimer
    Left = 168
    Top = 80
  end
end
