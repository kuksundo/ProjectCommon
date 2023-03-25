unit UnitScreenUtil2;

interface

uses windows, sysutils, Dialogs, MultiMon, Forms, Graphics,
  pngImage, Jpeg;

procedure GetMonitorFromRunningApp(AHandle: THandle);
procedure MakeScreenShot(ASaveDir: string; AImgFormat: integer);

implementation

procedure GetMonitorFromRunningApp(AHandle: THandle);
var
 LMonitor : TMonitor;
 LMonitorInfo : TMonitorInfoEx;
begin
  ZeroMemory(@LMonitorInfo, SizeOf(LMonitorInfo));
  LMonitorInfo.cbSize := SizeOf(LMonitorInfo);
  LMonitor:=Screen.MonitorFromWindow(AHandle); //pass the handle of the form
  if not GetMonitorInfo(LMonitor.Handle, @LMonitorInfo) then
     RaiseLastOSError;
  ShowMessage(Format('The form is in the monitor Index %d - %s', [LMonitor.MonitorNum, LMonitorInfo.szDevice]));
end;

procedure MakeScreenShot(ASaveDir: string; AImgFormat: integer);
var
  dirname, filename: string;
  png: TPNGObject;
  bmp: TBitmap;
  jpg: TJPEGImage;
begin
  DateTimeToString(filename, 'yyyy-mm-dd hh.mm.ss', now());
  dirname := ASaveDir;

  bmp := TBitmap.Create;
  try
    bmp.Width := Screen.Width;
    bmp.Height := Screen.Height;

    BitBlt(bmp.Canvas.Handle, 0, 0, Screen.Width, Screen.Height, GetDC(0), 0, 0, SRCCOPY);

    case AImgFormat of
      1: begin
        PNG := TPNGObject.Create;
        try
          PNG.Assign(bmp);
          PNG.SaveToFile(dirname + filename + '.png');
        finally
          PNG.Free;
        end;
      end;
      2: begin
        jpg := TJPEGImage.Create;
        try
          jpg.Assign(bmp);
          jpg.CompressionQuality := 80;
          jpg.Compress;
          jpg.SaveToFile(dirname + filename + '.jpg');
        finally
          jpg.Free;
        end;
      end;
    end;
  finally
    bmp.Free;
  end;
end;

end.
