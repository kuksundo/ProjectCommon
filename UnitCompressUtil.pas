unit UnitCompressUtil;

interface

uses Classes, System.Zip, System.ZLib;

function ZCompressString(aText: string; aCompressionLevel: TZCompressionLevel=zcFastest): string;
function ZDecompressString(aText: string): string;

implementation

function ZCompressString(aText: string; aCompressionLevel: TZCompressionLevel): string;
var
  strInput,
  strOutput: TStringStream;
  Zipper: TZCompressionStream;
begin
  Result := '';
  strInput := TStringStream.Create(aText);
  strOutput := TStringStream.Create;
  try
    Zipper := TZCompressionStream.Create(strOutput, aCompressionLevel, 15);
    try
      Zipper.CopyFrom(strInput, strInput.Size);
    finally
      Zipper.Free;
    end;

    Result := strOutput.DataString;
  finally
    strInput.Free;
    strOutput.Free;
  end;
end;

function ZDecompressString(aText: string): string;
var
  strInput,
  strOutput: TStringStream;
  UnZipper: TZDeCompressionStream;
begin
  Result := '';
  strInput := TStringStream.Create(aText);
  strOutput := TStringStream.Create;
  try
    strInput.Position := 0;

    UnZipper := TZDeCompressionStream.Create(strInput, 15);
    try
      strOutput.CopyFrom(UnZipper, UnZipper.Size);
    finally
      UnZipper.Free;
    end;

    Result := strOutput.DataString;
  finally
    strInput.Free;
    strOutput.Free;
  end;
end;

end.
