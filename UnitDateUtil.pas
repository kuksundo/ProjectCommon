unit UnitDateUtil;

interface

uses SysUtils, System.DateUtils;

//날짜를 입력 받아서 분기를 반환함
function QuarterOf(ADate: TDateTime): word;
function IncQuarter(ADate: TDateTime): word;
function DecQuarter(ADate: TDateTime): word;
//년도와 분기를 입력 받아서 분기의 첫번째 날짜를 반환함
function GetBeginDateFromQuarter(AYear, AQuarter: word): TDateTime;
function GetEndDateFromQuarter(AYear, AQuarter: word): TDateTime;
function GetPrevQuarterFromQuarter(AQuarter: word): word;
function GetPrevYearFromQuarter(AYear, AQuarter: word): word;
function DateTimeMinusInteger(d1:TDateTime;i:integer;mType:integer;Sign:Char):TDateTime;
//ADate의 시간을 23:59:59 로 설정하여 반환함
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

//날짜에서 정수를 빼거나 더해서 반환함
//mType = 1 : '시간'에서 정수를 빼거나 더함
//        2 : '분'에서 정수를 빼거나 더함
//        3 : '초에서 정수를 빼거나 더함
//        4 : '년'에서 정수를 빼거나 더함
//        5 : '월' 에서 정수를 빼거나 더함
// '일'자는 바로 정수를 빼거나 더함도 가능함
function DateTimeMinusInteger(d1:TDateTime;i:integer;mType:integer;Sign:Char)
                                                                    :TDateTime;
var hour,min,sec,msec:word;
    year,mon,dat: word;
    tmp: integer;
begin
  Decodetime(d1,hour,min,sec,msec);
  Decodedate(d1,year,mon,dat);

  case mType of
    1:begin//시간
        tmp := 24;
      end;
    2:begin//분
        tmp := 24*60;
      end;
    3:begin//초
        tmp := 24*60*60;
      end;
    4:begin//년
      end;
    5:begin//월
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
