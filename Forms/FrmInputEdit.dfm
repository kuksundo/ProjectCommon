object InputEditF: TInputEditF
  Left = 0
  Top = 0
  Caption = 'Edit Invoice No.'
  ClientHeight = 139
  ClientWidth = 377
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 16
  object Label1: TLabel
    Left = 64
    Top = 24
    Width = 72
    Height = 16
    Alignment = taRightJustify
    Caption = 'Invoice No.: '
  end
  object InputEdit: TEdit
    Left = 142
    Top = 21
    Width = 203
    Height = 24
    ImeName = 'Microsoft IME 2010'
    TabOrder = 0
  end
  object BitBtn1: TBitBtn
    Left = 40
    Top = 82
    Width = 121
    Height = 39
    Kind = bkCancel
    NumGlyphs = 2
    TabOrder = 1
  end
  object BitBtn2: TBitBtn
    Left = 224
    Top = 82
    Width = 121
    Height = 39
    Kind = bkOK
    NumGlyphs = 2
    TabOrder = 2
  end
end
