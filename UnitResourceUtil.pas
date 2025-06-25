unit UnitResourceUtil;

interface

uses Windows, System.SysUtils, Vcl.Graphics, Classes;

function GetResourceFromName(AResName: string): string;
//AName : Bitmap File Name
function GetBitmapFromFileName(const AName: string; var ABitmap: TBitmap): Boolean;
function ExtractResourceToFile(const AResName, AFileName: string): Boolean;

implementation

function GetResourceFromName(AResName: string): string;
//var LResStream: TResourceStream;
begin
//  LResStream := TResourceStream.Create(hInstance, AResName, RT_RCDATA);
//  try
//    LResStream.Position := 0;
//
//  finally
//    LResStream.Free;
//  end;
end;

function GetBitmapFromFileName(const AName: string; var ABitmap: TBitmap): Boolean;
begin
  Result := FileExists(AName);

  if Result then
  begin
    ABitmap.LoadFromFile(AName);
  end;
end;

function ExtractResourceToFile(const AResName, AFileName: string): Boolean;
var
  ResStream: TResourceStream;
begin
  try
    ResStream := TResourceStream.Create(HInstance, AResName, RT_RCDATA);
    try
      ResStream.SaveToFile(AFileName);
      Result := True;
    finally
      ResStream.Free;
    end;
  except
    Result := False;
  end;
end;

end.
