unit UnitFileSearchUtil;

interface

uses Winapi.Windows, classes, SysUtils, Forms;

function GetFindFileList(filemask: string; IncludePath: boolean=True): TStringList;
function WindowsFindFileList(filemask: string; showFiles, showFolders, fullPath: boolean): TStringList;
function GetFileSize(szFile: PChar): Int64;
function FindAllFiles(RootFolder: string; Mask: string = '*.*';
  Recurse: Boolean = True; ExcludeDir: string = ''): TStringList;
function FindAllFiles2(RootFolder: string; Mask: string = '*.*'): TStringList;
function GetFirstFileNameIfExist(foldername, filemask: string): string;
function DeleteFilesFromMatchDir(AExcludeFileDir, AExcludeFileMask, ADeleteFileDir, ADeleteFileMask: string; ASkipDir: string=''): integer;

implementation

//filemask: 'c:\*.txt'
function GetFindFileList(filemask: string; IncludePath: boolean): TStringList;
var
  SR: TSearchRec;
begin
  Result := TStringList.Create;
  FindClose(sr);

  if FindFirst(filemask, faAnyFile, SR) = 0 then
  try
    repeat
      if SR.Attr and faDirectory <> faDirectory then
      begin
        if IncludePath then
          Result.Add(ExtractFilePath(filemask) + SR.Name)
        else
          Result.Add(SR.Name);
      end;
    until FindNext(SR) <> 0;
  finally
    FindClose(SR);
  end;
end;

function WindowsFindFileList(filemask: string; showFiles, showFolders, fullPath: boolean): TStringList;
var
  h: THandle;
  wfa: WIN32_FIND_DATA;
  show: boolean;
 begin
  Result := TStringList.Create;
  h := Winapi.Windows.FindFirstFile(PChar(filemask),wfa);

  if h<>INVALID_HANDLE_VALUE then begin
    repeat
      show := true;
      if ((wfa.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY)>0) and (not showfolders) then show := false;
      if ((wfa.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY)=0) and (not showfiles) then show := false;
      if show then
      begin
        case fullPath of
            false: Result.Add(wfa.cFileName);
            true: Result.Add(ExtractFilePath(filemask)+wfa.cFileName);
        end;
      end;
    until not Winapi.Windows.FindNextFile(h,wfa);
  end;
  Winapi.Windows.FindClose(h);
end;

function GetFileSize(szFile: PChar): Int64;
var
  fFile        : THandle;
  wfd          : TWIN32FINDDATA;
begin
  result := 0;
  if not FileExists(szFile) then
    exit;
  fFile := FindFirstfile(pchar(szFile), wfd);
  if fFile = INVALID_HANDLE_VALUE then
    exit;
  result := (wfd.nFileSizeHigh * (Int64(MAXDWORD) + 1)) + wfd.nFileSizeLow;
  Winapi.windows.FindClose(fFile);
end;

//Result: filename = filesize
function FindAllFiles(RootFolder: string; Mask: string = '*.*';
  Recurse: Boolean = True; ExcludeDir: string = ''): TStringList;
var
  LStr : string;

  procedure _AllFilesInDir(ADir, AMask: string; AResult: TStrings);
  var
    LSR, SR   : TSearchRec;
  begin
    ADir := IncludeTrailingPathDelimiter(ADir);

    if Recurse then
    begin
      if FindFirst(ADir + Mask, faAnyFile, SR) = 0 then
      try
        repeat
          if SR.Attr and faDirectory = faDirectory then
            if (SR.Name <> '.') and (SR.Name <> '..') and (SR.Name <> ExcludeDir) then
              _AllFilesInDir(ADir + SR.Name, AMask, AResult);
        until FindNext(SR) <> 0;
      finally
        FindClose(SR);
      end;
    end;

    if FindFirst(ADir + Mask, faAnyFile, LSR) = 0 then
    try
      repeat
        if LSR.Attr and faDirectory <> faDirectory then
        begin
          LStr := LSR.Name + '=';
          LStr := LStr + IntToStr(GetFileSize(PChar(ADir + LSR.Name)));
          Result.Add(LStr);
        end;
      until FindNext(LSR) <> 0;
    finally
      FindClose(LSR);
    end;
  end;
begin
  Result := TStringList.Create;

  if RootFolder = '' then
    Exit;

  RootFolder := IncludeTrailingPathDelimiter(RootFolder);

  _AllFilesInDir(RootFolder, Mask, Result);
end;

function FindAllFiles2(RootFolder: string; Mask: string = '*.*'): TStringList;
var SR: TSearchRec;

  procedure _AllFilesInDir(ADir, AMask: string; AResult: TStrings);
  begin
    if FindFirst(IncludeTrailingBackSlash(ADir) + Mask, faAnyFile or faDirectory, SR) = 0 then
    begin
      try
        repeat
          if (SR.Attr and faDirectory) = 0 then
            AResult.Add(SR.Name)
          else
          if (SR.Name <> '.') and (SR.Name <> '..') then
            _AllFilesInDir(IncludeTrailingBackSlash(ADir) + SR.Name, AMask, AResult);
        until FindNext(SR) <> 0;
      finally
        FindClose(SR);
      end;
    end;
  end;
begin
  Result := TStringList.Create;

  if RootFolder = '' then
    Exit;

   _AllFilesInDir(RootFolder, Mask, Result);
end;

function GetFirstFileNameIfExist(foldername, filemask: string): string;
var
  LStrList: TStringList;
begin
  Result := '';
  LStrList := FindAllFiles(foldername, filemask);

  if LStrList.Count > 0 then
    Result := LStrList.Names[0];
end;

//AExcludeFileDir: 원본 파일이 있는 Dir(SubDir포함)
//AExcludeFileMask: AExcludeFileDir에서 검색할 Mask
//ADeleteFileDir: 파일을 삭제할 Dir
//ADeleteFileMask: ADeleteFileDir에서 삭제할 Mask
//ASkipDir: AExcludeFileDir의 SubDir에서 검색 Skip할 Dir
//용도 : 원본의 .pas파일을 제외한 나머지 .Dcu 파일을 삭제하기 위함
function DeleteFilesFromMatchDir(AExcludeFileDir, AExcludeFileMask, ADeleteFileDir, ADeleteFileMask: string; ASkipDir: string=''): integer;
var
  LPasList, LDcuList: TStringList;
  LStr: string;
  LIsExist: Boolean;
  i,j: integer;
begin
  try
    LPasList := FindAllFiles(AExcludeFileDir,AExcludeFileMask, True, ASkipDir);
    LDcuList := GetFindFileList(IncludeTrailingPathDelimiter(ADeleteFileDir) + ADeleteFileMask);

    for i := LDcuList.Count - 1 downto 0 do
    begin
      LIsExist := False;

      for j := 0 to LPasList.Count - 1 do
      begin
        LStr := ChangeFileExt(LPasList.Names[j], '.dcu');

        if ExtractFileName(LDcuList.Strings[i]) = LStr then
        begin
          LIsExist := True;
          Break;
        end;
      end;//for j

      if not LIsExist then
        DeleteFile(LDcuList.Strings[i]);
    end;//for i

  finally
    LPasList.Free;
    LDcuList.Free;
  end;
end;

end.
