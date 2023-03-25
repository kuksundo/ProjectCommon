unit UnitDBXJsonUtil;

interface

uses
  Classes, Data.DBXJSON;

{¿¹½Ã:
procedure TForm1.Button1Click(Sender: TObject);
var
  s: TStringList;
  a: TJSONArray;
  JSONDataString: string;
begin
  s := TStringList.Create;
  try
    s.Add('Value1');
    s.Add('Value2');
    s.Add('Value3');
    a := StringsToJSONArray(s);
    try
     JSONDataString := a.ToString; //JSONDataString = ["Value1","Value2","Value3"]
    finally
      a.Free;
    end;
  finally
    s.Free;
  end;

  a := TJSONObject.ParseJSONValue(JSONDataString) as TJSONArray;
  try
    s := JSONArrayToStrings(a);
    try
      ShowMessage(s.Text);
    finally
      s.Free;
    end;
  finally
    a.Free;
  end;
end;
}
function StringsToJSONArray(const Data: TStrings): TJSONArray;
function JSONArrayToStrings(const Data: TJSONArray): TStringList;

implementation

function StringsToJSONArray(const Data: TStrings): TJSONArray;
var
  I: Integer;
begin
  Result := TJSONArray.Create;
  for I := 0 to Data.Count - 1 do
    Result.Add(Data[I]);
end;

function JSONArrayToStrings(const Data: TJSONArray): TStringList;
var
  I: Integer;
begin
  Result := TStringList.Create;
  for I := 0 to Data.Size - 1 do
    Result.Add(Data.Get(I).Value);
end;

end.
