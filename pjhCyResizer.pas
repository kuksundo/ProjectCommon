unit pjhCyResizer;

interface

uses Classes, Forms, Windows, SysUtils, RTLConsts, Controls, Graphics, Messages,
  VCL.cyTypes, VCL.cyGraphics, Dialogs, cyResizer;

type
  TControlJob = (cjNothing, cjInserted, cjRemoved);
  TProcPostMouseInformation = procedure (aPoint: TPoint; var aControl: TControl; var ControlRect, HandlerRect: TRect; var Job: TControlJob) of object;

  TcyResizerHelper = class helper for TcyResizer
  protected
    function GetSurface: TWinControl;
    procedure SetMouseHandlingFromPoint(AValue: TPoint);
    function GetMouseHandlingFromPoint: TPoint;
    procedure SetRangeSelectMinX(AValue: Integer);
    function GetRangeSelectMinX: Integer;
    procedure SetRangeSelectMaxX(AValue: Integer);
    function GetRangeSelectMaxX: Integer;
    procedure SetRangeSelectMinY(AValue: Integer);
    function GetRangeSelectMinY: Integer;
    procedure SetRangeSelectMaxY(AValue: Integer);
    function GetRangeSelectMaxY: Integer;
    procedure SetMouseHandling1stTask(AValue: Boolean);
    function GetMouseHandling1stTask: Boolean;

    function GetLastMouseDownControl: TControl;
    procedure SetLastMouseDownControl(AValue: TControl);
  public
    property Surface: TWinControl read GetSurface;
    property MouseHandlingFromPoint: TPoint read GetMouseHandlingFromPoint write SetMouseHandlingFromPoint;
    property RangeSelectMinX: Integer read GetRangeSelectMinX write SetRangeSelectMinX;
    property RangeSelectMaxX: Integer read GetRangeSelectMaxX write SetRangeSelectMaxX;
    property RangeSelectMinY: Integer read GetRangeSelectMinY write SetRangeSelectMinY;
    property RangeSelectMaxY: Integer read GetRangeSelectMaxY write SetRangeSelectMaxY;
    property MouseHandling1stTask: Boolean read GetMouseHandling1stTask write SetMouseHandling1stTask;
  end;

  TpjhCyResizer = class(TcyResizer)
  private
//    FSurface: TWinControl;
//    FMouseHandlingFromPoint: TPoint;
//    FRangeSelectMinX: Integer;
//    FRangeSelectMaxX: Integer;
//    FRangeSelectMinY: Integer;
//    FRangeSelectMaxY: Integer;
//    FMouseHandling1stTask: Boolean;
//    FLastMouseJob: TMouseJob;
    FOnPostProcessMouseInformation: TProcPostMouseInformation;

    //Add by pjh
    FControlJob: TControlJob;
  protected
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  published
    property OnPostProcessMouseInformation: TProcPostMouseInformation read FOnPostProcessMouseInformation write FOnPostProcessMouseInformation;

  end;

implementation

{ TpjhCyResizer }

procedure TpjhCyResizer.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  aMouseJob: TMouseJob;
  aHandlingControl: TControl;
  aHandlingControlRect, HandlerRect: TRect;
  ControlAccepted: Boolean;
  aPt: TPoint;
  i: Integer;
  LLastMouseDownControl: TControl;
begin
  FControlJob := cjNothing;

  ControlAccepted := true;
  if not Focused then SetFocus;

  if (not ReadOnly) and (Button = mbLeft)
  then begin
    MouseHandlingFromPoint := Point(x, y);

    // Determine mouse over control :
    DoGetHandlingMouseInformation(MouseHandlingFromPoint, aHandlingControl, aHandlingControlRect, HandlerRect, aMouseJob);

    // *** Attention: because we are clicking, we need to select topleft control ***
    if (aHandlingControl = Nil) or (aMouseJob = mjMove) then
    begin
      LLastMouseDownControl := DetermineControlAtPos(Surface, MouseHandlingFromPoint);  // Retrieve topMost control at mouse position ...
      aMouseJob := mjMove;  // 2014-07-04
    end
    else
      LLastMouseDownControl := aHandlingControl;
    // *** Attention end *** //

    // 2014-07-4 Let user change information :
    if Assigned(OnGetHandlingMouseInformation) then
      OnGetHandlingMouseInformation(Self, MouseHandlingFromPoint, LLastMouseDownControl, aHandlingControlRect, HandlerRect, aMouseJob);

    MouseHandlingJob := aMouseJob;

    if LLastMouseDownControl <> Nil
    then begin
      if (aHandlingControl = LLastMouseDownControl) and (MouseHandlingJob <> mjNothing)
      then begin
        if ssCtrl in Shift
        then begin
          if roMouseSelect in Options
          then begin
            HandlingControlList.Clear;

            if Assigned(OnControlListInsert)
            then OnControlListInsert(Self, aHandlingControl, ControlAccepted);

            if ControlAccepted
            then begin
              HandlingControlList.InsertControl(aHandlingControl);
              MouseHandlingJob := mjRangeSelect;
              MouseHandling := MouseHandlingJob <> mjNothing;
              FControlJob := cjInserted;
            end;
          end;
        end
        else
          if ssShift in Shift
          then begin
            if roMouseSelect in Options then
            begin
              HandlingControlList.RemoveControl(aHandlingControl);
              FControlJob := cjRemoved;
            end;
          end
          else begin
            // Prepare to move/resize :
            MouseHandling := MouseHandlingJob <> mjNothing;
          end;
      end
      else
        if roMouseSelect in Options
        then begin           // RHR Need to enter here !!!
          if not (ssShift in Shift) or not (roMouseMultiSelect in Options)
          then HandlingControlList.Clear;

          if not (ssCtrl in Shift)   // Add control to handled ControlList
          then begin
            if Assigned(OnControlListInsert)
            then OnControlListInsert(Self, LastMouseDownControl, ControlAccepted);
            // Old 2013-07-03 then FOnControlListInsert(Self, aHandlingControl, ControlAccepted);

            if ControlAccepted
            then begin
              HandlingControlList.InsertControl(LastMouseDownControl);
              MouseHandlingJob := mjMove;  // Start to move after selecting ...
              MouseHandling := MouseHandlingJob <> mjNothing;
              FControlJob := cjInserted;
            end;
          end;
        end;
    end
    else
      if not (ssShift in Shift) or not (roMouseMultiSelect in Options) then
        if roMouseUnselectAll in Options    // Unselect all ...
        then HandlingControlList.Clear;
  end
  else
    LLastMouseDownControl := DetermineControlAtPos(Surface, MouseHandlingFromPoint);  // Retrieve topMost control at mouse position ...

  if (not MouseHandling) and (ControlAccepted)
  then begin
    MouseHandlingJob := mjRangeSelect;
    MouseHandling := MouseHandlingJob <> mjNothing;
  end;

  if MouseHandling
  then begin
    if MouseHandlingJob = mjRangeSelect
    then begin
      RangeSelectMinX := 0;
      RangeSelectMaxX := Width;
      RangeSelectMinY := 0;
      RangeSelectMaxY := Height;

      // Range selection inside a control?
      if LastMouseDownControl <> Nil
      then
        if LastMouseDownControl is TWinControl
        then
          if csAcceptsControls in LastMouseDownControl.ControlStyle
          then begin
            aPt := ScreenToClient( LastMouseDownControl.ClientToScreen(Point(0, 0)) );
            RangeSelectMinX := aPt.X;
            RangeSelectMinY := aPt.Y;
            RangeSelectMaxX := aPt.X + LastMouseDownControl.Width;
            RangeSelectMaxY := aPt.Y + LastMouseDownControl.Height;
          end;
    end
    else begin
      for i := 0 to HandlingControlList.Count-1 do
        HandlingControlList.Items[i].OldRect := HandlingControlList.Items[i].Control.BoundsRect;
    end;

    LastMouseJob := MouseHandlingJob;
    MouseHandling1stTask := true;
  end;

  Cursor := GetMouseJobCursor(LastMouseJob);

  if Assigned(FOnPostProcessMouseInformation) then
    FOnPostProcessMouseInformation(MouseHandlingFromPoint, LLastMouseDownControl, aHandlingControlRect, HandlerRect, FControlJob);

  SetLastMouseDownControl(LLastMouseDownControl);

  inherited;
end;

{ TcyResizerHelper }

function TcyResizerHelper.GetLastMouseDownControl: TControl;
begin
  Result := Self.FLastMouseDownControl;
end;

function TcyResizerHelper.GetMouseHandling1stTask: Boolean;
begin
  Result := Self.FMouseHandling1stTask;
end;

function TcyResizerHelper.GetMouseHandlingFromPoint: TPoint;
begin
  Result := Self.FMouseHandlingFromPoint;
end;

function TcyResizerHelper.GetRangeSelectMaxX: Integer;
begin
  Result := Self.FRangeSelectMaxX;
end;

function TcyResizerHelper.GetRangeSelectMaxY: Integer;
begin
  Result := Self.FRangeSelectMaxY;
end;

function TcyResizerHelper.GetRangeSelectMinX: Integer;
begin
  Result := Self.FRangeSelectMinX;
end;

function TcyResizerHelper.GetRangeSelectMinY: Integer;
begin
  Result := Self.FRangeSelectMinY;
end;

function TcyResizerHelper.GetSurface: TWinControl;
begin
  Result := Self.FSurface;
end;

procedure TcyResizerHelper.SetLastMouseDownControl(AValue: TControl);
begin
  Self.FLastMouseDownControl := AValue;
end;

procedure TcyResizerHelper.SetMouseHandling1stTask(AValue: Boolean);
begin
  Self.FMouseHandling1stTask := AValue;
end;

procedure TcyResizerHelper.SetMouseHandlingFromPoint(AValue: TPoint);
begin
  Self.FMouseHandlingFromPoint := AValue;
end;

procedure TcyResizerHelper.SetRangeSelectMaxX(AValue: Integer);
begin
  Self.FRangeSelectMaxX := AValue;
end;

procedure TcyResizerHelper.SetRangeSelectMaxY(AValue: Integer);
begin
  Self.FRangeSelectMaxY := AValue;
end;

procedure TcyResizerHelper.SetRangeSelectMinX(AValue: Integer);
begin
  Self.FRangeSelectMinX := AValue;
end;

procedure TcyResizerHelper.SetRangeSelectMinY(AValue: Integer);
begin
  Self.FRangeSelectMinY := AValue;
end;

end.

