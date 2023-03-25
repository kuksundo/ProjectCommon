(*
  * Copyright (c) 2013-2016 Thundax Macro Actions
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
  * modification, are permitted provided that the following conditions are
  * met:
  *
  * * Redistributions of source code must retain the above copyright
  *   notice, this list of conditions and the following disclaimer.
  *
  * * Redistributions in binary form must reproduce the above copyright
  *   notice, this list of conditions and the following disclaimer in the
  *   documentation and/or other materials provided with the distribution.
  *
  * * Neither the name of 'Thundax Macro Actions' nor the names of its contributors
  *   may be used to endorse or promote products derived from this software
  *   without specific prior written permission.
  *
  * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
  * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
  * TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
  * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
  * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
  * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
  * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
  * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
  * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
  * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*)
unit thundax.lib.actions_pjh;

interface

uses
  Generics.Collections;

type
  TDynGetMessage = procedure(AIndex: integer; var AMsg: string) of object;
  TExecuteFunction = procedure(AFuncName: string) of object;

  TActionType = (atNull, atMousePos, atMouseLClick, atMouseLDClick, atMouseRClick, atMouseRDClick, atKey,
    atMessage, atWait, atMessage_Dyn, atExecuteFunc, atMouseDrag, atDragBegin, atDragEnd);

  TActionTypeHelper = class(TObject)
    class function CastToString(action: TActionType): string;
    class function GetActionTypeFromDesc(description: string): TActionType;
  end;

  IAction = interface
    procedure Execute(ANotUseLerpWithMove: Boolean=False);
    function ToString(AIsCustom: Boolean=False): string;
    function GetActionType: TActionType;
    function GetVKExtendKey: integer;
    procedure SetVKExtendKey(AVK: integer);
    procedure SetVKAction(AVKAction: integer);
  end;

  TParameters<T> = class(TObject)
  private
    Fparam2: T;
    Fparam1: T;
    procedure Setparam1(const Value: T);
    procedure Setparam2(const Value: T);
  public
    property param1: T read Fparam1 write Setparam1;
    property param2: T read Fparam2 write Setparam2;
    function IntegerConverterP1(): Integer;
    function IntegerConverterP2(): Integer;
    function StringConverterP1(): String;
    function StringConverterP2(): String;
    constructor Create(param1: T; param2: T);
  end;

  TAction<T> = class(TInterfacedObject, IAction)
  private
    Fparam: TParameters<T>;
    Faction: TActionType;
    FCustomDesc: string;
    FVKExtendKey,//Mouse Drag시 누른 확장 KeyCode 저장
    FVKAction //1: VKExtendKey Down, 2: VKExtendKey Up
    : integer;

    procedure Setaction(const Value: TActionType);
    procedure Setparam(const Value: TParameters<T>);
    function getKey(key: String): Char;
    procedure TypeMessage(Msg: string);
    procedure TypeMessageUsingSendKey(Msg: string);
    procedure ExcuteKeyDown(AVKeyCode: integer);
    procedure ExcuteKeyUp(AVKeyCode: integer);
  public
    property action: TActionType read Faction write Setaction;
    property param: TParameters<T>read Fparam write Setparam;
    property CustomDesc: string read FCustomDesc write FCustomDesc;
    property VKExtendKey: integer read FVKExtendKey write FVKExtendKey;

    constructor Create(action: TActionType; param: TParameters<T>; ACustomDesc: string='');
    procedure Execute(ANotUseLerpWithMove: Boolean=False);
    function ToString(AIsCustom: Boolean=False): string;
    function GetActionType: TActionType;
    function GetVKExtendKey: integer;
    procedure SetVKExtendKey(AVK: integer);
    procedure SetVKAction(AVKAction: integer);
  end;

  TActionList = class(TList<IAction>)
    procedure SaveToFile(const FileName: string);
    procedure LoadFromFile(const FileName: string);
  public
    FNotUseLerpWithMove: Boolean;//False = Mouse Move(Drag) 시 Linear Interpolation 사용
  end;

function GenericAsInteger(const Value): Integer; inline;
function GenericAsString(const Value): string; inline;

var
  g_DynGetMessage: TDynGetMessage;
  g_ExecuteFunction: TExecuteFunction;

implementation

uses
  Windows,
  TypInfo,
  Variants,
  SysUtils,
//  dbxjson,
//  dbxjsonreflect,
  dialogs,
//  XMLDoc,
//  xmldom,
//  XMLIntf,
  UnitMouseUtil,
  sndkey32;

var
  lg_DragStartPoint: TPoint;

{ TParameters<T> }

function GenericAsInteger(const Value): Integer;
begin
  Result := Integer(Value);
end;

function GenericAsString(const Value): string;
begin
  Result := string(Value);
end;

constructor TParameters<T>.Create(param1, param2: T);
begin
  Setparam1(param1);
  Setparam2(param2);
end;

function TParameters<T>.IntegerConverterP1: Integer;
begin
  Result := GenericAsInteger(Fparam1);
end;

function TParameters<T>.IntegerConverterP2: Integer;
begin
  Result := GenericAsInteger(Fparam2);
end;

procedure TParameters<T>.Setparam1(const Value: T);
begin
  Fparam1 := Value;
end;

procedure TParameters<T>.Setparam2(const Value: T);
begin
  Fparam2 := Value;
end;

function TParameters<T>.StringConverterP1: String;
begin
  Result := GenericAsString(Fparam1);
end;

function TParameters<T>.StringConverterP2: String;
begin
  Result := GenericAsString(Fparam2);
end;

{ TAction<T> }

constructor TAction<T>.Create(action: TActionType; param: TParameters<T>; ACustomDesc: string);
begin
  Setaction(action);
  Setparam(param);

  if (atDragBegin = action) or (atMouseDrag = action) or (atDragEnd = action) then
    VKExtendKey := StrToIntDef(ACustomDesc, -1)
  else
    CustomDesc := ACustomDesc;
end;

procedure TAction<T>.ExcuteKeyDown(AVKeyCode: integer);
var
  ScanCode : Byte;
begin
  ScanCode:=Lo(MapVirtualKey(AVKeyCode,0));
  keybd_event(AVKeyCode, ScanCode, KEYEVENTF_EXTENDEDKEY,0);
end;

procedure TAction<T>.ExcuteKeyUp(AVKeyCode: integer);
var
  ScanCode : Byte;
begin
  ScanCode:=Lo(MapVirtualKey(AVKeyCode,0));
  keybd_event(AVKeyCode, ScanCode, KEYEVENTF_EXTENDEDKEY or KEYEVENTF_KEYUP,0);
end;

procedure TAction<T>.Execute(ANotUseLerpWithMove: Boolean);
var
  p: Integer;
  LMsg: string;
begin
  case Faction of
    atMousePos:
      SetCursorPos(param.IntegerConverterP1, param.IntegerConverterP2);
    atMouseLClick:
      begin
        mouse_event(MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0);
        mouse_event(MOUSEEVENTF_LEFTUP, 0, 0, 0, 0);
      end;
    atMouseLDClick:
      begin
        mouse_event(MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0);
        Sleep(10);
        mouse_event(MOUSEEVENTF_LEFTUP, 0, 0, 0, 0);
        Sleep(50);//GetDoubleClickTime;
        mouse_event(MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0);
        Sleep(10);
        mouse_event(MOUSEEVENTF_LEFTUP, 0, 0, 0, 0);
      end;
    atMouseRClick:
      begin
        mouse_event(MOUSEEVENTF_RIGHTDOWN, 0, 0, 0, 0);
        mouse_event(MOUSEEVENTF_RIGHTUP, 0, 0, 0, 0);
      end;
    atMouseRDClick:
      begin
        mouse_event(MOUSEEVENTF_RIGHTDOWN, 0, 0, 0, 0);
        Sleep(10);
        mouse_event(MOUSEEVENTF_RIGHTUP, 0, 0, 0, 0);
        Sleep(50);//GetDoubleClickTime;
        mouse_event(MOUSEEVENTF_RIGHTDOWN, 0, 0, 0, 0);
        Sleep(10);
        mouse_event(MOUSEEVENTF_RIGHTUP, 0, 0, 0, 0);
      end;
    atKey:
//      TypeMessage(getKey(param.StringConverterP1));
      TypeMessageUsingSendKey(param.StringConverterP1);
    atMessage:
//      TypeMessage(param.StringConverterP1);
      TypeMessageUsingSendKey(param.StringConverterP1);
    atWait:
      Sleep(param.IntegerConverterP1);// * 1000);
    atMessage_Dyn:
      begin
        if Assigned(g_DynGetMessage) then
        begin
          g_DynGetMessage(param.IntegerConverterP1, LMsg);
//          TypeMessage(LMsg);
          TypeMessageUsingSendKey(LMsg);
        end;
      end;
    atExecuteFunc:
      begin
        g_ExecuteFunction(param.StringConverterP1);
      end;
    atMouseDrag:
      begin
        if ANotUseLerpWithMove then
          SetCursorPos(param.IntegerConverterP1, param.IntegerConverterP2);
      end;
    atDragBegin:
      begin
        SetCursorPos(param.IntegerConverterP1, param.IntegerConverterP2);

        if VKExtendKey <> -1 then
        begin
          if FVKAction = 1 then
          begin
            ExcuteKeyDown(VKExtendKey);
          end
          else if FVKAction = 2 then
          begin
            ExcuteKeyUp(VKExtendKey);
          end;
        end;

        if ANotUseLerpWithMove then
          mouse_event(MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0)
        else
        begin
//          lg_DragStartPoint.X := param.IntegerConverterP1;
//          lg_DragStartPoint.Y := param.IntegerConverterP2;
        end;
      end;
    atDragEnd:
      begin
        if ANotUseLerpWithMove then
          mouse_event(MOUSEEVENTF_LEFTUP, 0, 0, 0, 0)
        else
        begin
          MoveMouse(param.IntegerConverterP1, param.IntegerConverterP2, 1);
        end;

        if VKExtendKey <> -1 then
          if FVKAction = 2 then
            ExcuteKeyUp(VKExtendKey);
      end;
  end;
end;

function TAction<T>.GetActionType: TActionType;
begin
  Result := Faction;
end;

function TAction<T>.getKey(key: String): Char;
begin
  if key = 'TAB' then
    Result := Char(VK_TAB);
  if key = 'CLEAR' then
    Result := Char(VK_CLEAR);
  if key = 'RETURN' then
    Result := Char(VK_RETURN);
  if key = 'SHIFT' then
    Result := Char(VK_SHIFT);
  if key = 'CONTROL' then
    Result := Char(VK_CONTROL);
  if key = 'ESCAPE' then
    Result := Char(VK_ESCAPE);
  if key = 'SPACE' then
    Result := Char(VK_SPACE);
  if key = 'LEFT' then
    Result := Char(VK_LEFT);
  if key = 'UP' then
    Result := Char(VK_UP);
  if key = 'RIGHT' then
    Result := Char(VK_RIGHT);
  if key = 'DOWN' then
    Result := Char(VK_DOWN);
  if key = 'INSERT' then
    Result := Char(VK_INSERT);
  if key = 'DELETE' then
    Result := Char(VK_DELETE);
  if key = 'F1' then
    Result := Char(VK_F1);
  if key = 'F2' then
    Result := Char(VK_F2);
  if key = 'F3' then
    Result := Char(VK_F3);
  if key = 'F4' then
    Result := Char(VK_F4);
  if key = 'F5' then
    Result := Char(VK_F5);
  if key = 'F6' then
    Result := Char(VK_F6);
  if key = 'F7' then
    Result := Char(VK_F7);
  if key = 'F8' then
    Result := Char(VK_F8);
  if key = 'F9' then
    Result := Char(VK_F9);
  if key = 'F10' then
    Result := Char(VK_F10);
  if key = 'F11' then
    Result := Char(VK_F11);
  if key = 'F12' then
    Result := Char(VK_F12);
end;

function TAction<T>.GetVKExtendKey: integer;
begin
  Result := FVKExtendKey;
end;

function TAction<T>.ToString(AIsCustom: Boolean): string;
var
  varRes: TVarType;
  description: string;
  x, y: Integer;
  p: string;
begin
  description := TActionTypeHelper.CastToString(Faction);

  if AIsCustom then
  begin
    Case PTypeInfo(TypeInfo(T))^.Kind of
      tkInteger:
        begin
          if Faction = atWait then
            description := description + ' ' + IntToStr(param.IntegerConverterP1) + ' (mSec)'
          else
          if Faction = atMessage_Dyn then
            description := description + ' (' + IntToStr(param.IntegerConverterP1) + ')'
          else
            description := description + ' (' + IntToStr(param.IntegerConverterP1) + ', ' + IntToStr(param.IntegerConverterP2) + ')';
        end;
      tkString, tkUString, tkChar, tkWChar, tkLString, tkWString, tkUnknown, tkVariant:
        begin
          if param.StringConverterP1 <> '' then
            description := description + ' (' + param.StringConverterP1 + ')';
        end;
    End;//case
  end
  else
  begin
    Case PTypeInfo(TypeInfo(T))^.Kind of
      tkInteger:
        begin
          if Faction = atWait then
            description := description + ' ' + IntToStr(param.IntegerConverterP1) + ' (mSec)'
          else
          if Faction = atMessage_Dyn then
            description := description + ' (' + IntToStr(param.IntegerConverterP1) + ')'
          else
            description := description + ' (' + IntToStr(param.IntegerConverterP1) + ', ' + IntToStr(param.IntegerConverterP2) + ')';
        end;
      tkString, tkUString, tkChar, tkWChar, tkLString, tkWString, tkUnknown, tkVariant:
        begin
          if param.StringConverterP1 <> '' then
            description := description + ' (' + param.StringConverterP1 + ')';
        end;
    End;//case
  end;

  if CustomDesc <> '' then
    description := CustomDesc + ' => ' + description;

  Result := description;
end;

//*********************************
//This code has been extracted from:
//http://stackoverflow.com/questions/9673442/how-can-i-send-keys-to-another-application-using-delphi-7
//http://stackoverflow.com/users/1211614/dampsquid
//*********************************
procedure TAction<T>.TypeMessage(Msg: string);
var
  CapsOn: boolean;
  i: Integer;
  ch: Char;
  shift: boolean;
  key: short;
begin
  CapsOn := (GetKeyState(VK_CAPITAL) and $1) <> 0;

  for i := 1 to length(Msg) do
  begin
    ch := Msg[i];
    ch := UpCase(ch);

    if ch <> Msg[i] then
    begin
      if CapsOn then
        keybd_event(VK_SHIFT, 0, 0, 0);
      keybd_event(ord(ch), 0, 0, 0);
      keybd_event(ord(ch), 0, KEYEVENTF_KEYUP, 0);
      if CapsOn then
        keybd_event(VK_SHIFT, 0, KEYEVENTF_KEYUP, 0);
    end
    else
    begin
//      key := VKKeyScan(ch);
      key := Ord(ch);
      if ((not CapsOn) and (ch >= 'A') and (ch <= 'Z')) or ((key and $100) > 0) then
        keybd_event(VK_SHIFT, 0, 0, 0);
      keybd_event(key, 0, 0, 0);
      keybd_event(key, 0, KEYEVENTF_KEYUP, 0);
      if ((not CapsOn) and (ch >= 'A') and (ch <= 'Z')) or ((key and $100) > 0) then
        keybd_event(VK_SHIFT, 0, KEYEVENTF_KEYUP, 0);
    end;
  end;
end;

procedure TAction<T>.TypeMessageUsingSendKey(Msg: string);
begin
  Msg := GetKeyStr4SendKey(Msg);
  SendKeys(PChar(Msg), True);
end;

procedure TAction<T>.Setaction(const Value: TActionType);
begin
  Faction := Value;
end;

procedure TAction<T>.Setparam(const Value: TParameters<T>);
begin
  Fparam := Value;
end;

procedure TAction<T>.SetVKAction(AVKAction: integer);
begin
  FVKAction := AVKAction;
end;

procedure TAction<T>.SetVKExtendKey(AVK: integer);
begin
  FVKExtendKey := AVK;
end;

{ TActionTypeHelper }

class function TActionTypeHelper.CastToString(action: TActionType): string;
begin
  case action of
    atMousePos:
      Result := 'Mouse position';
    atMouseLClick:
      Result := 'Mouse Left Click';
    atMouseLDClick:
      Result := 'Mouse Left Double Click';
    atMouseRClick:
      Result := 'Mouse Right Click';
    atMouseRDClick:
      Result := 'Mouse Right Double Click';
    atKey:
      Result := 'Press special key';
    atMessage:
      Result := 'Type message';
    atWait:
      Result := 'Waiting Time';
    atMessage_Dyn:
      Result := 'Dynamic message';
    atExecuteFunc:
      Result := 'Execute Function';
    atMouseDrag:
      Result := 'Mouse Drag';
    atDragBegin:
      Result := 'Drag Begin';
    atDragEnd:
      Result := 'Drag End';
  end;
end;

class function TActionTypeHelper.GetActionTypeFromDesc(
  description: string): TActionType;
begin
  if description = 'Mouse position' then
    result := atMousePos
  else
  if description = 'Mouse Left Click' then
    result := atMouseLClick
  else
  if description = 'Mouse Left Double Click' then
    result := atMouseLDClick
  else
  if description = 'Mouse Right Click' then
    result := atMouseRClick
  else
  if description = 'Mouse Right Double Click' then
    result := atMouseRDClick
  else
  if description = 'Press special key' then
    result := atKey
  else
  if description = 'Type message' then
    result := atMessage
  else
  if description = 'Wait (ms)' then
    result := atWait
  else
  if description = 'Dynamic message' then
    result := atMessage_Dyn
  else
  if description = 'Execute Function' then
    result := atExecuteFunc
  else
  if description = 'Mouse Drag' then
    result := atMouseDrag
  else
  if description = 'Drag Begin' then
    result := atDragBegin
  else
  if description = 'Drag End' then
    result := atDragEnd;
end;

{ TActionList }

procedure TActionList.LoadFromFile(const FileName: string);
begin

end;

procedure TActionList.SaveToFile(const FileName: string);
//var
//  Document: IXMLDocument;
//  iXMLRootNode, iNode: IXMLNode;
//  i: Integer;
begin
//  XMLDoc := TXMLDocument.Create(nil);
//  XMLDoc.Active := true;
//  for i := 0 to count-1 do
//  begin
//    Self[i].ToString
//  end;

end;

initialization
  g_DynGetMessage := nil;
end.
