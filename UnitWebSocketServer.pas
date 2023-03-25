unit UnitWebSocketServer;

interface

uses System.SysUtils,//System.Classes, DateUtils,
  SynCommons, mORMot, mORMotHttpServer;

type
  TpjhHttpWSServer = class
  public
    FModel: TSQLModel;
    FHTTPServer: TSQLHttpServer;
    FRestServer: TSQLRestServerFullMemory;
    FServiceFactoryServer: TServiceFactoryServer;
    FPortName,
    FTransmissionKey: string;
    FIsServerActive : Boolean;

    procedure CreateHttpServer4WS(APort, ATransmissionKey: string;
      aClient: TInterfacedClass; const aInterfaces: array of TGUID);
    procedure DestroyHttpServer;
  end;

implementation

{ TpjhHttpWSServer }

//사용예: CreateHttpServer4WS(TDTF.FPortName, TDTF.FTransmissionKey, TServiceIM4WS, [IInqManageService]);
procedure TpjhHttpWSServer.CreateHttpServer4WS(APort, ATransmissionKey: string;
  aClient: TInterfacedClass; const aInterfaces: array of TGUID);
begin
  if not Assigned(FRestServer) then
  begin
    // initialize a TObjectList-based database engine
    FRestServer := TSQLRestServerFullMemory.CreateWithOwnModel([]);
    // register our Interface service on the server side
    FRestServer.CreateMissingTables;
    FServiceFactoryServer := FRestServer.ServiceDefine(aClient, aInterfaces , sicShared);  //sicClientDriven, sicShared
    FServiceFactoryServer.SetOptions([], [optExecLockedPerInterface]). // thread-safe fConnected[]
      ByPassAuthentication := true;
  end;

  if not Assigned(FHTTPServer) then
  begin
    // launch the HTTP server
//    FPortName := APort;
    FHTTPServer := TSQLHttpServer.Create(APort, [FRestServer], '+' , useBidirSocket);

    if ATransmissionKey = '' then
      ATransmissionKey := 'OL_PrivateKey';

    FHTTPServer.WebSocketsEnable(FRestServer, ATransmissionKey);
    FIsServerActive := True;
  end;
end;

procedure TpjhHttpWSServer.DestroyHttpServer;
begin
  if Assigned(FHTTPServer) then
    FHTTPServer.Free;

  if Assigned(FRestServer) then
  begin
    //에러가 나서 주석 처리함(향후 원인 분석해야 함 - 2019.3.4
//    FRestServer.Free;
  end;

  if Assigned(FModel) then
    FreeAndNil(FModel);
end;

end.
