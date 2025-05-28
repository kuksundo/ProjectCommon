unit UnitFormUtil;

interface

uses Forms, SysUtils, Windows, Classes, Controls, TypInfo, Vcl.Graphics, Vcl.StdCtrls;

procedure ScreenActiveControlChange(Sender: TObject; activeControl: TWinControl;
  prevInactiveColor: TColor);
procedure ToggleBorderStyle(AForm: TForm);
procedure ToggleWindowMaxmize(AForm: TForm);
procedure ResetWindowPosition(AForm: TForm);
procedure ToggleStayOnTop(AForm: TForm);
procedure ToggleAlignTop(AForm: TForm);
procedure OpenFormAtMousePoint(AForm: TForm);
procedure ToggleStayOnTop4MultiMonitor(AForm: TForm);
procedure ToggleAlignTop4MultiMonitor(AForm: TForm);
//MDI Child Form이 이미 생성 되었다면 Show 하고 MIDChild[Index}의 index Return
//기 생성 폼이 없으면 -1 Return
function CheckMDIChildAndShow(AMDIForm: TForm; AChildClassName: string): integer;
procedure ToggleFullScreen(AForm: TForm);
procedure ToggleFullScreenWithNoTaskBar(AForm: TForm);
procedure DisplayFormOnMultiMonitor(AForm: TForm; AMonitorIdx: integer);
procedure ToggleFullScreenWidth(AForm: TForm; AMonitorIdx: integer);
procedure SetWindowPos_JH(AHandle: THandle);
procedure MakeTransparentForm(AForm: TForm; AAlpha: integer);
procedure WindowShake(wHandle: THandle) ;

function CreateNShowFormByClassName(const AFormClassName: string): TForm;

//아래 함수는 UnitMouseUtil.pas로 이동함
//function GetComponentUnderMouseCursor(AAllowDisabled: Boolean=True; AAllowWinControl: Boolean=True): TControl;

implementation

procedure ScreenActiveControlChange(Sender: TObject; activeControl: TWinControl;
  prevInactiveColor: TColor);
var
  noEnter, noExit : boolean;
  prevActiveControl : TWinControl;

  procedure ColorEnter(Sender : TObject);
  begin
    if Assigned(Sender) AND IsPublishedProp(Sender,'Color') then
    begin
      prevInactiveColor := GetOrdProp(Sender, 'Color');
      SetOrdProp(Sender, 'Color', clSkyBlue); //change clSkyBlue to something else or read from some application configuration <img class="emoji" draggable="false" alt="??" src="https://s.w.org/images/core/emoji/11/svg/1f642.svg">
    end;
  end; (*ColorEnter*)

  procedure ColorExit(Sender : TObject);
  begin
    if Assigned(Sender) AND IsPublishedProp(Sender,'Color') then
      SetOrdProp(Sender, 'Color', prevInactiveColor);
  end; (*ColorExit*)
begin
  if Screen.ActiveControl = nil then
  begin
    activeControl := nil;
    Exit;
  end;

  noExit := false;

  noEnter := NOT Screen.ActiveControl.Enabled;
  noEnter := noEnter OR (Screen.ActiveControl is TForm); //disabling active control focuses the form
  noEnter := noEnter OR (Screen.ActiveControl is TCheckBox); // skip checkboxes

  prevActiveControl := activeControl;

  if prevActiveControl <> nil then
  begin
    noExit := prevActiveControl is TForm;
    noExit := noExit OR (prevActiveControl is TCheckBox);
  end;

  activeControl := Screen.ActiveControl;

  if NOT noExit then ColorExit(prevActiveControl);
  if NOT noEnter then ColorEnter(activeControl);
end;

procedure ToggleBorderStyle(AForm: TForm);
begin
  with AForm do
  begin
    if BorderStyle = bsNone then
      BorderStyle := bsSizeable
    else
      BorderStyle := bsNone;
  end;
end;

procedure ToggleWindowMaxmize(AForm: TForm);
begin
  with AForm do
  begin
    if WindowState = wsMaximized then
      WindowState := wsNormal
    else
      WindowState := wsMaximized;
  end;
end;

procedure ToggleStayOnTop(AForm: TForm);
begin
  with AForm do
  begin
    if FormStyle = fsNormal then
      FormStyle := fsStayOnTop
    else
    if FormStyle = fsStayOnTop then
      FormStyle := fsNormal;
  end;
end;

procedure ToggleAlignTop(AForm: TForm);
begin
  with AForm do
  begin
    if Align = alTop then
      Align := alNone
    else
    if Align = alNone then
      Align := alTop;
  end;
end;

procedure ResetWindowPosition(AForm: TForm);
begin
  with AForm do
  begin
    Top := 0;
    Left := 0;
  end;
end;

procedure OpenFormAtMousePoint(AForm: TForm);
var
  LRect: TRect;
begin
//  if Screen.MonitorCount > 1 then
//  begin
    LRect := Screen.MonitorFromPoint(Mouse.CursorPos).WorkareaRect;
    AForm.Position := poDesigned;
    AForm.Left := LRect.Left + ((LRect.Width - AForm.Width) div 2);
    AForm.Top := LRect.Top + ((LRect.Height - AForm.Height) div 2);
//  end
//  else
//  begin
//    AForm.Position := poScreenCenter;
//  end;
end;

procedure ToggleStayOnTop4MultiMonitor(AForm: TForm);
var
  LMonitor: TMonitor;
  Lx, Ly: integer;
begin
  Lx := 0;
  Ly := 0;

  if Screen.MonitorCount > 1 then
  begin
    LMonitor := Screen.MonitorFromWindow(AForm.Handle);
    Lx := LMonitor.Left;
    Ly := LMonitor.Top;
  end;

  if AForm.Tag = 0 then
  begin
    AForm.Tag := 1;
    SetWindowPos(AForm.Handle, HWND_TOPMOST, Lx, Ly,0,0, SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE);
  end
  else
  begin
    AForm.Tag := 0;
    SetWindowPos(AForm.Handle, HWND_NOTOPMOST, Lx, Ly,0,0, SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE);
  end;
end;

procedure ToggleAlignTop4MultiMonitor(AForm: TForm);
var
  LMonitor: TMonitor;
  Lx, Ly: integer;
begin
  Lx := 0;
  Ly := 0;

  if Screen.MonitorCount > 1 then
  begin
    LMonitor := Screen.MonitorFromWindow(AForm.Handle);
    Lx := LMonitor.Left;
    Ly := LMonitor.Top;
  end;

  if AForm.Tag = 0 then
  begin
    AForm.Tag := 1;
    AForm.SetBounds(Lx, Ly,LMonitor.WorkareaRect.Right-LMonitor.WorkareaRect.Left, AForm.Height);
  end
  else
  begin
    AForm.Tag := 0;
    AForm.SetBounds(Lx, Ly,LMonitor.WorkareaRect.Right-LMonitor.WorkareaRect.Left, AForm.Height);
  end;
end;

function CheckMDIChildAndShow(AMDIForm: TForm; AChildClassName: string): integer;
var
  i: integer;
begin
  Result := -1;

  for i := 0 to AMDIForm.MDIChildCount - 1 do
  begin
    if pos(AChildClassName, TForm(AMDIForm.MDIChildren[i]).ClassName) > 0 then
    begin
      AMDIForm.MDIChildren[i].Show;
      Result := i;
      Break;
    end;
  end;//for
end;

procedure ToggleFullScreen(AForm: TForm);
  {$J+} //writeable constants on
  const
    rect: TRect = (Left:0; Top:0; Right:0; Bottom:0);
    ws : TWindowState = wsNormal;
  {$J-} //writeable constants off
var
   r : TRect;
begin
   if AForm.BorderStyle <> bsNone then
   begin
      ws := AForm.WindowState;
      rect := AForm.BoundsRect;
      AForm.BorderStyle := bsNone;
      r := Screen.MonitorFromWindow(AForm.Handle).BoundsRect;
      AForm.SetBounds(r.Left, r.Top, r.Right-r.Left, r.Bottom-r.Top) ;
   end
   else
   begin
      AForm.BorderStyle := bsSizeable;
      if ws = wsMaximized then
        AForm.WindowState := wsMaximized
      else
        AForm.SetBounds(rect.Left, rect.Top, rect.Right-rect.Left, rect.Bottom-rect.Top) ;
   end;
end;

procedure ToggleFullScreenWithNoTaskBar(AForm: TForm);
var
   r : TRect;
begin
   AForm.Borderstyle := bsNone;
   SystemParametersInfo(SPI_GETWORKAREA, 0, @r,0) ;
   AForm.SetBounds(r.Left, r.Top, r.Right-r.Left, r.Bottom-r.Top) ;
end;

procedure DisplayFormOnMultiMonitor(AForm: TForm; AMonitorIdx: integer);
begin
  if Screen.MonitorCount > AMonitorIdx then
  begin
    AForm.Top := Screen.Monitors[AMonitorIdx].Top;
    AForm.Left := Screen.Monitors[AMonitorIdx].Left;
  end;
end;

procedure ToggleFullScreenWidth(AForm: TForm; AMonitorIdx: integer);
var
  r : TRect;
begin
  if Screen.MonitorCount > AMonitorIdx then
  begin
    AForm.Width := Screen.Monitors[AMonitorIdx].Width;
  end;
end;

procedure SetWindowPos_JH(AHandle: THandle);
begin
  SetWindowPos(AHandle, HWND_TOPMOST, 0,0,0,0, SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE);
end;

procedure MakeTransparentForm(AForm: TForm; AAlpha: integer);
begin
  //폼을 레이어드윈도스타일로 바꾼다
  SetWindowLong(AForm.Handle, GWL_EXSTYLE, GetWindowLong(AForm.Handle, GWL_EXSTYLE) or WS_EX_LAYERED);
  //폼에 Alpha 걊을 적용한다
  SetLayeredWindowAttributes(AForm.Handle, 0, Round((255 * 70) / 100), LWA_ALPHA);
end;

procedure WindowShake(wHandle: THandle) ;
const
  MAXDELTA = 2;
  SHAKETIMES = 500;
var
  oRect, wRect :TRect;
  deltax : integer;
  deltay : integer;
  cnt : integer;
  dx, dy : integer;
begin
  //remember original position
  GetWindowRect(wHandle,wRect) ;
  oRect := wRect;

  Randomize;
  for cnt := 0 to SHAKETIMES do
  begin
    deltax := Round(Random(MAXDELTA)) ;
    deltay := Round(Random(MAXDELTA)) ;
    dx := Round(1 + Random(2)) ;
    if dx = 2 then dx := -1;
    dy := Round(1 + Random(2)) ;
    if dy = 2 then dy := -1;
    OffsetRect(wRect,dx * deltax, dy * deltay) ;
    MoveWindow(wHandle, wRect.Left,wRect.Top,wRect.Right - wRect.Left,wRect.Bottom - wRect.Top,true) ;
    Application.ProcessMessages;
  end;

  //return to start position
  MoveWindow(wHandle, oRect.Left,oRect.Top,oRect.Right - oRect.Left,oRect.Bottom - oRect.Top,true) ;
end;

//사용예: CreateNShowFormByClassName(TForm1);
function CreateNShowFormByClassName(const AFormClassName: string): TForm;
var
  LPersistentClass: TPersistentClass;
begin
  Result := nil;
  LPersistentClass <> nil then
  begin
    Result := TFormClass(LPersistentClass).Create(Application);
    Result.Show;
  end
  else
    raise Exception.Create('FormClass : %s not found', [AFormClassName]);
end;

end.
