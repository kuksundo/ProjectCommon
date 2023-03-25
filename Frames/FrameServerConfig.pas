unit FrameServerConfig;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, AdvGroupBox,
  JvExControls, JvComCtrls, Vcl.ComCtrls;

type
  TServerConfigFrame = class(TFrame)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    MQServerTS: TTabSheet;
    TabSheet2: TTabSheet;
    WSSocketEnableCB: TAdvGroupBox;
    Label20: TLabel;
    Label25: TLabel;
    Label26: TLabel;
    WSPortEdit: TEdit;
    Edit14: TEdit;
    JvIPAddress1: TJvIPAddress;
    RemoteAuthEnableCB: TCheckBox;
    AdvGroupBox1: TAdvGroupBox;
    Label28: TLabel;
    Label29: TLabel;
    Edit15: TEdit;
    Edit16: TEdit;
    MQServerEnableCheck: TAdvGroupBox;
    Label9: TLabel;
    Label10: TLabel;
    Label21: TLabel;
    Label23: TLabel;
    Label18: TLabel;
    Label11: TLabel;
    Label27: TLabel;
    MQIPAddress: TJvIPAddress;
    MQPortEdit: TEdit;
    MQUserEdit: TEdit;
    MQPasswdEdit: TEdit;
    MQTopicEdit: TEdit;
    MQBindComboBox: TComboBox;
    MQProtocolCombo: TComboBox;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

end.
