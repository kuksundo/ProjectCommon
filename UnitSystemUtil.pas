unit UnitSystemUtil;

interface

uses Classes, Psapi, Windows, tlhelp32, SysUtils, Registry, ShellAPI;

procedure EnumComPorts(const Ports: TStringList);
function NTSetPrivilege(APrivilege: string; AEnabled: Boolean): Boolean;
function IsWindowsAdminAutoLoginEnabled: Boolean;
procedure SetWindowsAdminAutoLogin(const AEnable: Boolean);
function IsWindowsPasswordLessEnabled: Boolean;
procedure SetWindowsPasswordLessEnable(const AEnable: Boolean);
function GetComputerNameStr: string;
function SetComputerNameStr(const ANewName: string): Boolean;

implementation

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

function GetComputerNameStr: string;
var
  Buffer: array[0..MAX_COMPUTERNAME_LENGTH + 1] of char;
  Size: DWORD;
begin
  Result := '';

  Size := Length(Buffer);

  if GetComputerName(Buffer, Size) then
    Result := String(Buffer);
end;

function SetComputerNameStr(const ANewName: string): Boolean;
var
  lpszName: array[0..MAX_COMPUTERNAME_LENGTH + 1] of char;
begin
  StrPCopy(lpszName, ANewName);
  Result := SetComputerName(lpszName);
end;

end.
