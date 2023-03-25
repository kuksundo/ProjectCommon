object pjhStringsEditorDlg: TpjhStringsEditorDlg
  Left = 245
  Top = 177
  Caption = 'String List Editor'
  ClientHeight = 492
  ClientWidth = 713
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 451
    Width = 713
    Height = 41
    Align = alBottom
    TabOrder = 0
    object btnOk: TButton
      Left = 265
      Top = 5
      Width = 75
      Height = 25
      Caption = '&OK'
      Default = True
      ModalResult = 1
      TabOrder = 0
    end
    object btnCancel: TButton
      Left = 345
      Top = 5
      Width = 75
      Height = 25
      Cancel = True
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 1
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 713
    Height = 35
    Align = alTop
    TabOrder = 1
    object lbLineCount: TLabel
      Left = 12
      Top = 12
      Width = 30
      Height = 13
      AutoSize = False
      Caption = '0 lines'
    end
  end
  object memMain: TMemo
    Left = 0
    Top = 35
    Width = 713
    Height = 416
    Align = alClient
    ScrollBars = ssVertical
    TabOrder = 2
  end
end
