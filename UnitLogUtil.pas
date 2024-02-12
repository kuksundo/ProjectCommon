unit UnitLogUtil;

interface

uses System.Classes, System.Sysutils, Vcl.StdCtrls;

procedure DoLogTextFile(const AFileName, ATxt: string);
procedure DoLogTFileStream(const AFileName, ATxt: string);
procedure DoLogMemo(const AMsg: string; AMemo: TMemo=nil);

implementation

const
  MEMO_LOG_MAX_LINE_COUNT = 1000;

procedure DoLogTextFile(const AFileName, ATxt: string);
var
  F: TextFile;
begin
  AssignFile(F, AFileName);
  try
    if FileExists(AFileName) then
      Append(f)
    else
      Rewrite(f);
    WriteLn(f,ATxt);
  finally
    CloseFile(F);
  end;
end;

procedure DoLogTFileStream(const AFileName, ATxt: string);
var
  F: TFileStream;
  b: TBytes;
begin
  if FileExists(AFileName) then
    F := TFileStream.Create(AFileName, fmOpenReadWrite)
  else
    F := TFileStream.Create(AFileName, fmCreate);
  try
    F.Seek(0, soFromEnd);
    b := TEncoding.Default.GetBytes(ATxt + sLineBreak);
    F.Write(b, Length(b));
  finally
    F.Free;
  end;
end;

procedure DoLogMemo(const AMsg: string; AMemo: TMemo=nil);
begin
  if AMemo.Lines.Count > MEMO_LOG_MAX_LINE_COUNT then
    AMemo.Lines.Clear;

  AMemo.Lines.Add(AMsg);
end;

end.
