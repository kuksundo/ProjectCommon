unit UnitAddSystem.DateUtils_XE7;

interface

uses System.SysUtils, System.RTLConsts,System.Character, System.DateUtils,
  UnitAddSystem.RTLConsts_XE7;

type
  EDateTimeException = class(Exception);

function ISO8601ToDate(const AISODate: string; AReturnUTC: Boolean = True): TDateTime;
function DateToISO8601(const ADate: TDateTime; AInputIsUTC: Boolean = True): string;

implementation

type
  DTErrorCode = (InvDate, InvTime, InvOffset);

procedure DTFmtError(AErrorCode: DTErrorCode; const AValue: string);
const
  Errors: array[DTErrorCode] of string = (SInvalidDateString, SInvalidTimeString, SInvalidOffsetString);
begin
  raise EDateTimeException.CreateFmt(Errors[AErrorCode], [AValue]);
end;

function GetNextDTComp(var P: PChar; const PEnd: PChar;  ErrorCode: DTErrorCode;
  const AValue: string): string; overload;
begin
  Result := '';
  while ((P <= PEnd) and P^.IsDigit) do
  begin
    Result := Result + P^;
    Inc(P);
  end;
  if Result = '' then
    DTFmtError(ErrorCode, AValue);
end;

function GetNextDTComp(var P: PChar; const PEnd: PChar; const DefValue: string; Prefix: Char;
  IsOptional: Boolean; ErrorCode: DTErrorCode; const AValue: string): string; overload;
begin
  if (P >= PEnd) then
  begin
    Result := DefValue;
    Exit;
  end;

  if P^ <> Prefix then
  begin
    if IsOptional then
    begin
      Result := DefValue;
      Exit;
    end;
    DTFmtError(ErrorCode, AValue);
  end;
  Inc(P);

  Result := '';
  while ((P <= PEnd) and P^.IsDigit) do
  begin
    Result := Result + P^;
    Inc(P);
  end;
  if Result = '' then
    DTFmtError(ErrorCode, AValue);
end;

procedure DecodeISO8601Date(const DateString: string; var AYear, AMonth, ADay: Word);

  procedure ConvertDate(const AValue: string);
  const
    SDateSeparator: Char = '-';
  var
    P, PE: PChar;
  begin
    P := PChar(AValue);
    PE := P + (AValue.Length - 1);
    AYear := StrToInt(GetNextDTComp(P, PE, InvTime, AValue));
    AMonth := StrToInt(GetNextDTComp(P, PE, '00', SDateSeparator, True, InvDate, AValue));
    ADay := StrToInt(GetNextDTComp(P, PE, '00', SDateSeparator, True, InvDate, AValue));
  end;

var
  TempValue: string;
  LNegativeDate: Boolean;
begin
  AYear := 0;
  AMonth := 0;
  ADay := 1;

  LNegativeDate := (DateString[Low(string)] = '-');
  if LNegativeDate then
    TempValue := DateString.Substring(1)
  else
    TempValue := DateString;
  if Length(TempValue) < 4 then
    raise EDateTimeException.CreateFmt(SInvalidDateString, [TempValue]);
  ConvertDate(TempValue);
end;

procedure DecodeISO8601Time(const TimeString: string; var AHour, AMinute, ASecond, AMillisecond: Word;
  var AHourOffset, AMinuteOffset: Integer);
const
  STimeSeparator: Char = ':';
  SMilSecSeparator: Char = '.';
var
  LFractionalSecondString: string;
  P, PE: PChar;
  LOffsetSign: Char;
begin
  AHour := 0;
  AMinute := 0;
  ASecond := 0;
  AMillisecond := 0;
  AHourOffset := 0;
  AMinuteOffset := 0;
  if TimeString <> '' then
  begin
    P := PChar(TimeString);
    PE := P + (TimeString.Length - 1);
    AHour := StrToInt(GetNextDTComp(P, PE, InvTime, TimeString));
    AMinute := StrToInt(GetNextDTComp(P, PE, '00', STimeSeparator, False, InvTime, TimeString));
    ASecond := StrToInt(GetNextDTComp(P, PE, '00', STimeSeparator, True, InvTime, TimeString));
    LFractionalSecondString := GetNextDTComp(P, PE, '', SMilSecSeparator, True, InvTime, TimeString);
    if LFractionalSecondString <> '' then
      AMillisecond := StrToInt(LFractionalSecondString + StringOfChar('0', (3 - Length(LFractionalSecondString))));
    if P^.IsInArray(['-', '+']) then
    begin
      LOffsetSign := P^;
      Inc(P);
      if not P^.IsDigit then
        DTFmtError(InvTime, TimeString);
      AHourOffset  := StrToInt(LOffsetSign + GetNextDTComp(P, PE, InvOffset, TimeString));
      AMinuteOffset:= StrToInt(LOffsetSign + GetNextDTComp(P, PE, '00', STimeSeparator, True, InvOffset, TimeString));
    end;
  end;
end;

function AdjustDateTime(const ADate: TDateTime; AHourOffset, AMinuteOffset:Integer; IsUTC: Boolean = True): TDateTime;
var
  AdjustDT: TDateTime;
  BiasLocal: Int64;
  BiasTime: Word;
  BiasHour: Integer;
  BiasMins: Integer;
  BiasDT: TDateTime;
  TZ: TTimeZone;
begin
  Result := ADate;
  if IsUTC then
  begin
    { If we have an offset, adjust time to go back to UTC }
    if (AHourOffset <> 0) or (AMinuteOffset <> 0) then
    begin
      AdjustDT := EncodeTime(Abs(AHourOffset), Abs(AMinuteOffset), 0, 0);
      if ((AHourOffset * MinsPerHour) + AMinuteOffset) > 0 then
        Result := Result - AdjustDT
      else
        Result := Result + AdjustDT;
    end;
  end
  else
  begin
    { Now adjust TDateTime based on any offsets we have and the local bias }
    { There are two possibilities:
        a. The time we have has the same offset as the local bias - nothing to do!!
        b. The time we have and the local bias are different - requiring adjustments }
    TZ := TTimeZone.Local;
    BiasLocal := Trunc(TZ.GetUTCOffset(Result).Negate.TotalMinutes);
    BiasTime  := (AHourOffset * MinsPerHour) + AMinuteOffset;
    if (BiasLocal + BiasTime) = 0 then
      Exit;

    { Here we adjust the Local Bias to make it relative to the Time's own offset
      instead of being relative to GMT }
    BiasLocal := BiasLocal + BiasTime;
    BiasHour := Abs(BiasLocal) div MinsPerHour;
    BiasMins := Abs(BiasLocal) mod MinsPerHour;
    BiasDT := EncodeTime(BiasHour, BiasMins, 0, 0);
    if (BiasLocal > 0) then
      Result := Result - BiasDT
    else
      Result := Result + BiasDT;
  end;
end;

function ISO8601ToDate(const AISODate: string; AReturnUTC: Boolean = True): TDateTime;
const
  STimePrefix: Char = 'T';
var
  TimeString, DateString: string;
  TimePosition: Integer;
  Year, Month, Day, Hour, Minute, Second, Millisecond: Word;
  HourOffset, MinuteOffset: Integer;
begin
  HourOffset := 0;
  MinuteOffset := 0;
  TimePosition := AISODate.IndexOf(STimePrefix);
  if TimePosition >= 0 then
  begin
    DateString := AISODate.Substring(0, TimePosition);
    TimeString := AISODate.Substring(TimePosition + 1);
  end
  else
  begin
    Hour := 0;
    Minute := 0;
    Second := 0;
    Millisecond := 0;
    HourOffset := 0;
    MinuteOffset := 0;
    DateString := AISODate;
    TimeString := '';
  end;
  DecodeISO8601Date(DateString, Year, Month, Day);
  DecodeISO8601Time(TimeString, Hour, Minute, Second, Millisecond, HourOffset, MinuteOffset);
  Result := EncodeDateTime(Year, Month, Day, Hour, Minute, Second, Millisecond);
  Result := AdjustDateTime(Result, HourOffset, MinuteOffset, AReturnUTC);
end;

function DateToISO8601(const ADate: TDateTime; AInputIsUTC: Boolean = true): string;
const
  SDateFormat: string = 'yyyy''-''mm''-''dd''T''hh'':''nn'':''ss''.''zzz''Z'''; { Do not localize }
  SOffsetFormat: string = '%s%s%.02d:%.02d'; { Do not localize }
  Neg: array[Boolean] of string = ('+', '-'); { Do not localize }
var
  Bias: Integer;
  TimeZone: TTimeZone;
begin
  Result := FormaTDateTime(SDateFormat, ADate);
  if not AInputIsUTC then
  begin
    TimeZone := TTimeZone.Local;
    Bias := Trunc(TimeZone.GetUTCOffset(ADate).Negate.TotalMinutes);
    if Bias <> 0 then
    begin
      // Remove the Z, in order to add the UTC_Offset to the string.
      SetLength(Result, Result.Length - 1);
      Result := Format(SOffsetFormat, [Result, Neg[Bias > 0], Abs(Bias) div MinsPerHour,
        Abs(Bias) mod MinsPerHour]);
    end
  end;
end;

end.
