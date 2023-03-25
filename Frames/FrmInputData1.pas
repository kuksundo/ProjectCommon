unit FrmInputData1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, JvExControls, JvLabel,
  Vcl.ExtCtrls, Vcl.Buttons;

type
  TInputDataRec = record
    Label1,
    Label2,
    Label3,
    Label4,

    Data1,
    Data2,
    Data3,
    Data4: string;
  end;

  TInputDataF = class(TForm)
    Panel1: TPanel;
    Label1: TJvLabel;
    Edit1: TEdit;
    Panel2: TPanel;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    Label2: TJvLabel;
    Edit2: TEdit;
    Label3: TJvLabel;
    Edit3: TEdit;
    Label4: TJvLabel;
    Edit4: TEdit;
  private
    { Private declarations }
  public
    procedure SetLabelFromInputRec(AInputRec: TInputDataRec);
  end;

  function CrerateInputDataForm(var AInputRec: TInputDataRec): integer;

var
  InputDataF: TInputDataF;

implementation

{$R *.dfm}

function CrerateInputDataForm(var AInputRec: TInputDataRec): integer;
begin
  Result := -1;

  InputDataF := TInputDataF.Create(nil);
  try
    InputDataF.SetLabelFromInputRec(AInputRec);

    if InputDataF.ShowModal = mrOK then
    begin
      AInputRec.Data1 := InputDataF.Edit1.text;
      AInputRec.Data2 := InputDataF.Edit2.text;
      AInputRec.Data3 := InputDataF.Edit3.text;
      AInputRec.Data4 := InputDataF.Edit4.text;
      Result := 1;
    end;
  finally
    InputDataF.Free;
  end;
end;

{ TInputDataF }

procedure TInputDataF.SetLabelFromInputRec(AInputRec: TInputDataRec);
begin
  Label1.Caption := AInputRec.Label1;
  Label2.Caption := AInputRec.Label2;
  Label3.Caption := AInputRec.Label3;
  Label4.Caption := AInputRec.Label4;

  Edit1.Text := AInputRec.Data1;
  Edit2.Text := AInputRec.Data2;
  Edit3.Text := AInputRec.Data3;
  Edit4.Text := AInputRec.Data4;
end;

end.
