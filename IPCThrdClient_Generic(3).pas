unit IPCThrdClient_Generic;
{
  IPCThrdClient Unit���� ������ �߰���
  1. ����͸� �̿��� ���� ��� ������(debug, client directory��)
  2. FState ���� ����
}

interface

uses Windows, Classes, SysUtils, IPCThreadEvent;

Type
{ TIPCClient2 }

  TIPCClient<TEventData> = class(TThread)
  private
    FWaitEvent: TIPCEvent<TEventData>;
    FIPCObject: TIPCObject<TEventData>;

    function GetSharedMemSize: integer;
  protected
    procedure Execute; override;
  public
    constructor Create(const AName, AConstName: string; AMalual: Boolean);
    destructor Destroy; override;
    procedure PulseMonitor(Data: TEventData);

    property SharedMemSize: Integer read GetSharedMemSize;
  end;

implementation

{ TIPCClient2 }

constructor TIPCClient<TEventData>.Create(const AName, AConstName: string;
  AMalual: Boolean);
begin
  inherited Create(True);

  FIPCObject := TIPCObject<TEventData>.Create(AName, AConstName);
  FWaitEvent := FIPCObject.FMonitorEvent;
end;

destructor TIPCClient<TEventData>.Destroy;
begin
  Terminate;
  FreeAndNil(FIPCObject);
  inherited Destroy;
end;

procedure TIPCClient<TEventData>.Execute;
begin
  //DbgStr(FName + ' Activated');

{  while not Terminated do
  try
    if WaitForSingleObject(FWaitEvent.Handle, INFINITE) <> WAIT_OBJECT_0 then Break;
      if Assigned(FIPCObject.OnSignal) then
        FIPCObject.OnSignal(FIPCObject, FWaitEvent.FData^);
  except
    on E:Exception do
      ;//DbgStr(Format('Exception raised in Thread Handler: %s at %X', [E.Message, ExceptAddr]));
  end;
}
  //DbgStr('Thread Handler Exited');
end;

function TIPCClient<TEventData>.GetSharedMemSize: integer;
begin
  Result := FWaitEvent.SharedMemSize;
  //Result := SizeOf(TEventData);
end;

procedure TIPCClient<TEventData>.PulseMonitor(Data: TEventData);
begin
  //DbgStr('Pulse Monitor');
  FIPCObject.FMonitorEvent.PulseData(Data);
end;

end.
 