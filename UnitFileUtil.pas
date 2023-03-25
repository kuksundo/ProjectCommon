unit UnitFileUtil;

interface

uses Winapi.Windows, classes, SysUtils, Forms, Registry, Graphics, CommCtrl, ShellAPI;
//  SynCommons, mORMot;

function FileSize(const AFileName: string): Int64;
function GetImageListSH(SHIL_FLAG: Cardinal): HIMAGELIST;
procedure GetIconFromFile(aFile: string; var aIcon: TIcon; SHIL_FLAG: Cardinal);
function TrunFileSize(const FileName: string): LongInt;
function GetFileAssociation(const AFileName: string): string;
Function SaveData2DateFile(dirname: string; extname: string; data: string; APosition: integer;
                                          AHeader: string=''): Boolean; overload;
Function SaveData2DateFile(dirname: string; extname: string; datalist: TStringList;
                     APosition: integer; AHeader: string=''): Boolean; overload;
Function SaveData2FixedFile(dirname,filename,data: string; APosition: integer;
                            AHeader: string=''): Boolean;
function File_Open_Append(FileName:string;var Data:String;
                    AppendPosition:integer; AHeader: string=''): Boolean;
function File_Open_Append2(FileName:string;var Data:String;
                    AppendPosition:integer; AHeader: string=''): Boolean;
procedure String2File(const AFileName, AData: string);
function StringFromFile(const AFileName: string): string;

implementation

function FileSize(const AFileName: string): Int64;
var
  LInfo: TWin32FileAttributeData;
begin
  Result := -1;

  if not GetFileAttributesEx(PWideChar(AFileName), GetFileExInfoStandard, @LInfo) then
    exit;

  Result := Int64(LInfo.nFileSizeLow) or Int64(LInfo.nFileSizeHigh shl 32);
end;

function GetImageListSH(SHIL_FLAG: Cardinal): HIMAGELIST;
const
  IID_IImageList: TGUID = '{46EB5926-582E-4017-9FDF-E8998DAA0950}';
type
  _SHGetImageList = function(iImageList: integer; const riid: TGUID; var ppv: Pointer): hResult; stdcall;
var
  Handle: THandle;
  SHGetImageList: _SHGetImageList;
begin
  Result := 0;
  Handle := LoadLibrary(shell32);
  if Handle <> S_OK then
  try
    SHGetImageList := GetProcAddress(Handle, PChar(727));
    if Assigned(SHGetImageList) and (Win32Platform = VER_PLATFORM_WIN32_NT) then
      SHGetImageList(SHIL_FLAG, IID_IImageList, Pointer(Result));
  finally
    FreeLibrary(Handle);
  end;
end;

procedure GetIconFromFile(aFile: string; var aIcon: TIcon; SHIL_FLAG: Cardinal);
var
  aImgList: HIMAGELIST;
  SFI: TSHFileInfo;
begin
  SHGetFileInfo(PChar(aFile), FILE_ATTRIBUTE_NORMAL, SFI, SizeOf(TSHFileInfo), SHGFI_ICON or SHGFI_LARGEICON or SHGFI_SHELLICONSIZE or SHGFI_SYSICONINDEX or SHGFI_TYPENAME or SHGFI_DISPLAYNAME);
  if not Assigned(aIcon) then
    aIcon := TIcon.Create;
  aImgList := GetImageListSH(SHIL_FLAG);
  aIcon.Handle := ImageList_GetIcon(aImgList, SFI.iIcon, ILD_NORMAL);
end;

function TrunFileSize(const FileName: string): LongInt;
Var
  SearchRec: TSearchRec;
  sgPath   : String;
  inRetval : Integer;
begin
  sgPath   := ExpandFileName(FileName);
  Try
    inRetval := FindFirst(ExpandFileName(FileName), faAnyFile, SearchRec);
    If inRetval = 0 Then
      Result := SearchRec.Size
    Else Result := -1;
  Finally
    SysUtils.FindClose(SearchRec);
  End;
end;

function GetFileAssociation(const AFileName: string): string;
var
  LFileClass: string;
  LReg: TRegistry;
begin
  Result := '';
  LReg := TRegistry.Create(KEY_EXECUTE);
  try
    LReg.RootKey := HKEY_CLASSES_ROOT;
    LFileClass := '';

    if LReg.OpenKeyReadOnly(ExtractFileExt(AFileName)) then
    begin
      LFileClass := LReg.ReadString('');
      LReg.CloseKey;
    end;

    if LFileClass <> '' then
    begin
      if LReg.OpenKeyReadOnly(LFileClass + '\Shell\Open\Command') then
      begin
        Result := LReg.ReadString('');
        LReg.CloseKey;
      end;
    end;
  finally
    LReg.Free;
  end;
end;

//Directory Name, Extention Name, Data를 화일이름이 현재날짜인 화일에 기록
//화일이 처음 생성된 경우 True를 반환함
Function SaveData2DateFile(dirname: string; extname: string; data: string; APosition: integer;
                          AHeader: string=''): Boolean;
var filename:string;
begin
  Result := False;
  setcurrentdir(ExtractFilePath(Application.Exename));
  if not setcurrentdir(dirname) then
    createdir(dirname);
  setcurrentdir(ExtractFilePath(Application.Exename));
  dirname := IncludeTrailingPathDelimiter(dirname);
  filename := dirname + FormatDatetime('yyyymmdd',date) + '.' + extname;

  if File_Open_Append(filename,data,APosition,AHeader) then
    Result := True;

  //extname := filename;
end;

Function SaveData2DateFile(dirname: string; extname: string; datalist: TStringList;
                              APosition: integer; AHeader: string=''): Boolean;
var
  filename:string;
  i: integer;
  LData: string;
begin
  Result := False;
  setcurrentdir(ExtractFilePath(Application.Exename));
  if not setcurrentdir(dirname) then
    createdir(dirname);
  setcurrentdir(ExtractFilePath(Application.Exename));
  dirname := IncludeTrailingPathDelimiter(dirname);
  filename := dirname + FormatDatetime('yyyymmdd',date) + '.' + extname;

  Result := not FileExists(FileName);

  for i := 0 to DataList.Count - 1 do
  begin
    LData := DataList.Strings[i];
    File_Open_Append(filename, LData,APosition,AHeader);
  end;

  extname := filename;
end;

//화일이 처음 생성된 경우 True를 반환함
Function SaveData2FixedFile(dirname,filename,data: string; APosition: integer;
                            AHeader: string=''): Boolean;
var
  LStr: string;
begin
  Result := False;
  setcurrentdir(ExtractFilePath(Application.Exename));
  if not setcurrentdir(dirname) then
    createdir(dirname);
  setcurrentdir(ExtractFilePath(Application.Exename));
  LStr := ExtractFilePath(filename);

  if LStr = '' then
  begin
    dirname := IncludeTrailingPathDelimiter(dirname);
    filename := dirname + filename;
  end;

  Result := File_Open_Append2(filename,data,APosition,AHeader);
end;

//파일의 AppendPosition에 한 개의 라인을 써 넣는다.
//AppendPosition = soFromBeginning, soFromCurrent, soFromEnd
function FileAppend2(hFile, AppendPosition: Integer; Data: String): Boolean;
var
  BWrite: word;
  Buffer: RawByteString;
begin
  if hFile > 0 then
  begin
    if FileSeek(hFile,0,AppendPosition) <> HFILE_ERROR then
    begin
      try
        Buffer := PChar(Data+#13+#10);
        BWrite:=FileWrite(hFile,Buffer[1],Length(Buffer));
        if BWrite = Sizeof(Data) then
          Result := True
        else
          Result := False;
      finally
      end;
    end;
  end;
end;

//화일을 생성(IsUpdate가 False이고 화일이 존재하지 않을경우)하거나
//기존 화일에 Data를 추가함
//IsUpdate : True = 기존 화일을 삭제하고 재 생성
//화일이 처음 생성된 경우 True를 반환함
function File_Open_Append(FileName:string;var Data:String;
                          AppendPosition:integer; AHeader: string=''): Boolean;
var hFile: integer;
begin
  Result := False;
  SetCurrentDir(ExtractFilePath(Application.exename));
  try
    if FileExists(FileName) then
    begin
        hFile := FileOpen(FileName,fmOpenWrite+fmShareDenyNone);  { Open Source }
    end
    else
    begin
      hFile := FileCreate(FileName);

      if AHeader <> '' then
        FileAppend2(hFile,AppendPosition,AHeader);

      Result := True;
    end;

    FileAppend2(hFile,AppendPosition,data);
  finally
    if hFile > 0 then
      FileClose(hFile);
  end;
end;

function File_Open_Append2(FileName:string;var Data:String;
                    AppendPosition:integer; AHeader: string=''): Boolean;
var hFile: integer;
begin
  Result := False;
  SetCurrentDir(ExtractFilePath(Application.exename));
  try
    if FileExists(FileName) then
    begin
        hFile := FileOpen(FileName,fmOpenWrite+fmShareDenyNone);  { Open Source }
    end
    else
    begin
      hFile := FileCreate(FileName);

      if AHeader <> '' then
        FileAppend2(hFile,AppendPosition,AHeader);

      Result := True;
    end;

    FileAppend2(hFile,AppendPosition,data);
  finally
    if hFile > 0 then
      FileClose(hFile);
  end;
end;

procedure String2File(const AFileName, AData: string);
var
  LStrStream: TStringStream;
begin
  LStrStream := TStringStream.Create;

  try
    LStrStream.WriteString(AData);
    LStrStream.SaveToFile(AFileName);
  finally
    LStrStream.Free;
  end;
end;

function StringFromFile(const AFileName: string): string;
var
  LStrStream: TStringStream;
begin
  Result := '';

  if not FileExists(AFileName) then
    exit;

  LStrStream := TStringStream.Create;

  try
    LStrStream.LoadFromFile(AFileName);
    Result := LStrStream.DataString;
  finally
    LStrStream.Free;
  end;
end;

end.
