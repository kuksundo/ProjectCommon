unit UnitRegistryUtil;

interface

uses System.SysUtils, Winapi.Windows, Registry, Winapi.Messages;

//Win32 또는 Win64일때 레지스트리 접근 방법이 다름
function CreateRegistryWin32orWin64: TRegistry;
//환경변수 설정(기존 변수를 Overwrite 하므로 주의 필요)
//User : False = System 변수
function SetGlobalEnvironment(const Name, Value: string; const User: Boolean = True): Boolean;
function GetGlobalEnvironment(const Name: string; const User: Boolean = True): string;

implementation

function CreateRegistryWin32orWin64: TRegistry;
Type TTypWin32Or64 = (Bit32,Bit64);
var TypWin32Or64 :TTypWin32Or64;
  Procedure TypeOS(var TypWin32Or64:TTypWin32Or64 ) ;
  begin
    if DirectoryExists('c:\Windows\SysWOW64') then
      TypWin32Or64:=Bit64
    else
      TypWin32Or64:=Bit32;
  end;
begin
  TypeOS(TypWin32Or64);

  case TypWin32Or64 of
    Bit32: Result := TRegistry.Create;
    Bit64: Result := TRegistry.Create(KEY_READ OR KEY_WOW64_64KEY);
    //use if if 64 bit enviroment Windows
  end;
end;

function SetGlobalEnvironment(const Name, Value: string; const User: Boolean = True): Boolean;
const
  REG_MACHINE_LOCATION = 'System\CurrentControlSet\Control\Session Manager\Environment';
  REG_USER_LOCATION = 'Environment';
var
  dwReturnValue: DWORD_PTR;
begin
  with TRegistry.Create do
  try
    LazyWrite := false;

    if User then
    begin
      { User Environment Variable }
      RootKey := HKEY_CURRENT_USER;
      Result := OpenKey(REG_USER_LOCATION, True);
    end else
    begin
      { System Environment Variable }
      RootKey := HKEY_LOCAL_MACHINE;
      Result := OpenKey(REG_MACHINE_LOCATION, True);
    end;

    if not Result then Exit;

    WriteString(Name, Value); { Write Registry for Global Environment }
  finally
    Free;
  end;

  { Update Current Process Environment Variable }
  SetEnvironmentVariable(PChar(Name), PChar(Value));
  { Send Message To All Top Windows for Refresh }
  //SendMessage(HWND_BROADCAST, WM_SETTINGCHANGE, 0, LPARAM(PChar('Environment')));
  SendMessageTimeout(HWND_BROADCAST, WM_SETTINGCHANGE, 0, LPARAM(PChar('Environment')), SMTO_ABORTIFHUNG, 5000, @dwReturnValue);
end;

function GetGlobalEnvironment(const Name: string; const User: Boolean = True): string;
const
  REG_MACHINE_LOCATION = 'System\CurrentControlSet\Control\Session Manager\Environment';
  REG_USER_LOCATION = 'Environment';
begin
  Result := '';

  with TRegistry.Create do
  try
    LazyWrite := false;

    if User then
    begin
      { User Environment Variable }
      RootKey := HKEY_CURRENT_USER;

      if OpenKey(REG_USER_LOCATION, True) then
        Result := ReadString(Name);
    end else
    begin
      { System Environment Variable }
      RootKey := HKEY_LOCAL_MACHINE;

      if OpenKey(REG_MACHINE_LOCATION, True) then
        Result := ReadString(Name);
    end;
  finally
    Free;
  end;
end;

end.
