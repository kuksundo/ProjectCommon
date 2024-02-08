unit UnitDFMUtil;

interface

uses Windows, System.SysUtils, System.classes, Vcl.Forms, Vcl.Controls,
  Vcl.Dialogs;

procedure DeleteAllComponents(ParentControl: TWinControl);
function ReadDFM(Form: TForm; const DFMName:string): integer;
function ReadFormAsText(const DFMName:string; Form: TForm):TForm;
procedure SaveToDFM(const FileName: string; ParentControl: TWinControl; AIsSaveToText: Boolean = False);
function LoadFromDFM(const FileName: string; ParentControl: TWinControl;
  AProc: TReaderError): integer;
procedure SaveToDFM2(const FileName: string; ParentControl: TWinControl);
function LoadFromDFM2(const FileName: string; ParentControl: TWinControl): integer;
procedure SaveBinDFM2TextDFM(const ABinFileName, ATextFileName: string;
  ParentControl: TWinControl; AProc: TReaderError);
procedure SaveTextDFM2BinDFM(const ATextFileName, ABinFileName: string;
  ParentControl: TWinControl);
procedure SaveBinDFM2TextDFMFromControl(AControl: TWinControl; ATextFileName: string);
function CheckDFMFormatFromStream(const AStream: TStream): TStreamOriginalFormat;

procedure SaveComponentToFile(Component: TComponent; const FileName: TFileName);
procedure LoadComponentFromFile(Component: TComponent; const FileName: TFileName);

function GetStringStreamFromControl(const AControl: TWinControl): TStringStream;

implementation

procedure DeleteAllComponents(ParentControl: TWinControl);
var
  I: Integer;
begin
  // Delete controls from ParentControl
  I := 0;
  // (rom) added Assigned for security
  if Assigned(ParentControl) then
  begin
    while I < ParentControl.ControlCount do
    begin
      //if ParentControl.Controls[I] is TJvCustomDiagramShape then
        ParentControl.Controls[I].Free;
        // Note that there is no need to increment the counter, because the
        // next component (if any) will now be at the same position in Controls[]
      //else
        Inc(I);
    end;
  end;
end;

function ReadDFM(Form: TForm; const DFMName: string): integer;
var
  Stream:TFileStream;
  DFMDataLen, LPosition:Integer;
  Reader:TReader;
  Flags:TFilerFlags;
  TypeName:string;
  //Form:TForm;
  Temp: Longint;
  RCType: Word;
  ret: word;

  LI: Longint;
  LB: Byte;
begin
  Result := 0;

  if not FileExists(DFMName) then
  begin
    Result := 1;
    Exit;
  end;

  try
    Stream:= TFileStream.Create(DFMName, fmOpenRead);
   //Stream.Read(LI, SizeOf(Longint));
   //if LI <> Longint(Signature) then
   //   raise Exception.Create('File "' + ExtractFileName(DFMName) +
   //     '" is not a Logic Form File');
   // Stream.Read(LB, SizeOf(Byte));
    Reader:= TReader.Create(Stream, Stream.Size);
    with Reader do
    begin
      Root:= Form;

      try
        BeginReferences;
        Read(RCType, SizeOf(RCType));

        if RcType <> $0AFF then
        // invalid file format or Delphi 5 form(text form file)
        begin
          if Reader <> nil then Reader.Free;
          if Stream <> nil then Stream.Free;
          //ret:= MessageDlg('This is not Logic Form!' +#10#13 +
          //    'Do you want read this form as text?', mtWarning, [mbYes, mbNo], 0);
          //if ret = mrYes then ReadFormAsText(DFMName, Form);
          ShowMessage('This is not Logic Form!');
          Exit;
        end;

        Position:= 3;                          // Resource Type

        while ReadValue <> vaNull do;          // Form Name

        Position:= Position + 2;        // Resource Flag($3010)
        Read(DFMDataLen, SizeOf(DFMDataLen));  // Resource Size
        ReadSignature;                         // 델파이 폼 식별 기호 ('TPF0')
        //ReadPrefix(Flags, LPosition);           // 폼 계승 여부 구별(ffInherited, ffChildPos)
        //Temp:= Position;
        //TypeName:= ReadStr;                    // Form Class Name (TForm1)
        //Self.Name := Reader.ReadStr;                  // Form Name (Form1)
        //Self.ClassName := Reader.ReadStr;                  // Form Name (Form1)
        //RenameSubClass(Form, TypeName);               // 폼의 ClassName을 재설정한다.
        //Position:= Temp;
        //Reader.OnFindMethod:= Self.OnFindMethodHandler;
        //Reader.OnError:= Self.OnReaderErrorHandler;
        ReadComponent(Form);
      finally//error가 났을 경우에 다시 파일을 오픈 할 수 있도록 하기 위해
        FixupReferences;
        EndReferences;

        if Reader <> nil then
          Reader.Free;
        if Stream <> nil then
          Stream.Free;
      end;//try
    end;//with
  except
    on EClassNotFound do Result := 3;
  end;
end;

function ReadFormAsText(const DFMName: string; Form: TForm): TForm;
var
  Input,Output:TMemoryStream;
  TempFormFileName: string;
begin
  Result:= nil;
  Input:= TMemoryStream.Create;
  Input.LoadFromFile(DFMName);
  Output:= TMemoryStream.Create;
  ObjectTextToResource(Input,Output);
  Output.SaveToFile(TempFormFileName);
  Output.LoadFromFile(TempFormFileName);

  Output.Position:=0;
 // ReadClass;
  try
    Output.ReadComponentRes(Form);
  finally
    Input.Free;
    OutPut.Free;
  end;

  Result:= Form;
end;

procedure SaveToDFM(const FileName: string; ParentControl: TWinControl; AIsSaveToText: Boolean);
var
  FS: TFileStream;
  MemoryStream: TMemoryStream;
  StringStream: TStringStream;
  Writer: TWriter;
  RealName: string;
begin
  if AIsSaveToText then
  begin
//    MemoryStream := TMemoryStream.Create;
//    try
//      Writer := TWriter.Create(MemoryStream, 4096);
//      try
//        WriteComp;
//      finally
//        Writer.Free;
//      end;
//
//      StringStream := TStringStream.Create;
//      try
//        MemoryStream.Position := 0;
//        ObjectBinaryToText(MemoryStream, StringStream);
//        StringStream.SaveToFile(FileName);
//      finally
//        StringStream.Free;
//      end;
//    finally
//      MemoryStream.Free;
//    end;
  end
  else
  begin
    FS := TFileStream.Create(FileName, fmCreate or fmShareDenyWrite);
    try
      Writer := TWriter.Create(FS, 4096);
      try
        Writer.Root := ParentControl;//.Owner;
        RealName := ParentControl.Name;
        ParentControl.Name := '';
        Writer.WriteComponent(ParentControl);
        ParentControl.Name := RealName;
      finally
        Writer.Free;
      end;
    finally
      FS.Free;
    end;
  end;
end;

function LoadFromDFM(const FileName: string; ParentControl: TWinControl;
  AProc: TReaderError): integer;
var //FileName은 반드시 절대 경로여야 함, 상대 경로는 에러 발생함
  FS: TFileStream;
  MemoryStream: TMemoryStream;
  StringStream: TStringStream;
  Reader: TReader;
  RealName: string;
  LDFMFormat: TStreamOriginalFormat;
begin
  Result := 0;

  if not FileExists(FileName) then
  begin
    Result := 1;
    Exit;
  end;

  MemoryStream := nil;

  DeleteAllComponents(ParentControl);

  FS := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  LDFMFormat := CheckDFMFormatFromStream(FS);

  case LDFMFormat of //TestStreamFormat(FS)
    sofBinary, sofUnknown: begin
      Reader := TReader.Create(FS, 4096);

      try
        Reader.OnError := AProc;
        // Save the parent's name, in case we are reading into a different
        // control than we saved the diagram from
        RealName := ParentControl.Name;
        Reader.Root := ParentControl;//.Owner;
        Reader.BeginReferences;
        try
          Reader.ReadComponent(ParentControl);
        finally
          if LDFMFormat <> sofText then
          begin
            Reader.FixupReferences;
            Reader.EndReferences;
          end;
        end;
        // Restore the parent's name
        ParentControl.Name := RealName;
      finally
        Reader.Free;
        FS.Free;
      end;
    end;//sofBinary

    sofText: begin
      MemoryStream := TMemoryStream.Create;

      try
        ObjectTextToBinary(FS, MemoryStream);
        MemoryStream.Position := 0;
        ParentControl := MemoryStream.ReadComponent(ParentControl) as TWinControl;
      finally
        FS.Free;

        if Assigned(MemoryStream) then
          MemoryStream.Free;
      end;

//      Reader := TReader.Create(MemoryStream, 4096);
    end;//sofText
  end;//case
end;

procedure SaveToDFM2(const FileName: string; ParentControl: TWinControl);
var
  Writer: TWriter;
  RealName: string;
  MemoryStream: TMemoryStream;
  StringStream: TStringStream;
begin
//  StoreProperties;
  MemoryStream := TMemoryStream.Create;
  try
    MemoryStream.WriteComponent(ParentControl);
    MemoryStream.Position := 0;
    StringStream := TStringStream.Create;
    try
      ObjectBinaryToText(MemoryStream, StringStream);
      StringStream.SaveToFile(FileName);
    finally
      StringStream.Free;
    end;
  finally
    MemoryStream.Free;
  end;
end;

function LoadFromDFM2(const FileName: string; ParentControl: TWinControl): integer;
var
  MemoryStream: TMemoryStream;
  StringStream: TStringStream;
begin
  Result := 0;

  if not FileExists(FileName) then
  begin
    Result := 1;
    Exit;
  end;

  StringStream := TStringStream.Create();
  try
    StringStream.LoadFromFile(FileName);
    StringStream.Position := 0;
    MemoryStream := TMemoryStream.Create;
    try
      ObjectTextToBinary(StringStream, MemoryStream);
      MemoryStream.Position := 0;
      ParentControl := MemoryStream.ReadComponent(ParentControl) as TWinControl;
    finally
      MemoryStream.Free;
    end;
  finally
    StringStream.Free;
  end;
//  RestoreProperties;
end;

procedure SaveBinDFM2TextDFM(const ABinFileName, ATextFileName: string;
  ParentControl: TWinControl; AProc: TReaderError);
var
  Reader: TReader;
  RealName: string;
  FS: TFileStream;
  MemoryStream: TMemoryStream;
  StringStream: TStringStream;
  LWinControl: TWinControl;
begin
  if not FileExists(ABinFileName) then
    Exit;

  FS := TFileStream.Create(ABinFileName, fmOpenRead or fmShareDenyWrite);
  Reader := TReader.Create(FS, 4096);
  try
    Reader.OnError := AProc;
    RealName := ParentControl.Name;
    Reader.Root := ParentControl;//.Owner;
    Reader.BeginReferences;
    try
      Reader.ReadComponent(ParentControl);
    finally
      Reader.FixupReferences;
      Reader.EndReferences;
    end;
    ParentControl.Name := RealName;
  finally
    Reader.Free;
    FS.Free;
  end;

  SaveBinDFM2TextDFMFromControl(ParentControl, AtextFileName);

//  MemoryStream := TMemoryStream.Create;
//  try
//    MemoryStream.WriteComponent(ParentControl);
//    MemoryStream.Position := 0;
//    StringStream := TStringStream.Create;
//    try
//      ObjectBinaryToText(MemoryStream, StringStream);
//      StringStream.SaveToFile(ATextFileName);
//    finally
//      StringStream.Free;
//    end;
//  finally
//    MemoryStream.Free;
//  end;
end;

procedure SaveTextDFM2BinDFM(const AtextFileName, ABinFileName: string;
  ParentControl: TWinControl);
var
  Writer: TWriter;
  RealName: string;
  FS: TFileStream;
  MemoryStream: TMemoryStream;
  StringStream: TStringStream;
  LWinControl: TWinControl;
begin
  if not FileExists(AtextFileName) then
    Exit;

  StringStream := TStringStream.Create();
  try
    StringStream.LoadFromFile(AtextFileName);
    StringStream.Position := 0;
    MemoryStream := TMemoryStream.Create;
    try
      ObjectTextToBinary(StringStream, MemoryStream);
      MemoryStream.Position := 0;
      ParentControl := MemoryStream.ReadComponent(ParentControl) as TWinControl;
    finally
      MemoryStream.Free;
    end;
  finally
    StringStream.Free;
  end;

  FS := TFileStream.Create(ABinFileName, fmCreate or fmShareDenyWrite);
  try
    Writer := TWriter.Create(FS, 4096);
    try
      Writer.Root := ParentControl;//.Owner;
      RealName := ParentControl.Name;
      ParentControl.Name := '';
      Writer.WriteComponent(ParentControl);
      ParentControl.Name := RealName;
    finally
      Writer.Free;
    end;
  finally
    FS.Free;
  end;
end;

procedure SaveBinDFM2TextDFMFromControl(AControl: TWinControl; ATextFileName: string);
var
  MemoryStream: TMemoryStream;
  StringStream: TStringStream;
begin
  MemoryStream := TMemoryStream.Create;
  try
    MemoryStream.WriteComponent(AControl);
    MemoryStream.Position := 0;
    StringStream := TStringStream.Create;
    try
      ObjectBinaryToText(MemoryStream, StringStream);
      StringStream.SaveToFile(ATextFileName);
    finally
      StringStream.Free;
    end;
  finally
    MemoryStream.Free;
  end;
end;

function CheckDFMFormatFromStream(const AStream: TStream): TStreamOriginalFormat;
const
  FilerSignature: Longint = $30465054; // ($54, $50, $46, $30) 'TPF0'
var
  Pos: Integer;
  Signature: Integer;
begin
  Pos := AStream.Position;
  Signature := 0;
  AStream.Read(Signature, SizeOf(Signature));
  AStream.Position := Pos;
  if (Byte(Signature) = $FF) or (Signature = Integer(FilerSignature)) or (Signature = 0) then
    Result := sofBinary
    // text format may begin with "object", "inherited", or whitespace
  else if Byte(Signature) in [Ord('o'), Ord('O'), Ord('i'), Ord('I')] then //, Ord(' ') , 13, 11, 9
    Result := sofText
  else if (Signature and $00FFFFFF) = $00BFBBEF then
    Result := sofUTF8Text
  else
    Result := sofUnknown;
end;

procedure SaveComponentToFile(Component: TComponent; const FileName: TFileName);
var
  FileStream : TFileStream;
  MemStream : TMemoryStream;
begin
  MemStream := nil;

  if not Assigned(Component) then
    raise Exception.Create('Component is not assigned');

  FileStream := TFileStream.Create(FileName,fmCreate);
  try
    MemStream := TMemoryStream.Create;
    MemStream.WriteComponent(Component);
    MemStream.Position := 0;
    ObjectBinaryToText(MemStream, FileStream);
  finally
    MemStream.Free;
    FileStream.Free;
  end;
end;

procedure LoadComponentFromFile(Component: TComponent; const FileName: TFileName);
var
  FileStream : TFileStream;
  MemStream : TMemoryStream;
  i: Integer;
begin
  MemStream := nil;

  if not Assigned(Component) then
    raise Exception.Create('Component is not assigned');

  if FileExists(FileName) then
  begin
    FileStream := TFileStream.Create(FileName,fmOpenRead);
    try
      for i := Component.ComponentCount - 1 downto 0 do
      begin
        if Component.Components[i] is TControl then
          TControl(Component.Components[i]).Parent := nil;
        Component.Components[i].Free;
      end;

      MemStream := TMemoryStream.Create;
      ObjectTextToBinary(FileStream, MemStream);
      MemStream.Position := 0;
      MemStream.ReadComponent(Component);
      Application.InsertComponent(Component);
    finally
      MemStream.Free;
      FileStream.Free;
    end;
  end;
end;

function GetStringStreamFromControl(const AControl: TWinControl): TStringStream;
var
  MemoryStream: TMemoryStream;
begin
  MemoryStream := TMemoryStream.Create;
  Result := TStringStream.Create;
  try
    MemoryStream.WriteComponent(AControl);
    MemoryStream.Position := 0;
    ObjectBinaryToText(MemoryStream, Result);
  finally
    MemoryStream.Free;
  end;
end;

end.
