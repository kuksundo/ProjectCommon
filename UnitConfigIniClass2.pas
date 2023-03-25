{����:
  1. Config Form�� Control.hint = ���� ���� �Ǵ� �ʵ��(��: Caption �Ǵ� Value �Ǵ� Text)�� ���� ��
    1) Ini ���� Config Form(AForm)�� Load�� ȣ��:
      FSettings.LoadConfig2Form(AForm, FSettings);
    2) Config Form�� ������ Ini�� Save �� ȣ��:
      FSettings.LoadConfigForm2Object(AForm, FSettings);
  2. Control.Tag�� 1���� �ߺ����� �ʰ� �Է���
}
unit UnitConfigIniClass2;

interface

uses SysUtils, Vcl.Controls, Forms, Rtti, TypInfo, IniPersist, AdvGroupBox;

type
  TINIConfigBase = class (TObject)
  private
    FIniFileName: string;
  public
    constructor create(AFileName: string);

    property IniFileName : String read FIniFileName write FIniFileName;

    procedure Save(AFileName: string = '');
    procedure Load(AFileName: string = '');

    procedure LoadConfig2Form(AForm: TForm; ASettings: TObject); virtual;
    procedure LoadConfigForm2Object(AForm: TForm; ASettings: TObject); virtual;

    class procedure LoadObject2Form(AForm, ASettings: TObject; AIsForm: Boolean);virtual;
    class procedure LoadForm2Object(AForm, ASettings: TObject; AIsForm: Boolean);virtual;
  end;

implementation

uses UnitRttiUtil2;

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

{ TINIConfigBase }

constructor TINIConfigBase.create(AFileName: string);
begin
  FIniFileName := AFileName;
end;

procedure TINIConfigBase.Load(AFileName: string);
begin
  if AFileName = '' then
    AFileName := FIniFileName;

  TIniPersist.Load(AFileName, Self);
end;

//Component�� Hint�� ���� ����Ǵ� �ʵ���� ����Ǿ� �־�� ��
procedure TINIConfigBase.LoadConfig2Form(AForm: TForm; ASettings: TObject);
var
  ctx, ctx2 : TRttiContext;
  objType, objType2 : TRttiType;
  Prop, Prop2  : TRttiProperty;
  Value : TValue;
  IniValue : IniValueAttribute;
//  Data : String;
  LControl: TControl;

  i, LTagNo: integer;
  LStr, s: string;
begin
  ctx := TRttiContext.Create;
  ctx2 := TRttiContext.Create;
  try
    objType2 := ctx2.GetType(ASettings.ClassInfo);

    for i := 0 to AForm.ComponentCount - 1 do
    begin
      LControl := TControl(AForm.Components[i]);
      LStr := LControl.Hint; //Caption �Ǵ� Text �Ǵ� Value
      LTagNo := LControl.Tag;

      if LStr = '' then
        Continue;

      objType := ctx.GetType(LControl.ClassInfo);

      Prop := nil;

      if LStr = 'TAdvGroupBox' then  //TAdvGroupBox�� ���
      begin
        objType := ctx.GetType(TAdvGroupBox(LControl).CheckBox.ClassInfo);
        LStr := 'Checked';
      end;

      Prop := objType.GetProperty(LStr);

      if Assigned(Prop) then
      begin
        for Prop2 in objType2.GetProperties do
        begin
          IniValue := TIniPersist.GetIniAttribute(Prop2);

          if Assigned(IniValue) then
          begin
            if IniValue.TagNo = LTagNo then
            begin
              Value := Prop2.GetValue(ASettings);
//              Data := TIniPersist.GetValue(Value);
              if LControl.ClassType = TAdvGroupBox then
                Prop.SetValue(TAdvGroupBox(LControl).CheckBox, Value)
              else
                Prop.SetValue(LControl, Value);
              break;
            end;
          end;
        end;
      end;
    end;
 finally
   ctx.Free;
   ctx2.Free;
 end;
end;

procedure TINIConfigBase.LoadConfigForm2Object(AForm: TForm; ASettings: TObject);
var
  ctx, ctx2 : TRttiContext;
  objType, objType2 : TRttiType;
  Prop, Prop2  : TRttiProperty;
  Value : TValue;
  IniValue : IniValueAttribute;
  Data : String;
  LControl: TControl;

  i, LTagNo: integer;
  LStr: string;
begin
  ctx := TRttiContext.Create;
  ctx2 := TRttiContext.Create;
  try
    objType2 := ctx2.GetType(ASettings.ClassInfo);

    for i := 0 to AForm.ComponentCount - 1 do
    begin
      LControl := TControl(AForm.Components[i]);
      LStr := LControl.Hint; //Caption �Ǵ� Text �Ǵ� Value �Ǵ� Checked
      LTagNo := LControl.Tag;

      if LStr = '' then
        Continue;

      objType := ctx.GetType(LControl.ClassInfo);

      Prop := nil;

      if (LStr = 'TAdvGroupBox') then  //TAdvGroupBox�� ���
      begin
        objType := ctx.GetType(TAdvGroupBox(LControl).CheckBox.ClassInfo);
        LStr := 'Checked';
      end;

      Prop := objType.GetProperty(LStr);

      if Assigned(Prop) then
      begin
        for Prop2 in objType2.GetProperties do
        begin
          IniValue := TIniPersist.GetIniAttribute(Prop2);

          if Assigned(IniValue) then
          begin
            if IniValue.TagNo = LTagNo then
            begin
              if LControl.ClassType = TAdvGroupBox then
                Value := Prop.GetValue(TAdvGroupBox(LControl).CheckBox)
              else
                Value := Prop.GetValue(LControl);

              Prop2.SetValue(ASettings, Value);
              break;
            end;
          end;
        end;
      end;
    end;
  finally
   ctx.Free;
   ctx2.Free;
  end;
end;

class procedure TINIConfigBase.LoadForm2Object(AForm, ASettings: TObject; AIsForm: Boolean);
var
  ctx, ctx2 : TRttiContext;
  objType, objType2 : TRttiType;
  Prop, Prop2  : TRttiProperty;
  Value : TValue;
  IniValue : IniValueAttribute;
  Data : String;
  LControl: TControl;
  LObj: TObject;

  i, LCount, LTagNo: integer;
  LStr: string;
begin
  ctx := TRttiContext.Create;
  ctx2 := TRttiContext.Create;
  try
    if AIsForm then
      LCount := TForm(AForm).ComponentCount
    else
      LCount := TFrame(AForm).ComponentCount;

    objType2 := ctx2.GetType(ASettings.ClassInfo);

    for Prop2 in objType2.GetProperties do
    begin
      IniValue := TIniPersist.GetIniAttribute(Prop2);

      if Assigned(IniValue) then
      begin
        if IniValue.DefaultValue = '->' then
        begin
          LObj := Prop2.GetValue(ASettings).AsType<TObject>;
          LoadForm2Object(AForm, LObj, AIsForm);
        end;

        for i := 0 to LCount - 1 do
        begin
          if AIsForm then
            LControl := TControl(TForm(AForm).Components[i])
          else
            LControl := TControl(TFrame(AForm).Components[i]);

          LStr := LControl.Hint; //Caption �Ǵ� Text �Ǵ� Value �Ǵ� Checked
          LTagNo := LControl.Tag;

          if LStr = '' then
            Continue;

          if IniValue.TagNo = LTagNo then
          begin
            objType := ctx.GetType(LControl.ClassInfo);

            Prop := nil;

            if (LStr = 'TAdvGroupBox') then  //TAdvGroupBox�� ���
            begin
              objType := ctx.GetType(TAdvGroupBox(LControl).CheckBox.ClassInfo);
              LStr := 'Checked';
            end;

            Prop := objType.GetProperty(LStr);

            if Assigned(Prop) then
            begin
              if LControl.ClassType = TAdvGroupBox then
                Value := Prop.GetValue(TAdvGroupBox(LControl).CheckBox)
              else
                Value := Prop.GetValue(LControl);

              SetValue2(Prop2, Value);

              Prop2.SetValue(ASettings, Value);
              break;
            end;
          end;//if Assigned(IniValue)
        end;//for
      end;//if Assigned(IniValue)
    end;//for
  finally
    ctx.Free;
    ctx2.Free;
  end;
end;

class procedure TINIConfigBase.LoadObject2Form(AForm, ASettings: TObject; AIsForm: Boolean);
var
  ctx, ctx2: TRttiContext;
  objType, objType2: TRttiType;
  Prop, Prop2: TRttiProperty;
  Value: TValue;
  IniValue: IniValueAttribute;
  LControl: TControl;
  LObj: TObject;

  i, LCount, LTagNo: integer;
  LStr, s: string;
begin
  ctx := TRttiContext.Create;
  ctx2 := TRttiContext.Create;
  try
    if AIsForm then
      LCount := TForm(AForm).ComponentCount
    else
      LCount := TFrame(AForm).ComponentCount;

    objType2 := ctx2.GetType(ASettings.ClassInfo);

    for Prop2 in objType2.GetProperties do
    begin
      IniValue := TIniPersist.GetIniAttribute(Prop2);

      if Assigned(IniValue) then
      begin
        if IniValue.DefaultValue = '->' then
        begin
          LObj := Prop2.GetValue(ASettings).AsType<TObject>;
          LoadObject2Form(AForm, LObj, AIsForm);
        end;

        for i := 0 to LCount - 1 do
        begin
          if AIsForm then
            LControl := TControl(TForm(AForm).Components[i])
          else
            LControl := TControl(TFrame(AForm).Components[i]);

          LStr := LControl.Hint; //Caption �Ǵ� Text �Ǵ� Value
          LTagNo := LControl.Tag;

          if LStr = '' then
            Continue;

          if IniValue.TagNo = LTagNo then
          begin
            objType := ctx.GetType(LControl.ClassInfo);

            Prop := nil;

            if LStr = 'TAdvGroupBox' then  //TAdvGroupBox�� ���
            begin
              objType := ctx.GetType(TAdvGroupBox(LControl).CheckBox.ClassInfo);
              LStr := 'Checked';
            end;

            Prop := objType.GetProperty(LStr);

            if Assigned(Prop) then
            begin
              Value := Prop2.GetValue(ASettings);
              SetValue2(Prop, Value);
  //              Data := TIniPersist.GetValue(Value);
              if LControl.ClassType = TAdvGroupBox then
                Prop.SetValue(TAdvGroupBox(LControl).CheckBox, Value)
              else
                Prop.SetValue(LControl, Value);

              break;
            end;
          end;
        end;//for
      end;
    end;
  finally
    ctx.Free;
    ctx2.Free;
  end;
end;

procedure TINIConfigBase.Save(AFileName: string);
begin
  if AFileName = '' then
    AFileName := FIniFileName;

  // This saves the properties to the INI
  TIniPersist.Save(AFileName ,Self);
end;

end.
