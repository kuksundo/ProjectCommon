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
    function IDVaidation(id: string): Boolean;                  // 주민등록번호, 외국인, 재외국민
    function CorporateResistrationNumber(id: string): Boolean;  // 법인등록번호
    function BusinessLicenseNumber(id: string): Boolean;        // 사업자등록번호
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
    0 : IDVaidation(id);             // 주민등록번호
    1 : CorporateResistrationNumber(id);   // 법인등록번호
    2 : BusinessLicenseNumber(id);         // 사업자등록번호
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
    0 : ShowMessage('주민등록번호 유효성 검사 오류! 주민등록번호를 확인하십시오.');
    1 : ShowMessage('법인등록번호 유효성 검사 오류! 법인등록번호를 확인하십시오.');
    2 : ShowMessage('사업자등록번호 유효성 검사 오류! 사업자등록번호를 확인하십시오.');
    3 : ShowMessage('외국인등록번호 유효성 검사 오류! 외국인등록번호를 확인하십시오.');
    4 : ShowMessage('재외국민등록번호 유효성 검사 오류! 재외국민등록번호를 확인하십시오.');
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
      // checkSum := CheckSum + StrToInt(id[i]) * (((i-1) mod 8) + 2);  // 위와 같다...

  var modCheckSum := checkSum mod 11;    // 검증값 합계의 11의 나머지수
  if (11 - modCheckSum) mod 10 = StrToInt(id[13]) then    // 주민번호 검증
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
