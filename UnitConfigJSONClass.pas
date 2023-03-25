{����:
  1. Config Form�� Control.hint = ���� ���� �Ǵ� �ʵ��(��: Caption �Ǵ� Value �Ǵ� Text)�� ���� ��
    1) Ini ���� Config Form(AForm)�� Load�� ȣ��:
      FSettings.LoadConfig2Form(AForm, FSettings);
    2) Config Form�� ������ Ini�� Save �� ȣ��:
      FSettings.LoadConfigForm2Object(AForm, FSettings);
}
unit UnitConfigJSONClass;

interface

uses SysUtils, Vcl.Controls, Classes, Forms, Rtti, TypInfo, JSONPersist;

type
  TJSONConfigBase = class (TJSONPersist)
  private
    FJSONFileName: string;
  public
    constructor create(AFileName: string);

    property JSONFileName : String read FJSONFileName write FJSONFileName;

    procedure LoadConfig2Form(AForm: TForm; ASettings: TObject; AItemIndex: integer = -1);
    procedure LoadConfigForm2Object(AForm: TForm; ASettings: TObject; AItemIndex: integer = -1);
  end;

implementation

function strToken(var S: String; Seperator: Char): String;
var
  I: Word;
begin
  I:=Pos(Seperator,S);
  if I<>0 then
  begin
    Result:=System.Copy(S,1,I-1);
    System.Delete(S,1,I);
  end else
  begin
    Result:=S;
    S:='';
  end;
end;

{ TJSONConfigBase }

constructor TJSONConfigBase.create(AFileName: string);
begin
  FJSONFileName := AFileName;
end;

//Property Attribute�� component name�� ��� ��
//AForm: ȯ�漳�� ��
//ASettings: ȯ�漳�� Class ����(TCollection�� �ַ� ��� ��)
procedure TJSONConfigBase.LoadConfig2Form(AForm: TForm; ASettings: TObject;
  AItemIndex: integer);
var
  ctx, ctx2 : TRttiContext;
  LComponentType, LConfigClassType : TRttiType;
  ComponentProp, ConfigProp  : TRttiProperty;
  Value : TValue;
  AttrValue : JSON2ComponentAttribute;
  LControl: TControl;

  i, j, LTagNo: integer;
  LStrList: TStringList;

  function SetValueFromConfigToComponent(AConfigClass: Pointer): boolean;
  begin
    Result := False;
    LConfigClassType := ctx2.GetType(AConfigClass); //ȯ�� ���� Class

    for ConfigProp in LConfigClassType.GetProperties do
    begin
      AttrValue := GetJSONAttribute(ConfigProp);

      if Assigned(AttrValue) then
      begin
        if AttrValue.ComponentTagNo = LTagNo then
        begin
          Value := ConfigProp.GetValue(ASettings);
          ComponentProp.SetValue(LControl, Value);
          Result := True;
          break;
        end;
      end;
    end;
  end;
begin
  ctx := TRttiContext.Create;
  ctx2 := TRttiContext.Create;
  LStrList := TStringList.Create;//Nested Class�� ��� �����ݷ�(;)���� ���е�
  LStrList.Delimiter := ';';
  LStrList.StrictDelimiter := True;
  try
    for i := 0 to AForm.ComponentCount - 1 do
    begin
      LControl := TControl(AForm.Components[i]);
      LTagNo := LControl.Tag;
      LComponentType := ctx.GetType(LControl.ClassInfo); //ȯ�漳�� ������Ʈ
      LStrList.Clear;
      LStrList.DelimitedText := LControl.Hint; //Nested Class�� + ;' + Caption �Ǵ� Text �Ǵ� Value

      for j := 0 to LStrList.Count - 1 do
      begin
        ComponentProp := nil;
        ComponentProp := LComponentType.GetProperty(LStrList.Strings[j]);

        if ctx.GetType(ComponentProp.PropertyType.Handle).TypeKind is tkClass then //Nested Class�� ���
          LComponentType := ctx.GetType(ComponentProp.PropertyType.Handle)
        else
          break;
      end; //for j

      if Assigned(ComponentProp) then
      begin
        if ASettings.InheritsFrom(TCollection) then
        begin
//          for k := 0 to TCollection(ASettings).Count - 1 do
//          begin
          if AItemIndex <> -1 then
            if SetValueFromConfigToComponent(TCollection(ASettings).Items[AItemIndex].ClassInfo) then
              break;
//          end;
        end
        else
        if ASettings.InheritsFrom(TCollectionItem) then
        begin
          if SetValueFromConfigToComponent(ASettings.ClassInfo) then
            break;
        end;
      end;
    end; //for i
 finally
   ctx.Free;
   ctx2.Free;
   LStrList.Free;
 end;
end;

procedure TJSONConfigBase.LoadConfigForm2Object(AForm: TForm; ASettings: TObject;
  AItemIndex: integer);
var
  ctx, ctx2 : TRttiContext;
  LComponentType, LConfigClassType : TRttiType;
  ComponentProp, ConfigProp  : TRttiProperty;
  Value : TValue;
  AttrValue : JSON2ComponentAttribute;
  LControl: TControl;

  i, j, LTagNo: integer;
  LStrList: TStringList;

  function SetValueFromComponentToConfig(AConfigClass: Pointer): boolean;
  begin
    Result := False;
    LConfigClassType := ctx2.GetType(AConfigClass); //ȯ�� ���� Class

    for ConfigProp in LConfigClassType.GetProperties do
    begin
      AttrValue := GetJSONAttribute(ConfigProp);

      if Assigned(AttrValue) then
      begin
        if AttrValue.ComponentTagNo = LTagNo then
        begin
          Value := ComponentProp.GetValue(LControl);
          ConfigProp.SetValue(ASettings, Value);
          Result := True;
          break;
        end;
      end;
    end;
  end;
begin
  ctx := TRttiContext.Create;
  ctx2 := TRttiContext.Create;
  LStrList := TStringList.Create;//Nested Class�� ��� �����ݷ�(;)���� ���е�
  LStrList.Delimiter := ';';
  LStrList.StrictDelimiter := True;
  try
    for i := 0 to AForm.ComponentCount - 1 do
    begin
      LControl := TControl(AForm.Components[i]);
      LTagNo := LControl.Tag;
      LComponentType := ctx.GetType(LControl.ClassInfo); //ȯ�漳�� ���� ������Ʈ
      LStrList.Clear;
      LStrList.DelimitedText := LControl.Hint; //Nested Class�� + ;' + Caption �Ǵ� Text �Ǵ� Value

      for j := 0 to LStrList.Count - 1 do
      begin
        ComponentProp := nil;
        ComponentProp := LComponentType.GetProperty(LStrList.Strings[j]);

        if ctx.GetType(ComponentProp.PropertyType.Handle).TypeKind is tkClass then //Nested Class�� ���
          LComponentType := ctx.GetType(ComponentProp.PropertyType.Handle)
        else
          break;
      end; //for j

      if Assigned(ComponentProp) then //hint�� ��ϵ� Value�� ����� �ʵ� �Ӽ��� ã������ (Text or Caption...)
      begin
        if ASettings.InheritsFrom(TCollection) then
        begin
          if AItemIndex <> -1 then
            if SetValueFromComponentToConfig(TCollection(ASettings).Items[AItemIndex].ClassInfo) then
              break;
        end
        else
        if ASettings.InheritsFrom(TCollectionItem) then
        begin
          if SetValueFromComponentToConfig(ASettings.ClassInfo) then
            break;
        end;
      end;
    end; //for i
  finally
     ctx.Free;
    ctx2.Free;
    LStrList.Free;
  end;
end;

end.
