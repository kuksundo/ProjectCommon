unit UnitAddSystem.SysUtils_XE7;

interface

uses System.SysUtils, System.SysConst, System.Types;

type
  TArrayInteger = array of integer;

function StrToUInt64(const S: string): UInt64; overload;
function StrToUInt64Def(const S: string; const Default: UInt64): UInt64; overload;
function TryStrToUInt64(const S: string; out Value: UInt64): Boolean; overload;
//XE7의 Insert 함수 대체
procedure InsertX(const S: string; var AAry: TStringDynArray; const AIndex: integer);

implementation

procedure ConvertErrorFmt(ResString: PResStringRec; const Args: array of const); local;
begin
  raise EConvertError.CreateResFmt(ResString, Args);
end;

function StrToUInt64(const S: string): UInt64;
var
  E: Integer;
begin
  Val(S, Result, E);
  if E <> 0 then ConvertErrorFmt(@System.SysConst.SInvalidInteger, [S]);
end;

function StrToUInt64Def(const S: string; const Default: UInt64): UInt64;
var
  E: Integer;
begin
  Val(S, Result, E);
  if E <> 0 then Result := Default;
end;

function TryStrToUInt64(const S: string; out Value: UInt64): Boolean;
var
  E: Integer;
begin
  Val(S, Value, E);
  Result := E = 0;
end;

procedure InsertX(const S: string; var AAry: TStringDynArray; const AIndex: integer);
var
  LLength: integer;
  LTail: integer;
begin
  LLength := Length(AAry);
  SetLength(AAry, LLength + 1);
  LTail := LLength - AIndex;

  if LTail > 0 then
    Move(AAry[AIndex], AAry[AIndex + 1], SizeOf(S) * LTail);

  AAry[AIndex] := S;
end;

end.
