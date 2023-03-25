unit FrameElecPartEdit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  JvExStdCtrls, JvCombobox, Vcl.ComCtrls,
  SynCommons, mORMot,
  UnitConfigIniClass,
  DomSensorCQRS,
  DomSensorInterfaces,
  DomSensorServices,
  DomSensorTypes,
  UnitEngineElecPartClass,
  UnitECUData, HiMECSConst,
  EngineParameterClass
  ;

type
  TFrameElecPartEdit1 = class(TFrame)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    NodeInfoTabSheet: TTabSheet;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label10: TLabel;
    DLLFuncIndexEdit: TEdit;
    AbsEdit: TEdit;
    NodeIndexEdit: TEdit;
    ImageListNameEdit: TEdit;
    ImageIndexEdit: TEdit;
    LevelEdit: TEdit;
    Edit1: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label15: TLabel;
    TerminalNoEdit: TEdit;
    TagNameEdit: TEdit;
    TagDescEdit: TEdit;
    TerminalNameEdit: TEdit;
    PanelNameEdit: TEdit;
    TabSheet3: TTabSheet;
    Label14: TLabel;
    ModuleNameEdit: TEdit;
    Label18: TLabel;
    ModuleNoEdit: TEdit;
    Label16: TLabel;
    SlotNoEdit: TEdit;
    Label17: TLabel;
    ChannelNoEdit: TEdit;
    TabSheet4: TTabSheet;
    Label19: TLabel;
    ProjectNoEdit: TEdit;
    Label20: TLabel;
    ProjectNameEdit: TEdit;
    Label21: TLabel;
    EngineNoEdit: TEdit;
    Label8: TLabel;
    UserLevelCB: TJvComboBox;
    Label9: TLabel;
    CategoryCB: TJvComboBox;
    Label22: TLabel;
    CableNoEdit: TEdit;
    Label23: TLabel;
    CableNoteEdit: TEdit;
    Label24: TLabel;
    SubTagNameEdit: TEdit;
  private
    procedure InitVar;
    procedure DestroyVar;
  public
    FEngElecPartItem: TEngElecPartItem;

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure LoadFromJsonString(AJson: string);
    procedure LoadFromSensorRouteClass(AClass: TEngElecPartItem);
    procedure Load2SensorRouteClass(AClass: TEngElecPartItem);
  end;

implementation

{$R *.dfm}

{ TFrameElecPartEdit1 }

constructor TFrameElecPartEdit1.Create(AOwner: TComponent);
begin
  inherited;

  InitVar;
end;

destructor TFrameElecPartEdit1.Destroy;
begin
  DestroyVar;

  inherited;
end;

procedure TFrameElecPartEdit1.DestroyVar;
begin
  FEngElecPartItem.Free;
end;

procedure TFrameElecPartEdit1.InitVar;
begin
  FEngElecPartItem := TEngElecPartItem.Create;

  NodeInfoTabSheet.Visible := False;
end;

procedure TFrameElecPartEdit1.Load2SensorRouteClass(AClass: TEngElecPartItem);
begin
  TINIConfigBase.LoadForm2Object(Self, AClass, False);
end;

procedure TFrameElecPartEdit1.LoadFromJsonString(AJson: string);
var
  LUtf8: RawUTF8;
  LValid: Boolean;
  LEngElecPartItem: TEngElecPartItem;
begin
  LEngElecPartItem := TEngElecPartItem.Create;
  try
    LUtf8 := StringToUTF8(AJson);
    JSONToObject(LEngElecPartItem, PUTF8Char(LUtf8), LValid, nil, [j2oIgnoreUnknownProperty]);
    LoadFromSensorRouteClass(LEngElecPartItem);
  finally
    LEngElecPartItem.Free;
  end;
end;

procedure TFrameElecPartEdit1.LoadFromSensorRouteClass(
  AClass: TEngElecPartItem);
begin
  AClass.AssignTo(TPersistent(FEngElecPartItem));

  TINIConfigBase.LoadObject2Form(Self, AClass, False);
end;

end.
