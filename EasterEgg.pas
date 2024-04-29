unit EasterEgg;

interface

uses System.SysUtils, classes, Forms, Generics.Collections, TimerPool;

type
  TOnEasterEgg = procedure(msg: string) of object;

  TEasterEggClass = class
  private
    FEggStr: String; //에그문자(반드시 대문자로 할것)
    FControlKey: TShiftState; //조합키
    FOnEasterEgg: TOnEasterEgg;
  public
    property EggStr: String read FEggStr write FEggStr;
    property ControlKey: TShiftState read FControlKey write FControlKey;
    property OnEasterEgg: TOnEasterEgg read FOnEasterEgg write FOnEasterEgg;
  end;

  TEasternEgg = class(TObject)
  private
    FTempEggList: TList<TPair<string, TEasterEggClass>>;
    FEasterEggObjDic: TObjectDictionary<string, TEasterEggClass>;
    FCount: Integer;
    FOwner: TForm;
    FIsShiftClick: Boolean;
    FPJHTimerPool: TPJHTimerPool;

    procedure OnResetEasterEggEnable(Sender : TObject; Handle : Integer;
            Interval : Cardinal; ElapsedTime : LongInt);
  public
    constructor create(ADesc: string; AControlKey: TShiftState; AEgg: string;
      Owner: TForm; AOnEasterEgg: TOnEasterEgg=nil);
    destructor Destroy; override;
    function AddEgg2ObjDic(ADesc: string; AControlKey: TShiftState; AEgg: string;
      AOnEasterEgg: TOnEasterEgg=nil): Boolean;
    function GetEggListFromObjDic(AKey: Word; AShift: TShiftState): Boolean;
    Procedure CheckKeydown(var Key: Word; Shift: TShiftState);
    procedure CheckEggFromEggList(AKey: Word);
    procedure ExecuteEasternEgg(AItem: TPair<string, TEasterEggClass>);
  end;

implementation

{ TEasternEgg }

//TForm의 OnKeyDown에서 이 함수를 실행시킴
//ex) Egg.CheckKeydown(Key, Shift);
function TEasternEgg.AddEgg2ObjDic(ADesc: string; AControlKey: TShiftState;
  AEgg: string; AOnEasterEgg: TOnEasterEgg): Boolean;
var
  LEEggClass: TEasterEggClass;
begin
  Result := False;

  LEEggClass := TEasterEggClass.Create;
  LEEggClass.ControlKey := AControlKey;
  LEEggClass.EggStr := AEgg;
  LEEggClass.OnEasterEgg := AOnEasterEgg;

  FEasterEggObjDic.Add(ADesc, LEEggClass);

  Result := True;
end;

function TEasternEgg.GetEggListFromObjDic(AKey: Word;
  AShift: TShiftState): Boolean;
var
  Item: TPair<string, TEasterEggClass>;
begin
  for Item in FEasterEggObjDic do
  begin
    //Are the correct control keys down?
    if AShift = Item.Value.ControlKey then
    begin
      //첫번째 문자가 눌렸으면 FTempEggList에 추가함
      if AKey = Ord(Item.Value.EggStr[1]) then
      begin
        FTempEggList.Add(Item);
        FCount := 2;
      end;
    end;
  end;
end;

procedure TEasternEgg.OnResetEasterEggEnable(Sender: TObject; Handle: Integer;
  Interval: Cardinal; ElapsedTime: Integer);
begin
  FIsShiftClick := False;
  FTempEggList.Clear;
end;

procedure TEasternEgg.CheckEggFromEggList(AKey: Word);
var
  i, LCount: integer;
  Item: TPair<string, TEasterEggClass>;
begin
  LCount := FCount;

  for i := 0 to FTempEggList.Count - 1 do
  begin
    Item := FTempEggList[i];

    if AKey = Ord(Item.Value.FEggStr[LCount]) then
    begin
      if LCount = Length(Item.Value.FEggStr) then
      begin
        ExecuteEasternEgg(Item);
        //failure - reset the count
        LCount := 1;
      end
      else
      begin
        Inc(LCount);
      end;
    end;
  end;

  FCount := LCount;
end;

procedure TEasternEgg.CheckKeydown(var Key: Word; Shift: TShiftState);
begin
  if Shift <> [] then
  begin
    FPJHTimerPool.AddOneShot(OnResetEasterEggEnable, 1000);
    FIsShiftClick := True;

    if FTempEggList.Count = 0 then
      GetEggListFromObjDic(Key, Shift);

     CheckEggFromEggList(Key);
  end;

  //Are the correct control keys down?
//  if Shift = FControlKey then
//  begin
//    //was the proper key pressed?
//    if Key = Ord(FEgg[FCount]) then
//    begin
//      //was this the last keystroke in the sequence?
//      if FCount = Length(FEgg) then
//      begin
//        //Code of the easter egg
//        ExecuteEasternEgg;
//        //failure - reset the count
//        FCount := 1; {}
//      end
//      else
//      begin
//        //success - increment the count
//        Inc(FCount);
//      end;
//    end
//    else
//    begin
//      //failure - reset the count
//      FCount := 1;
//    end;
//  end;
end;

//ControlKey와 Egg를 조합하면 부활절 달걀이 나옴
//Owner는 KeyPreview가 필요하기 때문임
//ex)  Egg := TEasternEgg.Create([ssCtrl],'EGG',Self);
constructor TEasternEgg.create(ADesc: string; AControlKey: TShiftState;
  AEgg: string; Owner: TForm; AOnEasterEgg: TOnEasterEgg);
begin
  //Key, Value중에서 Value를 자동 해제하고자 함: doOwnsValues
  FEasterEggObjDic := TObjectDictionary<string, TEasterEggClass>.Create([doOwnsValues]);
  FCount := 1;
  FOwner := Owner;
  FOwner.KeyPreview := True;

  AddEgg2ObjDic(ADesc, AControlKey, AEgg, AOnEasterEgg);

  FTempEggList := TList<TPair<string, TEasterEggClass>>.Create;
  FPJHTimerPool:= TPJHTimerPool.Create(nil);
end;

destructor TEasternEgg.Destroy;
begin
  if Assigned(FPJHTimerPool) then
  begin
    FPJHTimerPool.RemoveAll;
    FreeAndNil(FPJHTimerPool);
  end;

  FTempEggList.Free;
  //ObjectList Free시에 TEasterEggClass도 자동 해제됨
  FEasterEggObjDic.Free;
end;

//실제로 실행되는 함수
//ex)
//    public
//      procedure East(msg: string);
//           ...
//      Egg.FOnEasterEgg := East;
procedure TEasternEgg.ExecuteEasternEgg(AItem: TPair<string, TEasterEggClass>);
begin
  if Assigned(AItem.Value.FOnEasterEgg) then
    AItem.Value.FOnEasterEgg(AItem.Value.FEggStr);

    //  if ADesc = '' then
//    exit;
//
//  if Assigned(FEasterEggObjDic.Items[ADesc].FOnEasterEgg) then
//    FEasterEggObjDic.Items[ADesc].FOnEasterEgg(FEasterEggObjDic.Items[ADesc].FEggStr);
//  if Assigned(FOnEasterEgg) then
//    FOnEasterEgg(FEgg);
end;

end.
