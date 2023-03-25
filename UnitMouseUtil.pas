unit UnitMouseUtil;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, Forms;

procedure MouseLock(AForm: TForm; var AMouseLock: Boolean; AIsLock: Boolean);
procedure MoveMouse(X,Y,Speed: Integer);

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

end.
