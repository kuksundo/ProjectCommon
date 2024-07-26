unit UnitIndyUtil;

interface

uses System.SysUtils, Classes,
  IdCTypes, IdHTTP, IdSSL, IdSSLOpenSSL, IdSSLOpenSSLHeaders, IdURI, IdGlobal,
  IdIOHandler;

function HttpStart_Id(ARoot, AIpAddr, APort: string): boolean;
procedure HttpStop_Id;
procedure IdSSLIOHandlerSocketOpenSSLStatusInfoEx(ASender: TObject; const AsslSocket: PSSL;
  const AWhere, ARet: TIdC_INT; const AType, AMsg: string);
function HttpsGet_Id(pURL, pAuthorization: String): String;
function HttpsPost_Id(pURL, sParam1, sParam2, pAuthorization: String): String;
function GetUrlParams_Id(AUrl: string): TStringList;
function MakeUrlFromParam_Id(AParams: TStringList): string;
function IdBytesToString(const ABytes: TIdBytes): string;
procedure CopyInputBuffer(Comment: string; Source, Dest: TIdIOHandler);

var
  g_HTTPClient_Id: TIdHTTP;

implementation

function HttpStart_Id(ARoot, AIpAddr, APort: string): boolean;
var
  UseSSL: Boolean;
  SSLIoHandler: TIdSSLIoHandlerSocketOpenSSL;
  LStr: string;
begin
  g_HTTPClient_Id := TIdHttp.Create(nil);

  with g_HTTPClient_Id do
  begin
//    OnSelectAuthorization := HTTPSelectAuthorization;
    HTTPOptions := [hoInProcessAuth, hoForceEncodeParams, hoKeepOrigProtocol];
    Request.ContentType := 'application/json';
    HandleRedirects := False;
    ConnectTimeOut := 5000;
    ReadTimeOut := 5000;
//    OnStatus := HTTPStatus;
//    OnWorkEnd := HTTPWorkEnd;
//    Request.CustomHeaders := '';
//    Response.ProxyAuthenticate.
  end;

  if UseSSL and (SSLIoHandler = nil) then
  begin
    SSLIoHandler := TIdSSLIoHandlerSocketOpenSSL.Create(nil);
    SSLIoHandler.SSLOptions.Method := sslvTLSv1_2;
    SSLIoHandler.SSLOptions.Mode := sslmClient;
//    SSLIoHandler.OnGetPassword := SSLGetPassword;
    SSLIoHandler.SSLOptions.SSLVersions := [sslvTLSv1_2];
    SSLIoHandler.SSLOptions.CipherList := 'ALL';
    SSLIoHandler.SSLOptions.CertFile := 'aaa.crt';
    SSLIoHandler.SSLOptions.KeyFile := 'aaa.key';
//    SSLIoHandler.OnStatusInfoEx := IdSSLIOHandlerSocketOpenSSLStatusInfoEx;
//    SSLIoHandler.OnVerifyPeer := nil;
//    SSLIoHandler.OnGetPassword := nil;
  end;

  g_HTTPClient_Id.IOHandler := SSLIoHandler;
  LStr := g_HTTPClient_Id.Get('https://www.daum.net');
end;

procedure HttpStop_Id;
begin

end;

procedure IdSSLIOHandlerSocketOpenSSLStatusInfoEx(ASender: TObject; const AsslSocket: PSSL;
  const AWhere, ARet: TIdC_INT; const AType, AMsg: string);
begin
//  if AsslSocket.Version then
//  begin
//
//  end;
end;

//Https/Get
//pURL: 웹주소
//pAuthorization: 인증키
function HttpsGet_Id(pURL, pAuthorization: String): String;
var
  idhttps: TIdHttp;
  sslIOHandler: TIdSSLIoHandlerSocketOpenSSL;
  IStream: TStringStream;
begin
  try
    Result := '';
    idhttps := TIdHttp.Create();
    IStream := TStringStream.Create;
    sslIOHandler := TIdSSLIoHandlerSocketOpenSSL.Create(nil);
    try
      sslIOHandler.SSLOptions.Method := sslvSSLv23;
      sslIOHandler.SSLOptions.Mode := sslmClient;

      idhttps.IOHandler := sslIOHandler;

      idhttps.Request.CustomHeaders.Add(pAuthorization);
      idhttps.HandleRedirects := False;
      idhttps.Request.Method := 'GET';
      idhttps.Response.ContentType := 'application/json; charset=utf-8';
      idhttps.ConnectTimeOut := 5000;
      idhttps.ReadTimeOut := 5000;

      IStream.Position := 0;
      idhttps.Get(pURL, IStream, []);
    finally
      Result := TEncoding.UTF8.GetString(IStream.Bytes, 0, IStream.Size);
      FreeAndNil(IStream);
      FreeAndNil(idhttps);
      FreeAndNil(sslIOHandler);
    end;
  except
    On E: EIdHTTPProtocolException do
    begin
      Result := e.ErrorMessage;
      FreeAndNil(IStream);
      FreeAndNil(idhttps);
      FreeAndNil(sslIOHandler);
    end;
  end;
end;

//Https/Get
//pURL: 웹주소
//sParam1, sParam2: Parameter(name=value)
//pAuthorization: 인증키
function HttpsPost_Id(pURL, sParam1, sParam2, pAuthorization: String): String;
var
  idhttps: TIdHttp;
  sslIOHandler: TIdSSLIoHandlerSocketOpenSSL;
  IStream: TStringStream;
  sl: TStringList;
begin
  try
    Result := '';
    idhttps := TIdHttp.Create();
    IStream := TStringStream.Create;
    sl := TStringList.Create;
    sslIOHandler := TIdSSLIoHandlerSocketOpenSSL.Create(nil);
    try
      sslIOHandler.SSLOptions.Method := sslvSSLv23;
      sslIOHandler.SSLOptions.Mode := sslmClient;

      idhttps.IOHandler := sslIOHandler;

      idhttps.Request.CustomHeaders.Add(pAuthorization);
      idhttps.HandleRedirects := False;
      idhttps.Request.Method := 'POST';
      idhttps.Response.ContentType := 'application/json; charset=utf-8';
      idhttps.ConnectTimeOut := 5000;
      idhttps.ReadTimeOut := 5000;

      sl.Add(sParam1);
      sl.Add(sParam2);

      IStream.Position := 0;
      idhttps.Post(pURL, sl, IStream);
    finally
      Result := TEncoding.UTF8.GetString(IStream.Bytes, 0, IStream.Size);
      FreeAndNil(sl);
      FreeAndNil(IStream);
      FreeAndNil(idhttps);
      FreeAndNil(sslIOHandler);
    end;
  except
    On E: EIdHTTPProtocolException do
    begin
      Result := e.ErrorMessage;
      FreeAndNil(sl);
      FreeAndNil(IStream);
      FreeAndNil(idhttps);
      FreeAndNil(sslIOHandler);
    end;
  end;
end;

function GetUrlParams_Id(AUrl: string): TStringList;
var
  LUri: TIdURI;
  i: integer;
begin
  Result := TStringList.Create;
  Result.Delimiter := '&';
  Result.StrictDelimiter := True;

  LUri := TIdURI.Create(AUrl);
  try
    Result.DelimitedText := LUri.Params;
  finally
    LUri.Free;
  end;

  for i := 0 to Result.Count - 1 do
  begin
    Result.Strings[i] := StringReplace(Result.Strings[i], '+', ' ', [rfReplaceAll]);
    Result.Strings[i] := TIdURI.URLDecode(Result.Strings[i], enUTF8);
  end;
end;

//AParam[i]: 'AMethodName=GetDocPdf' 포맷으로 작성 됨
function MakeUrlFromParam_Id(AParams: TStringList): string;
var
  LUri: TIdURI;
  i: integer;
begin
  Result := '';

  for i := 0 to AParams.Count - 1 do
  begin
    AParams.Strings[i] := TIdURI.URLEncode(AParams.Names[i], enUTF8) + '=' +
      TIdURI.URLEncode(AParams.ValueFromIndex[i], enUTF8);
    AParams.Strings[i] := StringReplace(AParams.Strings[i], ' ', '+', [rfReplaceAll]);
  end;

  AParams.Delimiter := '&';
  AParams.StrictDelimiter := True;

  LUri := TIdURI.Create('');
  try
    LUri.Params := AParams.DelimitedText;
    Result := LUri.URI;
  finally
    LUri.Free;
  end;

end;

function IdBytesToString(const ABytes: TIdBytes): string;
var
  i: integer;
begin
  Result := '';

  for i := 0 to Length(ABytes) - 1 do
    Result := Result + Char(ABytes[i]);
end;

procedure CopyInputBuffer(Comment: string; Source, Dest: TIdIOHandler);
var
  Stream: TMemoryStream;
begin
  Stream := TMemoryStream.Create;
  try
    Source.InputBufferToStream(Stream);
    Stream.Position := 0;
    Dest.Write(Stream, Stream.Size);
//    Log(Comment + ' ' + IntToStr(Stream.Size) + ' bytes');
  finally
    FreeAndNil(Stream);
  end;
end;

end.
