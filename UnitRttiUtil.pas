unit UnitRttiUtil;

interface

uses SysUtils,Classes, Rtti, SynCommons, TypInfo;

{$TYPEINFO ON}
{$METHODINFO ON}

type
//  TRecordHlpr<T: record> = class
  TRecordHlpr<T> = class
  public
    {Usage:
      var
        rec: TMyRecord;
        s: string;
      begin
        s := TRecordHlpr<TMyRecord>.GetFields(rec);
      end;
    }
    class function GetFields(const ARec: T): string;
    procedure FromString(const FromValue: String);
    function  ToString : String;
    class procedure FromJson(const AJson: String; var ARec: T; AIsRemoveFirstChar: Boolean=False);
    class function ToJson(const ARec: T) : String;
    class function ToVariant(const ARec: T) : variant;
  end;

function ParamByNameAsString(
    const Params     : String;
    const ParamName  : String;
    var   Status     : Boolean;
    const DefValue   : String) : String;
function EscapeQuotes(const S: String) : String;

function IsEqualTypeKind(A,B: TTypeKind): Boolean;
function GetTypeInfoByName(ATypeName: string): PTypeInfo;
function GetTypeInfo2Name(AClass: TObject): string;
function GetTypeInfo2Class(AClass: TObject): TClass;
function SetToInt(const ASet; const ASize: integer): integer;
procedure IntToSet(const AValue: integer; var ASet; const ASize: integer);
function GetValue(var aValue : TValue) : String;
procedure SetValue(aData : String; var aValue : TValue; aTypeKind: TTypeKind = TTypeKind(0));
procedure GetValue2(var aValue: TValue; aTargetTypeKind: TTypeKind);
procedure SetValue2(aProp: TRttiProperty; var aValue : TValue);
//AClass�� APropertyName�� AData�� ������
//ex : SetValue3(aButton, 'caption', 'Pressed');
procedure SetValue3(AClass: TObject; AData, APropertyName : String);
function GetValue3(AClass: TObject; APropertyName : String): TValue;
procedure LoadRecordPropertyFromVariant(AClass: TObject; const ADoc: Variant; AIsPadFirstChar: Boolean=False);
procedure LoadRecordPropertyToVariant(const AClass: TObject; var ADoc: Variant; AIsPadFirstChar: Boolean=False; AIsPropertyOnly: Boolean=False);
procedure PersistentCopy(const ASrc: TPersistent; var ADest: TPersistent);
procedure ObjectCopyWithRtti(const ASrc: TObject; var ADest: TObject);
procedure CreatePersistentAssignFile(const ASrc: TPersistent; AFileName: string);
function GetVariantFromProperty(const AClass: TObject; AIsPadFirstChar: Boolean=False; AIsPropertyOnly: Boolean=False): Variant;
//procedure LoadRecordPropertyFromVariant2(ARecType: TypeInfo; const ADoc: Variant);
function GetPropertyNameValueList(AObj: TObject; AIsOnlyPublished: Boolean=False): TStringList;
function GetPropertyCount(AObj: TObject; AIsOnlyPublished: Boolean=False): integer;
procedure LoadRecordFieldFromVariant(ATypeInfo, ARecPointer: Pointer; const ADoc: Variant; AIsPadFirstChar: Boolean=False);
function FindNSetCompValue(AParentControl: TComponent; const ACompName, APropName, AValue: string): Boolean;
function FindNGetCompStringValue(AParentControl: TComponent; ACompName, APropName: string): string;

function ExecuteMethodByClass(AClass : TClass; AMethodName : String; const AArgs: Array of TValue) : TValue;
//ex)
//procedure TestMethod(const value: string);
//.....
//var
//  LStr: string;
//  tv: array of TValue;
//begin
//  LStr := 'hello';
//  //SOInvoke(Self, 'TestMethod', SO('{value: "hello"}'));
//  SetLength(tv,1);
//  tv[0] := TValue.From(LStr);
//  ExecuteMethodByObject(Self, 'TestMethod', tv);
//}
function ExecuteMethodByObject(AObj : TObject; AMethodName : String; const AArgs: Array of TValue) : TValue;

implementation

function StrIsNumeric(s: string): Boolean;
var
  iValue, iCode: integer;
begin
  Val(s, iValue, iCode);
  Result := iCode = 0;
end;

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
// This will take an inut string having the format:
//  name1=value1;name2=value2;...
// Value may also be placed between double quotes if it contain spaces.
// Double quotes inside the value is escaped with a backslash
// Backslashes are double. See EscapeQuotes below.
function ParamByNameAsString(
    const Params     : String;
    const ParamName  : String;
    var   Status     : Boolean;
    const DefValue   : String) : String;
var
  I, J  : Integer;
  Ch    : Char;
begin
  Status := FALSE;
  I := 1;

  while I <= Length(Params) do
  begin
    J := I;

    while (I <= Length(Params)) and (Params[I] <> '=')  do
      Inc(I);

    if I > Length(Params) then
    begin
      Result := DefValue;
      Exit;                  // Not found
    end;

    if SameText(ParamName, Trim(Copy(Params, J, I - J))) then
    begin
      // Found parameter name, extract value
      Inc(I); // Skip '='

      if (I <= Length(Params)) and (Params[I] = '"') then
      begin
        // Value is between double quotes
        // Embedded double quotes and backslashes are prefixed
        // by backslash
        Status := TRUE;
        Result := '';
        Inc(I);        // Skip starting delimiter

        while I <= Length(Params) do
        begin
          Ch := Params[I];

          if Ch = '\' then
          begin
            Inc(I);          // Skip escape character

            if I > Length(Params) then
              break;

            Ch := Params[I];
          end
          else if Ch = '"' then
            break;

          Result := Result + Ch;
          Inc(I);
        end;
      end
      else
      begin
        // Value is up to semicolon or end of string
        J := I;

        while (I <= Length(Params)) and (Params[I] <> ';') do
          Inc(I);

        Result := Copy(Params, J, I - J);
        Status := TRUE;
      end;

      Exit;
    end;
    // Not good parameter name, skip to next
    Inc(I); // Skip '='

    if (I <= Length(Params)) and (Params[I] = '"') then
    begin
      Inc(I);        // Skip starting delimiter

      while I <= Length(Params) do
      begin
        Ch := Params[I];

        if Ch = '\' then
        begin
          Inc(I);          // Skip escape character

          if I > Length(Params) then
            break;
        end
        else if Ch = '"' then
          break;

        Inc(I);
      end;

      Inc(I);        // Skip ending delimiter
    end;
    // Param ends with ';'
    while (I <= Length(Params)) and (Params[I] <> ';')  do
      Inc(I);

    Inc(I);  // Skip semicolon
  end;
  Result := DefValue;
end;

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function EscapeQuotes(const S: String) : String;
begin
  // Easy but not best performance
  Result := StringReplace(S, '\', '\\', [rfReplaceAll]);
  Result := StringReplace(Result, '"', '\"', [rfReplaceAll]);
end;

function IsEqualTypeKind(A,B: TTypeKind): Boolean;
begin
  Result := False;

  case A of
    tkWChar,
    tkLString,
    tkWString,
    tkString,
    tkChar,
    tkUString : Result := (B = tkWChar) or (B = tkLString) or (B = tkWString) or (B = tkString) or
      (B = tkChar) or (B = tkUString);
    tkInteger : Result := (B = tkInteger);
    tkInt64  : Result := (B = tkInt64);
    tkFloat  : Result := (B = tkFloat);
    tkEnumeration: Result := (B = tkEnumeration);
    tkSet: Result := (B = tkSet);
    else raise Exception.Create('Type not Supported');
  end;
end;

function GetTypeInfoByName(ATypeName: string): PTypeInfo;
var
  Ctx: TRttiContext;
  Typ: TRttiType;
begin
  Typ := nil;
  Typ := Ctx.FindType(ATypeName);
  if Assigned(Typ) then
    Result := Typ.Handle
  else
    Result := nil;
end;

function GetTypeInfo2Name(AClass: TObject): string;
var
  Ctx: TRttiContext;
  Typ: TRttiType;
begin
  Result := '';
  Typ := nil;

  ctx := TRttiContext.Create;
  try
    Typ := ctx.GetType(AClass.ClassInfo);
    Result := Typ.ToString;
  finally
    ctx.Free;
  end;
end;

function GetTypeInfo2Class(AClass: TObject): TClass;
var
  Ctx: TRttiContext;
  Typ: TRttiType;
begin
  Typ := nil;

  ctx := TRttiContext.Create;
  try
    Typ := ctx.GetType(AClass.ClassInfo);
    Result := Typ.ClassType;
  finally
    ctx.Free;
  end;
end;

function SetToInt(const ASet; const ASize: integer): integer;
begin
  Move(ASet, Result, ASize);
end;

procedure IntToSet(const AValue: integer; var ASet; const ASize: integer);
begin
  Move(AValue, ASet, ASize);
end;

function GetValue(var aValue : TValue) : String;
var
 I : Integer;
begin
   if aValue.Kind in [tkWChar, tkLString, tkWString, tkString, tkChar,
                    tkUString, tkInteger, tkInt64, tkFloat, tkEnumeration,
                    tkSet]  then
   result := aValue.ToString
   else raise Exception.Create('Type not Supported');
end;

procedure SetValue(aData: String; var aValue : TValue; aTypeKind: TTypeKind = TTypeKind(0));
var
 I : Integer;
 LKind: TTypeKind;
begin
  if aTypeKind <> TTypeKind(0) then
    LKind := aTypeKind
  else
    LKind := aValue.Kind;

  case LKind of
    tkWChar,
    tkLString,
    tkWString,
    tkString,
    tkChar,
    tkUString : aValue := aData;
    tkInteger : aValue := StrToIntDef(aData,0);
    tkInt64  : aValue := StrToInt64Def(aData,0);
    tkFloat  : aValue := StrToFloatDef(aData,0);
    tkEnumeration: begin
      i := StrToIntDef(aData, 0);

      if i = 0 then
        if (SysUtils.UpperCase(AData) = 'TRUE') or (SysUtils.UpperCase(AData) = 'FALSE') then
        begin
          i := Ord(StrToBoolDef(aData, False));
          aData := System.TypInfo.GetEnumName(aValue.TypeInfo,i);
        end;

//      if i <> -1 then //aData�� Enumeration ���� Interger�� ��ȯ�� String ���� ��
//      begin
//        aData := System.TypInfo.GetEnumName(aValue.TypeInfo,i);
      if StrIsNumeric(aData) then
        aValue := TValue.FromOrdinal(aValue.TypeInfo,Ord(StrToIntDef(aData,0)))
      else
        aValue := TValue.FromOrdinal(aValue.TypeInfo,GetEnumValue(aValue.TypeInfo,aData));
//      end;
    end;
    tkSet: begin
      i :=  StringToSet(aValue.TypeInfo,aData);
      TValue.Make(@i, aValue.TypeInfo, aValue);
    end;
    tkClass: begin
//      aValue := aData;
    end;
    else raise Exception.Create('Type not Supported');
  end;
end;

procedure GetValue2(var aValue: TValue; aTargetTypeKind: TTypeKind);
var
  I : Integer;
  LKind: TTypeKind;
  LStr: string;

//  procedure _GetValue(aTypeKind, aTargetTypeKind: TTypeKind);
//  begin
//    case aTypeKind of
//      tkWChar,
//      tkLString,
//      tkWString,
//      tkString,
//      tkChar,
//      tkUString : aValue.AsString;
//    end;
//  end;
begin
  LKind := aValue.Kind;

//  if LKind = aTargetTypeKind then
  if IsEqualTypeKind(LKind, aTargetTypeKind) then
    exit;

//  _GetValue(LKind, aTargetTypeKind);

    case aTargetTypeKind of
      tkWChar,
      tkLString,
      tkWString,
      tkString,
      tkChar,
      tkUString : aValue := IntToStr(aValue.AsInteger);
      tkInteger : aValue := StrToIntDef(aValue.AsString,0);
      tkInt64  : aValue := StrToInt64Def(aValue.AsString, 0);
      tkFloat  : aValue := StrToFloat(aValue.AsString);
      tkEnumeration: begin
        LStr := aValue.AsString;
        i := StrToIntDef(LStr,0);

        if i = 0 then
          if (SysUtils.UpperCase(LStr) = 'TRUE') or (SysUtils.UpperCase(LStr) = 'FALSE') then
            i := Ord(StrToBoolDef(LStr, False));

          LStr := System.TypInfo.GetEnumName(aValue.TypeInfo,i);
          aValue := TValue.FromOrdinal(aValue.TypeInfo,GetEnumValue(aValue.TypeInfo,LStr));
      end;
      tkSet: begin
        LStr := aValue.AsString;
        i :=  StringToSet(aValue.TypeInfo,LStr);
        TValue.Make(@i, aValue.TypeInfo, aValue);
      end;
      else raise Exception.Create('Type not Supported');
    end;
end;

//aProp: ������Ʈ �Ǵ� Object�� Field �Ӽ�(Property) - ex) Text or Caption
//aValue : aProp�� �Ҵ� �� TValue
procedure SetValue2(aProp: TRttiProperty; var aValue : TValue);
var
  I : Integer;
  LKind: TTypeKind;
  LStr: string;
begin
//  LKind := aValue.Kind;
  LKind := aProp.PropertyType.TypeKind;
  GetValue2(aValue, LKind);

//  if aValue.Kind <> LKind then
//  begin
//    case LKind of
//      tkWChar,
//      tkLString,
//      tkWString,
//      tkString,
//      tkChar,
//      tkUString : aValue := IntToStr(aValue.AsInteger);
//      tkInteger : aValue := aValue.AsInteger;
//      tkInt64  : aValue := aValue.AsInt64;
//      tkFloat  : aValue := aValue.AsExtended;
//      tkEnumeration: begin
//        LStr := aValue.AsString;
//        i := StrToIntDef(LStr,0);
//
//        if i = 0 then
//          if (SysUtils.UpperCase(LStr) = 'TRUE') or (SysUtils.UpperCase(LStr) = 'FALSE') then
//            i := Ord(StrToBoolDef(LStr, False));
//
//        LStr := System.TypInfo.GetEnumName(aValue.TypeInfo,i);
//        aValue := TValue.FromOrdinal(aValue.TypeInfo,GetEnumValue(aValue.TypeInfo,LStr));
//      end;
//      tkSet: begin
//        LStr := aValue.AsString;
//        i :=  StringToSet(aValue.TypeInfo,LStr);
//        TValue.Make(@i, aValue.TypeInfo, aValue);
//      end;
//      else raise Exception.Create('Type not Supported');
//    end;
//  end;
end;

procedure SetValue3(AClass: TObject; AData, APropertyName : String);
var
 ctx : TRttiContext;
 objType : TRttiType;
 Prop  : TRttiProperty;
 Value : TValue;
 LObj: TObject;
begin
  ctx := TRttiContext.Create;

  try
    objType := ctx.GetType(AClass.ClassInfo);

    for Prop in objType.GetProperties do
    begin
      if not Prop.IsWritable then
        continue;

      if Prop.Visibility <> mvPublished then
        Continue;

      if Prop.Name = APropertyName then
      begin
        //Property Field Address ������
        Value := Prop.GetValue(AClass);

        if Value.Kind = tkClass then
        begin
          LObj := Prop.GetValue(AClass).AsObject;

          if LObj is TStrings then
            TStrings(LObj).Text := AData;

//            if Assigned(LObj) then
//              Prop.SetValue(LObj, AData);
        end
        else
        begin
          //Field Value�� Data�� Assign��
          SetValue(AData, Value);
          Prop.SetValue(AClass,Value);
//        Prop.SetValue(AClass, TValue.From(AData));
        end;

        Break;
      end;
    end;
  finally
    ctx.Free;
  end;
end;

function GetValue3(AClass: TObject; APropertyName : String): TValue;
var
  ctx: TRttiContext;
  rttitype: TRttiType;
  rttiprop: TRttiProperty;
  LObj: TObject;
begin
  rttitype := ctx.GetType(AClass.ClassType);
  rttiprop := rttitype.GetProperty(APropertyName);

  if Assigned(rttiprop) then
  begin
    Result := rttiprop.GetValue(AClass);

    if Result.Kind = tkClass then
    begin
      LObj := rttiprop.GetValue(AClass).AsObject;

      if LObj is TStrings then
        Result := TStrings(LObj).Text;
    end;
  end;
end;

procedure LoadRecordPropertyFromVariant(AClass: TObject; const ADoc: Variant; AIsPadFirstChar: Boolean);
var
 ctx : TRttiContext;
 objType : TRttiType;
 Field : TRttiField;
 Prop  : TRttiProperty;
 Value : TValue;
 Data, LPropName : String;
// LVar: variant;
begin
  ctx := TRttiContext.Create;
  try
    objType := ctx.GetType(AClass.ClassInfo);

    for Prop in objType.GetProperties do
    begin
      if not Prop.IsWritable then
        continue;

      if Prop.Visibility <> mvPublished then
        Continue;

      LPropName := Prop.Name;

      if (LPropName = 'IDValue') or (LPropName = 'InternalState') then
        continue;

      if AIsPadFirstChar then
        Insert('F', LPropName,1);

      //Enumeration ���� ���� ��Ʈ������ ��ȯ�� ���̾�� ��
      Data := TDocVariantData(ADoc).GetValueOrEmpty(LPropName);
      //Property Field Address ������
      Value := Prop.GetValue(AClass);
      //Field Value�� Data�� Assign��
      SetValue(Data, Value);
      Prop.SetValue(AClass,Value);
    end;

//    for Field in objType.GetFields do
//    begin
//      Value := Field.GetValue(AClass);
//      SetValue(Data,Value);
//      Field.SetValue(AClass,Value);
//    end;
  finally
    ctx.Free;
  end;
end;

procedure LoadRecordPropertyToVariant(const AClass: TObject; var ADoc: Variant;
  AIsPadFirstChar: Boolean; AIsPropertyOnly: Boolean);
var
 ctx : TRttiContext;
 objType : TRttiType;
 Field : TRttiField;
 Prop  : TRttiProperty;
 Value : TValue;
 LPropName : String;
 LResult: Boolean;
begin
  ctx := TRttiContext.Create;
  try
    objType := ctx.GetType(AClass.ClassInfo);

    for Prop in objType.GetProperties do
    begin
      if not Prop.IsWritable then
        continue;

      if Prop.Visibility <> mvPublished then
        Continue;

      LPropName := Prop.Name;

      //"array of TSQLGSFileRec" type�� Skip��(Field��: Attachments)
      if (LPropName = 'IDValue') or (LPropName = 'InternalState') or
         (LPropName = 'Attachments') then
        continue;

      if AIsPadFirstChar then
        Insert('F', LPropName,1);

      //Value�� �����ϰ� Property(�Ӽ�)�� ADoc�� ������
      if AIsPropertyOnly then
      begin
        TDocVariantData(ADoc).Value[LPropName] := '';
      end
      else
      begin
        Value := Prop.GetValue(AClass);

        //tkSet Type�� value.AsVariant���� ���� ���� (type cast error �߻���)
        if Prop.PropertyType.TypeKind = tkSet then
        begin

        end
        else if Prop.PropertyType.TypeKind = tkEnumeration then
        begin
//          if Value.TryAsType<Boolean>(LResult) then
//            TDocVariantData(ADoc).Value[LPropName] := Value.AsInt64
          if Value.TypeInfo = TypeInfo(Boolean) then
            TDocVariantData(ADoc).Value[LPropName] := Value.AsBoolean
          else
          begin
            TDocVariantData(ADoc).Value[LPropName] := GetEnumValue(Value.TypeInfo, Value.ToString);//Value.TypeInfo.Name;
          end;
        end
        else
          TDocVariantData(ADoc).Value[LPropName] := Value.AsVariant;
      end;
    end;
  finally
    ctx.Free;
  end;
end;

procedure PersistentCopy(const ASrc: TPersistent; var ADest: TPersistent);
var
 ctx : TRttiContext;
 objType : TRttiType;
 Field : TRttiField;
 Prop  : TRttiProperty;
 Value : TValue;
 Data, LPropName : String;
begin
  ctx := TRttiContext.Create;
  try
    objType := ctx.GetType(ASrc.ClassInfo);

    for Prop in objType.GetProperties do
    begin
      if Prop.Name = '' then
        continue;

      if not Prop.IsWritable then
        continue;

      if Prop.Visibility <> mvPublished then
        Continue;

      //Property Field Address ������
      Value := Prop.GetValue(ASrc);
      Prop.SetValue(ADest,Value);
    end;

  finally
    ctx.Free;
  end;
end;

procedure ObjectCopyWithRtti(const ASrc: TObject; var ADest: TObject);
begin

end;

procedure CreatePersistentAssignFile(const ASrc: TPersistent; AFileName: string);
//TPersistent Assign ������ ������
var
 ctx : TRttiContext;
 objType : TRttiType;
 Field : TRttiField;
 Prop  : TRttiProperty;
 Value : TValue;
 Data, LPropName : String;
 LStrList: TStringList;
begin
  LStrList := TStringList.Create;
  LStrList.Add('//***This file is created auto by UnitRttiUtil.CreatePersistentAssignFile() ***' + #13#10);

  ctx := TRttiContext.Create;
  try
    objType := ctx.GetType(ASrc.ClassInfo);

    for Prop in objType.GetProperties do
    begin
      if not Prop.IsWritable then
        continue;

      if (Prop.Visibility <> mvPublished) then//and (Prop.Visibility <> mvPublic)
        Continue;

      LPropName := Prop.Name;
      Data := LPropName + ' := ' + ASrc.ClassName + '(Source).' + LPropName + ';';    // TEngineParameterItem
      LStrList.Add(Data);
    end;

    LStrLIst.SaveToFile(AFileName);
  finally
    ctx.Free;
    LStrList.Free;
  end;

end;

//procedure LoadRecordPropertyFromVariant2(ARecType: TypeInfo; const ADoc: Variant);
//var
//  LContext: TRttiContext;
//  LRecord: TRttiRecordType;
//  LField: TRttiField;
//  LFldName: string;
//  LValue: TValue;
//begin
//  LContext := TRttiContext.Create;
//  try
//    LRecord := LContext.GetType(TypeInfo(ARecType)).AsRecord;
//    for LField in LRecord.GetFields do
//    begin
//      LFldName := LField.Name;
//      LValue := LField.GetValue();
//    end;
//  finally
//    LContext.Free;
//  end;
//end;

{ TRecordHlpr<T> }

class procedure TRecordHlpr<T>.FromJson(const AJson: String; var ARec: T; AIsRemoveFirstChar: Boolean);
var
  ndx: integer;
  LDoc, LVar: variant;
  LValue    : TValue;
  LContext  : TRttiContext;
//  LRecord   : TRttiRecordType;
  LField    : TRttiField;
  LStrData, LFieldName  : String;
begin
  if AJson = '' then
      Exit;

  LDoc := _Json(StringToUtf8(AJson));
  LContext := TRttiContext.Create;
  try
//    LRecord := LContext.GetType(TypeInfo(T)).AsRecord;

    with _Safe(LDoc)^ do //note ^ to de-reference into TDocVariantData
    begin
      for LField in LContext.GetType(TypeInfo(T)).GetFields do
      begin
        LFieldName := LField.Name;

        if AIsRemoveFirstChar then
          System.Delete(LFieldName, 1, 1);

        ndx := GetValueIndex(LFieldName);

        if ndx >= 0 then
        begin
          LStrData := GetValueOrEmpty(LFieldName);
          LValue := LField.GetValue(@ARec);
          SetValue(LStrData, LValue);
          LField.SetValue(@ARec,LValue);
        end;
      end;
    end;
  finally
    LContext.Free;
  end;
end;

procedure TRecordHlpr<T>.FromString(const FromValue: String);
var
  Status    : Boolean;
  Value     : String;
  AValue    : TValue;
  AContext  : TRttiContext;
  ARecord   : TRttiRecordType;
  AField    : TRttiField;
  AFldName  : String;
begin
  if FromValue = '' then
      Exit;

  // We use RTTI to iterate thru all fields of THdr and use each field name
  // to get field value from metadata string and then set value into Hdr.
  AContext := TRttiContext.Create;
  try
    ARecord := AContext.GetType(TypeInfo(T)).AsRecord;

    for AField in ARecord.GetFields do
    begin
      AFldName := AField.Name;
      Value    := ParamByNameAsString(FromValue, AFldName, Status, '0');

      if Status then
      begin
        try
          case AField.FieldType.TypeKind of
          tkFloat:               // Also for TDateTime !
            begin
              if Pos('/', Value) >= 1 then
                AValue := StrToDateTime(Value)
              else
                AValue := StrToFloat(Value);

              AField.SetValue(@Self, AValue);
            end;
          tkInteger:
            begin
              AValue := StrToInt(Value);
              AField.SetValue(@Self, AValue);
            end;
          tkUString:
            begin
              AValue := Value;
              AField.SetValue(@Self, AValue);
            end;
          // You should add other types as well
          end;
        except
            // Ignore any exception here. Likely to be caused by
            // invalid value format
        end;
      end
      else begin
          // Do whatever you need if the string lacks a field
          // For example clear the field, or just do nothing
      end;
    end;
  finally
    AContext.Free;
  end;
end;

class function TRecordHlpr<T>.GetFields(const ARec: T): string;
var
  LContext: TRttiContext;
  LType: TRttiType;
  LField: TRttiField;
begin
  Result := '';
  LContext := TRttiContext.Create;

  for LField in LContext.GetType(TypeInfo(T)).GetFields do
  begin
    LType := LField.FieldType;
    Result := Result + '|' + Format('Field: %s, Type: %s, Value: %s',
      [LField.Name, LField.FieldType.Name, LField.GetValue(@ARec).AsString]);
  end;
end;

class function TRecordHlpr<T>.ToJson(const ARec: T): String;
begin
  Result := Utf8ToString(RecordSaveJson(ARec, TypeInfo(T)));
end;

function TRecordHlpr<T>.ToString: String;
var
  AContext  : TRttiContext;
  AField    : TRttiField;
  ARecord   : TRttiRecordType;
  AFldName  : String;
  AValue    : TValue;
begin
  Result := '';
  AContext := TRttiContext.Create;
  try
    ARecord := AContext.GetType(TypeInfo(T)).AsRecord;

    for AField in ARecord.GetFields do
    begin
      AFldName := AField.Name;
      AValue := AField.GetValue(@Self);
      Result := Result + AFldName + '="' +
                EscapeQuotes(AValue.ToString) + '";';
    end;
  finally
    AContext.Free;
  end;
end;

class function TRecordHlpr<T>.ToVariant(const ARec: T): variant;
var
  ndx: integer;
  LDoc, LVar: variant;
  LValue    : TValue;
  LContext  : TRttiContext;
//  LRecord   : TRttiRecordType;
  LField    : TRttiField;
  LStrData  : String;
begin
  TDocVariant.New(Result);
  LContext := TRttiContext.Create;
  try
    for LField in LContext.GetType(TypeInfo(T)).GetFields do
    begin
//      if LField.FieldType <> tkRecord then
      if not ((LField.FieldType.IsRecord) or (LField.FieldType.IsSet))then
      begin
        //EPItem.MultiStateValues�� array of char �̸� �̶����� ���� ���� ȸ�ǿ�
        if Assigned(LField.FieldType) then
        begin
          LValue := LField.GetValue(@ARec);
          TDocVariantData(Result).Value[LField.Name] := LValue.AsVariant;
        end;
      end;
    end;
  finally
    LContext.Free;
  end;
end;

function GetVariantFromProperty(const AClass: TObject; AIsPadFirstChar: Boolean=False; AIsPropertyOnly: Boolean=False): Variant;
begin
  TDocVariant.New(Result);
  LoadRecordPropertyToVariant(AClass, Result, AIsPadFirstChar, AIsPropertyOnly);
end;

function GetPropertyNameValueList(AObj: TObject; AIsOnlyPublished: Boolean): TStringList;
var //Name=Value�� ��ȯ��
  ctx: TRttiContext;
  rt: TRttiType;
  Prop: TRttiProperty;
//  Value: TValue;
begin
  Result := TStringList.Create;
  ctx := TRttiContext.Create;
  try
    rt := ctx.GetType(AObj.ClassType);

    for prop in rt.GetProperties do
    begin
      if (AIsOnlyPublished) and (Prop.Visibility <> mvPublished) then
        Continue;

      Result.Add(prop.Name + '=' + prop.GetValue(AObj).ToString);
    end;
  finally
    ctx.Free;
  end;
end;

function GetPropertyCount(AObj: TObject; AIsOnlyPublished: Boolean=False): integer;
var
  ctx: TRttiContext;
  rt: TRttiType;
  Prop: TRttiProperty;
begin
  Result := 0;
  ctx := TRttiContext.Create;
  try
    rt := ctx.GetType(AObj.ClassType);

    for prop in rt.GetProperties do
    begin
      if (AIsOnlyPublished) and (Prop.Visibility <> mvPublished) then
        Continue;

      Inc(Result);
    end;
  finally
    ctx.Free;
  end;
end;

procedure LoadRecordFieldFromVariant(ATypeInfo, ARecPointer: Pointer;
  const ADoc: Variant; AIsPadFirstChar: Boolean=False);
var
  rttiContext: TRttiContext;
  rttiType: TRttiType;
  LField : TRTTIField;
  Value : TValue;
begin
  rttiType := rttiContext.GetType(ATypeInfo);//TypeInfo(THiMECSMenuRecord));
  for LField in rttiType.GetFields do
  begin
    Value := LField.GetValue(ARecPointer);
    TDocVariantData(ADoc).Value[LField.Name] := Value.AsVariant;
  end;
end;

function FindNSetCompValue(AParentControl: TComponent; const ACompName, APropName, AValue: string): Boolean;
var
  LComp: TComponent;
begin
  Result := False;
  LComp := AParentControl.FindComponent(ACompName);

  if Assigned(LComp) then
  begin
    SetValue3(TObject(LComp), AValue, APropName);
    Result := True;
  end;
end;

function FindNGetCompStringValue(AParentControl: TComponent; ACompName, APropName: string): string;
var
  LComp: TComponent;
  LValue: TValue;
begin
  Result := '';
  LComp := AParentControl.FindComponent(ACompName);

  if Assigned(LComp) then
  begin
    LValue := GetValue3(TObject(LComp), APropName);
    Result := GetValue(LValue);
  end;
end;

function ExecuteMethodByClass(AClass : TClass; AMethodName : String; const AArgs: Array of TValue) : TValue;
var
//  RttiContext : TRttiContext;
//  RttiMethod  : TRttiMethod;
//  RttiType    : TRttiType;
  RttiObject  : TObject;
begin
  RttiObject := AClass.Create;
  try
    Result := ExecuteMethodByObject(RttiObject, AMethodName, AArgs);
//    RttiContext := TRttiContext.Create;
//    RttiType    := RttiContext.GetType(AClass);
//    RttiMethod  := RttiType.GetMethod(AMethodName);
//    Result      := RttiMethod.Invoke(RttiObject,AArgs);
  finally
    RttiObject.Free;
  end;
end;

//AArgs := TValue.From();
function ExecuteMethodByObject(AObj : TObject; AMethodName : String; const AArgs: Array of TValue) : TValue;
var
  RttiContext : TRttiContext;
  RttiMethod  : TRttiMethod;
  RttiType    : TRttiType;
begin
  if Assigned(AObj) then
  begin
    RttiContext := TRttiContext.Create;
    RttiType    := RttiContext.GetType(AObj.ClassType);
    RttiMethod  := RttiType.GetMethod(AMethodName);
    Result      := RttiMethod.Invoke(AObj,AArgs);
  end;
end;

end.

