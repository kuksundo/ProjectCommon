unit UnitNativeXMLTreeView;

interface

uses
  // delphi
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ActnList, ImgList, ComCtrls, ToolWin, ExtCtrls, VirtualTrees, Menus,
  StdCtrls,
  // nativexml
  NativeXml, SynJSONTreeView;

type
  TpjhXML2Json = class
  private
    JSONTreeView1: TSynJSONTreeView;
    FXml: TNativeXml;
  public
    constructor Create(AOwner: TComponent);
    destructor Destroy;

    procedure LoadXMLFromFile(AFileName: string);
    procedure LoadXML2VT;
  end;

implementation



{ TpjhXML2Json }

constructor TpjhXML2Json.Create(AOwner: TComponent);
begin
  JSONTreeView1 := TSynJSONTreeView.Create(AOwner);
//  JSONTreeView1.PopupMenu := PopupMenu1;
//  JSONTreeView1.Align := alClient;
  JSONTreeView1.Parent := AOwner;
//  JSONTreeView1.OnCustomInput := DoOnCustomInput;
end;

destructor TpjhXML2Json.Destroy;
begin
  JSONTreeView1.Free;
end;

procedure TpjhXML2Json.LoadXML2VT;
begin
  JSONTreeView1.Clear;
  JSONTreeView1.RootNodeCount := FXml.RootContainerCount;

end;

procedure TpjhXML2Json.LoadXMLFromFile(AFileName: string);
var
  F: TFileStream;
begin
  F := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyWrite);
  try
    FXml.LoadFromStream(F);
  finally
    F.Free;
  end;
end;

end.
