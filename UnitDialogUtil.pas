
function HookResourceString(ResStringRec: pResStringRec; NewStr: pChar) : integer ;
var
  OldProtect: DWORD;
begin
  VirtualProtect(ResStringRec, SizeOf(ResStringRec^), PAGE_EXECUTE_READWRITE, @OldProtect) ;
  result := ResStringRec^.Identifier;
  ResStringRec^.Identifier := Integer(NewStr) ;
  VirtualProtect(ResStringRec, SizeOf(ResStringRec^), OldProtect, @OldProtect) ;
end;
 
procedure UnHookResourceString(ResStringRec: pResStringRec; oldData: integer);
var
  OldProtect: DWORD;
begin
  VirtualProtect(ResStringRec, SizeOf(ResStringRec^), PAGE_EXECUTE_READWRITE, @OldProtect) ;
  ResStringRec^.Identifier := oldData ;
  VirtualProtect(ResStringRec, SizeOf(ResStringRec^), OldProtect, @OldProtect) ;
end;

function MessageDlgTimed(const Msg: string; DlgType: TMsgDlgType; Buttons: TMsgDlgButtons; HelpCtx: Longint): Integer;
const
  closePeriod = 2 * 1000;
  tickPeriod = 250;
var
  timerCloseId, timerTickId: UINT_PTR;
  r : integer;
  peekMsg : TMsg;
 
  procedure CloseMessageDlgCallback(AWnd: HWND; AMsg: UINT; AIDEvent: UINT_PTR; ATicks: DWORD); stdcall;
  var
    activeWnd: HWND;
  begin
    KillTimer(AWnd, AIDEvent);
 
    activeWnd := GetActiveWindow;
 
    if IsWindow(activeWnd) AND IsWindowEnabled(activeWnd) then
      PostMessage(activeWnd, WM_CLOSE, 0, 0);
  end; (*CloseMessageDlgCallback*)
 
  procedure PingMessageDlgCallback(AWnd: HWND; AMsg: UINT; AIDEvent: UINT_PTR; ATicks: DWORD); stdcall;
  var
    activeWnd: HWND;
    wCaption : string;
    wCaptionLength : integer;
  begin
    activeWnd := GetActiveWindow;
    if IsWindow(activeWnd) AND IsWindowEnabled(activeWnd) AND IsWindowVisible(activeWnd) then
    begin
      wCaptionLength := GetWindowTextLength(activeWnd);
      SetLength(wCaption, wCaptionLength);
      GetWindowText(activeWnd, PChar(wCaption), 1 + wCaptionLength);
      SetWindowText(activeWnd, Copy(wCaption, 1, -1 + Length(wCaption)));
    end
    else
      KillTimer(AWnd, AIDEvent);
  end; (*PingMessageDlgCallback*)
begin
  if (DlgType = mtInformation) AND ([mbOK] = Buttons) then
  begin
    timerCloseId := SetTimer(0, 0, closePeriod, @CloseMessageDlgCallback);
 
    if timerCloseId <> 0 then
    begin
      timerTickId := SetTimer(0, 0, tickPeriod, @PingMessageDlgCallback);
 
      if timerTickId <> 0 then
        r := HookResourceString(@SMsgDlgInformation, PChar(SMsgDlgInformation + ' ' + StringOfChar('.', closePeriod div tickPeriod)));
    end;
 
    result := MessageDlg(Msg, DlgType, Buttons, HelpCtx);
 
    if timerTickId <> 0 then
    begin
      KillTimer(0, timerTickId);
      UnHookResourceString(@SMsgDlgInformation, r);
    end;
 
    if timerCloseId <> 0 then
      KillTimer(0, timerCloseId);
  end
  else
    result := MessageDlg(Msg, DlgType, Buttons, HelpCtx);
end;