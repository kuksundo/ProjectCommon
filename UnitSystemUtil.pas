unit UnitSystemUtil;

interface

uses Classes, Psapi, Windows, tlhelp32, SysUtils, Registry, ShellAPI;

{Ex:
  if (AnsiLowerCase(ExtractFileName(GetTheParentProcessFileName)) <> 'explorer.exe') and
    (AnsiLowerCase(ExtractFileName(GetTheParentProcessFileName)) <> 'cmd.exe') then
  begin
    KillTask((ExtractFileName(GetTheParentProcessFileName)));
    exitprocess(0);
  end;
}
function KillTask(ExeFileName: string): Integer;
function GetTheParentProcessFileName(): String;
procedure EnumComPorts(const Ports: TStringList);
function RunAsAdmin(AWindow: HWND; FileName: string; Parameters: string): Boolean;
function NTSetPrivilege(APrivilege: string; AEnabled: Boolean): Boolean;
function IsWindowsAdminAutoLoginEnabled: Boolean;
procedure SetWindowsAdminAutoLogin(const AEnable: Boolean);
function IsWindowsPasswordLessEnabled: Boolean;
procedure SetWindowsPasswordLessEnable(const AEnable: Boolean);

implementation

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

//장치관리자의 COM1설명 문자 읽어 오기
procedure EnumComPorts(const Ports: TStringList);
var
  nInd:  Integer;
begin  { EnumComPorts }
  with  TRegistry.Create(KEY_READ)  do
  begin
    try
     RootKey := HKEY_LOCAL_MACHINE;
     if OpenKey('hardware\devicemap\serialcomm', False) then
       try
         Ports.BeginUpdate();
         try
           GetValueNames(Ports);
           for  nInd := Ports.Count - 1  downto  0  do
             Ports.Strings[nInd] := ReadString(Ports.Strings[nInd]);
           Ports.Sort()
         finally
           Ports.EndUpdate()
         end { try-finally }
       finally
         CloseKey()
       end { try-finally }
     else
       Ports.Clear()
    finally
     Free()
    end { try-finally }
  end;
end { EnumComPorts };

function RunAsAdmin(AWindow: HWND; FileName: string; Parameters: string): Boolean;
var
  ShellExeInfo: TShellExecuteInfo;
begin
  ZeroMemory(@ShellExeInfo, SizeOf(ShellExeInfo));
  ShellExeInfo.cbSize := SizeOf(TShellExecuteInfo);
  ShellExeInfo.Wnd := AWindow;
  ShellExeInfo.fMask := SEE_MASK_FLAG_DDEWAIT or SEE_MASK_FLAG_NO_UI;
  ShellExeInfo.lpVerb := PChar('runas');
  ShellExeInfo.lpFile := PChar(FileName);
  ShellExeInfo.lpParameters := PChar(Parameters);
  ShellExeInfo.nShow := SW_SHOWNORMAL;
  Result := ShellExecuteEx(@ShellExeInfo);
end;

//사용법: if not NTSetPrivilege('SeBackupPrivilege', True) then exit;
function NTSetPrivilege(APrivilege: string; AEnabled: Boolean): Boolean;
var
  hToken: THandle;
  TokenPriv: TOKEN_PRIVILEGES;
  PrevTokenPriv: TOKEN_PRIVILEGES;
  ReturnLength: Cardinal;
  errval: Cardinal;
begin
  Result := True;
  errval := 0;
  //Only for windows NT/2000/XP and later
  if not (Win32Platform = VER_PLATFORM_WIN32_NT) then exit;

  Result := False;
  //Obtain the processes token
  if OpenProcessToken(GetCurrentProcess(),
    TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY, hToken) then
    try
      //Get the locally unique identifier(LUID)
      if LookupPrivilegeValue(nil, PChar(APrivilege), TokenPriv.Privileges[0].Luid) then
      begin
        TokenPriv.PrivilegeCount := 1; //one privilege to set
        case AEnabled of
          True: TokenPriv.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;
          False: TokenPriv.Privileges[0].Attributes := 0;
        end;

        ReturnLength := 0; //replaces a var parameter
        PrevTokenPriv := TokenPriv;
        //enable or disable the privilege
        if AdjustTokenPrivileges(hToken, False, TokenPriv, SizeOf(PrevTokenPriv), PrevTokenPriv, ReturnLength) then
          Result := True
        else
        begin
          errval := GetLastError;
          Result := errval = 0;
        end;
      end;
    finally
      CloseHandle(hToken);
    end;

    //test the return value of AdjustTokenPrivileges.
    //Result := GetLastError = ERROR_SUCCESS;
    if not Result then
      raise Exception.Create(SysErrorMessage(errval));
end;

function IsWindowsAdminAutoLoginEnabled: Boolean;
var
  Reg: TRegistry;
  AutoAdminLogon: string;
begin
  Result := False;
  Reg := TRegistry.Create(KEY_READ);
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    // Open the Winlogon key in the registry
    if Reg.OpenKeyReadOnly('SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon') then
    begin
      // Check if AutoAdminLogon is set to '1' (enabled)
      if Reg.ValueExists('AutoAdminLogon') then
      begin
        AutoAdminLogon := Reg.ReadString('AutoAdminLogon');
        Result := AutoAdminLogon = '1';
      end;
      Reg.CloseKey;
    end;
  finally
    Reg.Free;
  end;
end;

procedure SetWindowsAdminAutoLogin(const AEnable: Boolean);
var
  Reg: TRegistry;
  AutoAdminLogon, LEnable: string;
begin
  Reg := TRegistry.Create(KEY_WRITE);
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    // Open the Winlogon key in the registry
    if Reg.OpenKey('SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon', True) then
    begin
      if AEnable then
        LEnable := '1'
      else
        LEnable := '0';

      Reg.WriteString('AutoAdminLogon', LEnable);
      Reg.CloseKey;
    end;
  finally
    Reg.Free;
  end;
end;

function IsWindowsPasswordLessEnabled: Boolean;
var
  Reg: TRegistry;
  AutoAdminLogon: string;
begin
  Result := False;
  Reg := TRegistry.Create(KEY_READ);
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;

    if Reg.OpenKeyReadOnly('SOFTWARE\Microsoft\Windows NT\CurrentVersion\PasswordLess\Device') then
    begin
      // Check if DevicePasswordLessBuildVersion is set to '0' (enabled)
      if Reg.ValueExists('DevicePasswordLessBuildVersion') then
      begin
        AutoAdminLogon := Reg.ReadString('DevicePasswordLessBuildVersion');
        Result := AutoAdminLogon = '0';
      end;
      Reg.CloseKey;
    end;
  finally
    Reg.Free;
  end;
end;

procedure SetWindowsPasswordLessEnable(const AEnable: Boolean);
var
  Reg: TRegistry;
  AutoAdminLogon, LEnable: string;
begin
  Reg := TRegistry.Create(KEY_WRITE);
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;

    // Open the Winlogon key in the registry
    if Reg.OpenKey('SOFTWARE\Microsoft\Windows NT\CurrentVersion\PasswordLess\Device', True) then
    begin
      if AEnable then
        LEnable := '1'
      else
        LEnable := '0';

      Reg.WriteString('DevicePasswordLessBuildVersion', LEnable);
      Reg.CloseKey;
    end;
  finally
    Reg.Free;
  end;
end;

end.
