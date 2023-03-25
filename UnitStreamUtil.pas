unit UnitStreamUtil;

interface

uses classes;

procedure WriteString2Stream(const ws: String; stream: TStream);
function ReadStringFromStream(stream: TStream): String;

implementation

procedure WriteString2Stream(const ws: String; stream: TStream);
var
  nChars: LongInt;
begin
  nChars := Length(ws);
  stream.WriteBuffer(nChars, SizeOf(nChars));
  if nChars > 0 then
    stream.WriteBuffer(ws[1], nChars * SizeOf(ws[1]));
end;

function ReadStringFromStream(stream: TStream): String;
var
  nChars: LongInt;
begin
  stream.ReadBuffer(nChars, SizeOf(nChars));
  SetLength(Result, nChars);
  if nChars > 0 then
    stream.ReadBuffer(Result[1], nChars * SizeOf(Result[1]));
end;

end.
