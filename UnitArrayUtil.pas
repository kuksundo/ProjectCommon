unit UnitArrayUtil;

interface

uses Windows, sysutils, classes, Generics.Collections, System.TypInfo, System.Rtti;

type
  TpjhArray<T> = record
    ArrayData: array of T;

    class function CompareArray(const OriginalArr, CompareArr: array of T) : boolean; static;
    class function GetAsString(const AArr: TArray<T>) : string; static;
    class function GetAsStringFrom2Dimension(const AArr: array of TArray<T>) : string; static;
    procedure Append(const AValue: T);
    procedure Assign(const AArr: array of T);
    function Count: integer;
    function ToString: string;
  end;

implementation

uses UnitStringUtil;

{ TpjhArray<T> }

procedure TpjhArray<T>.Append(const AValue: T);
begin
  SetLength(ArrayData, Length(ArrayData) + 1);
  ArrayData[High(ArrayData)] := AValue;
end;

procedure TpjhArray<T>.Assign(const AArr: array of T);
var
  i: integer;
begin
  SetLength(ArrayData, 0);

  for i := Low(AArr) to High(AArr) do
    Append(AArr[i]);
end;

class function TpjhArray<T>.CompareArray(const OriginalArr,
  CompareArr: array of T): boolean;
begin
  Result := CompareMem(@OriginalArr, @CompareArr, Sizeof(T));
end;

function TpjhArray<T>.Count: integer;
begin
  Result := Length(ArrayData);
end;

class function TpjhArray<T>.GetAsString(const AArr: TArray<T>): string;
var
  LStr: string;
  i: integer;
begin
  Result := '';

  for i := Low(AArr) to High(AArr) do
    Result := Result + TValue.From<T>(AArr[i]).ToString + ',';

  TrimRightChar(Result, ',');
  Result := '[' + Result + ']';
end;

class function TpjhArray<T>.GetAsStringFrom2Dimension(
  const AArr: array of TArray<T>): string;
var
  i: integer;
begin
  Result := '';

  for i := Low(AArr) to High(AArr) do
    Result := Result + TpjhArray<T>.GetAsString(AArr[i]) + ',';

  TrimRightChar(Result, ',');
  Result := '[' + Result + ']';
end;

function TpjhArray<T>.ToString: string;
var
  LStr: string;
  i: integer;
begin
  Result := '';

  for i := Low(ArrayData) to High(ArrayData) do
  begin
//    if TypeInfo(T) = TypeInfo(Variant) then
//    if PTypeInfo(TypeInfo(T)).Kind = tkVariant then
//      Result := VarToStr(TValue.From<T>(ArrayData[i]).AsVariant)
//    else
      Result := Result + TValue.From<T>(ArrayData[i]).ToString;
  end;
end;

end.
