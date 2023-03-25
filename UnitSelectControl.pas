unit UnitSelectControl;

interface

uses Classes, Forms, Windows, SysUtils, RTLConsts, Controls, Graphics, Messages,
  VCL.cyTypes, VCL.cyGraphics, Dialogs;

type
  TpjhSelector = class;

  TResizerOption = (roMouseSelect,                  // Allow select one control with mouse
                    roMouseMove,                    // Allow move one control with mouse
                    roMouseResize,                  // Allow resize one control with mouse
                    roMouseMultiSelect,             // Allow select multiple controls with mouse
                    roMouseMultiMove,               // Allow move multiple controls with mouse
                    roMouseMultiResize,             // Allow resize multiple controls with mouse

                    roKeySelect,                    // Allow select one control with keyboard
                    roKeyMove,                      // Allow move one control with keyboard
                    roKeyResize,                    // Allow resize one control with keyboard
                    roKeyMultiSelect,               // Allow select multiple controls with keyboard, !!! not used for now !!!
                    roKeyMultiMove,                 // Allow move multiple controls with keyboard
                    roKeyMultiResize,               // Allow resize multiple controls with keyboard
                    roKeyUnselectAll,               // Unselect all with esc key

                    roOnlyMultiSelectIfSameParent,  // Avoid multi-selection controls from diferent parents
                    roOnlyMultiMoveIfSameParent,    // Avoid multi-move controls from diferent parents
                    roOnlyMultiResizeIfSameParent,  // Avoid multi-resize controls from diferent parents


                    roMouseUnselectAll,             // Unselect all
                    roOutsideParentRect             // move and resize ouside parent bounds rect
                    );   // !!! New properties must be added at the end !!!

  TResizerOptions = Set of TResizerOption;

  THandlerStyle = (bsSquare, bsGradientSquare, bsCircle, bsGradientCircle);
  TMouseJob = (mjNothing, mjRangeSelect, mjResizeTopLeft,    mjResizeTop,    mjResizeTopRight,
                                         mjResizeLeft,       mjMove,         mjResizeRight,
                                         mjResizeBottomLeft, mjResizeBottom, mjResizeBottomRight);

  // Control item of THandlingControlList :
  THandlingControlItem=class
  private
    FControl: TControl;
    FOldRect: TRect;
  protected
    property OldRect: TRect read FOldRect;
  public
    property Control: TControl read FControl;
  end;

  // TcyResizer Control List of handled controls :
  TProcOnItem = procedure (Sender: TObject; Index: Integer) of object;

  THandlingControlList = class
  private
    FcyResizer: TpjhSelector;
    FList: array of THandlingControlItem;
    FOnInsertItem: TProcOnItem;
    FOnRemoveItem: TProcOnItem;
    FOnAfterRemoveItem: TProcOnItem;
    FOnClear: TNotifyEvent;
    function GetCount: Integer;
    function GetItem(Index: Integer): THandlingControlItem;
    procedure AddItem(Item: TControl);
    procedure DeleteItem(Index: Integer);
  protected
  public
    constructor Create(Owner: TComponent);
    destructor Destroy; override;
    procedure Clear;
    function ControlsFromSameParent: boolean;
    function InsertControl(aControl: TControl): Boolean;
    function RemoveControl(aControl: TControl): Boolean;
    function RemoveFromIndex(Index: Word): Boolean;
    function Find(aControl: TControl; var Index: Integer): Boolean;
    function IndexOf(aControl: TControl): Integer;
    property Count: Integer read GetCount;
    property Items[Index: Integer]: THandlingControlItem read GetItem; default;
    property OnInsertItem: TProcOnItem read FOnInsertItem write FOnInsertItem;
    property OnRemoveItem: TProcOnItem read FOnRemoveItem write FOnRemoveItem;
    property OnAfterRemoveItem: TProcOnItem read FOnAfterRemoveItem write FOnAfterRemoveItem;
    property OnClear: TNotifyEvent read FOnClear write FOnClear;
  end;

  // Properties to draw frame control
  TcyControlFrame=class(TPersistent)
  private
    FColor: TColor;
    FVisible: Boolean;
    FOnChange: TNotifyEvent;
    procedure SetColor(const Value: TColor);
    procedure SetVisible(const Value: Boolean);
  protected
    procedure StyleChanged(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); virtual;
    destructor Destroy; override;
  published
    property Color: TColor read FColor write SetColor default clBlack;
    property Visible: Boolean read FVisible write SetVisible default False;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  // Properties to draw resizing control Handlers
  TcyHandler=class(TPersistent)
  private
    FBrush: TBrush;
    FPen: TPen;
    FSize: integer;
    FVisible: Boolean;
    FOnChange: TNotifyEvent;
    FHandlerStyle: THandlerStyle;
    procedure SetBrush(Value: TBrush);
    procedure SetPen(Value: TPen);
    procedure SetSize(const Value: integer);
    procedure SetVisible(Value: Boolean);
    procedure SetHandlerStyle(const Value: THandlerStyle);
  protected
    procedure StyleChanged(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); virtual;
    destructor Destroy; override;
  published
    property Brush: TBrush read FBrush write SetBrush;
    property Pen: TPen read FPen write SetPen;
    property Size:integer read FSize write SetSize default 5;
    property Style: THandlerStyle read FHandlerStyle write SetHandlerStyle default bsSquare;
    property Visible: Boolean read FVisible write SetVisible default True;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  // Sub-properties of TcyResizer for the 2 types of resizing Handlers : corner and middle resizing Handlers
  TcyHandlingDef=class(TPersistent)
  private
    FCornerHandlers: TcyHandler;
    FMiddleHandlers: TcyHandler;
    FOnChange: TNotifyEvent;
    FFrame: TcyControlFrame;
    procedure SetCornerHandlers(const Value: TcyHandler);
    procedure SetMiddleHandlers(const Value: TcyHandler);
    procedure SetFrame(const Value: TcyControlFrame);
  protected
    procedure CornerHandlersChanged(Sender: TObject);
    procedure MiddleHandlersChanged(Sender: TObject);
    procedure FrameChanged(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); virtual;
    destructor Destroy; override;
  published
    property CornerHandlers: TcyHandler read FCornerHandlers write SetCornerHandlers;
    property MiddleHandlers: TcyHandler read FMiddleHandlers write SetMiddleHandlers;
    property Frame: TcyControlFrame read FFrame write SetFrame;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TpjhSelector = class(TCustomControl)
  private
    FActive: Boolean;
    FHandlingMultipleControls: TcyHandlingDef;
    FHandlingSingleControl: TcyHandlingDef;
    FHandlingControlList: THandlingControlList;
    FOptions: TResizerOptions;
    FPanelCanvas: TCanvas;
    FPanel: TCustomControl;

    procedure SetHandlingMultipleControls(const Value: TcyHandlingDef);
    procedure SetHandlingSingleControl(const Value: TcyHandlingDef);
    procedure SetOptions(const Value: TResizerOptions);

    procedure HandlingSingleControlChanged(Sender: TObject);
    procedure HandlingMultipleControlsChanged(Sender: TObject);
  protected
    function CalcHandlerRect(Handler: TcyHandler; Job: TMouseJob; ControlRect: TRect): TRect;
    procedure DrawHandler(Handler: TcyHandler; var Rect: TRect);

    procedure OnHandlingListInsertControl(Sender: TObject; Index: Integer);
    procedure OnHandlingListRemoveControl(Sender: TObject; Index: Integer);
    procedure OnHandlingListAfterRemoveControl(Sender: TObject; Index: Integer);

    procedure OnHandlingListClear(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure SetPanelCanvas(ACanvas: TCanvas);
    procedure SetDesignPanel(APanel: TCustomControl);

    procedure Activate(Surface: TWinControl = nil);
    procedure Deactivate;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure DrawHandlers(HandlingDef: TcyHandlingDef; aRect: TRect);
    procedure DrawControlHandlers(ControlIndex: Integer);
    procedure DrawSquareHandler(var Rect: TRect; FrameWidth: Integer);
    procedure DrawGradientSquareHandler(var Rect: TRect; FrameWidth: Integer);
    procedure DrawCircleHandler(var Rect: TRect; FrameWidth: Integer);
    procedure DrawGradientCircleHandler(var Rect: TRect; FrameWidth: Integer);
    function GetHandlingControlItemClientRect(Item: THandlingControlItem): TRect;
    function ItemToClientPoint(Item: THandlingControlItem; aPoint: TPoint): TPoint;

    property Active: Boolean read FActive default false;
    property HandlingControlList: THandlingControlList read FHandlingControlList;
  published
    property HandlingSingleControl: TcyHandlingDef read FHandlingSingleControl write SetHandlingSingleControl;
    property HandlingMultipleControls: TcyHandlingDef read FHandlingMultipleControls write SetHandlingMultipleControls;
    property Options: TResizerOptions read FOptions write SetOptions default [
              roMouseSelect, roMouseMove, roMouseResize, roMouseMultiSelect, roMouseMultiMove, roMouseMultiResize,
               roKeySelect, roKeyMove, roKeyResize, roKeyMultiSelect, roKeyMultiMove, roKeyMultiResize];
  end;

implementation

{ THandlingControlList }

procedure THandlingControlList.AddItem(Item: TControl);
var C: Integer;
    New: THandlingControlItem;
begin
  C := Count;
  SetLength(FList, C + 1);

  New := THandlingControlItem.Create;
  New.FControl := Item;
  FList[C] := New;
  Item.FreeNotification(FcyResizer);     // Inform cyResizer if the component is going to be deleted ...

  if Assigned(FOnInsertItem)
  then FOnInsertItem(Self, C);
end;

procedure THandlingControlList.Clear;
var i: Integer;
begin
  if Length(FList) = 0 then Exit;

  // Free THandlingControlItem objects :
  for i := 0 to Length(FList) -1 do
    FList[i].Free;

  SetLength(FList, 0);

  if Assigned(FOnClear) then
    FOnClear(Self);
end;

function THandlingControlList.ControlsFromSameParent: boolean;
var L: Integer;
begin
  RESULT := true;

  for L := 1 to Count-1 do
    if FList[L].FControl.Parent <> FList[0].FControl.Parent
    then begin
      RESULT := false;
      Break;
    end;
end;

constructor THandlingControlList.Create(Owner: TComponent);
begin
  inherited Create;
  FcyResizer := TpjhSelector(Owner);
  SetLength(FList, 0);
end;

procedure THandlingControlList.DeleteItem(Index: Integer);
begin
  if (Index < 0) or (Index >= Count) then
    raise EListError.Create(SListIndexError);

  if Assigned(FOnRemoveItem) then
    FOnRemoveItem(Self, Index);

  // Free THandlingControlItem object :
  FList[Index].Free;
  FList[Index] := nil;

  // Move items :
  if Index < Count-1
  then begin
    System.Move(FList[Index + 1], FList[Index], (Count - Index - 1) * SizeOf(THandlingControlItem));
    PPointer(@FList[Count-1])^ := nil;
  end;

  SetLength(FList, Count-1);

  if Assigned(FOnAfterRemoveItem) then
    FOnAfterRemoveItem(Self, Index);
end;

destructor THandlingControlList.Destroy;
begin
  Clear;
  inherited Destroy;
end;

function THandlingControlList.Find(aControl: TControl;
  var Index: Integer): Boolean;
var
  L, C: Integer;
begin
  RESULT := false;
  L := 0;
  C := Length(FList) - 1;

  while (not RESULT) and (L <= C) do
  begin
    if FList[L].FControl = aControl
    then begin
      RESULT := true;
      Index := L;
    end
    else
      Inc(L, 1);
  end;
end;

function THandlingControlList.GetCount: Integer;
begin
  Result := Length(FList);
end;

function THandlingControlList.GetItem(Index: Integer): THandlingControlItem;
begin
  Result := FList[Index];
end;

function THandlingControlList.IndexOf(aControl: TControl): Integer;
begin
  if not Find(aControl, RESULT)
  then RESULT := -1;
end;

function THandlingControlList.InsertControl(aControl: TControl): Boolean;
var Index: Integer;
begin
  if (FcyResizer.FActive) and (aControl <> FcyResizer)
  then begin
    RESULT := not Find(aControl, Index);

    if RESULT
    then begin
      if (Count <> 0) and (roOnlyMultiSelectIfSameParent in FcyResizer.FOptions)
      then
        if Items[0].FControl.Parent <> aControl.Parent
        then Clear;

      AddItem(aControl);
    end;
  end
  else
    RESULT := false;
end;

function THandlingControlList.RemoveControl(aControl: TControl): Boolean;
var Index: Integer;
begin
  if FcyResizer.FActive
  then begin
    RESULT := Find(aControl, Index);

    if RESULT
    then DeleteItem(Index);
  end
  else
    RESULT := false;
end;

function THandlingControlList.RemoveFromIndex(Index: Word): Boolean;
begin
  if FcyResizer.FActive
  then begin
    RESULT := Index < Count;

    if RESULT
    then DeleteItem(Index);
  end
  else
    RESULT := false;
end;

{ TcyControlFrame }

constructor TcyControlFrame.Create(AOwner: TComponent);
begin
  FColor := clBlack;
  FVisible := False;
end;

destructor TcyControlFrame.Destroy;
begin
  inherited;
end;

procedure TcyControlFrame.SetColor(const Value: TColor);
begin
  if Value <> FColor then
  begin
    FColor := Value;
    if Assigned(FOnChange) then FOnChange(Self);
  end;
end;

procedure TcyControlFrame.SetVisible(const Value: Boolean);
begin
  if Value <> FVisible then
  begin
    FVisible := Value;
    if Assigned(FOnChange) then FOnChange(Self);
  end;
end;

procedure TcyControlFrame.StyleChanged(Sender: TObject);
begin
  if Assigned(FOnChange) then FOnChange(Self);
end;

{ TcyHandler }

constructor TcyHandler.Create(AOwner: TComponent);
begin
  FPen := TPen.Create;
  FPen.OnChange := StyleChanged;
  FBrush := TBrush.Create;
  FBrush.OnChange := StyleChanged;
  FSize   := 5;
  FVisible := True;
end;

destructor TcyHandler.Destroy;
begin
  FPen.Free;
  FBrush.Free;
  inherited Destroy;
end;

procedure TcyHandler.SetBrush(Value: TBrush);
begin
  FBrush.Assign(Value);
end;

procedure TcyHandler.SetHandlerStyle(const Value: THandlerStyle);
begin
  if FHandlerStyle <> Value
  then begin
    FHandlerStyle := Value;
    if Assigned(FOnChange) then FOnChange(Self);
  end;
end;

procedure TcyHandler.SetPen(Value: TPen);
begin
  FPen.Assign(Value);
end;

procedure TcyHandler.SetSize(const Value: integer);
begin
  if (FSize <> Value) and (Value > 0)
  then begin
    FSize := Value;
    if Assigned(FOnChange) then FOnChange(Self);
  end;
end;

procedure TcyHandler.SetVisible(Value: Boolean);
begin
  if Value <> FVisible
  then begin
    FVisible := Value;
    if Assigned(FOnChange) then FOnChange(Self);
  end;
end;

procedure TcyHandler.StyleChanged(Sender: TObject);
begin
  if Assigned(FOnChange) then FOnChange(Self);
end;

{ TcyHandlingDef }

procedure TcyHandlingDef.CornerHandlersChanged(Sender: TObject);
begin
  if Assigned(FOnChange) then FOnchange(Sender);
end;

constructor TcyHandlingDef.Create(AOwner: TComponent);
begin
  FCornerHandlers := TcyHandler.Create(AOwner);
  FCornerHandlers.OnChange := CornerHandlersChanged;
  FMiddleHandlers := TcyHandler.Create(AOwner);
  FMiddleHandlers.OnChange := MiddleHandlersChanged;
  FFrame := TcyControlFrame.Create(AOwner);
  FFrame.OnChange := FrameChanged;
end;

destructor TcyHandlingDef.Destroy;
begin
  FCornerHandlers.Free;
  FMiddleHandlers.Free;
  FFrame.Free;
  inherited Destroy;
end;

procedure TcyHandlingDef.FrameChanged(Sender: TObject);
begin
  if Assigned(FOnChange) then FOnchange(Sender);
end;

procedure TcyHandlingDef.MiddleHandlersChanged(Sender: TObject);
begin
  if Assigned(FOnChange) then FOnchange(Sender);
end;

procedure TcyHandlingDef.SetCornerHandlers(const Value: TcyHandler);
begin
  FCornerHandlers := Value;
end;

procedure TcyHandlingDef.SetFrame(const Value: TcyControlFrame);
begin
  FFrame := Value;
end;

procedure TcyHandlingDef.SetMiddleHandlers(const Value: TcyHandler);
begin
  FMiddleHandlers := Value;
end;

{ TpjhSelector }

procedure TpjhSelector.Activate(Surface: TWinControl);
begin
  if not (FActive)// and (Surface <> nil)
  then begin
//    FSurface := Surface;
//    Parent := Surface;

//    Top := 0;
//    Left := 0;
//    Height := Surface.ClientHeight;
//    Width := Surface.ClientWidth;
//    Visible := true;
    FActive := true;
//    BringToFront;
//    SetFocus;
  end;
end;

function TpjhSelector.CalcHandlerRect(Handler: TcyHandler; Job: TMouseJob;
  ControlRect: TRect): TRect;
var aPoint: TPoint;
begin
  case Job of
    // Corners:
    mjResizeTopLeft:     aPoint := ControlRect.TopLeft;
    mjResizeTopRight:    aPoint := Point(ControlRect.Right, ControlRect.Top);
    mjResizeBottomLeft:  aPoint := Point(ControlRect.Left, ControlRect.Bottom);
    mjResizeBottomRight: aPoint := ControlRect.BottomRight;
    // Middle:
    mjResizeTop:         aPoint := Point(ControlRect.Left + (ControlRect.Right-ControlRect.Left) div 2, ControlRect.Top);
    mjResizeLeft:        aPoint := Point(ControlRect.Left, ControlRect.Top + (ControlRect.Bottom-ControlRect.Top) div 2);
    mjResizeRight:       aPoint := Point(ControlRect.Right, ControlRect.Top + (ControlRect.Bottom-ControlRect.Top) div 2);
    mjResizeBottom:      aPoint := Point(ControlRect.Left + (ControlRect.Right-ControlRect.Left) div 2, ControlRect.Bottom);
  end;

  // Determine RESULT position :
  aPoint := Point(aPoint.X - Handler.FSize div 2, aPoint.Y - Handler.FSize div 2);
  // Determine Rect size :
  RESULT := classes.Rect(aPoint.X, aPoint.Y, aPoint.X + Handler.FSize, aPoint.Y + Handler.FSize);
end;

constructor TpjhSelector.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FOptions := [roMouseSelect, roMouseMove, roMouseResize, roMouseMultiSelect, roMouseMultiMove, roMouseMultiResize, roMouseUnselectAll,
               roKeySelect, roKeyMove, roKeyResize, roKeyMultiSelect, roKeyMultiMove, roKeyMultiResize, roKeyUnselectAll, roOutsideParentRect];

  FHandlingSingleControl := TcyHandlingDef.Create(self);
  FHandlingSingleControl.OnChange := HandlingSingleControlChanged;
  FHandlingMultipleControls := TcyHandlingDef.Create(self);
  FHandlingMultipleControls.OnChange := HandlingMultipleControlsChanged;
  FHandlingControlList := THandlingControlList.Create(self);
  FHandlingControlList.FOnInsertItem := OnHandlingListInsertControl;
  FHandlingControlList.FOnRemoveItem := OnHandlingListRemoveControl;
  FHandlingControlList.FOnAfterRemoveItem := OnHandlingListAfterRemoveControl;
  FHandlingControlList.FOnClear := OnHandlingListClear;
  FActive := false;
  DoubleBuffered := true;     // Avoid flickering !!!
  ParentBackground := false;  // Avoid flickering !!!
end;

procedure TpjhSelector.Deactivate;
begin
  if FActive
  then begin
    FActive := false;
    FHandlingControlList.Clear;
//    Visible := false;
  end;
end;

destructor TpjhSelector.Destroy;
begin

  inherited;
end;

procedure TpjhSelector.DrawCircleHandler(var Rect: TRect; FrameWidth: Integer);
var
  p: Integer;
  SauvB, SauvP: TColor;
begin
  // Draw frame :
  SauvB := FPanelCanvas.Brush.Color;
  SauvP := FPanelCanvas.Pen.Color;
  FPanelCanvas.Brush.Color := FPanelCanvas.Pen.Color;

  for p := 0 to FrameWidth - 1 do
  begin
    FPanelCanvas.Ellipse(Rect);
    InflateRect(Rect, -1, -1);
  end;
  FPanelCanvas.Brush.Color := SauvB;

  // Fill frame :
  FPanelCanvas.Pen.Color := FPanelCanvas.Brush.Color;
  FPanelCanvas.Ellipse(Rect);
  FPanelCanvas.Pen.Color := SauvP;
end;

procedure TpjhSelector.DrawControlHandlers(ControlIndex: Integer);
var
  HandlingControlItem: THandlingControlItem;
  ControlRect: TRect;
  MultiSelection: Boolean;
begin
  HandlingControlItem := FHandlingControlList.GetItem(ControlIndex);
  ControlRect := GetHandlingControlItemClientRect(HandlingControlItem);

  if ControlIndex = 0
  then begin
    if csDesigning in ComponentState
    then MultiSelection := false
    else MultiSelection := FHandlingControlList.Count > 1;
  end
  else
    MultiSelection := true;

  if MultiSelection
  then DrawHandlers(FHandlingMultipleControls, ControlRect)
  else DrawHandlers(FHandlingSingleControl, ControlRect);
end;

procedure TpjhSelector.DrawGradientCircleHandler(var Rect: TRect;
  FrameWidth: Integer);
var
  p: Integer;
  SauvB, SauvP: TColor;
  eye: TRect;
begin
  // Draw frame :
  SauvB := FPanelCanvas.Brush.Color;
  SauvP := FPanelCanvas.Pen.Color;
  FPanelCanvas.Brush.Color := FPanelCanvas.Pen.Color;

  for p := 0 to FrameWidth - 2 do
  begin
    FPanelCanvas.Ellipse(Rect);
    InflateRect(Rect, -1, -1);
  end;
  FPanelCanvas.Brush.Color := SauvB;

  // Fill frame :
  eye := Rect;
  OffSetRect(Eye, -1, -1);
  InflateRectPercent(eye, -1);  // Inflate Rect -100%
  cyGradientFillShape(FPanelCanvas, Rect, SauvP, SauvB, 255, Eye, osRadial);
  FPanelCanvas.Brush.Color := SauvB;
  FPanelCanvas.Pen.Color := SauvP;
end;

procedure TpjhSelector.DrawGradientSquareHandler(var Rect: TRect;
  FrameWidth: Integer);
var
  p: Integer;
  SauvB, SauvP: TColor;
  eye: TRect;
begin
  // Draw frame :
  SauvB := FPanelCanvas.Brush.Color;
  SauvP := FPanelCanvas.Pen.Color;

  FPanelCanvas.Brush.Color := FPanelCanvas.Pen.Color;

  for p := 0 to FrameWidth - 2 do
  begin
    FPanelCanvas.FrameRect(Rect);
    InflateRect(Rect, -1, -1);
  end;

  // Fill frame :
  eye := Rect;
  OffSetRect(Eye, -1, -1);
  InflateRectPercent(eye, -1);  // Inflate Rect -100%
  cyGradientFillShape(FPanelCanvas, Rect, SauvP, SauvB, 255, Eye, osRectangle);
  FPanelCanvas.Brush.Color := SauvB;
  FPanelCanvas.Pen.Color := SauvP;
end;

procedure TpjhSelector.DrawHandler(Handler: TcyHandler; var Rect: TRect);
begin
  case Handler.FHandlerStyle of
    bsSquare:         DrawSquareHandler(Rect, Handler.Pen.Width);
    bsGradientSquare: DrawGradientSquareHandler(Rect, Handler.Pen.Width);
    bsCircle:         DrawCircleHandler(Rect, Handler.Pen.Width);
    bsGradientCircle: DrawGradientCircleHandler(Rect, Handler.Pen.Width);
  end;
end;

procedure TpjhSelector.DrawHandlers(HandlingDef: TcyHandlingDef; aRect: TRect);
var HandlerRect: TRect;
begin
  // Draw frame :
  if HandlingDef.Frame.Visible then
  begin
    FPanelCanvas.Pen.Width := 1;
    FPanelCanvas.Brush.Color := HandlingDef.Frame.Color;
    FPanelCanvas.FrameRect(aRect);
  end;

  // Draw corner Handlers :
  if HandlingDef.CornerHandlers.Visible
  then begin
    FPanelCanvas.Pen.Assign(HandlingDef.FCornerHandlers.Pen);
    FPanelCanvas.Pen.Width := 1;
    FPanelCanvas.Brush.Assign(HandlingDef.FCornerHandlers.FBrush);

    HandlerRect := CalcHandlerRect(HandlingDef.FCornerHandlers, mjResizeTopLeft, aRect);
    DrawHandler(HandlingDef.FCornerHandlers, HandlerRect);

    HandlerRect := CalcHandlerRect(HandlingDef.FCornerHandlers, mjResizeTopRight, aRect);
    DrawHandler(HandlingDef.FCornerHandlers, HandlerRect);

    HandlerRect := CalcHandlerRect(HandlingDef.FCornerHandlers, mjResizeBottomRight, aRect);
    DrawHandler(HandlingDef.FCornerHandlers, HandlerRect);

    HandlerRect := CalcHandlerRect(HandlingDef.FCornerHandlers, mjResizeBottomLeft, aRect);
    DrawHandler(HandlingDef.FCornerHandlers, HandlerRect);
  end;

  // Draw middle Handlers :
  if HandlingDef.MiddleHandlers.Visible
  then begin
    FPanelCanvas.Pen.Assign(HandlingDef.FMiddleHandlers.Pen);
    FPanelCanvas.Pen.Width := 1;
    FPanelCanvas.Brush.Assign(HandlingDef.FMiddleHandlers.FBrush);

    HandlerRect := CalcHandlerRect(HandlingDef.FMiddleHandlers, mjResizeTop, aRect);
    DrawHandler(HandlingDef.FMiddleHandlers, HandlerRect);

    HandlerRect := CalcHandlerRect(HandlingDef.FMiddleHandlers, mjResizeRight, aRect);
    DrawHandler(HandlingDef.FMiddleHandlers, HandlerRect);

    HandlerRect := CalcHandlerRect(HandlingDef.FMiddleHandlers, mjResizeBottom, aRect);
    DrawHandler(HandlingDef.FMiddleHandlers, HandlerRect);

    HandlerRect := CalcHandlerRect(HandlingDef.FMiddleHandlers, mjResizeLeft, aRect);
    DrawHandler(HandlingDef.FMiddleHandlers, HandlerRect);
  end;
end;

procedure TpjhSelector.DrawSquareHandler(var Rect: TRect; FrameWidth: Integer);
var
  p: Integer;
  SauvB: TColor;
begin
  // Draw frame :
  SauvB := FPanelCanvas.Brush.Color;
  FPanelCanvas.Brush.Color := FPanelCanvas.Pen.Color;

  for p := 0 to FrameWidth - 1 do
  begin
    FPanelCanvas.FrameRect(Rect);
    InflateRect(Rect, -1, -1);
  end;
  FPanelCanvas.Brush.Color := SauvB;

  // Fill frame :
  FPanelCanvas.FillRect(Rect);
end;

function TpjhSelector.GetHandlingControlItemClientRect(
  Item: THandlingControlItem): TRect;
var TopLeft, BottomRight: TPoint;
begin
  RESULT := classes.Rect(0, 0, Item.FControl.Width-1, Item.FControl.Height-1);
  TopLeft := ItemToClientPoint(Item, RESULT.TopLeft);
  BottomRight := ItemToClientPoint(Item, RESULT.BottomRight);
  RESULT := classes.Rect(TopLeft.X, TopLeft.Y, BottomRight.X, BottomRight.Y);
end;

procedure TpjhSelector.HandlingMultipleControlsChanged(Sender: TObject);
begin
  FPanel.invalidate;
end;

procedure TpjhSelector.HandlingSingleControlChanged(Sender: TObject);
begin
  FPanel.invalidate;
end;

function TpjhSelector.ItemToClientPoint(Item: THandlingControlItem;
  aPoint: TPoint): TPoint;
begin
  RESULT := aPoint;
  RESULT := Item.FControl.ClientToScreen(RESULT);
  RESULT := ScreenToClient(RESULT);
end;

procedure TpjhSelector.Notification(AComponent: TComponent;
  Operation: TOperation);
var Index: Integer;
begin
  inherited Notification(AComponent, Operation);

//  if (Operation = opRemove) and (AComponent <> Self)
//  then
//    if not (csDestroying in Owner.ComponentState)
//    then
//      if AComponent is TControl
//      then begin
//        if AComponent = FLastMouseDownControl
//        then FLastMouseDownControl := nil;
//
//        if FHandlingControlList.Find(TControl(AComponent), Index)
//        then FHandlingControlList.RemoveFromIndex(Index);
//      end;
end;

procedure TpjhSelector.OnHandlingListAfterRemoveControl(Sender: TObject;
  Index: Integer);
var i: integer;
begin
  // Draw control handlers :
  for i := 0 to FHandlingControlList.Count-1 do
    DrawControlHandlers(i);
end;

procedure TpjhSelector.OnHandlingListClear(Sender: TObject);
begin
  FPanel.Invalidate;
end;

procedure TpjhSelector.OnHandlingListInsertControl(Sender: TObject;
  Index: Integer);
begin
//  if Index = 1    // Passing from 1 control handled to 2, we need to repaint the first one !!!
//  then FPanel.Invalidate
//  else
  DrawControlHandlers(Index);
end;

procedure TpjhSelector.OnHandlingListRemoveControl(Sender: TObject;
  Index: Integer);
var i: integer;
begin
  FPanel.Invalidate;
end;

procedure TpjhSelector.SetDesignPanel(APanel: TCustomControl);
begin
  FPanel := APanel;
end;

procedure TpjhSelector.SetHandlingMultipleControls(const Value: TcyHandlingDef);
begin
  FHandlingMultipleControls := Value;
end;

procedure TpjhSelector.SetHandlingSingleControl(const Value: TcyHandlingDef);
begin
  FHandlingSingleControl := Value;
end;

procedure TpjhSelector.SetOptions(const Value: TResizerOptions);
begin
  FOptions := Value;
end;

procedure TpjhSelector.SetPanelCanvas(ACanvas: TCanvas);
begin
  FPanelCanvas := ACanvas;
end;

end.
