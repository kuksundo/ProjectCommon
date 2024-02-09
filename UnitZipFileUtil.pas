unit UnitZipFileUtil;

interface

uses classes, SysUtils, System.Zip;

function SizeStr(const ASize: UInt32): string;
function ZipVerStr(const AVersion: UInt16): string;
function DOSFileDateToDateTime(FileDate: UInt32): Extended;
function GetZipFileInfo2StrList(AZipHeader: TZipHeader; AFileName: string; AFileComment: string=''): TStringList;
function IsValidZipFile(const AZipFileName: string): integer;
procedure AddText2Zip(const AZipFileName, AInternalName, AText: string);
procedure AddStream2Zip(const AZipFileName, AInternalName: string; AStream: TStream);
function ExtractFile2StreamByName(const AZipFileName, AInternalName: string): TStringStream;
function ExtractFile2StreamByNameFromOpenedZipFile(AZipFile: TZipFile; const AInternalName: string): TStringStream;
function GetIndexFromOpenedZipFile(AZipFile: TZipFile; const AInternalName: string): integer;
function GetIndexFromZipFile(const AZipFileName, AInternalName: string): integer;

implementation

function SizeStr(const ASize: UInt32): string;
begin
  if ASize < 1024 then
    Result := Format('%d bytes', [ASize])
  else
    Result := Format('%.0n KB', [ASize/1024]);
end;

function ZipVerStr(const AVersion: UInt16): string;
begin
  Result := Format('%.1n', [AVersion/10]);
end;

function DOSFileDateToDateTime(FileDate: UInt32): Extended;
begin
  Result := EncodeDate(LongRec(FileDate).Hi SHR 9 + 1980,
                       LongRec(FileDate).Hi SHR 5 and 15,
                       LongRec(FileDate).Hi and 31) +
            EncodeTime(LongRec(FileDate).Lo SHR 11,
                       LongRec(FileDate).Lo SHR 5 and 63,
                       LongRec(FileDate).Lo and 31 SHL 1, 0);
end;

function GetZipFileInfo2StrList(AZipHeader: TZipHeader; AFileName, AFileComment: string): TStringList;
begin
  Result := TStringList.Create;

  Result.Add('File Name : ' + AFileName);
  Result.Add('=======================================');
  Result.Add('Compression Method : ' + TZipCompressionToString(TZipCompression(AZipHeader.CompressionMethod)));
  Result.Add('Compressed Size : ' + SizeStr(AZipHeader.CompressedSize));
  Result.Add('UnCompressed Size : ' + SizeStr(AZipHeader.UnCompressedSize));
  Result.Add('Modifued Date/Time : ' + DateTimeToStr(DOSFileDateToDateTime(AZipHeader.ModifiedDateTime)));
  Result.Add('CRC : ' + IntToHex(AZipHeader.CRC32, 8));
  Result.Add('Zip Format Version : ' + ZipVerStr(AZipHeader.MadeByVersion));
  Result.Add('Minimum ZIP Version : ' + ZipVerStr(AZipHeader.RequiredVersion));
  Result.Add('Comment : ' + AFileComment);
end;

function IsValidZipFile(const AZipFileName: string): integer;
var
  LZipFile: TZipFile;
  LIsValid: Boolean;
begin
  Result := 0;

  if not FileExists(AZipFileName) then
  begin
    Result := -1;
    exit;
  end;

  LZipFile := TZipFile.Create;
  try
    LZipFile.Open(AZipFileName, zmRead);
//    LIsValid := LZipFile.IsValid()
  finally
    LZipFile.Free;
  end;
end;

procedure AddText2Zip(const AZipFileName, AInternalName, AText: string);
var
  LZip: TZipFile;
  LFileName: string;
  LSrcStream: TStringStream;
begin
  LSrcStream := TStringStream.Create(AText);
  LZip := TZipFile.Create;
  try
    LZip.Open(AZipFileName, zmWrite);
    LFileName := ExtractFileName(AInternalName);
    LZip.Add(LSrcStream, LFileName);
    LZip.Close;
  finally
    LZip.Free;
    LSrcStream.Free;
  end;
end;

procedure AddStream2Zip(const AZipFileName, AInternalName: string; AStream: TStream);
var
  LZip: TZipFile;
  LFileName: string;
begin
  LZip := TZipFile.Create;
  try
    if FileExists(AZipFileName) then
      LZip.Open(AZipFileName, zmReadWrite)
    else
      LZip.Open(AZipFileName, zmWrite);

    LFileName := ExtractFileName(AInternalName);
    LZip.Add(AStream, LFileName);
    LZip.Close;
  finally
    LZip.Free;
  end;
end;

function ExtractFile2StreamByName(const AZipFileName, AInternalName: string): TStringStream;
var
  LZip: TZipFile;
  LocalHeader: TZipHeader;
  LFileName: string;
  i: integer;
begin
  Result := nil;

  if not FileExists(AZipFileName) then
    exit;

  LZip := TZipFile.Create;
  try
    LZip.Open(AZipFileName, zmReadWrite);
    Result := ExtractFile2StreamByNameFromOpenedZipFile(LZip, LFileName);
    LZip.Close;
  finally
    LZip.Free;
  end;
end;

function ExtractFile2StreamByNameFromOpenedZipFile(AZipFile: TZipFile; const AInternalName: string): TStringStream;
var
  LocalHeader: TZipHeader;
  LFileName: string;
  i: integer;
begin
//  Result := TStringStream.Create;
  LFileName := ExtractFileName(AInternalName);
  i := GetIndexFromOpenedZipFile(AZipFile, LFileName);
  AZipFile.Read(i, TStream(Result), LocalHeader);  //Read 함수 내에서 TStream을 생성하여 반환함
end;

function GetIndexFromOpenedZipFile(AZipFile: TZipFile; const AInternalName: string): integer;
var
  i: integer;
  LFileName: string;
begin
  Result := -1;

  for i := 0 to AZipFile.FileCount - 1 do
  begin
    LFileName := AZipFile.FileNames[i];

    if LFileName = AInternalName then
    begin
      Result := i;
      Break;
    end;
  end;
end;

function GetIndexFromZipFile(const AZipFileName, AInternalName: string): integer;
var
  LZip: TZipFile;
begin
  Result := -1;

  if not FileExists(AZipFileName) then
    exit;

  LZip := TZipFile.Create;
  try
    LZip.Open(AZipFileName, zmRead);
    Result := GetIndexFromOpenedZipFile(LZip, AInternalName);
    LZip.Close;
  finally
    LZip.Free;
  end;
end;

end.
