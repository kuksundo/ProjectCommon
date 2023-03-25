unit FrmInputEdit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons;

type
  TInputEditF = class(TForm)
    Label1: TLabel;
    InputEdit: TEdit;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  function CreateInputEdit(const ACaption, ALabel, ADefault: string): string;
var
  InputEditF: TInputEditF;

implementation

{$R *.dfm}

function CreateInputEdit(const ACaption, ALabel, ADefault: string): string;
begin
  Result := '';

  if Assigned(InputEditF) then
    FreeAndNil(InputEditF);

  InputEditF := TInputEditF.Create(nil);
  try
    with InputEditF do
    begin
      Caption := ACaption;
      Label1.Caption := ALabel;
      InputEdit.Text := ADefault;

      if ShowModal = mrOK then
      begin
        Result := InputEdit.Text;
      end;
    end;
  finally
    FreeAndNil(InputEditF);
  end;
end;

end.
