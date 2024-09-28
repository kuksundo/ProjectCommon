unit UnitDateUtil;

interface

uses SysUtils, System.DateUtils;

const
  HoursPerDay   = 24;
  MinsPerHour   = 60;
  SecsPerMin    = 60;
  MSecsPerSec   = 1000;
  MinsPerDay    = HoursPerDay * MinsPerHour;
  SecsPerDay    = MinsPerDay * SecsPerMin;
  MSecsPerDay   = SecsPerDay * MSecsPerSec;
  FMSecsPerDay: Single = MSecsPerDay;
  IMSecsPerDay: integer = MSecsPerDay;
  DateDelta = 693594;
  UnixDateDelta = 25569;

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
//ADate의 시간을 00:00:01 로 설정하여 반환함
function GetBeginTimeOfTheDay(ADate:TDateTime): TDateTime;
//ADate의 시간을 23:59:59 로 설정하여 반환함
function GetEndTimeOfTheDay(ADate:TDateTime): TDateTime;
//초를 시분초로 분할
function GetSecTohhnnss(ASec: double): string;
//두 날짜의 차이를 00년00월00일 형식으로 반환(입사일과 퇴사일을 주면 근무일수를 년월일 형식으로 표시함)
procedure GetyymmddBetweenDate(AFrom, ATo: TDate; var Ayy, Amm, Add: word);
function DateTimeToMilliseconds(ADT: TDateTime): int64;
//시작일자 + 만료 개월수를 입력
//만료일자를 반환함
function GetExpireDateFromStartDateByMonth(AStartDate: TDate; ANumOfMonth: integer): TDate;
//DateTimeToUnix(value, False)와 동일함
function DateTimeToUnixNoUTC(const AValue: TDateTime): Int64;
//분을 시간과 남은 분으로 표시(2:30)
function GetHhnnFromMinute(const AMin: integer): string;
//분을 시간.분으로 표시(2.5)
function GetHhCommannFromMinute(const AMin: integer): string;

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

function GetBeginTimeOfTheDay(ADate:TDateTime): TDateTime;
var hour,min,sec,msec:word;
    year,mon,dat: word;
begin
  Decodedate(ADate,year,mon,dat);

  hour := 00;
  min := 00;
  sec := 01;
  msec := 000;

  Result := EncodeDateTime(year,mon,dat,hour,min,sec,msec);
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

function GetSecTohhnnss(ASec: double): string;
var
  r, r1, r2: double;
begin
  r := ASec;
  r1 := Trunc(r/60); //분
  r2 := Trunc(r1/60); //시
  r := r - (r1*60);
  r1 := r1 - (r2*60);

  Result := FloatToStr(r2) + '시' + FloatToStr(r1) + '분' + FloatToStr(r) + '초';
end;

procedure GetyymmddBetweenDate(AFrom, ATo: TDate; var Ayy, Amm, Add: word);
var
  d1, d2, m1, m2: word;
begin
  Ayy := 0;
  Amm := 0;
  Add := 0;
  d1 := 0;

  ATo := IncDay(ATo);
  Ayy := YearsBetween(AFrom, ATo);
  AFrom := IncYear(AFrom, Ayy);
  m1 := DaysInMonth(AFrom);
  m2 := DaysInMonth(ATo-1);
  d2 := DayOf(ATo-1);
  ATo := ATo-d2;

  if DayOf(AFrom) > 1 then
  begin
    d1 := m1 - DayOf(AFrom) + 1;
    AFrom := AFrom + d1;
  end;

  if AFrom < ATo then
  begin
    while AFrom + DaysInMonth(AFrom) < ATo + 1 do
    begin
      Inc(Amm);
      AFrom := AFrom + DaysInMonth(AFrom);
    end;
  end;

  if d1 = m1 then
  begin
    Inc(Amm);
    d1 := 0;
  end;

  if d1 = m2 then
  begin
    Inc(Amm);
    d2 := 0;
  end;

  d1 := d1 + d2;

  if d1 >= m1 then
  begin
    d1 := d1 - m1;
    Inc(Amm);
  end;

  if AFrom > ATo then
  begin
    Inc(Amm, -1);
    Add := d1;
    Ayy := Ayy + Amm div 12;
    Amm := Amm mod 12;
  end;
end;

function DateTimeToMilliseconds(ADT: TDateTime): int64;
asm // faster version by AB
       fld   ADT
       fmul  fmsecsperday
       sub   esp,8
       fistp qword ptr [esp]
       pop   eax
       pop   edx
       or    edx,edx
       mov   ecx,MSecsPerDay
       jns   @@1
       neg   edx
       neg   eax
       sbb   edx,0
  @@1: div   ecx
       mov   eax,edx // we only need ttimestamp.time = Milli Seconds count
end;

function GetExpireDateFromStartDateByMonth(AStartDate: TDate; ANumOfMonth: integer): TDate;
begin
  Result := IncMonth(AStartDate, ANumOfMonth);
end;

function DateTimeToUnixNoUTC(const AValue: TDateTime): Int64;
var
  LDate: TDateTime;
begin
  LDate := TTimeZone.Local.ToUniversalTime(AValue);
  Result := DateTimeToUnix(LDate);
end;

function GetHhnnFromMinute(const AMin: integer): string;
var
  LHour, LRemainMin: integer;
begin
  LHour := AMin div 60;
  LRemainMin := AMin mod 60;

  Result := Format('%d.2d:%.2d', [LHour, LRemainMin]);
end;

function GetHhCommannFromMinute(const AMin: integer): string;
var
  LHour: Double;
begin
  LHour := AMin / 60;

  Result := FormatFloat('0.0', LHour);
end;

end.

