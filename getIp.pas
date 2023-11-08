unit getIp;

interface

uses Windows, Classes, SysUtils, WinSock, IpHlpApi, IpTypes, IdTCPClient,
  IdGlobal, IdStack;

function GetLocalIP(AIndex: integer = -1; AStrings: TStrings=nil) : string;
function GetLocalIPFromDesignated(ADesignatedIP: string) : string;
function GetLocalIPList : TStrings;
function GetLocalIPListUsingIndy : TStrings;
procedure RetrieveLocalAdapterInformation(strings: TStrings);
function CheckTCP_PortOpen(ipAddressStr: Ansistring; dwPort: Word): Boolean;
function IsPortActive(AHost : string; APort : Word): boolean;

implementation

uses UnitStringUtil;

function RemoveNonIp(AString: string): string;
var
 I: Integer;
begin
 Result := '';
 for I := 1 to Length(AString) do
   if (AString[I] in ['0'..'9','.']) then
     Result := Result + AString[I];
end;

// returns ISP assigned IP
//AIndex = -1 �̸� ��� ����� IP�� AStrings�� ��ȯ��
//AIndex = 0 �̸� ù��° ����� IP�� ��ȯ��
function GetLocalIP(AIndex: integer = -1; AStrings: TStrings=nil) : string;
type
    TaPInAddr = array [0..10] of PInAddr;
    PaPInAddr = ^TaPInAddr;
var
    phe  : PHostEnt;
    pptr : PaPInAddr;
    Buffer : array [0..63] of PAnsichar;
    I    : Integer;
    GInitData      : TWSADATA;
begin
  // WSAStartup�� ���� ���α׷��� �������� �Ұ��� �̿��� �� ���ʷ� ȣ���Ͽ�
  // �ٸ� ���� �Լ��� ����� �� �ֵ��� �ʱ�ȭ �Ѵ�.(�������� WSACleanup���)
  // �� �Լ��� ���� ���α׷��� �ʿ��� �������� ���� API�� ������ �˷��ְ�,
  // ���� ������ ���� ������ �����Ѵ�.
    WSAStartup($101, GInitData);
    Result := '';
    GetHostName(@Buffer, SizeOf(Buffer));
    phe :=GetHostByName(@buffer);
    if phe = nil then Exit;
    pptr := PaPInAddr(Phe^.h_addr_list);
    I := 0;

    while pptr^[I] <> nil do
    begin
      Result:=StrPas(inet_ntoa(pptr^[I]^));

      if AIndex = -1 then
      begin
        if Assigned(AStrings) then
          AStrings.Add(Result);
      end;

      if (AIndex = I) then
        exit;

      Inc(I);
    end;
    WSACleanup;
end;

//ADesignatedIP�� ���Ե� IP �뿪 �� ù��°�� ��ȯ��(ex: 10.)
function GetLocalIPFromDesignated(ADesignatedIP: string) : string;
var
  LIPList: TStringList;
  LStr: string;
  i: integer;
begin
  LIPList := TStringList.Create;
  try
    GetLocalIP(-1, LIPList);

    for i := 0 to LIPList.Count - 1 do
    begin
      LStr := Copy(LIPList.Strings[i], 1, Length(ADesignatedIP));

      if ADesignatedIP = LStr then
      begin
        Result := LIPList.Strings[i];
        exit;
      end;
    end;
  finally
    LIPList.Free;
  end;
end;

//IP List�� ��ȯ��
//
function GetLocalIPList : TStrings;
begin
  Result := TStringList.Create;
  GetLocalIP(-1, Result);
end;

function GetLocalIPListUsingIndy : TStrings;
var
  LList: TIdStackLocalAddressList;
  LTemp: TIdStackLocalAddress;
  i: integer;
begin
  Result := TStringList.Create;
  try
    TIdStack.IncUsage;//Instantiates GStack if needed
    try
//      LList := TIdStackLocalAddressList.Create;
//      try
//        GStack.GetLocalAddressList(LList);
//
//
//        for i := 0 to LList.Count - 1 do
//        begin
//          LTemp := LList[i];
//
//          if LTemp.IPVersion = Id_IPv4 then
//            Result.Add(LTemp.IPAddress);
//        end;
//      finally
//        LList.Free;
//      end;
      Result := GStack.LocalAddresses;
    finally
      TIdStack.DecUsage;
    end;
  except
    Result.Free;
    raise;
  end;
end;

procedure RetrieveLocalAdapterInformation(strings: TStrings);
var
  pAdapterInfo, pTempAdapterInfo: PIP_ADAPTER_INFO;
  AdapterInfo: IP_ADAPTER_INFO;
  BufLen: DWORD;
  Status: DWORD;
  strMAC: AnsiString;
  i: Integer;
begin
  strings.Clear;

  BufLen:= sizeof(AdapterInfo);
  pAdapterInfo:= @AdapterInfo;

  Status:= GetAdaptersInfo(nil, BufLen);
  pAdapterInfo:= AllocMem(BufLen);
  try
    Status:= GetAdaptersInfo(pAdapterInfo, BufLen);

    if (Status <> ERROR_SUCCESS) then
      begin
        case Status of
          ERROR_NOT_SUPPORTED:
            strings.Add('GetAdaptersInfo is not supported by the operating ' +
                        'system running on the local computer.');
          ERROR_NO_DATA:
            strings.Add('No network adapter on the local computer.');
        else
            strings.Add('GetAdaptersInfo failed with error #' + IntToStr(Status));
        end;
        Dispose(pAdapterInfo);
        Exit;
      end;

    while (pAdapterInfo <> nil) do
      begin
        strings.Add('Description: ' + pAdapterInfo^.Description);
        strings.Add('Name: ' + pAdapterInfo^.AdapterName);

        strMAC := '';
        for I := 0 to pAdapterInfo^.AddressLength - 1 do
            strMAC := strMAC + '-' + IntToHex(pAdapterInfo^.Address[I], 2);

        Delete(strMAC, 1, 1);
        strings.Add('MAC address: ' + strMAC);
        strings.Add('IP address: ' + pAdapterInfo^.IpAddressList.IpAddress.S);
        strings.Add('IP subnet mask: ' + pAdapterInfo^.IpAddressList.IpMask.S);
        strings.Add('Gateway: ' + pAdapterInfo^.GatewayList.IpAddress.S);
        strings.Add('DHCP enabled: ' + IntTOStr(pAdapterInfo^.DhcpEnabled));
        strings.Add('DHCP: ' + pAdapterInfo^.DhcpServer.IpAddress.S);
        strings.Add('Have WINS: ' + BoolToStr(pAdapterInfo^.HaveWins,True));
        strings.Add('Primary WINS: ' + pAdapterInfo^.PrimaryWinsServer.IpAddress.S);
        strings.Add('Secondary WINS: ' + pAdapterInfo^.SecondaryWinsServer.IpAddress.S);

        pTempAdapterInfo := pAdapterInfo;
        pAdapterInfo:= pAdapterInfo^.Next;
      if assigned(pAdapterInfo) then Dispose(pTempAdapterInfo);
    end;
  finally
    Dispose(pAdapterInfo);
  end;
end;

function ResolveAddress(HostName: String; out Address: DWORD): Boolean;
var  lpHost:        PHostEnt;
begin
  // Set default address
  Address := DWORD(INADDR_NONE);
  try
    // Check host name length
    if (Length(HostName) > 0) then begin
      // Try converting the hostname
      Address := inet_addr(PAnsiChar(HostName));
      // Check address
      if (DWORD(Address) = DWORD(INADDR_NONE)) then begin
        // Attempt to get host by name
        lpHost := gethostbyname(PAnsiChar(HostName));
        // Check host ent structure for valid ip address
        if Assigned(lpHost) and Assigned(lpHost^.h_addr_list^) then
          // Get the address from the list
          Address := u_long(PLongInt(lpHost^.h_addr_list^)^);
      end;// if (DWORD(Address) = DWORD(INADDR_NONE)) then begin
    end;// if (Length(HostName) > 0) then begin
  finally
    // Check result address
    if (DWORD(Address) = DWORD(INADDR_NONE)) then
      // Invalid host specified
      Result:= False
    else
      // Converted correctly
      Result := True;
  end;// try ... finally
end;

//function IsPortOpened(const Host: DWORD; Port: Integer): Boolean;
//const
//  szSockAddr = SizeOf(TSockAddr);
//var
//  WinSocketData: TWSAData;
//  Socket: TSocket;
//  Address: TSockAddr;
//begin
//  Result := False;// initialize result
//  if WinSock.WSAStartup(MakeWord(1, 1), WinSocketData) = 0 then // create WinSocketData
//  begin
//    Address.sin_family := AF_INET;// set address family
//    Address.sin_addr.S_addr := Host;// set the address
//    Socket := WinSock.Socket(AF_INET, SOCK_STREAM, IPPROTO_IP);// create a socket
//    if Socket = INVALID_SOCKET then WinSock.WSACleanup // if failed to create socket
//    else begin
//      Address.sin_port := WinSock.htons(Port); // set the port
//      SetSocketTimeOut(Socket, 300, 300); // set timeout
//      // attempt remote connection to Host on Port
//      if WinSock.Connect(Socket, Address, szSockAddr) = 0 then
//      begin
//        Result := True; // if succeeded return true
//        WinSock.closesocket(Socket); // close the socket
//      end;
//    end;
//  end;
//end;

function CheckTCP_PortOpen(ipAddressStr: Ansistring; dwPort: Word): Boolean;
  function PortTCPIsOpen(dwPort : Word; ipAddressStr:string) : boolean;
  var
    client : sockaddr_in;//sockaddr_in is used by Windows Sockets to specify a local or remote endpoint address
    sock   : Integer;
  begin
      client.sin_family      := AF_INET;
      client.sin_port        := htons(dwPort);//htons converts a u_short from host to TCP/IP network byte order.
      client.sin_addr.s_addr := inet_addr(PAnsiChar(ipAddressStr)); //the inet_addr function converts a string containing an IPv4 dotted-decimal address into a proper address for the IN_ADDR structure.
      sock  :=socket(AF_INET, SOCK_STREAM, 0);//The socket function creates a socket
      Result:=connect(sock,client,SizeOf(client))=0;//establishes a connection to a specified socket.
  end;
var
  ret    : Integer;
  wsdata : WSAData;
begin
  ret := WSAStartup($0002, wsdata);//initiates use of the Winsock
  if ret<>0 then exit;
  try
//    Writeln('Description : '+wsData.szDescription);
//    Writeln('Status      : '+wsData.szSystemStatus);

//    Result := PortTCPIsOpen(705,'10.14.21.117');
    Result := PortTCPIsOpen(dwPort,ipAddressStr);
  finally
    WSACleanup; //terminates use of the Winsock
  end;
end;

function IsPortActive(AHost : string; APort : Word): boolean;
var
  IdTCPClient : TIdTCPClient;
begin
  Result := False;
  try
    IdTCPClient := TIdTCPClient.Create(nil);
    try
      IdTCPClient.Host := AHost;
      IdTCPClient.Port := APort;
      IdTCPClient.ConnectTimeout := 3000;
      IdTCPClient.Connect;
      Result := True;
    finally
      IdTCPClient.Free;
    end;
  except
    //Ignore exceptions
  end;
end;

end.


