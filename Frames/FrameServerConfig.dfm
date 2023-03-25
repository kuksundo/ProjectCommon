object ServerConfigFrame: TServerConfigFrame
  Left = 0
  Top = 0
  Width = 449
  Height = 394
  TabOrder = 0
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 449
    Height = 394
    ActivePage = TabSheet2
    Align = alClient
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    object TabSheet1: TTabSheet
      Caption = #51200#51109#51068#49884
      TabVisible = False
    end
    object TabSheet2: TTabSheet
      Caption = 'IPC Server'
      ImageIndex = 2
      object WSSocketEnableCB: TAdvGroupBox
        Tag = 90
        Left = 32
        Top = 41
        Width = 353
        Height = 121
        Hint = 'TAdvGroupBox'
        CaptionPosition = cpTopCenter
        CheckBox.Visible = True
        Caption = 'Web Socket Enable'
        TabOrder = 0
        object Label20: TLabel
          Left = 101
          Top = 58
          Width = 58
          Height = 16
          Caption = 'Port Num:'
          ParentShowHint = False
          ShowHint = False
        end
        object Label25: TLabel
          Left = 49
          Top = 87
          Width = 110
          Height = 16
          Caption = 'Transmission Key:'
          ParentShowHint = False
          ShowHint = False
        end
        object Label26: TLabel
          Left = 90
          Top = 23
          Width = 69
          Height = 16
          Caption = 'IP Address:'
          ParentShowHint = False
          ShowHint = False
        end
        object WSPortEdit: TEdit
          Tag = 92
          Left = 165
          Top = 56
          Width = 111
          Height = 22
          Hint = 'Text'
          Alignment = taRightJustify
          ImeName = #54620#44397#50612'('#54620#44544') (MS-IME98)'
          TabOrder = 0
        end
        object Edit14: TEdit
          Tag = 93
          Left = 165
          Top = 85
          Width = 173
          Height = 22
          Hint = 'Text'
          Alignment = taRightJustify
          ImeName = #54620#44397#50612'('#54620#44544') (MS-IME98)'
          TabOrder = 1
        end
        object JvIPAddress1: TJvIPAddress
          Tag = 91
          Left = 165
          Top = 22
          Width = 150
          Height = 24
          Hint = 'Text'
          Address = 0
          ParentColor = False
          TabOrder = 2
        end
      end
      object RemoteAuthEnableCB: TCheckBox
        Tag = 94
        Left = 48
        Top = 184
        Width = 177
        Height = 17
        Hint = 'Checked'
        Caption = 'Remote Auth Enable'
        TabOrder = 1
      end
      object AdvGroupBox1: TAdvGroupBox
        Tag = 100
        Left = 32
        Top = 223
        Width = 353
        Height = 106
        Hint = 'TAdvGroupBox'
        CaptionPosition = cpTopCenter
        CheckBox.Visible = True
        Caption = 'Named Pipe Enable'
        TabOrder = 2
        object Label28: TLabel
          Left = 76
          Top = 66
          Width = 83
          Height = 16
          Caption = 'Server Name:'
          ParentShowHint = False
          ShowHint = False
        end
        object Label29: TLabel
          Left = 58
          Top = 36
          Width = 101
          Height = 16
          Caption = 'Computer Name:'
          ParentShowHint = False
          ShowHint = False
        end
        object Edit15: TEdit
          Tag = 101
          Left = 165
          Top = 64
          Width = 172
          Height = 22
          Hint = 'Text'
          Alignment = taRightJustify
          ImeName = #54620#44397#50612'('#54620#44544') (MS-IME98)'
          TabOrder = 0
        end
        object Edit16: TEdit
          Tag = 102
          Left = 165
          Top = 34
          Width = 173
          Height = 22
          Hint = 'Text'
          Alignment = taRightJustify
          Enabled = False
          ImeName = #54620#44397#50612'('#54620#44544') (MS-IME98)'
          TabOrder = 1
        end
      end
    end
    object MQServerTS: TTabSheet
      Caption = 'MQ Server'
      Enabled = False
      ImageIndex = 3
      ExplicitWidth = 521
      ExplicitHeight = 354
      object MQServerEnableCheck: TAdvGroupBox
        Tag = 80
        Left = 16
        Top = 24
        Width = 396
        Height = 297
        Hint = 'TAdvGroupBox'
        CaptionPosition = cpTopCenter
        CheckBox.Visible = True
        Caption = 'MQ Server Enable'
        TabOrder = 0
        object Label9: TLabel
          Left = 41
          Top = 31
          Width = 69
          Height = 16
          Caption = 'IP Address:'
          ParentShowHint = False
          ShowHint = False
        end
        object Label10: TLabel
          Left = 52
          Top = 103
          Width = 58
          Height = 16
          Caption = 'Port Num:'
          ParentShowHint = False
          ShowHint = False
        end
        object Label21: TLabel
          Left = 51
          Top = 140
          Width = 48
          Height = 16
          Caption = 'User ID:'
        end
        object Label23: TLabel
          Left = 48
          Top = 170
          Width = 51
          Height = 16
          Caption = 'Passwd:'
        end
        object Label18: TLabel
          Left = 61
          Top = 200
          Width = 38
          Height = 16
          Caption = 'Topic:'
        end
        object Label11: TLabel
          Left = 35
          Top = 255
          Width = 99
          Height = 16
          Caption = 'Bind IP Address:'
          ParentShowHint = False
          ShowHint = False
        end
        object Label27: TLabel
          Left = 54
          Top = 71
          Width = 56
          Height = 16
          Caption = 'Protocol: '
          ParentShowHint = False
          ShowHint = False
        end
        object MQIPAddress: TJvIPAddress
          Tag = 81
          Left = 116
          Top = 31
          Width = 150
          Height = 24
          Hint = 'Text'
          Address = 0
          ParentColor = False
          TabOrder = 0
        end
        object MQPortEdit: TEdit
          Tag = 82
          Left = 116
          Top = 100
          Width = 111
          Height = 22
          Hint = 'Text'
          Alignment = taRightJustify
          ImeName = #54620#44397#50612'('#54620#44544') (MS-IME98)'
          TabOrder = 1
          Text = '61613'
        end
        object MQUserEdit: TEdit
          Tag = 83
          Left = 116
          Top = 138
          Width = 187
          Height = 22
          Hint = 'Text'
          ImeName = 'Microsoft Office IME 2007'
          TabOrder = 2
        end
        object MQPasswdEdit: TEdit
          Tag = 84
          Left = 116
          Top = 168
          Width = 187
          Height = 22
          Hint = 'Text'
          ImeName = 'Microsoft Office IME 2007'
          TabOrder = 3
        end
        object MQTopicEdit: TEdit
          Tag = 85
          Left = 116
          Top = 198
          Width = 187
          Height = 22
          Hint = 'Text'
          ImeName = 'Microsoft Office IME 2007'
          TabOrder = 4
        end
        object MQBindComboBox: TComboBox
          Left = 140
          Top = 252
          Width = 154
          Height = 24
          ImeName = 'Microsoft IME 2010'
          TabOrder = 5
        end
        object MQProtocolCombo: TComboBox
          Tag = 86
          Left = 116
          Top = 66
          Width = 153
          Height = 24
          Hint = 'Text'
          ImeName = 'Microsoft IME 2010'
          TabOrder = 6
        end
      end
    end
  end
end
