unit UnitIDUtil;

interface

uses
  Winapi.Messages, System.SysUtils, Vcl.Dialogs, System.RegularExpressions;

type
  {$M+}
  TIDValidation = class
  private
    FIsValid: Boolean;
    FIDGubun: Integer;
    function IDVaidation(id: string): Boolean;                  // �ֹε�Ϲ�ȣ, �ܱ���, ��ܱ���
    function CorporateResistrationNumber(id: string): Boolean;  // ���ε�Ϲ�ȣ
    function BusinessLicenseNumber(id: string): Boolean;        // ����ڵ�Ϲ�ȣ
    function ForeignResistrationNumber(id: string): Boolean;
    procedure DisplayResult;
  public
    Constructor Create(IDGubun: Integer; id: string);
    Destructor Destroy; override;
    procedure Free;
  published
    property IsValid: Boolean read FIsValid write FIsValid;
  end;
  {$M+}

implementation

{ TValidation }

Constructor TIDValidation.Create(IDGubun: Integer; id: string);
begin
  inherited Create;

  FIDGubun := IDGubun;

  case FIDGubun of
    0 : IDVaidation(id);             // �ֹε�Ϲ�ȣ
    1 : CorporateResistrationNumber(id);   // ���ε�Ϲ�ȣ
    2 : BusinessLicenseNumber(id);         // ����ڵ�Ϲ�ȣ
    3, 4: ForeignResistrationNumber(id);
  end;
end;

destructor TIDValidation.Destroy;
begin

  inherited;
end;

procedure TIDValidation.DisplayResult;
begin
  if FIsValid then
      Exit;

  case FIDGubun of
    0 : ShowMessage('�ֹε�Ϲ�ȣ ��ȿ�� �˻� ����! �ֹε�Ϲ�ȣ�� Ȯ���Ͻʽÿ�.');
    1 : ShowMessage('���ε�Ϲ�ȣ ��ȿ�� �˻� ����! ���ε�Ϲ�ȣ�� Ȯ���Ͻʽÿ�.');
    2 : ShowMessage('����ڵ�Ϲ�ȣ ��ȿ�� �˻� ����! ����ڵ�Ϲ�ȣ�� Ȯ���Ͻʽÿ�.');
    3 : ShowMessage('�ܱ��ε�Ϲ�ȣ ��ȿ�� �˻� ����! �ܱ��ε�Ϲ�ȣ�� Ȯ���Ͻʽÿ�.');
    4 : ShowMessage('��ܱ��ε�Ϲ�ȣ ��ȿ�� �˻� ����! ��ܱ��ε�Ϲ�ȣ�� Ȯ���Ͻʽÿ�.');
  end;
end;

function TIDValidation.IDVaidation(id: string): Boolean;
begin
  FIsValid := False;

  if id.Length <> 13 then
      Exit;

  var checkSum := 0;
  var CheckNum := '234567892345';

  for var i := 1 to 12 do
      checkSum := CheckSum + StrToInt(id[i]) * StrToInt(CheckNum[i]);
      // checkSum := CheckSum + StrToInt(id[i]) * (((i-1) mod 8) + 2);  // ���� ����...

  var modCheckSum := checkSum mod 11;    // ������ �հ��� 11�� ��������
  if (11 - modCheckSum) mod 10 = StrToInt(id[13]) then    // �ֹι�ȣ ����
      FIsValid := True;

  DisplayResult;
end;

function TIDValidation.CorporateResistrationNumber(id: string): Boolean;
begin
  FIsValid := False;

  if id.length <> 13 then
      Exit;

  var CheckNumber := '121212121212';
  var Sum := 0;
  var Num := 0;

  for var i := 1 to id.Length - 1 do
  begin
      num := StrToInt(id[i]) * StrToInt(CheckNumber[i]);
      Inc(Sum, Num); // Sum := Sum + Num;
  end;

  if StrToInt(id[13]) = (10 - (Sum mod 10)) mod 10 then
      FIsValid := True;

  DisplayResult;
end;

function TIDValidation.BusinessLicenseNumber(id: string): Boolean;
begin
  var TempStr := '';
  var Sum := 0;
  var Val := 0;

  FIsValid := False;

  if id.Length <> 10 then
      Exit;

  var CheckNum := '13713713';
  for var i := 1 to 8 do
      Sum := Sum + StrToInt(id[i]) * StrToInt(CheckNum[i]);

  Val := StrToInt(id[9]) * 5;
  Sum := Sum + (Val Div 10) + (Val mod 10);
  Sum := Sum mod 10;

  if Sum = 0 then
      TempStr:= '0'
  else
      TempStr:= IntToStr(10 - Sum);

  if TempStr = id[10] then
      FIsValid := True;

  DisplayResult;
end;

function TIDValidation.ForeignResistrationNumber(id: string): Boolean;
label
    Jump;
begin
  FIsValid := False;     // Test ID: 810120-5682051 9901015020063

  if id.Length <> 13 then
      Exit;

  var checkSum := 0;
  var CheckNum := '234567892345';

  var c := StrToInt(id[7]);

  if (c <> 5) and (c <> 6) and (c <> 7) and (c <> 8) then
     goto Jump;

  if StrToInt(Copy(id, 8, 2)) mod 2 <> 0 then
      goto Jump;

  for var i := 1 to id.Length - 1 do
      checkSum := checkSum + StrToInt(id[i]) * StrToInt(CheckNum[i]);

  if (((11 - (checkSum mod 11)) mod 10 + 2) mod 10) =  StrToInt(id[13]) then
      FIsValid := True;

Jump:
    DisplayResult;
end;

procedure TIDValidation.Free;
begin
    Destroy;
end;

end.

end.
