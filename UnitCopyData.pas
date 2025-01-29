unit UnitCopyData;

interface

uses Windows, Messages, SysUtils, System.Classes;

Const
  WParam_SENDWINHANDLE = 200;
  WParam_RECVHANDLEOK =  201;
  WParam_DISPLAYMSG = 202;
  WParam_FORMCLOSE = 203;
  WParam_REQMULTIRECORD = 204;
  WParam_CHANGECOPYMODE = 205;
  WM_MULTICOPY_BEGIN = 206;
  WM_MULTICOPY_END = 207;

type
  PCopyDataStruct = ^TCopyDataStruct;
  TCopyDataStruct = record
    dwData: LongInt;
    cbData: LongInt;
    lpData: Pointer;
  end;

  PRecToPass = ^TRecToPass;
  TRecToPass = record
    StrMsg : array[0..500] of char;
    StrSrcFormName : array[0..255] of char;
    iHandle : integer;
  end;

  PRecToPass2 = ^TRecToPass2;
  TRecToPass2 = record
    CompName : array[0..255] of char;//astring[255];
    PropName : array[0..255] of char;//string[255];
    Value: array[0..255] of char;//string[255];
    ValueType: integer;
//    StrSrcFormName : array[0..255] of char;
  end;

  PKbdShiftRec = ^TKbdShiftRec;
  TKbdShiftRec = record
    iHandle : THandle;
    MyHandle: THandle;
    FKbdShift: TShiftState;
    ParamDragMode: integer;
  end;

  procedure UnitCopyDataInit(_FormName: string; _msgHandle: THandle);
  function SendCopyData(FromFormName, ToFormName, Msg: string; MsgType: integer):integer;
  procedure SendCopyData2(ToHandle: integer; Msg: string; MsgType: integer; WParam: integer=0);
  procedure SendCopyData3(ToHandle: integer; ARec : TRecToPass; WParam: integer);
  procedure SendCopyData4(ToHandle: integer; Msg: string; WParam: integer);
  procedure SendHandleCopyData(AToHandle: integer; AMyHandle: THandle;
    AWaram: integer);
  procedure SendHandleCopyDataWithShift(AToHandle: integer; AMyHandle: THandle;
    AWaram: integer; AShift: TShiftState; ADragMode: integer);

var
  FormName4CopyData: string;   //�޼����� ������ �� �̸�
  msgHandle4CopyData: THandle; //�޼����� ���� �� �ڵ�

implementation

//�޼��� ���÷��̿� �ʿ��� �� �̸��� �ڵ��� �Ҵ��Ѵ�.
//�� Unit�� ����ϴ� Unit�ּ� �ѹ��� �� �����ؾ� ��
//FormName: �޼����� ���� Form Name
//msgHandle: �޼����� ������ ���� Form Handle(��� 0�� ��)
procedure UnitCopyDataInit(_FormName: string; _msgHandle: THandle);
begin
  FormName4CopyData := _FormName;
  msgHandle4CopyData := _msgHandle;
end;

//FromFormName: �޼����� ������ ���� �̸�, �ΰ� ����
//ToFormName: �޼����� �޴� ���� �̸�, �ΰ� �Ұ�
//Msg: �������� �ϴ� �޼���
//SrcHandle:�޼����� ������ ���� �ڵ�,Form1.Handle
//Result: ToForm Handle
function SendCopyData(FromFormName, ToFormName, Msg: string; MsgType: integer):integer;
var
  h : THandle;
  fname:array[0..255] of char;
  pfName: PChar;
  cd : TCopyDataStruct;
  rec : TRecToPass;
begin
  if ToFormName = '' then
    exit;
  pfName := @fname[0];
  StrPCopy(pfName,ToFormName);
  h := FindWindow(nil, pfName);
  if h <> 0 then
  begin
    with rec, cd do
    begin
      if Msg <> '' then
        StrPCopy(StrMsg,Msg);

      if FromFormName <> '' then
        StrPCopy(StrSrcFormName,FromFormName);

      iHandle := MsgType;
      dwData := 3232;
      cbData := sizeof(rec);
      lpData := @rec;
    end;//with

    SendMessage(h, WM_COPYDATA, 0, LongInt(@cd));
    Result := h;
  end;//if
end;

//ToHandle: �޼����� ������ ���� �ڵ�
//Msg: ������ ���ڿ�
//iMag: ������ ����
procedure SendCopyData2(ToHandle: integer; Msg: string; MsgType: integer;
  WParam: integer);
var
  cd : TCopyDataStruct;
  rec : TRecToPass;
begin
    with rec, cd do
    begin
      if Msg <> '' then
        StrPCopy(StrMsg,Msg);

      iHandle := MsgType;

      dwData := 3232;
      cbData := sizeof(rec);
      lpData := @rec;
    end;//with

    SendMessage(ToHandle, WM_COPYDATA, WParam, LongInt(@cd));
end;

procedure SendCopyData3(ToHandle: integer; ARec : TRecToPass; WParam: integer);
var
  cd : TCopyDataStruct;
begin
    with ARec, cd do
    begin
      dwData := 3232;
      cbData := sizeof(ARec);
      lpData := @ARec;
    end;//with

    SendMessage(ToHandle, WM_COPYDATA, WParam, LongInt(@cd));
end;

procedure SendCopyData4(ToHandle: integer; Msg: string; WParam: integer);
var
  cd : TCopyDataStruct;
begin
  with cd do
  begin
    dwData := 3232;
    cbData := Length(Msg)+1;
    lpData := PChar(Msg);
  end;//with

  SendMessage(ToHandle, WM_COPYDATA, WParam, LongInt(@cd));

end;
//��� const ����
procedure SendHandleCopyData(AToHandle: integer; AMyHandle: THandle;
  AWaram: integer);
var
  cd : TCopyDataStruct;
  rec : TKbdShiftRec;
begin
  with cd do
  begin
    dwData := AToHandle;
    cbData := sizeof(rec);//AMyHandle;
    rec.MyHandle := AMyHandle;
    lpData := @rec;
  end;//with

  SendMessage(AToHandle, WM_COPYDATA, AWaram, LongInt(@cd));
end;

//Ű ���¸� ������
procedure SendHandleCopyDataWithShift(AToHandle: integer; AMyHandle: THandle;
    AWaram: integer; AShift: TShiftState; ADragMode: integer);
var
  cd : TCopyDataStruct;
  rec : TKbdShiftRec;
begin
  with cd do
  begin
    dwData := AToHandle;
    cbData := sizeof(rec);//AMyHandle;
    rec.FKbdShift := AShift;
    rec.MyHandle := AMyHandle;
    rec.ParamDragMode := ADragMode;
//    rec.iHandle := 1;
    lpData := @rec;
  end;//with

  SendMessage(AToHandle, WM_COPYDATA, AWaram, LongInt(@cd));
end;

end.
