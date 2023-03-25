unit DataSave2FileOmniThread;

interface

uses Winapi.Windows, System.SysUtils, System.Classes, Winapi.Messages,
  OtlCommon, OtlComm, System.SyncObjs, OtlContainerObserver, Vcl.Forms;

type
  TCsvDataRecord = record
    FFileName: string;
    FCsvData: string;
    FFiePos: integer;   //soFromBeginning..soFromEnd
  end;

  TDataSave2FileOmniThread = class(TThread)
  protected
    procedure Execute; override;
  public
    FCsvMsgQueue: TOmniMessageQueue;
    FStopEvent: TEvent;
    FFileHandle: integer;
    FHeaderData: string;

    constructor Create;
    destructor Destroy; override;
    procedure Stop;
  end;

implementation

uses CommonUtil;

{ TDataSave2FileOmniThread }

constructor TDataSave2FileOmniThread.Create;
begin
  inherited Create(True);
  FreeOnTerminate := True;
  FStopEvent := TEvent.Create;
  FCsvMsgQueue := TOmniMessageQueue.Create(1000); //1000
  Resume;
end;

destructor TDataSave2FileOmniThread.Destroy;
begin
  Stop;
  FStopEvent.Free;

  inherited;
end;

procedure TDataSave2FileOmniThread.Execute;
var
  handles: array [0..1] of THandle;
  msg    : TOmniMessage;
  rec    : TCsvDataRecord;
begin
  handles[0] := FStopEvent.Handle;
  handles[1] := FCsvMsgQueue.GetNewMessageEvent;

  while WaitForMultipleObjects(2, @handles, false, INFINITE) = (WAIT_OBJECT_0 + 1) do
  begin
    if Terminated then
      exit;

    while FCsvMsgQueue.TryDequeue(msg) do
    begin
      rec := msg.MsgData.ToRecord<TCsvDataRecord>;

      //������ ó�� ������ ��� ���� �Ӹ��� ����� ������
      if SaveData2FixedFile('CSVFile', rec.FFileName, rec.FCsvData, soFromEnd) then
        SaveData2FixedFile('CSVFile', rec.FFileName, FHeaderData, soFromBeginning);
    end;
  end;
end;

//����Ÿ�� ����µ� �����ϸ� True�� ��ȯ��
procedure TDataSave2FileOmniThread.Stop;
begin
  FStopEvent.SetEvent;
end;

end.
