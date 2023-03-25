unit UnitAddSystem_XE7;

interface

uses System.SysUtils, System.SysConst, System.Rtti;

type
  TBA = array of Boolean;

procedure Delete_BoolArray(var A: TBA; AIdx: integer);
//function IsManagedType(T: TypeIdentifier): Boolean;
//function HasWeakRef(T: TypeIdentifier): Boolean;
//function GetTypeKind(T: TypeIdentifier): TTypeKind;
//function IsConstValue(Value): Boolean;

implementation

procedure Delete_BoolArray(var A: TBA; AIdx: integer);
var
  LLength,
  i: Cardinal;
begin
  LLength := Length(A);
  Assert(LLength > 0);
  Assert(AIdx < LLength);

  for i := AIdx + 1 to LLength - 1 do
    A[i-1] := A[i];

  SetLength(A, LLength-1);
end;

//function IsManagedType(T: TypeIdentifier): Boolean;
//begin
// Result := System.Rtti.IsManaged(TypeInfo(T))
//end;

//function HasWeakRef(T: TypeIdentifier): Boolean;
//begin
//  Result := System.TypInfo.HasWeakRef(TypeInfo(T))
//end;

//function GetTypeKind(T: TypeIdentifier): TTypeKind;
//begin
//  Result := PTypeInfo(System.TypeInfo(T))^.Kind;
//end;

end.
