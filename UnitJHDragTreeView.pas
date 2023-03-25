unit UnitJHDragTreeView;

interface

uses
  Windows, Messages, CommCtrl, Classes, Controls, ComCtrls, Forms,
  JvComCtrls, JvCheckTreeView, decTreeView;

type
  TJHDragTreeView = class(TdecTreeView)
  private
    CurrentNode, GhostNode: TTreeNode;
    CurrentPos: Char;

    procedure decTreeView1DragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure decTreeView1DragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure decTreeView1EndDrag(Sender, Target: TObject; X, Y: Integer);
  end;

implementation

{ TJHDragTreeView }

procedure TJHDragTreeView.decTreeView1DragDrop(Sender, Source: TObject; X,
  Y: Integer);
var
  Node: TTreeNode;
  Expanded: Boolean;
begin
  if (GhostNode <> nil) and (TTreeView(Sender).Selected <> nil) then
  begin
    TTreeView(Sender).Items.BeginUpdate;
    try
      Node := TTreeView(Sender).Selected;
      Expanded := (Node.Count > 0) and Node.Expanded;

      TTreeView(Sender).Selected.MoveTo(GhostNode, naInsert);

      Node.Expanded := Expanded;
      Node.Selected := True;
      Node.Focused := True;
    finally
      TTreeView(Sender).Items.EndUpdate;
    end;
  end;
end;

procedure TJHDragTreeView.decTreeView1DragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
const
  GhostText = '[   ]';
var
  Node: TTreeNode;
  HitPos: Char;

  function GetHitPos: Char;
  var
    Rect: TRect;
  begin
    Rect := Node.DisplayRect(True);

    if (Rect.Top <= Y) and (Y <= Rect.Bottom) then
    begin
      if (Rect.Right - X in [0..14]) and
        ((Node.Count = 0) or ((Node.Count = 1) and (Node.Item[0] = GhostNode))) then
      begin
        Result := 'R';
      end
      else
      if (X - Rect.Left in [0..14]) and ((Node.Parent <> nil) and
        ((Node.getNextSibling = nil) or (Node.getNextSibling = GhostNode))) then
      begin
        Result := 'L';
      end
      else
      begin
        if (Rect.Bottom - Y) > (Rect.Bottom - Rect.Top) div 2 then
          Result := 'T'
        else
          Result := 'B';
      end;
    end
    else
      Result := #0;
  end;
begin
  Node := TTreeView(Sender).GetNodeAt(X,Y);

  if (Node <> nil) and (Node <> GhostNode) then
  begin
    HitPos := GetHitPos;

    if (CurrentNode <> Node) or (CurrentPos <> HitPos) and (Node <> TTreeView(Sender).Selected) then
    begin
      if GhostNode <> nil then
        GhostNode.Free;

      if HitPos <> #0 then
      begin
        GhostNode := TTreeNode.Create(TTreeView(Sender).Items);
        GhostNode.ImageIndex := -1;
      end
      else
        GhostNode := nil;

      case HitPos of
        'T': begin
          GhostNode := TTreeView(Sender).Items.InsertNode(GhostNode, Node, GhostText, nil);
        end;
        'B': begin
          if Node.getNextSibling <> nil then
            GhostNode := TTreeView(Sender).Items.InsertNode(GhostNode, Node.GetNext, GhostText, nil)
          else
            GhostNode := TTreeView(Sender).Items.AddNode(GhostNode, Node, GhostText, nil, naAdd);
        end;
        'R': begin
          if Node.Count = 0 then
          begin
            GhostNode := TTreeView(Sender).Items.AddNode(GhostNode, Node, GhostText, nil, naAddChild);
            Node.Expand(True);
          end;
        end;
        'L': begin
          Node := Node.Parent;
          GhostNode := TTreeView(Sender).Items.AddNode(GhostNode, Node, GhostText, nil, naAdd);
        end;
      else
        exit;
      end;
    end;

    CurrentNode := Node;
    CurrentPos := HitPos;

    ShowCursor(True);
  end;
end;

procedure TJHDragTreeView.decTreeView1EndDrag(Sender, Target: TObject; X,
  Y: Integer);
begin
  if GhostNode <> nil then
    FreeAndNil(GhostNode);
end;

end.
