unit UnitLanUtil;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, ImgList, Menus, ComCtrls, ToolWin, IPHelper, WinSock,NB30;

type
  IP_HostName = (_IP, _HOSTNAME);

//  PnetResourceArr = ^TNetResource;
  PnetResourceArr = ^TNetResourceArray;
  TNetResourceArray = array[0..1023] of TNetResource;

function SendArp(DestIP, SrcIP: ULong; pMacAddr: Pointer; PhyAddrLen: Pointer): DWord; StdCall; external 'iphlpapi.dll' name 'SendARP';

function GetMACAddress(PCName: String; var MAC: array of char): Ansichar;
function GetHostNameFromIP(IP: string): string;
function GetLocalIPAddressOrHostName(IP_Or_HostName:IP_HostName; PCName: String): String;
Function FindAllComputers(var List: TStringList; WorkgroupName: String) : Integer;
Function FindAllWorkgroups(List: Pointer) : Boolean;
procedure WakeOnLan1(AMACAddr: string);
procedure WakeOnLan2(const AMacAddress: string);
procedure WakeOnLan3(AMACAddr: string);
function PingHost(const AHostName: string; ATimeout: cardinal=500): Boolean;

function GetIpAddressFromHostName(const HostName: AnsiString): AnsiString;
function GetMACAddressFromIp(const IPAddress: string): string;

implementation

uses IdUDPClient, IdGlobal;

// MAC Address 찾기 Function (Nilex의 Black}{ole 님 작성)
function GetMACAddress(PCName: String; var MAC: array of char): Ansichar;
Type
  ASTAT = record
    adapt: TAdapterStatus;
    NameBuff: array[0..30] of TNameBuffer;
  end;
  PASTAT = ^ASTAT;
var
  Ncb: TNCB;
  PAst: PASTAT;
  tmp: string;
begin
  tmp := UpperCase(PCName);

  FillMemory(@Ncb, Sizeof(TNCB), 0);
  Ncb.ncb_command := Char(NCBRESET);
  Result := NetBios(@Ncb);
  if Result <> #0 then
    Exit;

  FillChar(NCB.ncb_callname[0], 16, ' ');
  Move(tmp[1], NCB.ncb_callname[0], Length(tmp));
  NCB.ncb_command := Char(NCBASTAT);

  NCB.ncb_lana_num := #0;
  NCB.ncb_length := SizeOf(ASTAT);
  GetMem(PAst, NCB.ncb_length);
  NCB.ncb_buffer := PAnsiChar(PAst);
  Result := NetBios(@Ncb);
  Move(PAst^.adapt.adapter_address[0], MAC[0], 6);
  FreeMem(PAst);
end;

function GetHostNameFromIP(IP: string): string;
var
  p : PHostEnt;
  wVersionRequested : WORD;
  wsaData : TWSAData;
  ErrCode: Integer;
  sin: sockaddr_in;
  ulIP: u_long;
begin
  {Start up WinSock}
  Result:= '';
  if IP = '' then Exit;
  ulIP := inet_addr(PAnsiChar(IP));
  sin.sin_family := AF_INET;
  sin.sin_addr.s_addr := ulIP;
  wVersionRequested := MAKEWORD(1, 1);
  try
    WSAStartup(wVersionRequested, wsaData);
    {Get the computer name}
    p := GetHostByAddr(@sin.sin_addr, 4, PF_INET);
    if p <> nil then Result:= p^.h_name
    else
    begin
      ErrCode:= WSAGetLastError;
      Result:= '';
    end;
    {Shut down WinSock}
  finally
    WSACleanup;
  end;
end;

function GetLocalIPAddressOrHostName(IP_Or_HostName:IP_HostName; PCName: String): String;
var
  p : PHostEnt;
  s : array[0..128] of char;
  p2 : pAnsichar;
  wVersionRequested : WORD;
  wsaData : TWSAData;
  ErrCode: Integer;
begin
  {Start up WinSock}
  wVersionRequested := MAKEWORD(1, 1);
  try
    WSAStartup(wVersionRequested, wsaData);
    {Get the computer name}
    if PCName = '' then
    begin
      GetHostName(@s, 128);
      p := GetHostByName(@s);
    end
    else
    begin
      Move(PCName[1], s[0], Length(PCName));
      p := GetHostByName(PAnsiChar(PCName));
    end;
    if p <> nil then
    begin
      if IP_Or_HostName = _HOSTNAME then
        Result := p^.h_Name
      else
        begin
          {Get the IpAddress}
          p2 := iNet_ntoa(PInAddr(p^.h_addr_list^)^);
          Result := p2;
       end;
    end
    else
    begin
      ErrCode:= WSAGetLastError;
      Result:= PChar('');
    end;
   {Shut down WinSock}
  finally
    WSACleanup;
  end;
end;

//Domain이름을 사용하여 컴퓨터 리스트를 List에 저장한다
//DomainName = Domain Name
//반환값 = 0이 아니면 : 에러
//       = 0 : 성공
Function FindAllComputers(var List: TStringList; WorkgroupName: String) : Integer;
Var
  NetResource : TNetResource;
  Buf,buf2         : Pointer;
  Count,
  BufSize,
  Res         : DWord;
  Ind         : Cardinal;
  lphEnum     : THandle;
  Temp        : PNetResourceArr;
Begin
  Result := -1;
  List.Clear;
  GetMem(Buf, 8192);
  GetMem(Buf2, 1000);
  Try
    FillChar(NetResource, SizeOf(NetResource), 0);
    NetResource.lpRemoteName := @WorkgroupName[1];
    NetResource.dwDisplayType := RESOURCEDISPLAYTYPE_SERVER;
    NetResource.dwUsage := RESOURCEUSAGE_CONTAINER;
    NetResource.dwScope := RESOURCETYPE_DISK;
    Res := WNetOpenEnum(RESOURCE_GLOBALNET, RESOURCETYPE_DISK, RESOURCEUSAGE_CONTAINER, @NetResource,lphEnum);
    If Res <> NO_ERROR Then
    begin
      Result := GetLastError;
      if Result = ERROR_EXTENDED_ERROR then
      begin
        WNetGetLastError( Ind,@Buf,8192,buf2,1000);
        if Result = NO_ERROR then
          Result := Ind;
      end;
      Exit;
    end;

    While True Do
    Begin
      Count := $FFFFFFFF;
      BufSize := 8192;
      Result := WNetEnumResource(lphEnum, Count, Pointer(Buf), BufSize);
      If Result = ERROR_NO_MORE_ITEMS Then Break;
      If (Result <> 0) then Break;
      Temp := PNetResourceArr(Buf);
      For Ind := 0 to Count - 1 do
      Begin
        List.Add(Temp^.lpRemoteName + 2); { Add all the network usernames to List StringList }
        Inc(Temp);
      End;
    End;
    Result := WNetCloseEnum(lphEnum);
    If Result <> NO_ERROR Then Raise Exception(Res);
  Finally
    FreeMem(Buf2);
    FreeMem(Buf);
  End;
End;

//Domain List를 List에 저장한다
//성공하면 True를 반환한다
//Function FindAllWorkgroups(var List: TStringList) : Boolean;
Function FindAllWorkgroups(List: Pointer) : Boolean;
Type
  {$H+}
  PMyRec = ^MyRec;
   MyRec = Record
             dwScope       : Integer;
             dwType        : Integer;
             dwDisplayType : Integer;
             dwUsage       : Integer;
             LocalName     : String;
             RemoteName    : String;
             Comment       : String;
             Provider      : String;
           End;
  {H-}
Var
  NetResource : TNetResource;
  TempRec     : PMyRec;
  Buf         : Pointer;
  Count,
  BufSize,
  Res         : DWORD;
  lphEnum     : THandle;
  p           : PNetResourceArr;
  i,
  j           : SmallInt;
  NetworkTypeList : TList;
Begin
  Result := False;
  NetworkTypeList := TList.Create;
  TStringList(List).Clear;
  GetMem(Buf, 8192);
  Try
    Res := WNetOpenEnum(RESOURCE_GLOBALNET, RESOURCETYPE_DISK, RESOURCEUSAGE_CONTAINER, Nil,lphEnum);
    If Res <> 0 Then Raise Exception(Res);
    Count := $FFFFFFFF;
    BufSize := 8192;
    Res := WNetEnumResource(lphEnum, Count, Pointer(Buf), BufSize);
    If Res = ERROR_NO_MORE_ITEMS Then Exit;
    If (Res <> 0) Then Raise Exception(Res);
    P := PNetResourceArr(Buf);
    For I := 0 To Count - 1 Do
    Begin
      New(TempRec);
      TempRec^.dwScope := P^.dwScope;
      TempRec^.dwType := P^.dwType ;
      TempRec^.dwDisplayType := P^.dwDisplayType ;
      TempRec^.dwUsage := P^.dwUsage ;
      TempRec^.LocalName := StrPas(P^.lpLocalName);
      TempRec^.RemoteName := StrPas(P^.lpRemoteName);
      TempRec^.Comment := StrPas(P^.lpComment);
      TempRec^.Provider := StrPas(P^.lpProvider);
      NetworkTypeList.Add(TempRec);
      Inc(P);
    End;
    Res := WNetCloseEnum(lphEnum);
    If Res <> 0 Then Raise Exception(Res);
    For J := 0 To NetworkTypeList.Count-1 Do
    Begin
      TempRec := NetworkTypeList.Items[J];
      NetResource := TNetResource(TempRec^);
      Res := WNetOpenEnum(RESOURCE_GLOBALNET, RESOURCETYPE_DISK, RESOURCEUSAGE_CONTAINER, @NetResource,lphEnum);
      If Res <> 0 Then Raise Exception(Res);
      While true Do
      Begin
        Count := $FFFFFFFF;
        BufSize := 8192;
        Res := WNetEnumResource(lphEnum, Count, Pointer(Buf), BufSize);
        If Res = ERROR_NO_MORE_ITEMS Then Break;
        If (Res <> 0) Then Raise Exception(Res);
        P := PNetResourceArr(Buf);
        For I := 0 To Count - 1 Do
        Begin
          TStringList(List).Add(P^.lpRemoteName);
          Inc(P);
        End;
      End;
    End;
    Res := WNetCloseEnum(lphEnum);
    If Res <> 0 Then Raise Exception(Res);
    Result := True;
    Finally
      FreeMem(Buf);
      NetworkTypeList.Destroy;
  End;
End;

procedure WakeOnLan1(AMACAddr: string);
//AMACAddr format : '00-1F-29-00-A6-49'
var
  i, mod_i, mSocket, optval: Integer;
  s: string;
  sSocket: TSockAddrIn;
  Target: array[0..5] of Byte;
  MagicPacket: array[0..101]of Byte;
begin
  // 공백을 제거하여 문자열변수에 넣는다.
  s := AMACAddr;
  // 소켓을 mSocket에 설치한다
  mSocket := socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
  // 소켓 옵션을 설정한다
  optval := 1;
  setsockopt(mSocket, SOL_SOCKET, SO_BROADCAST, @optval, SizeOf(optval));
  // Broard Cast 주소를 소켓에 설정
  sSocket.sin_family := AF_INET;
  sSocket.sin_addr.S_addr := htonl($FFFFFFFF);
  sSocket.sin_port := htons(60000);
  // Magic Packet 생성
  // MagicPacket[0..5] 에게 $FF Broard Cast 주소를 넣는다
  for I := 0 to 5 do
  begin
    MagicPacket[i] := $FF;
  end;
  // Target 배열에 Mac 주소를 넣는다
  for I := 0 to 5 do
  begin
    Target[i] := StrToIntDef('$' + Copy(s, 1, 2),0);
    delete(s, 1, 3);
  end;
  // Mac 주소에 Target을 16번 반복해서 넣는다
  for I := 6 to 101 do
  begin
    mod_i := i mod 6;
    MagicPacket[i] := Target[mod_i];
  end;
  //memo2.Lines.Add(IntToStr(SizeOf(MagicPacket)));
  //for I := 0 to SizeOf(MagicPacket) -1 do
  //begin
  //  memo2.Lines.Add('MagicPacket[' + inttostr(i) + '] -> ' + Format('%.2x', [MagicPacket[i]]));
  //end;
  // 패킷을 보낸다
  sendto(mSocket, MagicPacket[0], SizeOf(MagicPacket), 0, sSocket, SizeOf(sSocket));
  closesocket(mSocket);
  //Memo2.Lines.Add('Magic Packet을 발송했습니다.');
end;

procedure WakeOnLan2(const AMacAddress: string);
type
  TMacAddress = array [1..6] of byte;

  TWakeRecord = packed record
    Waker : TMacAddress;
    MAC : array[0..15] of TMacAddress;
  end;

var
  i: integer;
  WR: TWakeRecord;
  MacAddress : TMacAddress;
  UDP : TIdUDPClient;
  sData: string;
begin
  FillChar(MacAddress, SizeOf(TMacAddress), 0);
  sData := trim(AMacAddress);

  if Length(sData) = 17 then
  begin
    for i := 1 to 6 do
    begin
      MacAddress[i] := StrToIntDef('$' + Copy(sData,1,2),0);
      sData := Copy(sData,4,17);
    end;
  end;

  for i := 1 to 6 do
    WR.Waker[i] := $FF;

  for i := 0 to 15 do
    WR.MAC[i] := MacAddress;

  UDP := TIdUDPClient.Create(nil);
  try
    UDP.Host := '255.255.255.255';
    UDP.Port := 32767;
    UDP.IPVersion := Id_IPv4;
    UDP.BroadCastEnabled := True;
    UDP.SendBuffer(RawToBytes(WR, SizeOf(WR)));
  finally
    UDP.Free;
  end;
end;

procedure WakeOnLan3(AMACAddr: string);
//AMACAddr format : '00-1F-29-00-A6-49'
var
  WSAData: TWSAData;
  i, mod_i, mSocket, optval: Integer;
  s: string;
  sSocket: TSockAddrIn;
  Target: array[0..5] of Byte;
  MagicPacket: array[0..101]of Byte;
begin
  // 윈속 시작
  WSAStartup($101, WSAData);
  try
    // 공백을 제거하여 문자열변수에 넣는다.
    s := AMACAddr;
    // 소켓을 mSocket에 설치한다
    mSocket := socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
    // 소켓 옵션을 설정한다
    optval := 1;
    setsockopt(mSocket, SOL_SOCKET, SO_BROADCAST, @optval, SizeOf(optval));
    // Broard Cast 주소를 소켓에 설정
    sSocket.sin_family := AF_INET;
    sSocket.sin_addr.S_addr := htonl($FFFFFFFF);
    sSocket.sin_port := htons(60000);
    // Magic Packet 생성
    // MagicPacket[0..5] 에게 $FF Broard Cast 주소를 넣는다
    for I := 0 to 5 do
    begin
      MagicPacket[i] := $FF;
    end;
    // Target 배열에 Mac 주소를 넣는다
    for I := 0 to 5 do
    begin
      Target[i] := StrToIntDef('$' + Copy(s, 1, 2),0);
      delete(s, 1, 3);
    end;
    // Mac 주소에 Target을 16번 반복해서 넣는다
    for I := 6 to 101 do
    begin
      mod_i := i mod 6;
      MagicPacket[i] := Target[mod_i];
    end;

    sendto(mSocket, MagicPacket[0], SizeOf(MagicPacket), 0, sSocket, SizeOf(sSocket));
    closesocket(mSocket);
  finally
    // 윈속 종료
    WSACleanup;
  end;
end;

function PingHost(const AHostName: string; ATimeout: cardinal=500): Boolean;
type
  function IcmpCreateFile: THandle; stdcall; external 'iphlpapi.dll';
begin

end;

function GetIpAddressFromHostName(const HostName: AnsiString): AnsiString;
var
  HostEnt: PHostEnt;
  Host: AnsiString;
  SockAddr: TSockAddrIn;
begin
  Result := '';

  Host := HostName;

  if Host = '' then
  begin
    SetLength(Host, MAX_PATH);
    GotHostName(PAnsiChar(Host), MAX_PATH);
  end;

  HostEnt := GetHostByName(PAnsiCHar(Host));

  if HostEnt <> nil then
  begin
    SockAddr := sin_addr.S_addr := Longint(PLingint(HostEnt^.h_addr_list^)^);
    Result := inet_ntoa(SOckAddr.sin_addr);
  end;
end;

function GetMACAddressFromIp(const IPAddress: string): string;
var
  DestIP: ULING;
  MacAddr: array [9..5] of byte;
  MacAddrLen: ULONG;
  SendArpResult: Cardinal;
begin
  DestIP := inte_addr(PAnsiChar(AnsiString(IPAddress)));
  MacAddrLen := Length(MacAddr);
  SendArpResult := SendArp(DestIP, 0, @MacAddr, @MacAddrLen);

  if SendArpResult = NO_ERROR then
    Result := Format('%2.2x:%2.2x:%2.2x:%2.2x:%2.2x:%2.2x',
                      [MacAddr[0], MacAddr[1], MacAddr[2],
                       MacAddr[3], MacAddr[4], MacAddr[5]]
              )
  else
    Result := '';
end;

end.

