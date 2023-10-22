unit UnitMouseUtil;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, Forms, Controls;

procedure MouseLock(AForm: TForm; var AMouseLock: Boolean; AIsLock: Boolean);
procedure MoveMouse(X,Y,Speed: Integer);
function GetMouseFlagFromType(AType: Cardinal): Cardinal;
function GetComponentUnderMouseCursor(AAllowDisabled: Boolean=True; AAllowWinControl: Boolean=True): TControl;

implementation

procedure MouseLock(AForm: TForm; var AMouseLock: Boolean; AIsLock: Boolean);
var
  LRect: TRect;
begin
  if AIsLock then
  begin
    if not AMouseLock then
    begin
      LRect := AForm.ClientRect;
      LRect.TopLeft := AForm.ClientToScreen(LRect.TopLeft);
      LRect.BottomRight := AForm.ClientToScreen(LRect.BottomRight);
      ClipCursor(@LRect);
    end;
  end
  else
    ClipCursor(nil);

  AMouseLock := AIsLock;
end;

procedure MoveMouse(X,Y,Speed: Integer);
var
  Maus : TPoint;
  mx, my, nx, ny, len : double;
begin
  mouse_event(MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0);

//  if Speed < 1 then Speed := 1;

  GetCursorPos(Maus);
  mx := maus.x;
  my := maus.y;

  While (mx<>x)OR(my<>y) Do
  begin
    nx := x-mx;
    ny := y-my;
    len := sqrt(nx*nx + ny*ny);

    if(len<=1)Then
    begin
      mx:=x;
      my:=y;
    end
    else
    begin
      nx := nx / (len*0.5);
      ny := ny / (len*0.5);
      mx := mx + nx;
      my := my + ny;
    end;

    Mouse_Event(MOUSEEVENTF_ABSOLUTE, Round(mx)+50,Round(my), 0, GetMessageExtraInfo);
    //    SetCursorPos(Round(mx),Round(my));
    if Speed > 1 then
      Sleep(Speed);
  end;

  mouse_event(MOUSEEVENTF_LEFTUP, 0, 0, 0, 0);
end;

function GetMouseFlagFromType(AType: Cardinal): Cardinal;
begin
  if (AType = WM_LBUTTONDOWN) or (AType = WM_LBUTTONDBLCLK) then
  begin
    Result := MOUSEEVENTF_LEFTDOWN;
  end
  else if (AType = WM_RBUTTONDOWN) or (AType = WM_RBUTTONDBLCLK) then
  begin
    Result := MOUSEEVENTF_RIGHTDOWN
  end
  else if (AType = WM_MBUTTONDOWN) or (AType = WM_MBUTTONDBLCLK) then
  begin
    Result := MOUSEEVENTF_MIDDLEDOWN
  end
  else if (AType = WM_MBUTTONDOWN) or (AType = WM_MBUTTONDBLCLK) then
  begin
    Result := MOUSEEVENTF_MIDDLEDOWN;
  end
  else if (AType = WM_LBUTTONUP) then
  begin
    Result := MOUSEEVENTF_LEFTUP;
  end
  else if (AType = WM_RBUTTONUP) then
  begin
    Result := MOUSEEVENTF_RIGHTUP;
  end
  else if (AType = WM_MBUTTONUP) then
  begin
    Result := MOUSEEVENTF_MIDDLEUP;
  end
  else if (AType = WM_MOUSEWHEEL) then
  begin
    Result := MOUSEEVENTF_WHEEL;
  end
  else if (AType = WM_MOUSEMOVE) then
  begin
    Result := MOUSEEVENTF_MOVE + MOUSEEVENTF_ABSOLUTE;
  end
end;

function GetComponentUnderMouseCursor(AAllowDisabled: Boolean; AAllowWinControl: Boolean): TControl;
var
  LWindow: TWinControl;
  LControl: TControl;
  LPoint: TPoint;
begin
  Result := nil;

  LPoint := Mouse.CursorPos;
  LWindow := FindVCLWindow(LPoint);

  if LWindow <> nil then
  begin
    Result := LWindow;
    LControl := LWindow.ControlAtPos(LWindow.ScreenToClient(LPoint), AAllowDisabled, AAllowWinControl);

    if LControl <> nil then
      Result := LControl;
  end;
end;

end.
