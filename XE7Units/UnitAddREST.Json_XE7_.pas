{*******************************************************}
{                                                       }
{             Delphi REST Client Framework              }
{                                                       }
{ Copyright(c) 2013 Embarcadero Technologies, Inc.      }
{                                                       }
{*******************************************************}
unit UnitAddREST.Json_XE7;

/// <summary>
/// REST.Json implements a TJson class that offers several convenience methods:
/// - converting Objects to Json and vice versa
/// - formating Json
/// </summary>

interface

uses
  System.JSON,
  UnitAddREST.JsonReflect_XE7{REST.JsonReflect};

type
  TJsonOption = (joIgnoreEmptyStrings, joIgnoreEmptyArrays);
  TJsonOptions = set of TJsonOption;

  TJson = class(TObject)
  private
    class procedure ProcessOptions(AJsonObject: TJSOnObject; AOptions: TJsonOptions); static;
  public
    class function ObjectToJsonObject(AObject: TObject; AOptions: TJsonOptions = []): TJSOnObject;
    class function ObjectToJsonString(AObject: TObject; AOptions: TJsonOptions = []): string;
    class function JsonToObject<T: class, constructor>(AJsonObject: TJSOnObject): T; overload;
    class function JsonToObject<T: class, constructor>(AJson: string): T; overload;
    class function Format(AJsonValue: TJsonValue): string;
  end;

implementation

uses
  System.DateUtils, System.SysUtils, System.Rtti, System.Character,
  Data.DBXPlatform, Data.DBXJsonCommon, Data.DBXCommonResStrs;

class function TJson.Format(AJsonValue: TJsonValue): string;
var
  s: string;
  c: char;
  EOL: string;
  INDENT: string;
  LIndent: string;
  isEOL: boolean;
  isInString: boolean;
  isEscape: boolean;
begin
  EOL := #13#10;
  INDENT := '  ';
  isEOL := true;
  isInString := false;
  isEscape := false;
  s := AJsonValue.ToString;
  for c in s do
  begin
    if not isInString and ((c = '{') or (c = '[')) then
    begin
      if not isEOL then
        Result := Result + EOL;
      Result := Result + LIndent + c + EOL;
      LIndent := LIndent + INDENT;
      Result := Result + LIndent;
      isEOL := true;
    end
    else if not isInString and (c = ',') then
    begin
      isEOL := false;
      Result := Result + c + EOL + LIndent;
    end
    else if not isInString and ((c = '}') or (c = ']')) then
    begin
      Delete(LIndent, 1, Length(INDENT));
      if not isEOL then
        Result := Result + EOL;
      Result := Result + LIndent + c + EOL;
      isEOL := true;
    end
    else
    begin
      isEOL := false;
      Result := Result + c;
    end;
    isEscape := (c = '\') and not isEscape;
    if not isEscape and (c = '"') then
      isInString := not isInString;
  end;
end;

class function TJson.JsonToObject<T>(AJson: string): T;
var
  LJSONValue: TJsonValue;
  LJSONObject: TJSOnObject;
begin
  LJSONValue := TJSOnObject.ParseJSONValue(AJson);
  try
    if assigned(LJSONValue) and (LJSONValue is TJSOnObject) then
      LJSONObject := LJSONValue as TJSOnObject
    else
      raise EConversionError.Create(SCannotCreateObject);
    Result := JsonToObject<T>(LJSONObject);
  finally
    FreeAndNil(LJSONObject);
  end;
end;

class function TJson.JsonToObject<T>(AJsonObject: TJSOnObject): T;
var
  LUnMarshaler: TJSONUnMarshal;
begin
  LUnMarshaler := TJSONUnMarshal.Create;
  try
    Result := LUnMarshaler.CreateObject(T, AJsonObject) as T;
  finally
    FreeAndNil(LUnMarshaler);
  end;
end;

class function TJson.ObjectToJsonObject(AObject: TObject; AOptions: TJsonOptions = []): TJSOnObject;
var
  LMarshaler: TJSONMarshal;
  LJSONObject: TJSOnObject;
begin
  LMarshaler := TJSONMarshal.Create(TJSONConverter.Create);
  try
    LJSONObject := LMarshaler.Marshal(AObject) as TJSOnObject;
    ProcessOptions(LJSONObject, AOptions);

    Result := LJSONObject;
  finally
    FreeAndNil(LMarshaler);
  end;
end;

class function TJson.ObjectToJsonString(AObject: TObject; AOptions: TJsonOptions = []): string;
var
  LJSONObject: TJSOnObject;
begin
  LJSONObject := ObjectToJsonObject(AObject, AOptions);
  try
    Result := LJSONObject.ToString;
  finally
    FreeAndNil(LJSONObject);
  end;
end;

class procedure TJson.ProcessOptions(AJsonObject: TJSOnObject; AOptions: TJsonOptions);
var
  LPair: TJSONPair;
  LItem: TObject;
  i: Integer;

  function IsEmpty(ASet: TJsonOptions):boolean;
  var
    LElement: TJsonOption;
  begin
    Result := true;
    for LElement in ASet do
    begin
      Result := false;
      break;
    end;
  end;

begin
  if assigned(AJsonObject) and not isEmpty(AOptions) then

   for i := AJsonObject.Size -1 downto 0  do
    begin
      LPair := TJSONPair(AJsonObject.Get(i));
      if LPair.JsonValue is TJSOnObject then
        TJson.ProcessOptions(TJSOnObject(LPair.JsonValue), AOptions)
      else if LPair.JsonValue is TJSONArray then
      begin
        if (joIgnoreEmptyArrays in AOptions) and (TJSONArray(LPair.JsonValue).Size = 0) then
        begin
          AJsonObject.RemovePair(LPair.JsonString.Value);
        end;
        for LItem in TJSONArray(LPair.JsonValue) do
        begin
          if LItem is TJSOnObject then
            TJson.ProcessOptions(TJSOnObject(LItem), AOptions)
        end;
      end
      else
      begin
        if (joIgnoreEmptyStrings in AOptions) and (LPair.JsonValue.Value = '') then
        begin
          AJsonObject.RemovePair(LPair.JsonString.Value);
        end;
      end;
    end;
end;

end.
