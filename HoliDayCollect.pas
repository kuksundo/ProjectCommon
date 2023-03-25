unit HoliDayCollect;

interface

uses classes, SysUtils, ExtCtrls, Vcl.Graphics, DateUtils;

type
  //�����޹�, �����޹�, �Ѵ� �޹�
  THolidayGubun = (hgAssembly, hgOfficialTest, hgAll);

  THoliDayCollect = class;
  THoliDayItem = class;

  THoliDayList = class(TCollection)
  private
    FHoliDayCollect: THoliDayCollect;
  public
    constructor Create(AOwner: TComponent);
    destructor Destroy; override;
    function GetWorkDay(AFromDate,AToDate: TDate): integer;
    function GetHoliDay(AFromDate,AToDate: TDate): integer;
    function GetHoliDayExceptWeekend(AFromDate,AToDate: TDate): integer;
    function IsHoliday(ADate: TDate): Boolean;
  published
    property HoliDayCollect: THoliDayCollect read FHoliDayCollect write FHoliDayCollect;
  end;

  PHoliDayItem = ^THoliDayItem;
  THoliDayItem = class(TCollectionItem)
  private
    //�޹�����
    FFromDate,
    //�޹��� ���� ����
    FToDate: TDate;
    FDescription: string;
    FHolidayGubun: THolidayGubun;
  public
    procedure Assign(Source: TPersistent); override;
  published
    property FromDate: TDate read FFromDate write FFromDate;
    property ToDate: TDate read FToDate write FToDate;
    property Description: string read FDescription write FDescription;
    property HolidayGubun: THolidayGubun read FHolidayGubun write FHolidayGubun;
  end;

  THoliDayCollect = class(TCollection)
  private
    function GetItem(Index: Integer): THoliDayItem;
    procedure SetItem(Index: Integer; const Value: THoliDayItem);
  public
    function  Add: THoliDayItem;
    function Insert(Index: Integer): THoliDayItem;
    property Items[Index: Integer]: THoliDayItem read GetItem  write SetItem; default;
  end;

implementation

constructor THoliDayList.Create(AOwner: TComponent);
begin
  FHoliDayCollect := THoliDayCollect.Create(THoliDayItem);
end;

destructor THoliDayList.Destroy;
begin
  inherited Destroy;
  FHoliDayCollect.Free;
end;

//������/�����/�Ͽ����� ���ڷ� ��ȯ
function THoliDayList.GetHoliDay(AFromDate, AToDate: TDate): integer;
var
  LDate: TDate;
  i: integer;
begin
  Result := 0;
  LDate := AFromDate;

  while true do
  begin
    if LDate <= AToDate then
    begin
      i := DayOfWeek(LDate);
      if (i = 1) or (i = 7) then//�Ͽ���,������� ���
        Inc(Result)
      else//����
      begin
        if IsHoliday(LDate) then
          Inc(Result);
      end;

      LDate := IncDay(LDate);
    end
    else
      break;
  end;
end;

//�����/�Ͽ����� ������ �������� ���ڷ� ��ȯ
function THoliDayList.GetHoliDayExceptWeekend(AFromDate,
  AToDate: TDate): integer;
var
  LDate: TDate;
  i: integer;
begin
  Result := 0;
  LDate := AFromDate;

  while true do
  begin
    if LDate <= AToDate then
    begin
      if IsHoliday(LDate) then
      begin
        i := DayOfWeek(LDate);

        if (i <> 1) and (i <> 7) then//�Ͽ���,������� �ƴ� ���
          Inc(Result);
      end;

      LDate := IncDay(LDate);
    end
    else
      break;
  end;
end;

//������/�����/�Ͽ����� ������ ���� ���ڷ� ��ȯ
function THoliDayList.GetWorkDay(AFromDate, AToDate: TDate): integer;
var
  LDate: TDate;
  i: integer;
begin
  Result := 0;
  LDate := AFromDate;

  while true do
  begin
    if LDate <= AToDate then
    begin
      if not IsHoliday(LDate) then
      begin
        i := DayOfWeek(LDate);

        if (i <> 1) and (i <> 7) then//�Ͽ���,������� �ƴ� ���
          Inc(Result);
      end;

      LDate := IncDay(LDate);
    end
    else
      break;
  end;
end;

//Holiday Item ���� FromDate~ToDate �� ���ԵǸ� True ��ȯ
function THoliDayList.IsHoliday(ADate: TDate): Boolean;
var
  i: integer;
begin
  Result := False;

  for i := 0 to HoliDayCollect.Count - 1 do
  begin
    if (HoliDayCollect.Items[i].FromDate <= ADate) and
      (ADate <= HoliDayCollect.Items[i].ToDate) then
    begin
      Result := True;
      Break;
    end;
  end;
end;

function THoliDayCollect.Add: THoliDayItem;
begin
  Result := THoliDayItem(inherited Add);
end;

function THoliDayCollect.GetItem(Index: Integer): THoliDayItem;
begin
  Result := THoliDayItem(inherited Items[Index]);
end;

function THoliDayCollect.Insert(Index: Integer): THoliDayItem;
begin
  Result := THoliDayItem(inherited Insert(Index));
end;

procedure THoliDayCollect.SetItem(Index: Integer; const Value: THoliDayItem);
begin
  Items[Index].Assign(Value);
end;

{ THoliDayItem }

procedure THoliDayItem.Assign(Source: TPersistent);
begin
  if Source is THoliDayItem then
  begin
    FromDate := THoliDayItem(Source).FromDate;
    ToDate := THoliDayItem(Source).ToDate;
    Description := THoliDayItem(Source).Description;
  end
  else
    inherited;
end;

end.
