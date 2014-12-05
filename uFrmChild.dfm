object frmChild: TfrmChild
  Left = 0
  Top = 0
  Caption = 'frmChild'
  ClientHeight = 357
  ClientWidth = 605
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object lbl1: TLabel
    Left = 16
    Top = 8
    Width = 261
    Height = 13
    Caption = 'frmChild use public query to read data,stack overflow.'
  end
  object btnDataChild: TBitBtn
    Left = 397
    Top = 8
    Width = 116
    Height = 26
    Caption = 'GetChildData'
    TabOrder = 0
    OnClick = btnDataChildClick
  end
  object dbgrd1: TDBGrid
    Left = 16
    Top = 40
    Width = 561
    Height = 297
    DataSource = dsChild
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
    Columns = <
      item
        Expanded = False
        FieldName = 'ibm'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'cmc'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'cxm'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'benable'
        Visible = True
      end>
  end
  object qryChild: TADOQuery
    Connection = DM_data.ado_mydata
    CursorType = ctStatic
    Parameters = <>
    SQL.Strings = (
      'SELECT * FROM TBadoChild')
    Left = 216
    Top = 104
  end
  object dsChild: TDataSource
    DataSet = qryChild
    Left = 272
    Top = 128
  end
end
