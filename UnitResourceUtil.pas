unit UnitResourceUtil;

interface

uses System.SysUtils, Vcl.Graphics;

function GetResourceFromName(AResName: string): string;
//AName : Bitmap File Name
function GetBitmapFromFileName(const AName: string; var ABitmap: TBitmap): Boolean;

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

end.
