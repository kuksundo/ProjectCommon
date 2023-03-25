unit UnitMSXMLTree;
{
procedure TForm1.Button1Click(Sender: TObject);
begin
  With TTreeToXML.Create(TreeView1) do
    try
      SaveToFile('C:\temp\test.xml');
    finally
      Free;
    end;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  With TXMLToTree.Create do
    try
      XMLToTree(TreeView2, 'C:\temp\test.xml')
    finally
      Free;
    end;
end;
}
interface

uses Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, xmldom, XMLIntf, msxmldom, XMLDoc, ActiveX, ComObj, ComCtrls;

Type

  TTreeToXML = Class
  private
    FDOC: TXMLDocument;
    FRootNode: IXMLNode;
    FTree: TTreeView;
    procedure IterateRoot;
    procedure WriteNode(N: TTreeNode; ParentXN: IXMLNode);
  Public
    Constructor Create(Tree: TTreeView);
    Procedure SaveToFile(const fn: String);
    Destructor Destroy; override;
  End;

  TXMLToTree = Class
  private
    FTree: TTreeView;
    procedure IterateNodes(xn: IXMLNode; ParentNode: TTreeNode);
  Public
    Procedure XMLToTree(Tree: TTreeView; Const FileName: String);
  End;

implementation

{ TTreeToXML }

constructor TTreeToXML.Create(Tree: TTreeView);
begin
  FTree := Tree;
  FDOC := TXMLDocument.Create(nil);
  FDOC.Options := FDOC.Options + [doNodeAutoIndent];
  FDOC.Active := true;
  FDOC.Encoding := 'UTF-8';
  FRootNode := FDOC.CreateElement('Treeview', '');
  FDOC.DocumentElement := FRootNode;
  IterateRoot;
end;

Procedure TTreeToXML.WriteNode(N: TTreeNode; ParentXN: IXMLNode);
var
  CurrNode: IXMLNode;
  Child: TTreeNode;
begin
  CurrNode := ParentXN.AddChild(N.Text);
  CurrNode.Attributes['NodeLevel'] := N.Level;
  CurrNode.Attributes['Index'] := N.Index;
  Child := N.getFirstChild;
  while Assigned(Child) do
  begin
    WriteNode(Child, CurrNode);
    Child := Child.getNextSibling;
  end;
end;

Procedure TTreeToXML.IterateRoot;
var
  N: TTreeNode;
begin
  N := FTree.Items[0];
  while Assigned(N) do
  begin
    WriteNode(N, FRootNode);
    N := N.getNextSibling;
  end;
end;

procedure TTreeToXML.SaveToFile(const fn: String);
begin
  FDOC.SaveToFile(fn);
end;

destructor TTreeToXML.Destroy;
begin
  if Assigned(FDOC) then
    FDOC.Free;

  inherited;
end;

{ TXMLToFree }

Procedure TXMLToTree.XMLToTree(Tree: TTreeView; const FileName: String);
var
  Doc: TXMLDocument;
begin
  FTree := Tree;
  Doc := TXMLDocument.Create(Application);
  try
    Doc.LoadFromFile(FileName);
    Doc.Active := true;
    IterateNodes(Doc.DocumentElement, NIL);
  finally
    Doc.Free;
  end;
end;

Procedure TXMLToTree.IterateNodes(xn: IXMLNode; ParentNode: TTreeNode);
var
  ChildTreeNode: TTreeNode;
  i: Integer;
begin
  For i := 0 to xn.ChildNodes.Count - 1 do
  begin
    ChildTreeNode := FTree.Items.AddChild(ParentNode,
      xn.ChildNodes[i].NodeName);
    IterateNodes(xn.ChildNodes[i], ChildTreeNode);
  end;
end;

end.
