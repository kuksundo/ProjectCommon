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
    procedure AssignFrom(const AArr: TArray<T>);
    function Count: integer;
    function ToString: string;
  end;

  function FindMissingNumber(const ANumbers: TArray<Integer>; var AStartIndex: integer): Integer;
  function FindMissingNumbers(const ANumbers: TArray<Integer>;
    var AStartIndex: integer): TArray<Integer>;
  function FindMissingNumbers2List(const ANumbers: TArray<Integer>): TStringList;

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

procedure TpjhArray<T>.AssignFrom(const AArr: TArray<T>);
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

function FindMissingNumber(const ANumbers: TArray<Integer>; var AStartIndex: integer): Integer;
var
  i: integer;
begin
  for i := AStartIndex to High(ANumbers) - 1 do
  begin
    if ANumbers[i+1] <> ANumbers[i] + 1 then
    begin
      Result := ANumbers[i] + 1;
      AStartIndex := i+1;
      Exit;
    end;
  end;

  Result := -1; //누락된 숫자가 없는 경우 -1을 반환함
end;

function FindMissingNumbers(const ANumbers: TArray<Integer>;
  var AStartIndex: integer): TArray<Integer>;
var
  i, j, LCount, LMissNum, LInt: integer;
begin
  LCount := 0;

  SetLength(Result, 1000);

  for i := AStartIndex to High(ANumbers) - 1 do
  begin
    if ANumbers[i+1] <> ANumbers[i] + 1 then
    begin
      AStartIndex := i+1;
      LInt := ANumbers[i+1] - ANumbers[i];

      for j := 1 to LInt-1 do
      begin
        Result[LCount] := ANumbers[i] + j;
        Inc(LCount);
      end;

      Break;
    end;
  end;//for

  SetLength(Result, LCount);
end;

function FindMissingNumbers2List(const ANumbers: TArray<Integer>): TStringList;
var
  i, j, LMissNum, LStartIndex, LCount: integer;
  LAry: TArray<Integer>;
begin
  LCount := 0;
  LStartIndex := 0;
  Result := TStringList.Create;

  for i := 0 to High(ANumbers) - 1 do
  begin
    LAry := FindMissingNumbers(ANumbers, LStartIndex);

    for j := 0 to High(LAry) do
    begin
      Result.AddObject(IntToStr(LAry[j]), TObject(LStartIndex+LCount));
      Inc(LCount);
    end;
  end;//for
end;

end.
