unit UnitRegistryUtil;

interface

uses System.SysUtils, Winapi.Windows, Registry, Winapi.Messages, System.Classes,
  Math, mormot.core.collections, mormot.core.variants;

type
  TRegistryHelper = class helper for TRegistry
  public
    function ReadMultiSz(const AName: string; var AStrings: TStrings): Boolean;
    function WriteMultiSz(const AName: string; const AStrings: TStrings): Boolean;
    function GetValues2Json(const AKeyPath: string): string;
    function GetKeyNValues2JsonAry(const AKeyPath: string): string;
  end;

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

{ TRegistryHelper }

function TRegistryHelper.GetKeyNValues2JsonAry(const AKeyPath: string): string;
var
  LDict: IDocDict;
  LList: IDocList;
  LReg: TRegistry;
  LSubKeys: TStringList;
  i: integer;
  LKeyPath: string;
begin
  Result := '';
  LList := DocList('[]');
  LDict := DocDict('{}');

  LReg := TRegistry.Create(KEY_READ);
  try
    if LReg.OpenKey(AKeyPath, False) then
    begin
      LReg.GetKeyNames(LSubKeys);
      LReg.CloseKey;

      for i := 0 to LSubKeys.Count - 1 do
      begin
        LKeyPath := AKeyPath + '\' + LSubKeys.Strings[I];

        if LReg.OpenKey(LKeyPath, False) then
        begin
          if LReg.ValueExists('NetCfgInstanceId') then
          begin

          end;
        end;
      end;
    end;
  finally
    LSubKeys.Free;
    LReg.Free;
  end;
end;

function TRegistryHelper.GetValues2Json(const AKeyPath: string): string;
var
  LDict: IDocDict;
//  LReg: TRegistry;
  LValueNames: TStringList;
  i: integer;
  LStr: string;
begin
  Result := '';
  LDict := DocDict('{}');

//  LReg := TRegistry.Create(KEY_READ);
  LValueNames := TStringList.Create;
  try
    CloseKey();

    if OpenKey(AKeyPath, False) then
    begin
      GetValueNames(LValueNames);

      for i := 0 to LValueNames.Count - 1 do
      begin
        LStr := LValueNames.Strings[i];

        if ValueExists(LStr) then
        begin
//          LDict.S['Name'] := LStr;
          LDict.S[LStr] := GetDataAsString(LStr);
        end;
      end;//for i

      Result := Utf8ToString(LDict.Json);
    end;
  finally
    LValueNames.Free;
//    LReg.Free;
  end;
end;

function TRegistryHelper.ReadMultiSz(const AName: string;
  var AStrings: TStrings): Boolean;
var
  LSizeInByte: integer;
  LBuffer: array of WChar;
  LWCharsInBuffer: integer;
  Lz: integer;
  LStr: string;
begin
  LSizeInByte := GetDataSize(AName);

  if LSizeInByte > 0 then
  begin
    SetLength(LBuffer, Floor(LSizeInByte / SizeOf(WChar)));
    LWCharsInBuffer := Floor(ReadBinaryData(AName, LBuffer[0], LSizeInByte) / SizeOf(WChar));
    LStr := '';

    for Lz := 0 to LWCharsInBuffer do
    begin
      if LBuffer[Lz] <> #0 then
      begin
        LStr := LStr + LBuffer[Lz];
      end
      else
      begin
        if LStr <> '' then
        begin
          AStrings.Append(LStr);
          LStr := '';
        end;
      end;
    end;//for
    Result := True;
  end
  else
    Result := False;
end;

function TRegistryHelper.WriteMultiSz(const AName: string;
  const AStrings: TStrings): Boolean;
var
  LContent: string;
  i: integer;
begin
  LContent := '';

  for i := 0 to Pred(AStrings.Count) do
    LContent := LContent + AStrings.Strings[i] + #0;

  LContent := LContent + #0;
  Result := RegSetValueEx(CurrentKey, PChar(AName), 0, REG_MULTI_SZ,
                        Pointer(LContent), Length(LContent) * SizeOf(Char)) = 0;
end;

end.
