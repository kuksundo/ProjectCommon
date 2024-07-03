unit UnitStringUtil;

interface

uses Windows, sysutils, classes, Vcl.Forms, shellapi, Vcl.Graphics, math, MMSystem,
    JclStringConversions, TlHelp32, StrUtils, Comobj;

const
  OneKB = 1024;
  OneMB = OneKB * OneKB;
  OneGB = OneKB * OneMB;
  OneTB = Int64(OneKB) * OneGB;
  B36 : PChar = ('0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ');

type
  TByteStringFormat = (bsfDefault, bsfBytes, bsfKB, bsfMB, bsfGB, bsfTB);

function StrIsNumeric(s: string): Boolean;
function strToken(var S: String; Seperator: Char): String;
function strTokenRev(var S: String; Seperator: Char): String;
function ExtractText(const Str: string; const Delim1, Delim2: string): string;
function strTokenCount(S: String; Seperator: Char): Integer;
function GetstrTokenNth(S: string; seperator: Char; Nth: integer): string;
function NextPos2(SearchStr, Str : String; Position : integer) : integer;
function PosRev(SubStr,s : string; IgnoreCase : boolean = false) : integer;
function ExtractRelativePathBaseApplication(AApplicationPath, AFileNameWithPath: string): string;
function InsertSymbols(s: string; c: Char; Position: Integer = 1): string;
function AddThousandSeparator(S: string; Chr: Char=','): string;
function IsValidGUID(const AGUID: string): boolean;
function StringToCharSet(const AStr: string): TSysCharSet;
function CharSetToString(const AChars: TSysCharSet): string;
function CharSetToInt(const AChars: TSysCharSet): integer;
function InsertSeperator(var AStr: string; ASep: String = '-'): string;
function DeleteSeperator(var AStr: string): string;
function ArrayToString(const AArray: array of char): string;
function GetCharFromVirtualKey(AKey: Word): string;
procedure TrimLeftChar(var S: String; Seperator: Char);
procedure TrimRightChar(var S: String; Seperator: Char);
procedure TrimLeftRightChar(var S: String; Seperator: Char);
function replaceString(str,s1,s2:string;casesensitive:boolean=false):string;
procedure TrimRightCharPos(var S: String; Seperator: Char);
function RemoveSpaceBetweenStrings(const AStr: string): string;
//대문자 단위로 문자를 반환함
function StrTokenUpcase(var S: String): string;
function PosUpcase(const S: String): integer;
function InsertCharAtUpcase(const S: string; Seperator: Char): string;

function NewGUID(const ARemoveBrace: Boolean=False; const ARemoveHypen: Boolean=False): string;
function FormatByteString(Bytes: UInt64; Format: TByteStringFormat = bsfDefault): string;
function IntToDot3Digit(AInt: integer): string;

function HexToInt(HexStr : string) : Int64;
function Real2Str(Number:real;Decimals:byte):string;
function AtoX_Int(Ch : Char): Integer;
function AtoX(Ch : Char): Byte;
function Str2Hex_Byte(szStr: string): Byte;
function Str2Hex_Int(szStr: string): integer;

function PathRelativePathTo(pszPath: PChar; pszFrom: PChar; dwAttrFrom: DWORD;
  pszTo: PChar; dwAtrTo: DWORD): LongBool; stdcall; external 'shlwapi.dll' name 'PathRelativePathToW';
function PathCanonicalize(lpszDst: PChar; lpszSrc: PChar): LongBool; stdcall;
  external 'shlwapi.dll' name 'PathCanonicalizeW';
function AbsToRel(const AbsPath, BasePath: string): string;
function RelToAbs(const RelPath, BasePath: string): string;
function pjhStrPCopy(const Source: AnsiString; Dest: PAnsiChar): PAnsiChar;
function IntToBase(iValue: integer; Base: byte; Digits: byte): string;
function ArrOfByte2Str(const Arr: array of byte): string;
function MemoryStream2Str(AMS: TMemoryStream): string;
function Color2Str(AColor: TColor): string;//Result is HTML Color
function Str2Color(AHtmlColor: string): TColor;

implementation

function StrIsNumeric(s: string): Boolean;
var
  iValue: Int64;
begin
  Result := TryStrToInt64(s, iValue);
end;

function strToken(var S: String; Seperator: Char): String;
var
  I               : Word;
begin
  I:=Pos(Seperator,S);
  if I<>0 then
  begin
    Result:=System.Copy(S,1,I-1);
    System.Delete(S,1,I);
  end else
  begin
    Result:=S;
    S:='';
  end;
end;

function strTokenRev(var S: String; Seperator: Char): String;
var
  I               : Word;
begin
  I:=PosRev(Seperator,S);
  if I<>0 then
  begin
    Result:=System.Copy(S,I+1,Length(S));
    System.Delete(S,I,Length(S));
  end else
  begin
    Result:=S;
    S:='';
  end;
end;

function ExtractText(const Str: string; const Delim1, Delim2: string): string;
var
  pos1, pos2: integer;
begin
  result := '';
  pos1 := Pos(Delim1, Str);
  if pos1 > 0 then begin
    pos2 := PosEx(Delim2, Str, pos1+1);
    if pos2 > 0 then
      result := Copy(Str, pos1 + 1, pos2 - pos1 - 1);
  end;
end;

function strTokenCount(S: String; Seperator: Char): Integer;
begin
  Result:=0;
  while S<>'' do begin
    StrToken(S,Seperator);
    Inc(Result);
  end;
end;

function GetstrTokenNth(S: string; seperator: Char; Nth: integer): string;
var
  i: integer;
begin
  Result:='';
  for i := 1 to Nth do
  begin
    Result := StrToken(S,Seperator);
  end;
end;

//Position: 이 위치 이후부터 맨 처음에 나오는 SearchStr의 위치를 반환함
//없으면 0을 반환함
function NextPos2(SearchStr, Str : String; Position : integer) : integer;
begin
  delete(Str, 1, Position-1);
  Result := pos(SearchStr, upperCase(Str));
  If Result = 0 then exit;
  If (Length(Str) > 0) and (Length(SearchStr) > 0) then
    Result := Result + Position - 1;
end;

function PosRev(SubStr,s : string; IgnoreCase : boolean = false) : integer;
var i : integer;

   function IsMatch : boolean;
   var j : integer;
   begin
     Result := false;
     for j := 2 to Length(SubStr) do if SubStr[j]<>s[i+(j-1)] then exit;
     Result := true;
   end;

var l : integer;
begin
  Result := 0;
  if IgnoreCase then
  begin
    s := UpperCase(s);
    SubStr := UpperCase(SubStr);
  end;
  l := Length(SubStr);
  if l=0 then exit;
  for i := Length(s) downto 1 do
  begin
    if s[i]=SubStr[1] then
    begin
      if l=1 then
      begin
        Result := i;
        exit;
      end else
      begin
        if IsMatch then
        begin
          Result := i;exit;
        end;
      end;
    end;
  end;
end;

function ExtractRelativePathBaseApplication(AApplicationPath, AFileNameWithPath: string): string;
begin
  AApplicationPath := IncludeTrailingBackslash(AApplicationPath);

  Result := IncludeTrailingBackslash(ExtractRelativePath(
                      ExtractFilePath(AApplicationPath),
                      ExtractFilePath(AFileNameWithPath))) +
                      ExtractFileName(AFileNameWithPath);

  if Result = '\' then
    Result := '.\'
  else
  if Pos('.\', Result) = 0 then
    Result := '.\' + Result;
end;

function InsertSymbols(s: string; c: Char; Position: Integer = 1): string;
begin
  Result := Copy(s, 1, Position) + c + Copy(s, Position + 1, Length(s) - Position);
end;

//str에 있는 s1을 s2로 바꾼다.
//casesensitive = True이면 대소문자를 구분한다.
//예:replace('We know what we want','we','I',false) = 'I Know what I want'
function replaceString(str,s1,s2:string;casesensitive:boolean):string;
var i:integer;
    s,t:string;
begin
  s:='';
  t:=str;

  repeat
    if casesensitive then
      i:=pos(s1,t)
    else
      i:=pos(lowercase(s1),lowercase(t));

    if i>0 then
    begin
      s:=s+Copy(t,1,i-1)+s2;
      t:=Copy(t,i+Length(s1),MaxInt);
    end
    else s:=s+t;
  until i<=0;
  result:=s;
end;

function NewGUID(const ARemoveBrace: Boolean; const ARemoveHypen: Boolean): string;
var
  Guid: TGUID;
begin
  CreateGUID(Guid);
  Result := GUIDToString(Guid);

  if ARemoveBrace then
  begin
    Result := Result.Replace('{', '');
    Result := Result.Replace('}', '');
  end;

  if ARemoveHypen then
  begin
    Result := Result.Replace('-', '');
  end;

end;

function AddThousandSeparator(S: string; Chr: Char): string;
var
  I: Integer;
begin
  Result := S;
  I := Length(S) - 2;
  while I > 1 do
  begin
    Insert(Chr, Result, I);
    I := I - 3;
  end;
end;

function IsValidGUID(const AGUID: string): boolean;
var
  Lres: HResult;
  lg: TGuid;
begin
  Result := True;
  try

  except
    on E: Exception do
      Result := False;
  end;

  if Result then
  begin
    try
      OleCheck(Lres);
    except
      on E: Exception do
        Result := False;
    end;
  end;
end;

function StringToCharSet(const AStr: string): TSysCharSet;
var
  CP: PAnsiChar;
  LStr: AnsiString;
begin
  Result := [];

  if AStr = '' then
    exit;

  LStr := AStr;
  CP := PAnsiChar(LStr);

  while CP^ <> #0 do
  begin
    Include(Result, CP^);
    Inc(CP);
  end;
end;

function CharSetToString(const AChars: TSysCharSet): string;
var
  i: integer;
begin
  Result := '';
  for i := 0 to 255 do
    if Chr(i) in AChars then
      Result := Result + Chr(i);
end;

function CharSetToInt(const AChars: TSysCharSet): integer;
var
  i: integer;
begin
  Result := 0;
  for i := 0 to 255 do
    if Chr(i) in AChars then
      Result := Result + i;
end;

function InsertSeperator(var AStr: string; ASep: String = '-'): string;
begin
  // Insert spaces in the release code string for easier reading
  System.Insert(ASep, AStr, 13);
  System.Insert(ASep, AStr, 09);
  System.Insert(ASep, AStr, 05);

  Result := AStr;
end;

function DeleteSeperator(var AStr: string): string;
begin
  // Remove spaces from the Release code
  while pos(' ', AStr) > 0 do
    System.Delete(AStr, pos(' ', AStr), 1);

  // Remove '-' from the Release code
  while pos('-', AStr) > 0 do
    System.Delete(AStr, pos('-', AStr), 1);

  Result := AStr;
end;

function ArrayToString(const AArray: array of char): string;
begin
  if Length(AArray) > 0 then
  begin
    Result := string(AArray);
//    SetString(Result, PChar(@AArray[0]), Length(AArray));
  end
  else
    Result := '';
end;

function GetCharFromVirtualKey(AKey: Word): string;
var
  LKBDState: TKeyBoardState;
  LAscii: integer;
begin
  GetKeyboardState(LKBDState);

  SetLength(Result,2);

  LAscii := ToAscii(AKey, MapVirtualKey(Akey,0), LKBDState, @Result[1], 0);

  case LAscii of
    0: Result := '';
    1: SetLength(Result, 1);
    2: ;
    else
      Result := '';
  end;
end;

procedure TrimLeftChar(var S: String; Seperator: Char);
begin
  if S <> '' then
    if S[1] = Seperator then
      System.Delete(S,1,1);
end;

procedure TrimRightChar(var S: String; Seperator: Char);
var
  LLen: integer;
begin
  if S = '' then
    exit;

  LLen := Length(S);

  if S[LLen] = Seperator then
    S := System.Copy(S,1,LLen-1);
end;

procedure TrimLeftRightChar(var S: String; Seperator: Char);
begin
  TrimLeftChar(S, Seperator);
  TrimRightChar(S, Seperator);
end;

function FormatByteString(Bytes: UInt64; Format: TByteStringFormat = bsfDefault): string;
begin
  if Format = bsfDefault then begin
    if Bytes < OneKB then begin
      Format := bsfBytes;
    end
    else if Bytes < OneMB then begin
      Format := bsfKB;
    end
    else if Bytes < OneGB then begin
      Format := bsfMB;
    end
    else if Bytes < OneTB then begin
      Format := bsfGB;
    end
    else begin
      Format := bsfTB;
    end;
  end;

  case Format of
  bsfBytes:
    Result := SysUtils.Format('%d bytes', [Bytes]);
  bsfKB:
    Result := SysUtils.Format('%.1n KB', [Bytes / OneKB]);
  bsfMB:
    Result := SysUtils.Format('%.1n MB', [Bytes / OneMB]);
  bsfGB:
    Result := SysUtils.Format('%.1n GB', [Bytes / OneGB]);
  bsfTB:
    Result := SysUtils.Format('%.1n TB', [Bytes / OneTB]);
  end;
end;

procedure TrimRightCharPos(var S: String; Seperator: Char);
var
  LPos: integer;
begin
  if S = '' then
    exit;

  LPos := PosRev(Seperator, S);

  if LPos > 0 then
    S := System.Copy(S,1,LPos-1);
end;

function RemoveSpaceBetweenStrings(const AStr: string): string;
begin
  Result := replaceString(AStr, ' ', '');
end;

function StrTokenUpcase(var S: String): string;
var
  i: integer;
begin
  i := PosUpcase(S);

  if i > 0 then
  begin
    Result:=System.Copy(S,1,I-1);
    System.Delete(S,1,I);
  end else
  begin
    Result:=S;
    S:='';
  end;
end;

function PosUpcase(const S: String): integer;
var
  i: integer;
begin
  Result := 0;

  for i := 1 to Length(s) do
  begin
    if S[i] = UpCase(S[i]) then
    begin
      Result := i;
      break;
    end;
  end;
end;

function InsertCharAtUpcase(const S: string; Seperator: Char): string;
var
  LStr, LStr2: string;
begin
  Result := '';
  LStr := S;

  while True do
  begin
    LStr2 := StrTokenUpcase(LStr);

    if LStr2 = '' then
      break;

    Result := Result + LStr2 + Seperator;
  end;
end;

function IntToDot3Digit(AInt: integer): string;
//const LFormat : TFormatSettings = (DecimalSeparator: '.');
begin
  //AInt = 1230;
//  Result := Format('v%4.1f', [AInt/100.0], LFormat); //V12.3 으로 출력 됨
//  Result := FormatFloat('v##.#', AInt/100.0, LFormat); //V12.3 으로 출력 됨
end;

function HexToInt(HexStr : string) : Int64;
var RetVar : Int64;
    i : byte;
begin
  HexStr := UpperCase(HexStr);
  if HexStr[length(HexStr)] = 'H' then
    Delete(HexStr,length(HexStr),1);
  RetVar := 0;

  for i := 1 to length(HexStr) do
  begin
    RetVar := RetVar shl 4;
    if HexStr[i] in ['0'..'9'] then
      RetVar := RetVar + (byte(HexStr[i]) - 48)
    else
      if HexStr[i] in ['A'..'F'] then
        RetVar := RetVar + (byte(HexStr[i]) - 55)
      else begin
        Retvar := 0;
        break;
      end;
  end;

  Result := RetVar;
end;

function Real2Str(Number:real;Decimals:byte):string;
var Temp : string;
begin
    Str(Number:20:Decimals,Temp);
    repeat
       If copy(Temp,1,1)=' ' then delete(Temp,1,1);
    until copy(temp,1,1)<>' ';
    If Decimals=255 {Floating} then begin
       While Temp[1]='0' do Delete(Temp,1,1);
       If Temp[Length(temp)]='.' then Delete(temp,Length(temp),1);
    end;
    Result:= Temp;
end;

// Char를 Integer값으로 변환한다..
function AtoX_Int(Ch : Char): Integer;
var
  Check: Integer;
begin
  Check := Integer(Ch);

  if(Check >= Integer('0')) and (Check <= Integer('9')) then
  begin
    Result := Check-Integer('0');
    Exit;
  end
  else
  begin
    Result := Check-Integer('A')+Integer(10);
    Exit;
  end;
end;

// Char를 Byte값으로 변환한다..
function AtoX(Ch : Char): Byte;
var
  Check: Byte;
begin
  Check := Byte(Ch);

  if(Check >= Byte('0')) and (Check <= Byte('9')) then
  begin
    Result := Check-Byte('0');
    Exit;
  end
  else
  begin
    Result := Check-Byte('A')+Byte(10);
    Exit;
  end;
end;

//----------------------------------------------------------------------------------
// String을 Hex값으로 바꾼다.(Byte 단위 계산임)
function Str2Hex_Byte(szStr: string): Byte;
begin
  szStr := UpperCase(szStr);
  Result := ((AtoX(szStr[1]) shl 4)  or (AtoX(szStr[2])));
end;

// String을 Hex값으로 바꾼다.(Integer 단위 계산임)
function Str2Hex_Int(szStr: string): integer;
begin
  szStr := UpperCase(szStr);
  Result := ((AtoX_Int(szStr[1]) shl 12) or (AtoX_Int(szStr[2]) shl 8) or
              (AtoX_Int(szStr[3]) shl 4)  or (AtoX_Int(szStr[4])));
end;

function AbsToRel(const AbsPath, BasePath: string): string;
var
  Path: array[0..MAX_PATH-1] of char;
begin
  PathRelativePathTo(@Path[0], PChar(BasePath), FILE_ATTRIBUTE_DIRECTORY, PChar(AbsPath), 0);
  result := Path;
end;

function RelToAbs(const RelPath, BasePath: string): string;
var
  Dst: array[0..MAX_PATH-1] of char;
begin
  PathCanonicalize(@Dst[0], PChar(IncludeTrailingBackslash(BasePath) + RelPath));
  result := Dst;
end;

function pjhStrPCopy(const Source: AnsiString; Dest: PAnsiChar): PAnsiChar;
begin
  Move(PAnsiChar(Source)^, Dest^, Length(Source) + 1); //+1 for the 0 char
  Result := Dest;
end;

function IntToBase(iValue: integer; Base: byte; Digits: byte): string;
begin
  result := '';
  repeat
    result := B36[iValue MOD BASE]+result;
    iValue := iValue DIV Base;
  until (iValue DIV Base = 0);

  result := B36[iValue MOD BASE]+result;

  while length(Result) < Digits do
    Result := '0' + Result;
end;

function ArrOfByte2Str(const Arr: array of byte): string;
begin
  SetString(Result, PChar(@Arr[0]), Length(Arr));
//  SetString(Result, PChar(@Arr[0]), Length(Arr) div SizeOf(PChar^));
end;

function MemoryStream2Str(AMS: TMemoryStream): string;
begin
  SetString(Result, PChar(AMS.Memory), AMS.Size div SizeOf(Char));
end;

function Color2Str(AColor: TColor): string;//Result is HTML Color
var
  r,g,b: word;
begin
  r := GetRValue(AColor);
  g := GetGValue(AColor);
  b := GetBValue(AColor);

  Result := '#' + IntToHex(r,2) + IntToHex(g,2) + IntToHex(b,2);
end;

function Str2Color(AHtmlColor: string): TColor;
var
  s: string;
begin
  s := AHtmlColor;

  if not (Pos('#',s) = 1) then
    s := '#' + s;

  Result := StrToInt64('$100' + Copy(s, Pos('#',s)+5,2) +
    Copy(s, Pos('#',s)+3, 2) + Copy(s, Pos('#', s)+1,2));
end;

end.

