unit FrmModalAndMDIForm;

interface

uses System.Classes, System.SysUtils, Vcl.Controls, Forms;

type
  TModalAndMDIForm = class(TForm)
  private
    f_blChild: Boolean;
    f_Parent: TWinControl;
  protected
    procedure Loaded; override;
    procedure DoClose(var Action: TCloseAction); override;
  public
    constructor Create(AOwner: TComponent); overload; override;
    //as MDI Child
    constructor Create(AOwner: TComponent; AParent: TWinControl); reintroduce; overload;

    property IsChild: Boolean read f_blChild;
  end;

implementation

{ TModalAndMDIForm }

constructor TModalAndMDIForm.Create(AOwner: TComponent; AParent: TWinControl);
begin
  f_blChild := True;
  f_Parent := AParent;

  inherited Create(AOwner);
end;

constructor TModalAndMDIForm.Create(AOwner: TComponent);
begin
  f_blChild := False;

//  inherited Create(AOwner);

  GlobalNameSpace.BeginWrite;
  try
    inherited CreateNew(AOwner);

    if (not(csDesigning in ComponentState)) then
    begin
      Include(FFormState, fsCreating);
      try
        FormStyle := fsNormal;

        if (not(InitInheritedComponent(self, TForm))) then
          raise Exception.CreateFmt('Cannot create form %s as Normal Form', [ClassName]);
      finally
        Exclude(FFormState, fsCreating);
      end;
    end;
  finally
    GlobalNameSpace.EndWrite;
  end;
end;

procedure TModalAndMDIForm.DoClose(var Action: TCloseAction);
begin
  if f_blChild then
    Action := caFree;

  inherited DoClose(Action);
end;

procedure TModalAndMDIForm.Loaded;
begin
  inherited;

  if (f_blChild) then
  begin
    Parent := f_Parent;
    Position := poDefault;
  end
  else
  begin
    Position := poOwnerFormCenter;
    BorderStyle := bsDialog;
  end;
end;

end.
