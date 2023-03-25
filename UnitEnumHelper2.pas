unit UnitEnumHelper2;

interface

uses System.SysUtils, System.TypInfo, System.Rtti, Generics.Collections, Math;

type
  TJHEnumeration<T> = class
  strict private
    class function TypeInfo: PTypeInfo; inline; static;
    class function TypeData: PTypeData; inline; static;
  public
    class function IsEnumeration : Boolean; static;
    class function ToOrdinal(Enum: T): integer; inline; static;
    class function FromOrdinal(Value: integer): T; inline; static;
    class function MinValue: integer; inline; static;
    class function MaxValue: integer; inline; static;
    class function InRange(Value: integer): Boolean; inline; static;
    class function EnsureRange(Value: integer): integer; inline; static;
  end;

  TEnumHelp<TEnum> = record
  type
    ETEnumHelpError = class(Exception);
    class function Cast(const Value: Integer): TEnum; static;
  end;

  function EnumNameToTValue(EnumType: PTypeInfo; Name: string): TValue;
  function EnumOrdValueToTValue(EnumType: PTypeInfo; AOrdValue: Integer): TValue;

implementation

function EnumNameToTValue(EnumType: PTypeInfo; Name: string): TValue;
var
  V: integer;
begin
  V:= GetEnumValue(EnumType, Name);
  TValue.Make(V, EnumType, Result);
end;

function EnumOrdValueToTValue(EnumType: PTypeInfo; AOrdValue: Integer): TValue;
var
  LEnumName: string;
begin
  if AOrdValue = -1 then
    AOrdValue := 0;

  LEnumName := System.TypInfo.GetEnumName(EnumType, AOrdValue);
  Result := EnumNameToTValue(EnumType, LEnumName);
end;

{ TEnumeration<T> }

class function TJHEnumeration<T>.EnsureRange(Value: integer): integer;
var
  ptd: PTypeData;
begin
  Assert(IsEnumeration);
  ptd := TypeData;
  Result := Math.EnsureRange(Value, ptd.MinValue, ptd.MaxValue);
end;

class function TJHEnumeration<T>.FromOrdinal(Value: integer): T;
begin
  Assert(IsEnumeration);
  Assert(InRange(Value));
  Assert(SizeOf(Result) <= SizeOf(Value));
  Move(Value, Result, SizeOf(Value));
end;

class function TJHEnumeration<T>.InRange(Value: integer): Boolean;
var
  ptd: PTypeData;
begin
  Assert(IsEnumeration);
  ptd := TypeData;
  Result := Math.InRange(Value, ptd.MinValue, ptd.MaxValue);
end;

class function TJHEnumeration<T>.IsEnumeration: Boolean;
begin
  Result := TypeInfo.Kind = tkEnumeration;
end;

class function TJHEnumeration<T>.MaxValue: integer;
begin
  Assert(IsEnumeration);
  Result := TypeData.MaxValue;
end;

class function TJHEnumeration<T>.MinValue: integer;
begin
  Assert(IsEnumeration);
  Result := TypeData.MinValue;
end;

class function TJHEnumeration<T>.ToOrdinal(Enum: T): integer;
begin
  Assert(IsEnumeration);
  Assert(SizeOf(Enum) <= SizeOf(Result));
  Result := 0;
  Move(Enum, Result, SizeOf(Enum));
  Assert(InRange(Result));
end;

class function TJHEnumeration<T>.TypeData: PTypeData;
begin
  Result := System.TypInfo.GetTypeData(TypeInfo);
end;

class function TJHEnumeration<T>.TypeInfo: PTypeInfo;
begin
  Result := System.TypeInfo(T);
end;

{ TEnumHelp<TEnum> }

class function TEnumHelp<TEnum>.Cast(const Value: Integer): TEnum;
var
  typeInf  : PTypeInfo;
  typeData : PTypeData;
begin
  typeInf := PTypeInfo(TypeInfo(TEnum));
  if (typeInf = nil) or (typeInf^.Kind <> tkEnumeration) then
    raise ETEnumHelpError.Create('Not an enumeration type');
  typeData := GetTypeData(typeInf);
  if (Value < typeData^.MinValue) then
    raise ETEnumHelpError.CreateFmt('%d is below min value [%d]',[Value,typeData^.MinValue])
  else
  if (Value > typeData^.MaxValue) then
    raise ETEnumHelpError.CreateFmt('%d is above max value [%d]',[Value,typeData^.MaxValue]);
  case Sizeof(TEnum) of
    1: pByte(@Result)^ := Value;
    2: pWord(@Result)^ := Value;
    4: pCardinal(@Result)^ := Value;
  end;
end;

end.
