unit UnitTreeViewUtil;

interface

uses SysUtils, Classes, ComCtrls, Vcl.Graphics, JvComCtrls, StrUtils;  //JvCheckTreeView

const
  cParameter      = 0;
  cClosedPage     = 1;
  cOpenPage       = 2;
  cClosedBook     = 3;
  cOpenBook       = 4;
  cDateValue      = 5;
  cStringValue    = 6;
  cBinaryValue    = 7;
  cAddBookmark    = 10;
  cRemoveBookmark = 11;
  cRTD = 19;
  cThermoCouple = 20;
  cmA = 21;
  cDI = 24;
  cDO = 24;
  cPickUp = 23;

type
  TTreeNodeFunc = procedure(ANode: TTreeNode; AJson: string) of object;

  {: Callback to use to copy the data of a treenode when the
     node itself is copied by CopySubtree.
   @param oldnode is the old node
   @param newnode is the new node
   @Desc Use a callback of this type to implement your own algorithm
     for a node copy. The default just uses the Assign method, which
     produces a shallow copy of the nodes Data property. }
  TCopyDataProc = procedure(oldnode, newnode : TTreenode);

function MoveTreeNode(ATV: TTreeView; AIsDown: Boolean=False): Boolean;
function CopyTreeNode(ATV: TTreeView) : Boolean;
function GetRootNodeFromTreeView(ATV: TTreeView): TTreeNode;
function GetRootNode(ANode: TTreeNode): TTreeNode;
function GetLastNodeFromTreeView(ATV: TTreeView): TTreeNode;
function GetLastSibling(aNode : TTreeNode) : TTreeNode;
function GetNodeFromIndex(ATV: TTreeView; ALevel, AAbsIndex: integer): TTreeNode;
//Sibling만 순회함
procedure ExecuteWithAllChildren(ANode: TTreeNode; AFunc: TTreeNodeFunc; AJson: string);
//하위 모든 노드를 순회함
procedure ExecuteWithAllChildren2(ANode: TTreeNode; AFunc: TTreeNodeFunc; AJson: string);
//ANode 자신을 포함한 하위 모든 노드를 순회함
procedure ExecuteWithAllChildren3(ANode: TTreeNode; AFunc: TTreeNodeFunc; AJson: string);
procedure SetNodeImages2Index(ANode: TTreeNode; AIndex: integer);
procedure SetNodeImages(Node : TTreeNode; HasChildren : boolean);
procedure CopySubtree(sourcenode : TTreenode; target : TTreeview;
  targetnode : TTreenode; CopyProc : TCopyDataProc = nil);
function GetStringFromTreeView(ATV: TTreeView): string;
procedure LoadString2TreeView(ATV: TTreeView; AStr: string);
procedure ExpandTreeNodesByLevel(Nodes: TTreeNodes; Level: Integer);
function TreeView2StringList(ATV: TTreeView): TStringList;
procedure SelectNodeByIndex(ATV: TTreeView; AIndex: integer);
function GetNodeByText(ATV: TTreeView; AText: string; ALevel: integer=-1; AVisible: Boolean=True): TTreeNode;
function CompareTwoTreeViewByTextWithLevel(AOriginal, ATarget: TTreeView; ALevel: integer=-1; ANonExistList: TStrings=nil): TTreeNode;
function FindMatchStrFromTV(ATV: TTreeView; ASubStr: string; ALevel: integer=-1; AIsCaseSensitive: Boolean = False): integer;
function FindMatchStrFromList(AList: TStrings; ASubStr: string; ALevel: integer=-1; AIsCaseSensitive: Boolean = False): integer;

implementation

procedure SetNodeImages(Node : TTreeNode; HasChildren : boolean);
begin
  if HasChildren then begin
    Node.HasChildren    := true;
    Node.ImageIndex     := cClosedBook;
    Node.SelectedIndex  := cOpenBook;
  end else begin
    Node.ImageIndex     := cClosedPage;
    Node.SelectedIndex  := cOpenPage;
  end; {if}
end; {SetNodeImages}

function MoveTreeNode(ATV: TTreeView; AIsDown: Boolean): Boolean;
var
  LTreeNode: TTreeNode;
begin
  Result := False;

  if ATV.Items.Count = 0 then
    exit;

  if not Assigned(ATV.Selected) then
    exit;

  LTreeNode := ATV.Selected.GetPrev;

  if not Assigned(LTreeNode) then
    exit;

  if LTreeNode.Level > ATV.Selected.Level then
  begin
    repeat
      LTreeNode := LTreeNode.GetPrev;
    until (LTreeNode.Level = ATV.Selected.Level);
  end;

  ATV.Items.BeginUpdate;
  try
    ATV.Selected.MoveTo(LTreeNode, naInsert);
    Result := True;
  finally
    ATV.Items.EndUpdate;
  end;
end;

function CopyTreeNode(ATV: TTreeView) : Boolean;
var
  LNewNode, LDropTarget, LCurrentNode: TTreeNode;

  procedure CopyNodesRecursively(ASource, ATarget: TTreeNode);
  var
    LCurrentChildNode, LNewNode: TTreeNode;
  begin
    LNewNode := ATV.Items.AddChild(ATarget, ASource.Text);
    LCurrentChildNode := ASource.GetFirstChild;

    while Assigned(LCurrentChildNode) do
    begin
      CopyNodesRecursively(LCurrentChildNode, LNewNode);
      LCurrentChildNode := ASource.GetNextChild(LCurrentChildNode);
    end;
  end;
begin
  LDropTarget := ATV.DropTarget;
  LCurrentNode := LDropTarget;

  while Assigned(LCurrentNode) and (LCurrentNode <> ATV.Selected) do
  begin
    LCurrentNode := LCurrentNode.Parent;

    if not Assigned(LCurrentNode) then
      CopyNodesRecursively(ATV.Selected, LDropTarget);
  end;
end;

function GetRootNodeFromTreeView(ATV: TTreeView): TTreeNode;
begin
  Result := nil;

  if ATV = nil then
    exit;

  Result := ATV.Items.GetFirstNode;
end;

function GetRootNode(ANode: TTreeNode): TTreeNode;
begin
  Result := nil;

  if ANode.Parent = nil then
    exit;

  while ANode <> nil do
  begin
    if ANode.Parent = nil then
    begin
      Result := ANode;
      Break;
    end;

    ANode := ANode.Parent;
  end;
end;

function GetLastNodeFromTreeView(ATV: TTreeView): TTreeNode;
var
  Nodes: TTreeNodes;
  Node: TTreeNode;
begin
  Nodes := ATV.Items;

  Node := Nodes.GetFirstNode;
  Result := Node;

  if Result <> nil then
    repeat
      Result := Node;

      if Node <> nil then
        Node := Result.GetNextSibling;

      if Node = nil then
        Node := Result.GetFirstChild;
    until Node = nil;
end;

function GetLastSibling(aNode : TTreeNode) : TTreeNode;
begin
  if not Assigned(aNode) then
    EXIT(nil);

  repeat
    Result := aNode;
    aNode := Result.GetNextSibling;
  until not Assigned(aNode) ;
end;

function GetNodeFromIndex(ATV: TTreeView; ALevel, AAbsIndex: integer): TTreeNode;
var
  LNode: TTreeNode;
begin
  Result := nil;
  LNode := ATV.Items.GetFirstNode;

  while Assigned(LNode) do
  begin
    if (LNode.Level = ALevel) and (LNode.AbsoluteIndex = AAbsIndex) then
    begin
      Result := LNode;
      Break;
    end;

    LNode := LNode.GetNext;
  end;
end;

procedure ExecuteWithAllChildren(ANode: TTreeNode; AFunc: TTreeNodeFunc; AJson: string);
var
  LTreeNode: TTreeNode;
begin
  if ANode = nil then
    exit;

  LTreeNode := ANode.getFirstChild;

  if LTreeNode = nil then
    exit;

  repeat
    AFunc(LTreeNode, AJson);
    LTreeNode := ANode.getNextSibling;

    ExecuteWithAllChildren(LTreeNode, AFunc, AJson);
  until (LTreeNode = nil);
end;

procedure ExecuteWithAllChildren2(ANode: TTreeNode; AFunc: TTreeNodeFunc; AJson: string);
begin
  ANode := ANode.getFirstChild;

  while Assigned(ANode) do
  begin
    AFunc(ANode, AJson);
    ExecuteWithAllChildren2(ANode,AFunc, AJson);
    ANode := ANode.getNextSibling;
  end;
end;

procedure ExecuteWithAllChildren3(ANode: TTreeNode; AFunc: TTreeNodeFunc; AJson: string);
begin
  if not Assigned(ANode) then
    exit;

  AFunc(ANode, AJson);
  ExecuteWithAllChildren3(ANode, AFunc, AJson);
end;

procedure SetNodeImages2Index(ANode: TTreeNode; AIndex: integer);
begin
  ANode.ImageIndex := AIndex;
end;

{: The default operation is to do a shallow copy of the node, via
Assign. }
procedure DefaultCopyDataProc(oldnode, newnode : TTreenode);
begin
  newnode.Assign(oldnode);
end;

{사용예 :
procedure TForm1.Button1Click(Sender : TObject);
begin
  if assigned(treeview1.selected) then
    CopySubtree(treeview1.selected, treeview2, nil);
end;}

procedure CopySubtree(sourcenode : TTreenode; target : TTreeview;
  targetnode : TTreenode; CopyProc : TCopyDataProc = nil);
var
  anchor : TTreenode;
  child : TTreenode;
begin { CopySubtree }
  Assert(Assigned(sourcenode),
    'CopySubtree:sourcenode cannot be nil');
  Assert(Assigned(target),
    'CopySubtree: target treeview cannot be nil');
  Assert((targetnode = nil) or (targetnode.TreeView = target),
    'CopySubtree: targetnode has to be a node in the target treeview.');

  if (sourcenode.TreeView = target) and
    (targetnode.HasAsParent(sourcenode) or (sourcenode =
    targetnode)) then
    raise Exception.Create('CopySubtree cannot copy a subtree to one of the ' +
      'subtrees nodes.');

  if not Assigned(CopyProc) then
    CopyProc := DefaultCopyDataProc;

  anchor := target.Items.AddChild(targetnode, sourcenode.Text);
  CopyProc(sourcenode, anchor);
  child := sourcenode.GetFirstChild;

  while Assigned(child) do
  begin
    CopySubtree(child, target, anchor, CopyProc);
    child := child.getNextSibling;
  end; { While }
end; { CopySubtree }

function GetStringFromTreeView(ATV: TTreeView): string;
var
//  LStrList: TStringList;
  LStrStream: TStringStream;
begin
//  LStrList := TStringList.Create;
  LStrStream := TStringStream.Create;
  try
    ATV.SaveToStream(LStrStream);
    Result := LStrStream.DataString;
//    LStrList.LoadFromStream();
  finally
//    LStrList.Free;
    LStrStream.Free;
  end;
end;

procedure LoadString2TreeView(ATV: TTreeView; AStr: string);
var
  LStrStream: TStringStream;
begin
  LStrStream := TStringStream.Create(AStr);
  try
    ATV.Items.BeginUpdate;
    try
      ATV.Items.Clear;
      ATV.LoadFromStream(LStrStream);
    finally
      ATV.Items.EndUpdate;
    end;
  finally
    LStrStream.Free;
  end;
end;

//Level만 Expand 함
procedure ExpandTreeNodesByLevel(Nodes: TTreeNodes; Level: Integer);
var
  Node: TTreeNode;
  Next: TTreeNode;
begin
  if Level < 1 then
    Exit;

  Nodes.BeginUpdate;
  try
    Node := Nodes.GetFirstNode;

    while Node <> nil do
    begin
      Node.Expand(False);

      if (Node.Level < Level - 1) and Node.HasChildren then
        Node := Node.GetFirstChild
      else
      begin
        Next := Node.GetNextSibling;

        if Next <> nil then
          Node := Next
        else
          if Node.Level > 0 then
            Node := Node.Parent.GetNextSibling
          else
            Node := Node.GetNextSibling;
      end;
    end;//while
  finally
    Nodes.EndUpdate;
  end;
end;

function TreeView2StringList(ATV: TTreeView): TStringList;
var
  LMs: TMemoryStream;
begin
  Result := TStringList.Create;
  LMs := TMemoryStream.Create;

  try
    ATV.SaveToStream(LMs);
    LMs.Position := 0;
    Result.LoadFromStream(LMs);
  finally
    LMs.Free;
  end;
end;

procedure SelectNodeByIndex(ATV: TTreeView; AIndex: integer);
begin
  ATV.Selected := ATV.Items[AIndex];
end;

function GetNodeByText(ATV: TTreeView; AText: string; ALevel: integer; AVisible: Boolean): TTreeNode;
var
  LNode: TTreeNode;
begin
  Result := nil;

  if ATV.Items.Count = 0 then
    exit;

  ATV.Items.BeginUpdate;
  try
    LNode := ATV.Items[0];

    while LNode <> nil do
    begin
      if (ALevel <> -1) and (LNode.Level <> ALevel) then
      begin
        LNode := LNode.GetNext;
        Continue;
      end;

      if ContainsText(LNode.Text, AText) then
      begin
        Result := LNode;

        if AVisible then
        begin
          Result.MakeVisible;
  //        Result.Selected := True;
        end;

        Break;
      end;

      LNode := LNode.GetNext;
    end;
  finally
    ATV.Items.EndUpdate;
  end;
end;

function CompareTwoTreeViewByTextWithLevel(AOriginal, ATarget: TTreeView; ALevel: integer; ANonExistList: TStrings): TTreeNode;
var
  LNode, LNode2: TTreeNode;
  LFindStr: string;
  LIdx: integer;
  LStrList: TStringList;
begin
  Result := nil;

  if ATarget.Items.Count = 0 then
    exit;

  LStrList := TreeView2StringList(AOriginal);
  try

    //  AOriginal.Items.BeginUpdate;

    LNode := ATarget.Items[0];

    while LNode <> nil do
    begin
      if (ALevel <> -1) and (LNode.Level <> ALevel) then
      begin
        LNode := LNode.GetNext;
        Continue;
      end;

      LFindStr := LNode.Text;
      LIdx := FindMatchStrFromList(LStrList, LFindStr, ALevel);
//      LIdx := FindMatchStrFromTV(AOriginal, LFindStr, ALevel);

      if LIdx = -1 then
      begin
        Result := LNode;

        if Assigned(ANonExistList) then
          ANonExistList.Add(LFindStr + ';' + IntToStr(LNode.AbsoluteIndex))
        else
          Break;
      end;

      LNode := LNode.GetNext;
    end;
  finally
    LStrList.Free;
  end;
end;

function FindMatchStrFromTV(ATV: TTreeView; ASubStr: string; ALevel: integer; AIsCaseSensitive: Boolean): integer;
var
  LNode: TTreeNode;
begin
  Result := -1;

    LNode := GetNodeByText(ATV, ASubStr, ALevel, False);

    if Assigned(LNode) then
    begin
      Result := LNode.AbsoluteIndex;
    end;
end;

function FindMatchStrFromList(AList: TStrings; ASubStr: string; ALevel: integer=-1; AIsCaseSensitive: Boolean = False): integer;
begin
    for Result := 1 to ALevel do
      System.Insert(#9, ASubStr, 1);

    Result := AList.IndexOf(ASubStr);
end;

end.
