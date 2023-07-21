unit UnitDateUtil;

interface

uses SysUtils, System.DateUtils;

//��¥�� �Է� �޾Ƽ� �б⸦ ��ȯ��
function QuarterOf(ADate: TDateTime): word;
function IncQuarter(ADate: TDateTime): word;
function DecQuarter(ADate: TDateTime): word;
//�⵵�� �б⸦ �Է� �޾Ƽ� �б��� ù��° ��¥�� ��ȯ��
function GetBeginDateFromQuarter(AYear, AQuarter: word): TDateTime;
function GetEndDateFromQuarter(AYear, AQuarter: word): TDateTime;
function GetPrevQuarterFromQuarter(AQuarter: word): word;
function GetPrevYearFromQuarter(AYear, AQuarter: word): word;
function DateTimeMinusInteger(d1:TDateTime;i:integer;mType:integer;Sign:Char):TDateTime;
//ADate�� �ð��� 23:59:59 �� �����Ͽ� ��ȯ��
function GetEndTimeOfTheDay(ADate:TDateTime): TDateTime;

var pjhShortMonthNames : array[1..12] of string =
  ('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec');

implementation

function QuarterOf(ADate: TDateTime): word;
var
  ld, ald : double;
begin
  Result := MonthOf(ADate);
  Result := (Result + 2) div 3;

//  ld := 2.5 - Result;
//  ald := Abs(ld);
//  ald := ld / ald;
//  Result := Result + Round((ald * 2));

//  if Result <= 3 then
//    Result := 1
//  else if (Result > 3) and (Result <= 6)  then
//    Result := 2
//  else if (Result > 6) and (Result <= 9)  then
//    Result := 3
//  else if (Result > 9) and (Result <= 12)  then
//    Result := 4;
end;

function IncQuarter(ADate: TDateTime): word;
var
  q: integer;
begin
  Result := QuarterOf(ADate) + 1;

  if Result > 4 then
    Result := 1;
end;

function DecQuarter(ADate: TDateTime): word;
var
  q: integer;
begin
  Result := QuarterOf(ADate) - 1;

  if Result < 1 then
    Result := 4;
end;

function GetBeginDateFromQuarter(AYear, AQuarter: word): TDateTime;
var
  Lm: word;
begin
  case AQuarter of
    1: Lm := 1;
    2: Lm := 4;
    3: Lm := 7;
    4: Lm := 10;
  end;

  Result := EncodeDate(AYear, Lm, 1);
end;

function GetEndDateFromQuarter(AYear, AQuarter: word): TDateTime;
var
  Lm, Ld: word;
begin
  case AQuarter of
    1: Lm := 3;
    2: Lm := 6;
    3: Lm := 9;
    4: Lm := 12;
  end;

  Result := EndOfAMonth(AYear, Lm);
end;

function GetPrevQuarterFromQuarter(AQuarter: word): word;
begin
  if AQuarter = 1 then
    Result := 4
  else
    Result := AQuarter - 1;
end;

function GetPrevYearFromQuarter(AYear, AQuarter: word): word;
begin
  if AQuarter = 1 then
    Result := AYear - 1
  else
    Result := AYear;
end;

//��¥���� ������ ���ų� ���ؼ� ��ȯ��
//mType = 1 : '�ð�'���� ������ ���ų� ����
//        2 : '��'���� ������ ���ų� ����
//        3 : '�ʿ��� ������ ���ų� ����
//        4 : '��'���� ������ ���ų� ����
//        5 : '��' ���� ������ ���ų� ����
// '��'�ڴ� �ٷ� ������ ���ų� ���Ե� ������
function DateTimeMinusInteger(d1:TDateTime;i:integer;mType:integer;Sign:Char)
                                                                    :TDateTime;
var hour,min,sec,msec:word;
    year,mon,dat: word;
    tmp: integer;
begin
  Decodetime(d1,hour,min,sec,msec);
  Decodedate(d1,year,mon,dat);

  case mType of
    1:begin//�ð�
        tmp := 24;
      end;
    2:begin//��
        tmp := 24*60;
      end;
    3:begin//��
        tmp := 24*60*60;
      end;
    4:begin//��
      end;
    5:begin//��
      end;
  end;

  if Sign = '+' then
    Result := d1 + (i/tmp)
  else
    Result := d1 - (i/tmp);
end;

function GetEndTimeOfTheDay(ADate:TDateTime): TDateTime;
var hour,min,sec,msec:word;
    year,mon,dat: word;
begin
  Decodedate(ADate,year,mon,dat);

  hour := 23;
  min := 59;
  sec := 59;
  msec := 999;

  Result := EncodeDateTime(year,mon,dat,hour,min,sec,msec);
end;

end.
