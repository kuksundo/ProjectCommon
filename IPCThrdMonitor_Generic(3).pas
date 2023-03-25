unit IPCThrdMonitor_Generic;
{
  2013.1.11 Generic���� ������
  IPCThrdMonitor Unit���� ������ �߰���
  1. ����͸� �̿��� ���� ��� ������(debug, client directory��)
  2. FState ���� ����
}

interface

uses Windows, Classes, SysUtils, IPCThreadEvent {$IFDEF USECODESITE} ,CodeSiteLogging {$ENDIF}
;

Type
{ TIPCMonitor_ECS }

  TIPCMonitor<TEventData> = class(TThread)
  private
    FTempStr: string;
    function GetSharedMemSize: integer;
  protected
    procedure DoOnSignal;
    procedure Execute; override;
  public
    FIPCObject: TIPCObject<TEventData>;
    FTermination: Boolean;
    FEventDataRecord: TEventData;

    constructor Create(const AName, AConstName: string; AMalual: Boolean);
    destructor Destroy; override;

    property SharedMemSize: Integer read GetSharedMemSize;
  end;

implementation

{ TIPCMonitor }

constructor TIPCMonitor<TEventData>.Create(const AName, AConstName: string; AMalual: Boolean);
begin
  inherited Create(True);

  FIPCObject := TIPCObject<TEventData>.Create(AName, AConstName);
end;

procedure TIPCMonitor<TEventData>.Execute;
var
  WaitResult: Integer;
begin
  //DbgStr(FName + ' Activated');
  while not Terminated do
  try
    {$IFDEF USECODESITE}
    CodeSite.EnterMethod('Enter TIPCMonitor<TEventData>.Execute');
    try
      CodeSite.Send('FIPCObject', FIPCObject.FMonitorEvent.Handle);
      CodeSite.Send('TThread Handle', Self.Handle);
//      CodeSite.Send('FIPCObject', FIPCObject.FMonitorEvent.FSharedMem.Name);
    {$ENDIF}

//    FTempStr := FIPCObject.FMonitorEvent.FSharedMem.Name;
    if FIPCObject.FMonitorEvent.Handle = 0 then
      terminate;

    WaitResult := WaitForSingleObject(FIPCObject.FMonitorEvent.Handle, INFINITE);

    {$IFDEF USECODESITE}
    finally
      CodeSite.ExitMethod('Exit TIPCMonitor<TEventData>.Execute');
    end;
    {$ENDIF}

    if FTermination then
      exit;

    if WaitResult = WAIT_OBJECT_0 then          { Monitor Event }
    begin
      //case FMonitorEvent.Kind of
      //  evClientSignal: //Client�� ���� ���� Signal�� ����
          DoOnSignal;

      //end;
    end
    else
      ;//DbgStr(Format('Unexpected Wait Return Code: %d', [WaitResult]));
  except
    on E:Exception do
      ;//DbgStr(Format('Exception raised in Thread Handler: %s at %X', [E.Message, ExceptAddr]));
  end;
  //DbgStr('Thread Handler Exited');
end;

function TIPCMonitor<TEventData>.GetSharedMemSize: integer;
begin
  Result := FIPCObject.FMonitorEvent.SharedMemSize;
end;

{ This method is called when the client has new data for us }

destructor TIPCMonitor<TEventData>.Destroy;
begin
  FIPCObject.OnSignal := nil;
  FIPCObject.FMonitorEvent.Pulse;
  FIPCObject.Free;

  Terminate;


//  inherited;
end;

procedure TIPCMonitor<TEventData>.DoOnSignal;
begin
  if Assigned(FIPCObject.OnSignal) then//and (FMonitorEvent.ID = FClientID) then
    FIPCObject.OnSignal(FIPCObject.FMonitorEvent.FData^);
end;

end.
