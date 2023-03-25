unit FrameNextGridOnly;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, NxScrollControl,
  NxCustomGridControl, NxCustomGrid, NxGrid, AdvOfficeTabSet, Vcl.ImgList, UnitDFMUtil,
  Vcl.Menus, JvDialogs, NxColumns, NxColumnClasses,
  SynCommons;

type
  TFrameNGOnly = class(TFrame)
    imagelist24x24: TImageList;
    ImageList32x32: TImageList;
    ImageList16x16: TImageList;
    TaskTab: TAdvOfficeTabSet;
    NextGrid1: TNextGrid;
    PopupMenu1: TPopupMenu;
    JvOpenDialog1: TJvOpenDialog;
    JvSaveDialog1: TJvSaveDialog;
    SaveToTextDFM1: TMenuItem;
    NxIncrementColumn1: TNxIncrementColumn;
    procedure SaveToTextDFM1Click(Sender: TObject);
  private
  public
    procedure ReadComponentsProc(Reader: TReader; const Message: string; var Handled: Boolean);
  end;

implementation

uses UnitNextGridUtil;

{$R *.dfm}

procedure TFrameNGOnly.ReadComponentsProc(Reader: TReader; const Message: string;
  var Handled: Boolean);
begin
  Handled := True;
//  ShowMessage(Message);
end;

procedure TFrameNGOnly.SaveToTextDFM1Click(Sender: TObject);
var
  LFileName: string;
begin
  if JvSaveDialog1.Execute then
  begin
    LFileName := JvSaveDialog1.FileName;

    if FileExists(LFileName) then
    begin
      if MessageDlg('File is already existed. Are you overwrite? if No press, then the data is not saved!.',
      mtConfirmation, [mbYes, mbNo], 0)= mrNo then
        exit;
    end;

    SaveToDFM(LFileName+'.$$$', TWinControl(Self));
    SaveBinDFM2TextDFM(LFileName+'.$$$', LFileName, TWincontrol(Self), ReadComponentsProc);
  end;
end;

end.
