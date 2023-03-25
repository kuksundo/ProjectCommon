unit UnitNotifyScheduleClass;

interface

uses System.SysUtils, Classes, Generics.Legacy, BaseConfigCollect, UnitTimerPool;

type
  TpjhDay = (Mon=1, Tue, Wed, Thu, Fri, Sat, Sun);
  TpjhWeekDays = Mon..Fri;
  TpjhWeekend  = Sat..Sun;
  TpjhNotifyDays = set of TpjhDay;

  TNotifyTerminal = (ntNone, ntDesktop, ntMobile);
  TNotifyTerminals = set of TNotifyTerminal;

  TNotifyScheduleItem = class(TCollectionItem)
  private
    FIsPrivate,         //�����
    FIsEveryWeek,       //����
    FIsEveryMonth,      //�ſ�
    FIsAllDay: Boolean; //�Ϸ�����

    FNotifyDays: TpjhNotifyDays;
    FDuration: word; //���ӽð�(mSec)
    FBeginTime, FEndTime: TDateTime;
  public
  published
    property IsPrivate: Boolean read FIsPrivate write FIsPrivate;
    property IsEveryWeek: Boolean read FIsEveryWeek write FIsEveryWeek;
    property IsEveryMonth: Boolean read FIsEveryMonth write FIsEveryMonth;
    property IsAllDay: Boolean read FIsAllDay write FIsAllDay;
    property BeginTime: TDateTime read FBeginTime write FBeginTime;
    property EndTime: TDateTime read FEndTime write FEndTime;
    property Duration: word read FDuration write FDuration;
    property NotifyDays: TpjhNotifyDays read FNotifyDays write FNotifyDays;
  end;

  TNotifyScheduleCollect<T: TNotifyScheduleItem> = class(Generics.Legacy.TCollection<T>)
  end;

  TNotifyScheduleInfo = class(TpjhBase)
  private
    FNotifyScheduleCollect: TNotifyScheduleCollect<TNotifyScheduleItem>;
    //ConfigJSONClass�� �̿��Ͽ� ȯ�漳�� ���� ���� �ÿ� ���� CollectItem Index�� �����ϱ� ����
    FConfigItemIndex:integer;
  public
    constructor Create(AOwner: TComponent);
    destructor Destroy; override;
    procedure Clear;
    property ConfigItemIndex: integer read FConfigItemIndex write FConfigItemIndex;
  published
    property NotifyScheduleCollect: TNotifyScheduleCollect<TNotifyScheduleItem> read FNotifyScheduleCollect write FNotifyScheduleCollect;
  end;

  function NotifyDaySetToInteger(ss : TpjhNotifyDays) : integer;
  function IntegerToNotifyDaySet(mask : integer) : TpjhNotifyDays;

implementation

function NotifyDaySetToInteger(ss : TpjhNotifyDays) : integer;
var intset : TIntegerSet;
    s : TpjhDay;
begin
  intSet := [];
  for s in ss do
    include(intSet, ord(s));
  result := integer(intSet);
end;

function IntegerToNotifyDaySet(mask : integer) : TpjhNotifyDays;
var intSet : TIntegerSet;
    b : byte;
begin
  intSet := TIntegerSet(mask);
  result := [];
  for b in intSet do
    include(result, TpjhDay(b));
end;

{ TNotifyScheduleInfo }

procedure TNotifyScheduleInfo.Clear;
begin

end;

constructor TNotifyScheduleInfo.Create(AOwner: TComponent);
begin
  FNotifyScheduleCollect := TNotifyScheduleCollect<TNotifyScheduleItem>.Create;
end;

destructor TNotifyScheduleInfo.Destroy;
begin
  FNotifyScheduleCollect.Free;

  inherited;
end;

end.
