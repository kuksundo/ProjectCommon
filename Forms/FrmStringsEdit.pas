{*******************************************************}
{                                                       }
{                                                       }
{*******************************************************}

unit FrmStringsEdit;

interface

uses
  Windows, Messages, SysUtils {$IFDEF VER140} , Variants {$ENDIF} , Classes,
  vcl.Graphics, vcl.Controls, vcl.Forms, vcl.Dialogs, vcl.StdCtrls, vcl.ComCtrls, vcl.ExtCtrls;

var
  SELStringsEditorDlgCaption: string              = 'String List Editor';
  SELStringsEditorDlgOkBtnCaption: string         = '&Ok';
  SELStringsEditorDlgCancelBtnCaption: string     = 'Cancel';
  SELStringsEditorDlgLinesCountTemplate: string   = '%d lines';

type
  TpjhStringsEditorDlg = class(TForm)
    Panel1: TPanel;
    btnOk: TButton;
    btnCancel: TButton;
    Panel2: TPanel;
    lbLineCount: TLabel;
    memMain: TMemo;
    procedure memMainChange(Sender: TObject);
  private
    function GetLines: TStrings;
    procedure SetLines(const Value: TStrings);
  public
    class function Execute(var AString: String): Boolean;
    function _Execute: Boolean;
    property Lines: TStrings read GetLines write SetLines;
  end;

implementation

{$R *.dfm}

{ TELStringsEditorDlg }

function TpjhStringsEditorDlg._Execute: Boolean;
begin
  Caption := SELStringsEditorDlgCaption;
  btnOk.Caption := SELStringsEditorDlgOkBtnCaption;
  btnCancel.Caption := SELStringsEditorDlgCancelBtnCaption;
  lbLineCount.Caption := Format(SELStringsEditorDlgLinesCountTemplate,
    [memMain.Lines.Count]);

  Result := (ShowModal = mrOk);
end;

class function TpjhStringsEditorDlg.Execute(var AString: String): Boolean;
begin
  with TpjhStringsEditorDlg.Create(nil) do
  begin
    memMain.Lines.Text := AString;

    Result := _Execute;

    if Result then
      AString := Lines.Text;

    Free;
  end;
end;

function TpjhStringsEditorDlg.GetLines: TStrings;
begin
  Result := memMain.Lines;
end;

procedure TpjhStringsEditorDlg.SetLines(const Value: TStrings);
begin
  if Value <> nil then
    memMain.Lines := Value;
end;

procedure TpjhStringsEditorDlg.memMainChange(Sender: TObject);
begin
  lbLineCount.Caption := Format(SELStringsEditorDlgLinesCountTemplate,
    [memMain.Lines.Count]);
end;

end.
