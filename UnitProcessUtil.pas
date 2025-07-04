unit UnitProcessUtil;

interface

uses Windows, sysutils, classes, Forms, shellapi, Graphics, math, MMSystem,
    JclStringConversions, WinSock, Winapi.Messages, TLHelp32, Registry, Winapi.PsAPI;

type
  PProcWndInfo = ^TProcWndInfo;
  TProcWndInfo = record
    TargetProcessID: DWORD;
    FoundWindow    : HWND;
  end; { TProcWndInfo }

function ExecNewProcess(ProgramName : String; Wait: Boolean): string;
function ExecNewProcess2(ProgramName: string; ParamString : String = ''): THandle;
function FileExecute(const FileName, Params, StartDir: string): Cardinal;
function ExecAndWait(const ExecuteFile, ParamString: string) : THandle;
function GetHandleByPID(Pid: longword): THandle;
function DSiGetProcessWindow(targetProcessID: cardinal): HWND;
function KillTask(ExeFileName: string): Integer;//파일명으로 실행중인 프로세스 죽이기
function isOpen(ExeFileName: string): integer; //파일명으로 실행여부 확인하고 프로세 아이디 얻기
procedure RunAsAdmin(hWnd : Hwnd; aFile : string; aParameters : string);
function IsUACActive: Boolean;
function IsRunningProcess( const ProcName: String ) : Boolean;
function KillProcess(const ProcName: String): Boolean;
function KillProcessId(const AProcId: THandle): Boolean;
function GetConsoleOutput2(const Command : WideString;
                          Output, Errors : TStrings) : Boolean;
function RunConsoleAndGetOutput(const ACommand: string; AOutput : TStrings): Boolean;

{Ex:
  if (AnsiLowerCase(ExtractFileName(GetTheParentProcessFileName)) <> 'explorer.exe') and
    (AnsiLowerCase(ExtractFileName(GetTheParentProcessFileName)) <> 'cmd.exe') then
  begin
    KillTask((ExtractFileName(GetTheParentProcessFileName)));
    exitprocess(0);
  end;
}
function GetTheParentProcessFileName(): String;

type
  TExecuteFileOption = (
    eoHide,
    eoWait,
    eoElevate
  );
  TExecuteFileOptions = set of TExecuteFileOption;

function ExecuteFile(Handle: HWND; const Filename, Paramaters: String; Options: TExecuteFileOptions): Integer;
// netsh 명령어를 실행하는 함수
procedure RunPowerShellCommand(Command: string);
{
  // netsh 명령어 생성
  Cmd := Format('interface ip set address name="%s" static %s %s %s 1',
                [InterfaceName, IPAddress, SubnetMask, Gateway]);
  // 마지막 '1'은 메트릭 값입니다. 게이트웨이가 없으면 Gateway 파라미터와 메트릭을 생략할 수 있습니다.
  // 예: Cmd := Format('interface ip set address name="%s" static %s %s', [InterfaceName, IPAddress, SubnetMask]);

  // DHCP 설정 명령어
  Cmd := Format('interface ip set address name="%s" dhcp', [InterfaceName]);
}
function ExecuteNetshCommand(const ACommand: string): string;

implementation

function ExecNewProcess(ProgramName : String; Wait: Boolean): string;
var
  StartInfo : TStartupInfo;
  ProcInfo : TProcessInformation;
  CreateOK : Boolean;
begin
  Result := '';
  { fill with known state }
  FillChar(StartInfo,SizeOf(TStartupInfo),#0);
  FillChar(ProcInfo,SizeOf(TProcessInformation),#0);
  StartInfo.cb := SizeOf(TStartupInfo);
  CreateOK :=   CreateProcessW(nil,
      PWideChar(UTF8Decode(ProgramName)),       // command line
      nil,          // process security attributes
      nil,          // primary thread security attributes
      TRUE,         // handles are inherited
      0,            // creation flags
      nil,          // use parent's environment
      nil,          // use parent's current directory
      StartInfo,  // STARTUPINFO pointer
      ProcInfo);  // receives PROCESS_INFORMATION
  WaitForInputIdle(ProcInfo.hProcess, INFINITE);
    { check to see if successful }
  if CreateOK then
    begin
        //may or may not be needed. Usually wait for child processes
      if Wait then
        WaitForSingleObject(ProcInfo.hProcess, INFINITE);
    end
  else
    Result := 'Unable to run '+ProgramName;

  CloseHandle(ProcInfo.hProcess);
  CloseHandle(ProcInfo.hThread);
end;

function ExecNewProcess2(ProgramName: string; ParamString : String = ''): THandle;
var
  StartInfo : TStartupInfo;
  ProcInfo : TProcessInformation;
  CreateOK : Boolean;
  Res: Boolean;
  Msg: TagMsg;
begin
  Result := 0;
  { fill with known state }
  FillChar(StartInfo,SizeOf(TStartupInfo),#0);
  FillChar(ProcInfo,SizeOf(TProcessInformation),#0);
  StartInfo.cb := SizeOf(TStartupInfo);

  if ParamString <> '' then
    ProgramName := ProgramName + ' ' + ParamString;

  CreateOK :=   CreateProcessW(nil,
      PChar(ProgramName),       // command line
      nil,          // process security attributes
      nil,          // primary thread security attributes
      TRUE,         // handles are inherited
      0,            // creation flags
      nil,          // use parent's environment
      nil,          // use parent's current directory
      StartInfo,  // STARTUPINFO pointer
      ProcInfo);  // receives PROCESS_INFORMATION
    { check to see if successful }
  if CreateOK then
  begin
    WaitForInputIdle(ProcInfo.hProcess, 1000);

    {while WaitForSingleObject(ProcInfo.hProcess,1) = WAIT_TIMEOUT do
    begin
      repeat
        Res := PeekMessage(Msg, ProcInfo.hProcess, 0,0,PM_REMOVE);
        if Res then
        begin
          TranslateMessage(Msg);
          DispatchMessage(Msg);
        end;
      until not Res;
    end;
     }
    //Result := GetHandleByPID(ProcInfo.dwProcessId);
    Result := ProcInfo.dwProcessId;
  end;
  CloseHandle(ProcInfo.hProcess);
  CloseHandle(ProcInfo.hThread);
end;

function FileExecute(const FileName, Params, StartDir: string): Cardinal;
begin
  Result := ShellExecute(Application.Handle, 'open', PChar(FileName),
                    PChar(Params), PChar(StartDir), SW_SHOWNORMAL);
end;

function ExecAndWait(const ExecuteFile, ParamString: string) : THandle;
var
  SEInfo: TShellExecuteInfo;
  ExitCode: DWORD;
begin
  Result := 0;

  try
    FillChar(SEInfo, Sizeof(SEInfo), 0);
    SEInfo.cbSize := SizeOf(TShellExecuteInfo);
    with SEInfo do
    begin
      fMask := SEE_MASK_NOCLOSEPROCESS;
      Wnd := Application.Handle;
      lpFile := PChar(ExecuteFile);
      lpParameters := PChar(ParamString);
      nShow := SW_SHOW;
    end;

    if ShellExecuteEx(@SEInfo) then
    begin
      Result := SEInfo.hProcess;
    end;

  Except

  end;
end;

function GetHandleByPID(Pid: longword): THandle; // 델마당 '나도 한때는' 님의 코드를 슬쩍...
var
  test_hwnd  : longword;
  test_pid : longword;
  test_thread_id : longword;
begin
  Result := 0;
  test_hwnd := FindWindow(nil, nil);
  while test_hwnd <> 0 do
  begin
    If GetParent(test_hwnd) = 0 Then
    begin
      test_thread_id := GetWindowThreadProcessId(test_hwnd, test_pid);
      if test_pid = Pid then
      begin
        Result :=  test_hwnd;
        exit;
      end;
    end;
    test_hwnd := GetWindow(test_hwnd, GW_HWNDNEXT);
  end;
end;

function EnumGetProcessWindow(wnd: HWND; userParam: LPARAM): BOOL; stdcall;
var
  wndProcessID: DWORD;
begin
  GetWindowThreadProcessId(wnd, @wndProcessID);
  if (wndProcessID = PProcWndInfo(userParam)^.TargetProcessID) and
     //(GetWindowLong(wnd, GWL_HINSTANCE) <> 0) then
     (GetWindowLong(wnd, GWL_HWNDPARENT) = 0) then
  begin
    PProcWndInfo(userParam)^.FoundWindow := Wnd;
    Result := false;
  end
  else
    Result := true;
end; { EnumGetProcessWindow }

{ln}
function DSiGetProcessWindow(targetProcessID: cardinal): HWND;
var
  procWndInfo: TProcWndInfo;
begin
  procWndInfo.TargetProcessID := targetProcessID;
  procWndInfo.FoundWindow := 0;
  EnumWindows(@EnumGetProcessWindow, LPARAM(@procWndInfo));
  Result := procWndInfo.FoundWindow;
end; { DSiGetProcessWindow }

//출처 http://www.delphi3000.com/articles/article_4324.asp?SK=
//실행파일명으로 프로세스 종료
function KillTask(ExeFileName: string): Integer;
const
  PROCESS_TERMINATE = $0001;
var
  ContinueLoop: BOOL;
  FSnapshotHandle: THandle;
  FProcessEntry32: TProcessEntry32;
begin
  Result := 0;
  FSnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  FProcessEntry32.dwSize := SizeOf(FProcessEntry32);
  ContinueLoop := Process32First(FSnapshotHandle, FProcessEntry32);
  while Integer(ContinueLoop) <> 0 do
  begin
    if ((UpperCase(ExtractFileName(FProcessEntry32.szExeFile)) =
      UpperCase(ExeFileName)) or (UpperCase(FProcessEntry32.szExeFile) =
      UpperCase(ExeFileName))) then
      Result := Integer(TerminateProcess(
        OpenProcess(PROCESS_TERMINATE,
        BOOL(0),
        FProcessEntry32.th32ProcessID),
        0));

    ContinueLoop := Process32Next(FSnapshotHandle, FProcessEntry32);
  end;
  CloseHandle(FSnapshotHandle);
end;

 //출처 http://www.delphi3000.com/articles/article_4324.asp?SK=
 //
function isOpen(ExeFileName: string): integer;
const
  PROCESS_TERMINATE = $0001;
var
  ContinueLoop: BOOL;
  FSnapshotHandle: THandle;
  FProcessEntry32: TProcessEntry32;

begin
  Result := 0;
  FSnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  FProcessEntry32.dwSize := SizeOf(FProcessEntry32);
  ContinueLoop := Process32First(FSnapshotHandle, FProcessEntry32);

  while Integer(ContinueLoop) <> 0 do
  begin
    if ((UpperCase(ExtractFileName(FProcessEntry32.szExeFile)) =
      UpperCase(ExeFileName)) or (UpperCase(FProcessEntry32.szExeFile) =
      UpperCase(ExeFileName))) then
    begin
      result := FProcessEntry32.th32ProcessID;
      break;
    end;
    ContinueLoop := Process32Next(FSnapshotHandle, FProcessEntry32);
  end;
  CloseHandle(FSnapshotHandle);
end;

//관리자 권한으로 실행하기
procedure RunAsAdmin(hWnd : Hwnd; aFile : string; aParameters : string);
var
  sei : TShellExecuteInfoA;
begin
  FillChar(sei, SizeOf(sei), 0);
  sei.cbSize := SizeOf(sei);
  sei.Wnd := hWnd;
  sei.fMask := SEE_MASK_FLAG_DDEWAIT or SEE_MASK_FLAG_NO_UI;
  sei.lpVerb := pAnsiChar('runas');
  sei.lpFile := pAnsiChar(aFile);
  sei.lpParameters := PAnsiChar(aParameters);
  sei.nShow := SW_SHOWNORMAL;
  if not ShellExecuteEX(@sei) then
    RaiseLastOSError;
end;

function IsUACActive: Boolean;
var
  Reg: TRegistry;
begin
  Result := FALSE;

  // There's a chance it's active as we're on Vista or Windows 7. Now check the registry
  if CheckWin32Version(6, 0) then
  begin
    Reg := TRegistry.Create;
    try
      Reg.RootKey := HKEY_LOCAL_MACHINE;

      if Reg.OpenKeyReadOnly('SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System') then
      begin
        if (Reg.ValueExists('EnableLUA')) and (Reg.ReadBool('EnableLUA')) then
          Result := TRUE;
      end;
    finally
      FreeAndNil(Reg);
    end;
  end;
end;

//ExecuteFile(Self.Handle, 'Filename', 'Parameters', [eoHide, eoWait, eoElevate]);
function ExecuteFile(Handle: HWND; const Filename, Paramaters: String; Options: TExecuteFileOptions): Integer;
var
  ShellExecuteInfo: TShellExecuteInfo;
  ExitCode: DWORD;
begin
  Result := -1;

  ZeroMemory(@ShellExecuteInfo, SizeOf(ShellExecuteInfo));
  ShellExecuteInfo.cbSize := SizeOf(TShellExecuteInfo);
  ShellExecuteInfo.Wnd := Handle;
  ShellExecuteInfo.fMask := SEE_MASK_NOCLOSEPROCESS;

  if (eoElevate in Options) and (IsUACActive) then
    ShellExecuteInfo.lpVerb := PChar('runas');

  ShellExecuteInfo.lpFile := PChar(Filename);

  if Paramaters <> '' then
    ShellExecuteInfo.lpParameters := PChar(Paramaters);

  // Show or hide the window
  if eoHide in Options then
    ShellExecuteInfo.nShow := SW_HIDE
  else
    ShellExecuteInfo.nShow := SW_SHOWNORMAL;

  if ShellExecuteEx(@ShellExecuteInfo) then
    Result := 0;

  if (Result = 0) and (eoWait in Options) then
  begin
    GetExitCodeProcess(ShellExecuteInfo.hProcess, ExitCode);

    while (ExitCode = STILL_ACTIVE) and
          (not Application.Terminated) do
    begin
      sleep(50);

      GetExitCodeProcess(ShellExecuteInfo.hProcess, ExitCode);
    end;

    Result := ExitCode;
  end;
end;

//Check whether the process is alive
// uses 에 TlHelp32 추가
function IsRunningProcess( const ProcName: String ) : Boolean;
var
  Process32: TProcessEntry32;
  SHandle: THandle;
  Next: Boolean;
begin
  Result:=False;
  Process32.dwSize:=SizeOf(TProcessEntry32);
  SHandle :=CreateToolHelp32Snapshot(TH32CS_SNAPPROCESS, 0 );

  // 프로세스 리스트를 돌면서 매개변수로 받은 이름과 같은 프로세스가 있을 경우 True를 반환하고 루프종료
  if Process32First(SHandle, Process32) then
  begin
    repeat
      Next := Process32Next (SHandle, Process32);

      if AnsiCompareText (Process32.szExeFile, Trim (ProcName)) = 0 then
      begin
        Result:= True;
        break;
      end;
    until not Next;
  end;

  CloseHandle (SHandle);
end;

//프로세스 죽이기 (강제종료) Kill the process (kill)
function KillProcess(const ProcName: String): Boolean;
var
  Process32: TProcessEntry32;
  SHandle: THandle;
  Next: Boolean;
  i: Integer;
begin
  Result:=True;
  Process32.dwSize := SizeOf(TProcessEntry32);
  Process32.th32ProcessID:= 0;
  SHandle :=CreateToolHelp32Snapshot(TH32CS_SNAPPROCESS, 0 );

  // 종료하고자 하는 프로세스가 실행중인지 확인하는 의미와 함께...
  if Process32First(SHandle, Process32) then
  begin
    repeat
      Next:=Process32Next(SHandle, Process32);

      if AnsiCompareText(Process32.szExeFile, Trim(ProcName))= 0 then
        break;
    until not Next;
  end;

  CloseHandle(SHandle);

  // 프로세스가 실행중이라면 Open & Terminate
  if Process32.th32ProcessID<> 0 then
    Result := KillProcessId(Process32.th32ProcessID)
  else
    Result:=False;
end;

function KillProcessId(const AProcId: THandle): Boolean;
var
  hProcess: THandle;
begin
  Result := True;
  hProcess:=OpenProcess(PROCESS_TERMINATE, True, AProcId);

  if hProcess<> 0 then
  begin
    Result := TerminateProcess(hProcess, 0 );
    CloseHandle(hProcess);
  end // if Process32.th32ProcessID<>0 end / / if Process32.th32ProcessID <> 0
  else Result:=False;// 프로세스 열기 실패 / / Process failed to open
end;

function GetConsoleOutput2(const Command : WideString;
                          Output, Errors : TStrings) : Boolean;
var
  Buffer : array[0..2400] of AnsiChar;
  BufferStrOutput : AnsiString;
  BufferStrErrors : AnsiString;
  CreationFlags : DWORD;
  NumberOfBytesRead : DWORD;
  PipeErrorsRead : THandle;
  PipeErrorsWrite : THandle;
  PipeOutputRead : THandle;
  PipeOutputWrite : THandle;
  ProcessInfo : TProcessInformation;
  SecurityAttr : TSecurityAttributes;
  StartupInfo : TStartupInfo;
  tmpWaitR : DWORD;

  procedure AddLine(var AString : AnsiString; ALines : TStrings);
  var
    i : integer;
  begin
    i := pos(#13#10, AString);
    while i > 0 do begin
      ALines.Add(copy(AString,1,i-1));
      Delete(AString,1,i+1);
      i := pos(#13#10, AString);
    end;
  end;

begin
  //Initialisierung ProcessInfo
  FillChar(ProcessInfo, SizeOf(TProcessInformation), 0);

  //Initialisierung SecurityAttr
  FillChar(SecurityAttr, SizeOf(TSecurityAttributes), 0);
  SecurityAttr.nLength := SizeOf(TSecurityAttributes);
  SecurityAttr.bInheritHandle := True;
  SecurityAttr.lpSecurityDescriptor := nil;

  //Pipes erzeugen
  CreatePipe(PipeOutputRead, PipeOutputWrite, @SecurityAttr, 0);
  CreatePipe(PipeErrorsRead, PipeErrorsWrite, @SecurityAttr, 0);

  //Initialisierung StartupInfo
  FillChar(StartupInfo, SizeOf(TStartupInfo), 0);
  StartupInfo.cb := SizeOf(TStartupInfo);
  StartupInfo.hStdInput := 0;
  StartupInfo.hStdOutput := PipeOutputWrite;
  StartupInfo.hStdError := PipeErrorsWrite;
  StartupInfo.wShowWindow := SW_HIDE;
  StartupInfo.dwFlags := STARTF_USESHOWWINDOW or STARTF_USESTDHANDLES;

  CreationFlags := CREATE_DEFAULT_ERROR_MODE or
                   CREATE_NEW_CONSOLE or
                   NORMAL_PRIORITY_CLASS;

  result := CreateProcessW(nil, (PWideChar(Command)),
                   nil,
                   nil,
                   True,
                   CreationFlags,
                   nil,
                   nil,
                   StartupInfo,
                   ProcessInfo);
  if result then begin
    //Write-Pipes schließen
    CloseHandle(PipeOutputWrite);
    CloseHandle(PipeErrorsWrite);

    BufferStrOutput := '';
    BufferStrErrors := '';

    repeat
      tmpWaitR := WaitForSingleObject(ProcessInfo.hProcess, 100);

      NumberOfBytesRead := 0;
      //Ausgabe Read-Pipe auslesen
      if PeekNamedPipe(PipeOutputRead, nil, 0, nil, @NumberOfBytesRead, nil) and (NumberOfBytesRead > 0) then begin
        while ReadFile(PipeOutputRead, Buffer, Length(Buffer)-1, NumberOfBytesRead, nil) do begin
          Buffer[NumberOfBytesRead] := #0;
          OemToAnsi(Buffer, Buffer);
          BufferStrOutput := BufferStrOutput + Buffer;
          AddLine(BufferStrOutput,Output);
          Application.ProcessMessages();
        end;
      end;

      NumberOfBytesRead := 0;
      if PeekNamedPipe(PipeErrorsRead, nil, 0, nil, @NumberOfBytesRead, nil) and (NumberOfBytesRead > 0) then begin
        while ReadFile(PipeErrorsRead, Buffer, Length(Buffer)-1, NumberOfBytesRead, nil) do begin
          Buffer[NumberOfBytesRead] := #0;
          OemToAnsi(Buffer, Buffer);
          BufferStrErrors := BufferStrErrors + Buffer;
          AddLine(BufferStrErrors,Errors);
          Application.ProcessMessages();
        end;
      end;

      Application.ProcessMessages();
    until (tmpWaitR <> WAIT_TIMEOUT);

    if BufferStrOutput <> '' then Output.Add(BufferStrOutput);
    if BufferStrErrors <> '' then Errors.Add(BufferStrErrors);

    CloseHandle(ProcessInfo.hProcess);
    CloseHandle(ProcessInfo.hThread);

    CloseHandle(PipeOutputRead);
    CloseHandle(PipeErrorsRead);
  end else begin
    //Pipes schließen
    CloseHandle(PipeOutputRead);
    CloseHandle(PipeOutputWrite);
    CloseHandle(PipeErrorsRead);
    CloseHandle(PipeErrorsWrite);
  end;
end;

procedure RunPowerShellCommand(Command: string);
var
  PowerShellCmd: string;
begin
  PowerShellCmd := 'powershell.exe -Command ' + Command;

  ShellExecute(0, 'open', 'powershell.exe', PChar('-Command ' + Command), nil, SW_HIDE);
end;

function GetTheParentProcessFileName(): String;
const
  BufferSize = 4096;
var
  HandleSnapShot  : THandle;
  EntryParentProc : TProcessEntry32;
  CurrentProcessId: DWORD;
  HandleParentProc: THandle;
  ParentProcessId : DWORD;
  ParentProcessFound  : Boolean;
  ParentProcPath      : String;

begin
  ParentProcessFound := False;
  HandleSnapShot := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);   //enumerate the process
  if HandleSnapShot <> INVALID_HANDLE_VALUE then
  begin
    EntryParentProc.dwSize := SizeOf(EntryParentProc);
    if Process32First(HandleSnapShot, EntryParentProc) then    //find the first process
    begin
      CurrentProcessId := GetCurrentProcessId(); //get the id of the current process
      repeat
        if EntryParentProc.th32ProcessID = CurrentProcessId then
        begin
          ParentProcessId := EntryParentProc.th32ParentProcessID; //get the id of the parent process
          HandleParentProc := OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ, False, ParentProcessId);
          if HandleParentProc <> 0 then
          begin
              ParentProcessFound := True;
              SetLength(ParentProcPath, BufferSize);
              GetModuleFileNameEx(HandleParentProc, 0, PChar(ParentProcPath),BufferSize);
              ParentProcPath := PChar(ParentProcPath);
              CloseHandle(HandleParentProc);
          end;
          break;
        end;
      until not Process32Next(HandleSnapShot, EntryParentProc);
    end;
    CloseHandle(HandleSnapShot);
  end;

  if ParentProcessFound then
    Result := ParentProcPath
  else
    Result := '';
end;

function ExecuteNetshCommand(const ACommand: string): string;
var
  SEInfo: TShellExecuteInfo;
  ExitCode: DWORD;
begin
  Result := '';
  FillChar(SEInfo, SizeOf(SEInfo), 0);
  SEInfo.cbSize := SizeOf(TShellExecuteInfo);
  SEInfo.fMask := SEE_MASK_NOCLOSEPROCESS or SEE_MASK_FLAG_NO_UI; // UI 없이 실행하고 프로세스 핸들 얻기
  SEInfo.Wnd := Application.Handle;
  SEInfo.lpVerb := 'runas'; // 관리자 권한 요청!!!
  SEInfo.lpFile := 'netsh.exe';
  SEInfo.lpParameters := PChar(ACommand);
  SEInfo.nShow := SW_HIDE; // 창 숨기기

  if ShellExecuteEx(@SEInfo) then
  begin
    // 명령이 완료될 때까지 기다림 (선택 사항, 필요에 따라 조절)
    if SEInfo.hProcess <> 0 then
    begin
      WaitForSingleObject(SEInfo.hProcess, INFINITE);
      // GetExitCodeProcess(SEInfo.hProcess, ExitCode); // 종료 코드 확인 (필요시)
      CloseHandle(SEInfo.hProcess);
      Result := ''; // 성공적으로 실행 요청됨 (netsh 내부의 성공 여부는 별개)
    end
    else
    begin
      // 프로세스 핸들을 얻지 못한 경우 (드문 경우)
      Result := '프로세스 핸들을 얻지 못했습니다.';
    end;
  end
  else
  begin
    // ShellExecuteEx 실패 (예: 사용자가 권한 상승 거부)
    Result := 'netsh 명령 실행에 실패했습니다. 오류 코드: ' + IntToStr(GetLastError);
  end;
end;

function RunConsoleAndGetOutput(const ACommand: string; AOutput : TStrings): Boolean;
var
  Security: TSecurityAttributes;
  ReadPipe, WritePipe: THandle;
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
  Buffer: array [0..255] of AnsiChar;
  BytesRead: DWORD;
  AppRunning: DWORD;
  OutputLines: TStringList;
begin
  OutputLines := TStringList.Create;

  // 보안 속성 설정
  Security.nLength := SizeOf(TSecurityAttributes);
  Security.bInheritHandle := True;
  Security.lpSecurityDescriptor := nil;

  // 파이프 생성
  if not CreatePipe(ReadPipe, WritePipe, @Security, 0) then
    raise Exception.Create('파이프 생성 실패');

  // 시작 정보 설정
  ZeroMemory(@StartupInfo, SizeOf(StartupInfo));
  StartupInfo.cb := SizeOf(StartupInfo);
  StartupInfo.dwFlags := STARTF_USESTDHANDLES or STARTF_USESHOWWINDOW;
  StartupInfo.hStdInput := GetStdHandle(STD_INPUT_HANDLE);
  StartupInfo.hStdOutput := WritePipe;
  StartupInfo.hStdError := WritePipe;
  StartupInfo.wShowWindow := SW_HIDE;

  // 프로세스 실행
  if not CreateProcess(nil, PChar(ACommand), nil, nil, True, CREATE_NO_WINDOW,
    nil, nil, StartupInfo, ProcessInfo) then
  begin
    CloseHandle(ReadPipe);
    CloseHandle(WritePipe);
    OutputLines.Free;
    raise Exception.Create('프로세스 실행 실패');
  end;

  CloseHandle(WritePipe); // 쓰기 파이프 닫기

  // 출력 읽기
  repeat
    BytesRead := 0;
    if ReadFile(ReadPipe, Buffer, SizeOf(Buffer) - 1, BytesRead, nil) and (BytesRead > 0) then
    begin
      Buffer[BytesRead] := #0;
      OutputLines.Text := OutputLines.Text + String(Buffer);
    end;
    GetExitCodeProcess(ProcessInfo.hProcess, AppRunning);
  until (AppRunning <> STILL_ACTIVE) and (BytesRead = 0);

  CloseHandle(ReadPipe);
  CloseHandle(ProcessInfo.hProcess);
  CloseHandle(ProcessInfo.hThread);

  // 줄 단위로 나누기
  OutputLines.Text := Trim(OutputLines.Text);
  OutputLines.LineBreak := sLineBreak;
  AOutput := OutputLines;
end;

end.
