unit UnitZipFileUtil;

interface

uses classes, SysUtils, System.Zip;

function SizeStr(const ASize: UInt32): string;
function ZipVerStr(const AVersion: UInt16): string;
function DOSFileDateToDateTime(FileDate: UInt32): Extended;
function GetZipFileInfo2StrList(AZipHeader: TZipHeader; AFileName: string; AFileComment: string=''): TStringList;

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

end.
