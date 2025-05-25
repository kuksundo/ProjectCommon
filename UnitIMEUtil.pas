unit UnitIMEUtil;

interface

uses  Windows, SysUtils;

type
  THanType = (htHangul, htHanja, htOther);

function IsHanGeul(S: String): Boolean;
function IsHanGeul2(S: String; AIndex: integer): Boolean;
function GetHanType(const Src: string): THanType;
function HanDiv(const Han: PChar; Han3: PChar): Boolean;
function HanComPas(const Src: String): String;

implementation

//Unicode에서 한글이면 True
function IsHanGeul(S: String): Boolean;
const
  UniCodeHangeulBase1 = $1100;
  UniCodeHangeulLast1 = $11F9;
  UniCodeHangeulBase2 = $3130;
  UniCodeHangeulLast2 = $318E;
  UniCodeHangeulBase3 = $AC00;
  UniCodeHangeulLast3 = $D7A3;
begin
  if ((ord(s[1]) >= UniCodeHangeulBase1) and
    (ord(s[1]) <= UniCodeHangeulLast1)) or
    ((ord(s[1]) >= UniCodeHangeulBase2) and
    (ord(s[1]) <= UniCodeHangeulLast2)) or
    ((ord(s[1]) >= UniCodeHangeulBase3) and
    (ord(s[1]) <= UniCodeHangeulLast3)) then
    Result := True
  else
    Result := False;
end;

function IsHanGeul2(S: String; AIndex: integer): Boolean;
const
  UniCodeHangeulBase1 = $1100;
  UniCodeHangeulLast1 = $11F9;
  UniCodeHangeulBase2 = $3130;
  UniCodeHangeulLast2 = $318E;
  UniCodeHangeulBase3 = $AC00;
  UniCodeHangeulLast3 = $D7A3;
begin
  if ((ord(s[AIndex]) >= UniCodeHangeulBase1) and
    (ord(s[AIndex]) <= UniCodeHangeulLast1)) or
    ((ord(s[AIndex]) >= UniCodeHangeulBase2) and
    (ord(s[AIndex]) <= UniCodeHangeulLast2)) or
    ((ord(s[AIndex]) >= UniCodeHangeulBase3) and
    (ord(s[AIndex]) <= UniCodeHangeulLast3)) then
    Result := True
  else
    Result := False;
end;

//한글인지 한자인지 구분함
function GetHanType(const Src: string): THanType;
var
  Len, Hi, Lo: Integer;
begin
  Result := htOther;
  if Length(Src) < 2 then Exit;
  Len := Length(Src);
  Hi := Ord(Src[Len - 1]);
  Lo := Ord(Src[Len]);
  if ($A1 > Lo) or ($FE < Lo) then Exit;
  if ($B0 <= Hi)  and ($C8 >=  Hi) then
    Result := htHangul
  else if ($CA <= Hi) and ($FD >= Hi) then
    Result := htHanja;
end;

const
  ChoSungTbl:  PChar = 'ㄱㄲㄴㄷㄸㄹㅁㅂㅃㅅㅆㅇㅈㅉㅊㅋㅌㅍㅎ';
  JungSungTbl: PChar = 'ㅏㅐㅑㅒㅓㅔㅕㅖㅗㅘㅙㅚㅛㅜㅝㅞㅟㅠㅡㅢㅣ';
  JongSungTbl: PChar = '  ㄱㄲㄳㄴㄵㄶㄷㄹㄺㄻㄼㄽㄾㄿㅀㅁㅂㅄㅅㅆㅇㅈㅊㅋㅌㅍㅎ';
  UniCodeHangeulBase = $AC00;
  UniCodeHangeulLast = $D79F;
// function HanDiv: 한글을 자모로 분해
// Han: 변환할 글자, PChar 타입
// Han3: 분해된 자모, PChar 타입
// (Result): 함수 호출 성공(True), 실패(False)
// *주의: 변수 Han과 Han3이 가리키는 메모리 공간은 각각 2, 6바이트가
// 할당되어 있어야 한다. 그리고 Han과 Han3 모두 null-종료 문자열이 아니다.
function HanDiv(const Han: PChar; Han3: PChar): Boolean;
var
  UniCode: Word;
  ChoSung, JungSung, JongSung: Integer;
begin
  Result := False;

//  MultiByteToWideChar(CP_ACP, MB_PRECOMPOSED, Han, 2, @UniCode, 1);

  if (UniCode < UniCodeHangeulBase) or
     (UniCode > UniCodeHangeulLast) then Exit;

  UniCode := UniCode - UniCodeHangeulBase;
  ChoSung := UniCode div (21 * 28);
  UniCode := UniCode mod (21 * 28);
  JungSung := UniCode div 28;
  UniCode := UniCode mod 28;
  JongSung := UniCode;

  StrLCopy(Han3, ChoSungTbl + ChoSung * 2, 2);
  StrLCopy(Han3 + 2, JungSungTbl + JungSung * 2, 2);
  StrLCopy(Han3 + 4, JongSungTbl + JongSung * 2, 2);

  Result := True;
end;

// function HanDivPas: 한글을 자모로 분해
// Src: 변환할 글자, 예: '갈'
// (Result): 분해된 자모, 예: 'ㄱㅏㄹ', 함수 호출 실패의 경우 ''을 반환한다.
function HanDivPas(const Src: String): String;
var
  Buff: array[0..6] of Char;
begin
  Result := '';
  if Length(Src) = 2 then begin
    if HanDiv(PChar(Src), Buff) then begin
      Buff[6] := #0;
      Result := String(Buff);
    end;
  end;
end;

// function HanCom: 한글 자모를 글자로 조합
// Han3: 변환할 자모, PChar 타입
// Han: 조합된 글자, PChar 타입
// (Result): 함수 호출 성공(True), 실패(False)
// *주의: 변수 Han과 Han3이 가리키는 메모리 공간은 각각 2, 6바이트가
// 할당되어 있어야 한다. 그리고 Han과 Han3 모두 null-종료 문자열이 아니다.
function HanCom(const Han3: PChar; Han: PChar): Boolean;
var
  UniCode: Word;
  ChoSung, JungSung, JongSung: Integer;
  ChoSungPos, JungSungPos, JongSungPos: Integer;
begin
  Result := False;

  ChoSungPos := Pos(Copy(String(Han3), 1, 2), ChoSungTbl);
  JungSungPos := Pos(Copy(String(Han3), 3, 2), JungSungTbl);
  JongSungPos := Pos(Copy(String(Han3), 5, 2), JongSungTbl);

  if (ChoSungPos and JungSungPos and JongSungPos) = 0 then Exit;

  ChoSung := (ChoSungPos - 1) div 2;
  JungSung := (JungSungPos - 1) div 2;
  JongSung := (JongSungPos - 1) div 2;

  UniCode := UniCodeHangeulBase +
    (ChoSung * 21 + JungSung) * 28 + JongSung;

//  WideCharToMultiByte(CP_ACP, WC_COMPOSITECHECK,
//    @UniCode, 1, Han, 2, nil, nil);

  Result := True;
end;

// function HanComPas: 한글 자모를 글자로 조합
// Src: 변환할 자모, 예: 'ㄱㅏㄹ'
// (Result): 조합된 글자, 예: '갈', 함수 호출 실패의 경우 ''을 반환한다.
function HanComPas(const Src: String): String;
var
  Buff: array[0..2] of Char;
begin
  Result := '';
  if Length(Src) = 6 then begin
    if HanCom(PChar(Src), Buff) then begin
      Buff[2] := #0;
      Result := String(Buff);
    end;
  end;
end;

end.
