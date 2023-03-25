unit UnitMormotClientUtil;

interface

uses System.SysUtils,
  SynCommons, mORMot, mORMotHttpClient, mORMotDDD;

function GetClientWS(AIPAddrss, APortName, ATransmissionKey: string;
  AServiceInterfaces: array of TGUID; out AResultMsg: string): TSQLHttpClientWebsockets;
function GetRestClient(AIPAddrss, APortName, ATransmissionKey: string;
  AServiceInterfaces: array of TGUID; ATables: array of TSQLRecordClass; out AResultMsg: string): TSQLRestClientURI;
function GetRestService(AIPAddrss, APortName, ATransmissionKey: string;
  AServiceInterfaces: array of TGUID; ATables: array of TSQLRecordClass; out AResultMsg: string): ICQRSService;

implementation

function GetClientWS(AIPAddrss, APortName, ATransmissionKey: string;
  AServiceInterfaces: array of TGUID; out AResultMsg: string): TSQLHttpClientWebsockets;
begin
  AResultMsg := '';

  if AIPAddrss = '' then
    AIPAddrss := '127.0.0.1';

  Result := TSQLHttpClientWebsockets.Create(AIPAddrss,APortName,TSQLModel.Create([]));
  Result.Model.Owner := Result;
  AResultMsg := Result.WebSocketsUpgrade(ATransmissionKey);

  if AResultMsg = 'Impossible to connect to the Server' then
  begin
    FreeAndNil(Result);
    exit;
  end;

  if not Result.ServerTimeStampSynchronize then
  begin
    AResultMsg := 'Error ServerTimeStampSynchronize to the server';
    FreeAndNil(Result);
    exit;
//    raise EServiceException.Create(
//      'Error connecting to the server: please run InqManage.exe');
  end;

  Result.ServiceDefine(AServiceInterfaces, sicShared);//sicClientDriven
end;

function GetRestClient(AIPAddrss, APortName, ATransmissionKey: string;
  AServiceInterfaces: array of TGUID; ATables: array of TSQLRecordClass;
  out AResultMsg: string): TSQLRestClientURI;
var
  LIsLocal: Boolean;
begin
  LIsLocal := AIPAddrss = '';

  if LIsLocal then
  begin
    Result := TSQLRestClientURIDll.Create(TSQLModel.Create(ATables),@URIRequest);
    Result.Model.Owner := Result;
    Result.ServiceDefine(AServiceInterfaces,sicClientDriven);
  end
  else
  begin

  end;
end;

function GetRestService(AIPAddrss, APortName, ATransmissionKey: string;
  AServiceInterfaces: array of TGUID; ATables: array of TSQLRecordClass; out AResultMsg: string): ICQRSService;
var
  LSQLRestClientURI: TSQLRestClientURI;
begin
  LSQLRestClientURI := GetRestClient(AIPAddrss, APortName, ATransmissionKey,AServiceInterfaces,ATables,AResultMsg);
  LSQLRestClientURI.Services.Resolve(AServiceInterfaces[0], Result)
end;

end.
