UNIT UnitExcelUtil;

interface

uses SysUtils, StdCtrls,Classes, Graphics, Grids, ComObj, StrUtils,
    Variants, Dialogs, Forms, Excel2010, Office2010, NxColumnClasses, NxColumns, NxGrid;

procedure GridToExcel (GenericStringGrid :TStringGrid ; XLApp :TExcelApplication);
function GetIncXLColumn(AColChar: string): string;
function GetDecXLColumn(AColChar: string): string;
function GetExcelColumnAlphabetByInt(AIndex: integer): string;
procedure NextGridToExcel(ANextGrid :TNextGrid; ASheetName: string = '';
  ASaveFileName: string=''; ASkipHideColumn: Boolean=True);
//procedure Database2Excel(DbQuery: TQuery);
//procedure ExcelToStrGrid(sFileName: String; svGrid: TStringGrid);
//procedure DataSetToExcelFile(const Dataset: TDataset;const Filename: string);
procedure ChangePasswdXLFile(FName,FName2,Passwd: string);
function GetActiveExcelOleObject(AVisible: boolean) : Variant;
function GetActiveOrCreateExcelOleObject(AVisible: boolean; var AIsCreated: Boolean) : Variant;
function PutValInExcel(excSheet : Variant; const sName, sValue : string; Mess : boolean; var iRow, iCol : integer): boolean;
function GetLastRowNumFromExcel(AWorksheet: OleVariant): integer;
function GetLastColNumFromExcel(AWorksheet: OleVariant): integer;
procedure SetExcelCellRangeBorder(ARange: ExcelRange);
procedure SetExcelCellRangeBorderOle(ARange: variant);
function GetExcelVersion(XLApp :TExcelApplication): string;
function XlsInit(AVisible: boolean): ExcelApplication;
procedure XlsFinal(var AExcelApp: ExcelApplication);
function XlsWBSave2Pdf(AExcelWB: OleVariant; APdfFileName: string): Boolean;
function XlsWBSave2CSV(AExcelWB: OleVariant; ACsvFileName: string): Boolean;
function XlsSave2CSV(AXlsFileName: string): string;
procedure XlsWSStrFindAndReplaceAll(AWorksheet: OleVariant; AOldStr, ANewStr: string);
procedure XlsStrFindAndReplaceAll(AFileName, AOldStr, ANewStr: string);
procedure SetExcelColumnHeader(AWorksheet: OleVariant; AColName, ARange: string);
procedure SetExcelColumnHeaderFromList(AWorksheet: OleVariant; AList: TStringList);
function CheckExcelColumnHeader(AWorksheet: OleVariant; AColName, ARange: string): Boolean;
function CheckExcelColumnHeaderFromList(AWorksheet: OleVariant; AList: TStringList): Boolean;
function GetFileNameFromStream(const AStream: TStream): string;
procedure SetValueCheckBoxByNameOnWorkSheet(AWorksheet: OleVariant; ACBName: string; AIsCheck: Boolean);
function CheckWorksheetExistByName(AWorkBook: OleVariant; ASheetName: string): Boolean;
function AddSheet2WorkBookByName(AWorkBook: OleVariant; ASheetName: string; AIsCheckExist: Boolean=True): OleVariant;
function CopySheet2WorkBookByName(AWorkBook: OleVariant; ASrcSheetName, ADestSheetName: string; AIsCheckExist: Boolean=True): OleVariant;
function DeleteSheetFromWorkBookByName(AWorkBook: OleVariant; ASheetName: string): Boolean;

procedure SetValueCheckBoxByTextOnWorkSheet(AWorksheet: OleVariant; AText: string; AIsCheck: Boolean);

function GetChcekBoxNameByTextOnWorkSheet(AWorksheet: OleVariant; AText: string): string;
function GetCheckBoxByTextOnWorkSheet(AWorksheet: OleVariant; AText: string): OleVariant;

function XlsRangeCopyNInsert2WS(AWorksheet: OleVariant; ASrcRangeStr, ADestRangeStr: string): OleVariant;
function XlsRowCopyNInsert2WS(AWorksheet: OleVariant; ASrcRow, ADestRow: integer): OleVariant;

implementation

uses UnitMiscUtil;

//StringGrid의 내용을 MSExcel에 넣어주는 함수
//TExcelApplication의 ConnectKind Property 를 ckNewInstance로 설정해야함
procedure GridToExcel (GenericStringGrid :TStringGrid ; XLApp :TExcelApplication);
var
  WorkBk : _WorkBook; //  Define a WorkBook
  WorkSheet : _WorkSheet; //  Define a WorkSheet
  I, J, K, R, C : Integer;
  IIndex : OleVariant;
  TabGrid : Variant;
begin
  if GenericStringGrid.Cells[0,1] <> '' then
  begin
    IIndex := 1;
    R := GenericStringGrid.RowCount;
    C := GenericStringGrid.ColCount;
    // Create the Variant Array
    TabGrid := VarArrayCreate([0,(R - 1),0,(C - 1)],VarOleStr);
    I := 0;
    //  Define the loop for filling in the Variant
    repeat
      for J := 0 to (C - 1) do
        TabGrid[I,J] := GenericStringGrid.Cells[J,I];
      Inc(I,1);
    until

    I > (R - 1);

    // Connect to the server TExcelApplication
    XLApp.Connect;
    // Add WorkBooks to the ExcelApplication
    XLApp.WorkBooks.Add(xlWBatWorkSheet,0);
    // Select the first WorkBook
    WorkBk := XLApp.WorkBooks.Item[IIndex];
    // Define the first WorkSheet
    WorkSheet := WorkBk.WorkSheets.Get_Item(1) as _WorkSheet;
    // Assign the Delphi Variant Matrix to the Variant associated with the WorkSheet
    Worksheet.Range['A1',Worksheet.Cells.Item[R,C]].Value2 := TabGrid;
    // Customise the WorkSheet
    WorkSheet.Name := 'Customers';
    Worksheet.Columns.Font.Bold := True;
    Worksheet.Columns.HorizontalAlignment := xlRight;
    WorkSheet.Columns.ColumnWidth := 14;
    // Customise the first entire Column
    WorkSheet.Range['A' + IntToStr(1),'A' + IntToStr(R)].Font.Color := clBlue;
    WorkSheet.Range['A' + IntToStr(1),'A' + IntToStr(R)].HorizontalAlignment := xlHAlignLeft;
    WorkSheet.Range['A' + IntToStr(1),'A' + IntToStr(R)].ColumnWidth := 31;
    // Show Excel
    XLApp.Visible[0] := True;
    // Disconnect the Server
    XLApp.Disconnect;
    // Unassign the Delphi Variant Matrix
    TabGrid := Unassigned;
  end;
end;

function GetIncXLColumn(AColChar: string): string;
var
  LChar: Char;
begin
  if AColChar = '' then
  begin
    Result := 'A';
    exit;
  end;

  LChar := AColChar[AColChar.Length];
  Result := LeftStr(AColChar, AColChar.Length - 1);

  if LChar = 'Z' then
  begin
    Result := GetIncXLColumn(Result);
    Result := Result + 'A';
    exit;
  end;

  Result := Result + Chr(Succ(Ord(LChar)));
end;

function GetDecXLColumn(AColChar: string): string;
var
  LChar: Char;
begin
  if (AColChar = 'A') or (AColChar = '') then
  begin
    Result := '';
    exit;
  end;

  LChar := AColChar[AColChar.Length];
  Result := LeftStr(AColChar, AColChar.Length - 1);

  if LChar = 'Z' then
  begin
    Result := GetDecXLColumn(Result);
    Result := Result + 'Z';
    exit;
  end;

  Result := Result + Chr(Pred(Ord(LChar)));
end;

function GetExcelColumnAlphabetByInt(AIndex: integer): string;
var
  LDividend, LModulo: integer;
begin
  Result := '';
  LDividend := AIndex;

  while LDividend > 0 do
  begin
    LModulo := (LDividend - 1) mod 26;
    Result := Char(65 + LModulo) + Result;
    LDividend := (LDividend - LModulo) div 26;
  end;
end;

procedure NextGridToExcel(ANextGrid :TNextGrid; ASheetName: string;
  ASaveFileName: string; ASkipHideColumn: Boolean);
var
  XLApp :TExcelApplication;
  WorkBk : _WorkBook; //  Define a WorkBook
  WorkSheet : _WorkSheet; //  Define a WorkSheet
  I, J, K, R, C, C2, M: Integer;
  IIndex : OleVariant;
  LRange: ExcelRange;
  TabGrid : Variant;
  LStr: string;
  LChar: String;
  LVersion: string;
  LLength: integer;
  LVisible: Boolean;
  LCID: cardinal;
begin
  if ANextGrid.RowCount = 0 then
    exit;

  if ANextGrid.Cells[0,0] <> '' then
  begin
    IIndex := 1;
    R := ANextGrid.RowCount;

    if ASkipHideColumn then
      C := ANextGrid.Columns.VisibleCount
    else
      C := ANextGrid.Columns.Count;

    // Create the Variant Array
    TabGrid := VarArrayCreate([0,(R - 1),0,(C - 1)],VarOleStr);
    C2 := ANextGrid.Columns.Count;
    I := 0;
    M := 0;
    //  Define the loop for filling in the Variant
    repeat
      K := 0;

//      if ASkipHideRow and (not ANextGrid.Row[I].Visible) then
//      begin
//        Inc(I);
//        continue;
//      end;

      for J := 0 to (C2 - 1) do
      begin
        if (ASkipHideColumn) and (not ANextGrid.Columns.Item[J].Visible) then
        begin
          Continue;
        end;

        LStr := ANextGrid.Cells[J,I];
        TabGrid[M,K] := LStr;
        Inc(K);
        LLength := Length(LStr);
        //Cell 내용이 가장 긴 것 저장함
        if ANextGrid.Columns.Item[J].Tag < LLength then
           ANextGrid.Columns.Item[J].Tag := LLength;
      end;
      Inc(I,1);
      Inc(M);
    until I > (R - 1);

//    LCID := GetUserDefaultLCID;
    // Connect to the server TExcelApplication
    XLApp := TExcelApplication.Create(nil);
    LVersion := GetExcelVersion(XLApp);
//    XLApp.ConnectKind := ckNewInstance;
    // Add WorkBooks to the ExcelApplication
    XLApp.WorkBooks.Add(xlWBatWorkSheet,0);
    // Select the first WorkBook
    WorkBk := XLApp.WorkBooks.Item[IIndex];
    // Define the first WorkSheet
    WorkSheet := WorkBk.WorkSheets.Get_Item(1) as _WorkSheet;
    //Columng 제목 표시
    LChar := 'A';
    for i := 0 to C2 - 1 do
    begin
      if ANextGrid.Columns.Item[i].Visible then
      begin
        LRange := Worksheet.Range[LChar+'1',LChar+'1'];
        LRange.Value2 := ANextGrid.Columns.Item[i].Header.Caption;
        LRange.Interior.Color := clLtGray;//clGreen;
        SetExcelCellRangeBorder(LRange);
        LRange.ColumnWidth := ANextGrid.Columns.Item[i].Tag + 3;

//        with Worksheet.Range[LChar+'1',LChar+'1'].Borders do
//        begin
//          LineStyle := xlContinuous;
//          Weight := xlThin;
//        end;
//        LChar := Chr(Succ(Ord(LChar)));
        LChar := GetIncXLColumn(LChar);
      end;
    end;

    // Assign the Delphi Variant Matrix to the Variant associated with the WorkSheet
    Worksheet.Range['A2',Worksheet.Cells.Item[R+1,C]].Value2 := TabGrid;
    // Customise the WorkSheet
    if ASheetName = '' then
      ASheetName := 'Customers';
    WorkSheet.Name := ASheetName;
//    Worksheet.Columns.Font.Bold := True;
    Worksheet.Columns.HorizontalAlignment := xlRight;
//    WorkSheet.Columns.ColumnWidth := 30;
    // Customise the first entire Column
    WorkSheet.Range['A' + IntToStr(2),'A' + IntToStr(R+1)].Font.Color := clBlue;
//    LChar := Chr(Pred(Ord(LChar)));
    LChar := GetDecXLColumn(LChar);
    LRange := WorkSheet.Range['A' + IntToStr(1),LChar + IntToStr(R+1)];
    LRange.HorizontalAlignment := xlHAlignCenter;//xlHAlignLeft;

    if LVersion = '2010' then
      SetExcelCellRangeBorder(LRange)
    else
      ShowMessage('Excel Version is ' + LVersion);
//    WorkSheet.Range['A' + IntToStr(2),'A' + IntToStr(R+1)].ColumnWidth := 5;

    LVisible := ASaveFileName = '';
    // Show Excel
    XLApp.Visible[0] := LVisible;

    if not LVisible then
    begin
      LCID := 0;//GetUserDefaultLCID;
      WorkBk.SaveAs(ASaveFileName, xlOpenDocumentSpreadsheet,//xlWorkBookNormal,
        EmptyParam, EmptyParam, EmptyParam, EmptyParam,
        xlExclusive, xlUserResolution, EmptyParam, EmptyParam,
  //      xlNoChange, xlUserResolution, EmptyParam, EmptyParam,
        EmptyParam, EmptyParam, LCID
        );
      WorkBk.Close(False,EmptyParam,EmptyParam,LCID);
      XLApp.Quit;
    end;
    // Disconnect the Server
    // Unassign the Delphi Variant Matrix
    XLApp.Disconnect;
    XLApp.Free;
    TabGrid := Unassigned;
  end;
end;

//procedure Database2Excel(DbQuery: TQuery);
//var XApp:Variant;
//    sheet:Variant;
//    r,c:Integer;
//    row,col:Integer;
//    filName:Integer;
//    q:Integer;
//begin
//  XApp:=CreateOleObject('Excel.Application');
//  XApp.Visible:=true;
//  XApp.WorkBooks.Add(-4167);
//  XApp.WorkBooks[1].WorkSheets[1].Name:='Sheet1';
//  sheet:=XApp.WorkBooks[1].WorkSheets['Sheet1'];
//
//  for filName:=0 to DbQuery.FieldCount-1 do
//  begin
//    q:=filName+1;
//    sheet.Cells[1,q]:=DbQuery.Fields[filName].FieldName;
//  end;
//
//  for r:=0 to DbQuery.RecordCount-1 do
//  begin
//    for c:=0 to DbQuery.FieldCount-1 do
//    begin
//      row:=r+2;
//      col:=c+1;
//      sheet.Cells[row,col]:=DbQuery.Fields[c].AsString;
//    end;
//
//    DbQuery.Next;
//  end;
//
//  XApp.WorkSheets['Sheet1'].Range['A1:AA1'].Font.Bold:=True;
//  XApp.WorkSheets['Sheet1'].Range['A1:K1'].Borders.LineStyle :=13;
//  XApp.WorkSheets['Sheet1'].Range['A2:K'+inttostr(DbQuery.RecordCount-1)].Borders.LineStyle :=1;
//  XApp.WorkSheets['Sheet1'].Columns[1].ColumnWidth:=16;
//  XApp.WorkSheets['Sheet1'].Columns[2].ColumnWidth:=7;
//  XApp.WorkSheets['Sheet1'].Columns[3].ColumnWidth:=19;
//  XApp.WorkSheets['Sheet1'].Columns[4].ColumnWidth:=9;
//  XApp.WorkSheets['Sheet1'].Columns[5].ColumnWidth:=9;
//  XApp.WorkSheets['Sheet1'].Columns[6].ColumnWidth:=9;
//  XApp.WorkSheets['Sheet1'].Columns[7].ColumnWidth:=46;
//  XApp.WorkSheets['Sheet1'].Columns[8].ColumnWidth:=9;
//  XApp.WorkSheets['Sheet1'].Columns[9].ColumnWidth:=7;
//  XApp.WorkSheets['Sheet1'].Columns[10].ColumnWidth:=6;
//  XApp.WorkSheets['Sheet1'].Columns[11].ColumnWidth:=13;
//end;

//FXlsChoose는 일반 디자인 폼이며
//Listbox, Panel, Bitbtn 두개 ModalResult 값은 아래 코딩 보면 아실듯....
{procedure ExcelToStrGrid(sFileName: String; svGrid: TStringGrid);
const
  Cols  = 10;
  Rows  = 20;
var
  XL, WorkBK, worksheet: Variant;
  idx, jdx: Integer;
begin
  try
    //엑셀을 실행
    XL := CreateOLEObject('Excel.Application');
  except
    ShowMessage('Excel이 설치되어 있지 않습니다!!!');
    Exit;
  end;

  XL.Visible := false;
  XL.WorkBooks.Open(sFileName);
  WorkBK     := XL.WorkBooks.item[1]; //워크 쉬트 설정

  // 워크시트의 시트에 따른 쉬트명 디스플레이
  FXlsChoose := TFXlsChoose.Create(nil);
  FXlsChoose.LBSheet.Items.Clear;

  // 워크시트의 시트의 갯수에 따른 쉬트명 얻어오기
  For idx := 1 to WorkBK.WorkSheets.Count do
  Begin
    WorkSheet  := WorkBK.WorkSheets.Item[idx];
    FXlsChoose.LBSheet.Items.Add(WorkSheet.Name);
    //ShowMessage(WorkSheet.Name);
  End;

  // 워크시트의 시트의 갯수에 따른 쉬트명 얻어오기
  // 선택된 쉬트....
  if FXlsChoose.ShowModal = mrOK Then
  Begin
    WorkSheet := WorkBK.WorkSheets.Item[FXlsChoose.LBSheet.ItemIndex+1];

    For idx := 0 to svGrid.ColCount-1 do svGrid.Cols[idx].Clear;

    For idx := 1 to Rows do
      For jdx := 1 to Cols do
        svGrid.Cells[jdx, idx-1] := WorkSheet.Cells[idx, jdx];

  End;   4

  FXlsChoose.Free;
  XL.WorkBooks.Close;
  XL.quit;
  XL:=unassigned;
end;
}
////////////////////////////////////////////////////////////////////////////////
//  엑셀파일을 === StringGrid로 넘기기
////////////////////////////////////////////////////////////////////////////////
Procedure CsvtoStrGrid(aFile: String; vgrid: TStringGrid);
var
  csv : TextFile;
  csvLine: String;
  vList: TStringList;
  iy, icnt, ix: Integer;
begin
  for icnt := 0 to vgrid.ColCount-1 do
    vgrid.Cols[icnt].Clear;

  vList := TStringList.Create;
  AssignFile(csv, aFile);
  Reset(csv);
  iy := 0;
  ix := 0;

  while not eof(csv) do
  Begin
    Readln(csv, csvLine);
    csvLine := StringReplace(csvLine, ',', '","', [rfReplaceAll]);
    csvLine := '"' + csvLine;
    if csvLine[Length(csvLine)] <> '"' Then csvLine := csvLine + '"';
    vList.CommaText := csvLine;
    if (vLIst.Count+1) > ix Then ix := vLIst.Count+1;
    for icnt := 0 to vLIst.Count - 1 do
      vgrid.Cells[icnt+1, iy] := vLIst.Strings[icnt];
    inc(iy);
  end;
  CloseFile(csv);
  vList.Free;
  vgrid.RowCount := iy;
  vgrid.ColCount := ix;
End;

// Please see:
//   http://www.delphi3000.com/articles/article_1282.asp
//   http://msdn.microsoft.com/library/default.asp?url=/library/en-us/dnautoma/html/msdn_thrdole.asp
//   file://C:\Program Files\Microsoft Office\Office\1033\VBAXL9.CHM
{procedure DataSetToExcelFile(const Dataset: TDataset;const Filename: string);
var
  DefaultLCID: LCID;
  i: Integer;
  Row: Integer;
  ExcelApp: TExcelApplication;
  Worksheet: TExcelWorksheet;
  Workbook: TExcelWorkbook;
begin
  DefaultLCID := GetUserDefaultLCID;

  ExcelApp := TExcelApplication.Create(Self);
  ExcelApp.ConnectKind := ckNewInstance;
  ExcelApp.Connect;
  ExcelApp.ScreenUpdating[DefaultLCID] := False; // optimize presentation
  try
    // create workbook
    Workbook := TExcelWorkbook.Create(Self);
    Workbook.ConnectTo(ExcelApp.Workbooks.Add(TOleEnum(xlWBATWorksheet),
      DefaultLCID));
    // create worksheet
    Worksheet := TExcelWorksheet.Create(Self);
    Worksheet.ConnectTo(Workbook.Worksheets[1] as _Worksheet);
    Worksheet.Name := 'First WorkSheet';
    // populate with Dataset information
    Dataset.DisableControls;
    try
      // header
      for i := 0 to Dataset.FieldCount - 1 do
      begin
        if Dataset.Fields[i].Visible then
        begin
          Worksheet.Cells.Item[1, i + 1].Value :=
            Dataset.Fields[i].DisplayLabel;
          Worksheet.Cells.Item[1, i + 1].ColumnWidth :=
            Dataset.Fields[i].DisplayWidth;
        end;
      end;
      Worksheet.Range['A1', 'A1'].EntireRow.Interior.Color := clblue;
      Worksheet.Range['A1', 'A1'].EntireRow.Font.Bold := True;
      Worksheet.Range['A1', 'A1'].EntireRow.Font.Color := clWhite;
      // data
      Row := 2;
      Dataset.First; // TODO: add a bookmark
      while not Dataset.Eof do
      begin
        for i := 0 to Dataset.FieldCount - 1 do
        begin
          if Dataset.Fields[i].Visible then
          begin
            Worksheet.Cells.Item[Row, i + 1].Value :=
              Dataset.Fields[i].Text;
            Application.ProcessMessages;
          end;
        end;
        Inc(Row);
        Dataset.Next;
      end;
      // save it
      Workbook.SaveAs(
        Filename, // Filename
        XlWindowState(xlNormal), // FileFormat
        EmptyParam, //  Password,
        EmptyParam, // WriteResPass
        False, // ReadOnlyRecommended
        False, // CreateBackup
        xlNoChange, // AccessMode
        xlUserResolution, // ConflictResolution
        False, // AddToMru
        EmptyParam, // TextCodepage
        EmptyParam, // TextVisualLayout
        DefaultLCID);
      Workbook.Close;
    finally
      Dataset.EnableControls;
      Workbook.Free;
      Worksheet.Free;
    end;
  finally
    ExcelApp.ScreenUpdating[DefaultLCID] := True; // optimize presentation
    ExcelApp.Disconnect;
    ExcelApp.Free;
  end;
end;
}
// Formattted with "Source Code Formatter 2.41"
//   http://www.slm.wau.nl/wkao/delforexp.html

//open the password-protected xls-file and save without password
//ex) FName = 'd:\book1.xls'
//    Passwd = 'qq'
//    FName2 = 'd:\book2.xls'
procedure ChangePasswdXLFile(FName,FName2,Passwd: string);
var
  xls, xlw: Variant;
begin
  {load MS Excel}
  xls := CreateOLEObject('Excel.Application');

  {open your xls-file}
  xlw := xls.WorkBooks.Open(FileName := FName, Password :=Passwd,ReadOnly := True);
  {save with other file name}
  xlw.SaveAs(FileName := FName2, Password := '');

  {unload MS Excel}
  xlw := UnAssigned;
  xls := UnAssigned;
end;

function GetActiveExcelOleObject(AVisible: boolean) : Variant;
begin
  try
    Result := GetActiveOleOBject('Excel.Application');
  except
    Result := CreateOleObject('Excel.Application');

    if VarIsNull(Result) = false then
    begin
      Result.Visible := AVisible;
      if Screen.ActiveForm <> nil then
        Screen.ActiveForm.SetFocus;
    end;
  end;

  if VarIsNull(Result) = true then
    ShowMessage('Iaaiciiæii noaðoiaaou Microsoft Excel');
end;

function GetActiveOrCreateExcelOleObject(AVisible: boolean; var AIsCreated: Boolean) : Variant;
begin
  AIsCreated := False;

  try
    Result := GetActiveOleOBject('Excel.Application');
  except
    Result := CreateOleObject('Excel.Application');
    AIsCreated := True;

    if VarIsNull(Result) = false then
    begin
      Result.Visible := AVisible;

      if Screen.ActiveForm <> nil then
        Screen.ActiveForm.SetFocus;
    end;
  end;

  if VarIsNull(Result) = true then
    ShowMessage('Microsoft Excel is not installed!');
end;

function XlsInit(AVisible: boolean): ExcelApplication;
begin
//  DefaultLCID := LOCALE_USER_DEFAULT;
  try
    Result := GetActiveOleOBject('Excel.Application') as ExcelApplication;
  except
    Result := CreateOleObject('Excel.Application') as ExcelApplication;

    if Assigned(Result) then
    begin
      Result.Visible[1] := AVisible;
      if Screen.ActiveForm <> nil then
        Screen.ActiveForm.SetFocus;
    end;
  end;
end;

procedure XlsFinal(var AExcelApp: ExcelApplication);
begin
  AExcelApp.Quit;
  AExcelApp := nil;
end;

function XlsWBSave2Pdf(AExcelWB: OleVariant; APdfFileName: string): Boolean;
//var
//  LXlsWorkBook: ExcelWorkbook;//TExcelWorkBook;
begin
//  LXlsWorkBook := AExcelApp.ActiveWorkbook;
//  AExcelWB.SaveAs(xlTypePdf, APdfFileName);
  AExcelWB.ExportAsFileFormat(xlTypePdf, APdfFileName);//,
//  AExcelWB.SaveAs(APdfFileName, xlTypePdf);//,
//    EmptyParam, EmptyParam, True, False, xlNoChange, xlUserResolution, False,
//    EmptyParam, EmptyParam, True);
end;

function XlsWBSave2CSV(AExcelWB: OleVariant; ACsvFileName: string): Boolean;
begin
  AExcelWB.SaveAs(ACsvFileName, xlCSV);
end;

function XlsSave2CSV(AXlsFileName: string): string;
var
  LExcel: OleVariant;
  LWorkBook: OleVariant;
begin
  Result := '';

  if not FileExists(AXlsFileName) then
  begin
    ShowMessage('File(' + AXlsFileName + ')이 존재하지 않습니다');
    exit;
  end;

  LExcel := GetActiveExcelOleObject(True);
  LExcel.Visible := False;
  LWorkBook := LExcel.Workbooks.Open(AXlsFileName);
  AXlsFileName := ChangeFileExt(AXlsFileName, '.csv');
  LExcel.DisplayAlerts := False;
//  LWorkBook.SaveAs(AXlsFileName, xlCSV);
  XlsWBSave2CSV(LWorkBook, AXlsFileName);
  LWorkBook.Saved := True; //Prevent Prompt
  LWorkBook.Close;
  LWorkBook := UnAssigned;
  LExcel.Quit;
  LExcel := UnAssigned;
  Result := AXlsFileName;
end;

function PutValInExcel(excSheet : Variant; const sName, sValue : string; Mess : boolean; var iRow, iCol : integer): boolean;
 var
  Cell : variant;
  ii  : integer;
begin
  iRow := 0; iCol := 0; Result := false;
  try
    ii := 0;

    while ii < 100 do
    begin
      Inc(ii);
      Cell := excSheet.Cells.Find(sName);
      if VarIsEmpty(Cell) = true then
      begin
        if Mess = true then ShowMessage('A Cell is empty - '+sName);
          exit;
      end;

      iRow := Cell.Row; iCol := Cell.Column;
      Cell.Value := sValue;
      if Mess = true then
      begin
        Result := true;
        exit;
      end;
    end;

    if ii > 99 then
    begin
      ShowMessage('A aieoiaioa iiea - '+sName +' iaeaaii aieaa 100 ðac!');
      exit;
    end;

    Result := true;
  except
     on E: Exception do ShowMessage(E.Message);
  end;
end;

function GetLastRowNumFromExcel(AWorksheet: OleVariant): integer;
var
  LRange: OleVariant;
begin
  Result := AWorkSheet.Cells.SpecialCells(xlCellTypeLastCell, EmptyParam).Row;
end;

function GetLastColNumFromExcel(AWorksheet: OleVariant): integer;
begin
  Result := AWorkSheet.Cells.SpecialCells(xlCellTypeLastCell, EmptyParam).Column;
end;

procedure SetExcelCellRangeBorder(ARange: ExcelRange);
begin
  ARange.Borders[xlDiagonalDown].LineStyle := xlNone;
  ARange.Borders[xlDiagonalUp].LineStyle := xlNone;
  ARange.Borders[xlEdgeLeft].LineStyle := xlContinuous;
  ARange.Borders[xlEdgeTop].LineStyle := xlContinuous;
  ARange.Borders[xlEdgeBottom].LineStyle := xlContinuous;
  ARange.Borders[xlEdgeRight].LineStyle := xlContinuous;
  ARange.Borders[xlInsideVertical].LineStyle := xlContinuous;
  ARange.Borders[xlInsideHorizontal].LineStyle := xlContinuous;
  ARange.Borders.Weight := xlThin;

//  ARange.BorderAround(xlContinuous, xlThin,1, clFuchsia);
end;

procedure SetExcelCellRangeBorderOle(ARange: variant);
begin
//  ARange.Borders[xlDiagonalDown].LineStyle := xlNone;
//  ARange.Borders[xlDiagonalUp].LineStyle := xlNone;
//  ARange.Borders[xlEdgeLeft].LineStyle := xlContinuous;
//  ARange.Borders[xlEdgeTop].LineStyle := xlContinuous;
//  ARange.Borders[xlEdgeBottom].LineStyle := xlContinuous;
//  ARange.Borders[xlEdgeRight].LineStyle := xlContinuous;
//  ARange.Borders[xlInsideVertical].LineStyle := xlContinuous;
//  ARange.Borders[xlInsideHorizontal].LineStyle := xlContinuous;
  ARange.Borders.LineStyle := xlContinuous;
  ARange.Borders.Weight := xlThin;

//  ARange.BorderAround(xlContinuous, xlThin,1, clFuchsia);
end;

function GetExcelVersion(XLApp :TExcelApplication): string;
var
  LVersion: integer;
begin
  Result := XLApp.Version[0];
  LVersion := Round(StrToFloat(Result));
  case LVersion of
    7: Result := '1995';
    8: Result := '1997';
    9: Result := '2000';
    10: Result := 'XP';
    11: Result := '2003';
    12: Result := '2007';
    14: Result := '2010';
    15: Result := '2013';
    16: Result := '2016';
  end;
end;

procedure XlsWSStrFindAndReplaceAll(AWorksheet: OleVariant; AOldStr, ANewStr: string);
begin

end;

procedure XlsStrFindAndReplaceAll(AFileName, AOldStr, ANewStr: string);
var
  LExcel: OleVariant;
  LWorkBook: OleVariant;
  i,j: integer;
begin
  if not FileExists(AFileName) then
  begin
    ShowMessage('File(' + AFileName + ')이 존재하지 않습니다');
    exit;
  end;

  LExcel := GetActiveExcelOleObject(True);
  LWorkBook := LExcel.Workbooks.Open(AFileName);
  LExcel.DisplayAlerts := False;
  ANewStr := StringReplace(ANewStr, #13#10, #10, [rfReplaceAll, rfIgnoreCase]);

  for j := 1 to LExcel.Sheets.Count do
  begin
    LExcel.WorkSheets[j].Select;

    if Length(ANewStr) < 250 then
    begin
      LExcel.Cells.Replace(AOldStr, ANewStr, 2, 1, False);
    end
    else
    begin
      i := 1;

      while i <= Length(ANewStr) do
      begin
        if i+200-1 < Length(ANewStr) then
          LExcel.Cells.Replace(AOldStr, Copy(ANewStr,i,200)+AOldStr, 2, 1, False)
        else
          LExcel.Cells.Replace(AOldStr, Copy(ANewStr,i,200), 2, 1, False);

        i := i + 200;
      end;
    end;
  end;

  LExcel.WorkSheets[1].Select;
end;

procedure SetExcelColumnHeader(AWorksheet: OleVariant; AColName, ARange: string);
var
  LRange: OleVariant;
begin
  LRange := AWorksheet.Range[ARange];
  LRange.Value2 := AColName;
  LRange.Interior.Color := clLtGray;//clGreen;
  LRange.ColumnWidth := Length(AColName);
  SetExcelCellRangeBorderOle(LRange);
end;

procedure SetExcelColumnHeaderFromList(AWorksheet: OleVariant; AList: TStringList);
var
  i : integer;
  LChar: string;
begin
  LChar := 'A';

  for i := 0 to AList.Count - 1 do
  begin
    SetExcelColumnHeader(AWorksheet, AList.Names[i], LChar+'1');
    LChar := GetIncXLColumn(LChar);
  end;
end;

function CheckExcelColumnHeader(AWorksheet: OleVariant; AColName, ARange: string): Boolean;
var
  LRange: OleVariant;
begin
  LRange := AWorksheet.Range[ARange];
  Result := LRange.Value2 = AColName;
end;

function CheckExcelColumnHeaderFromList(AWorksheet: OleVariant; AList: TStringList): Boolean;
var
  i : integer;
  LChar: string;
begin
  Result := False;
  LChar := 'A';

  for i := 0 to AList.Count - 1 do
  begin
    Result := CheckExcelColumnHeader(AWorksheet, AList.Names[i], LChar+'1');

    if not Result then
      Break;

    LChar := GetIncXLColumn(LChar);
  end;
end;

function GetFileNameFromStream(const AStream: TStream): string;
var
  LTempFileName: string;
begin
  LTempFileName := 'c:\Temp\Temp.xlsx';

  AStream.Position := 0;

  with TFileStream.Create(LTempFileName, fmCreate) do
  try
    CopyFrom(AStream, AStream.Size);
  finally
    Free;
  end;

  Result := LTempFileName;
end;

procedure SetValueCheckBoxByNameOnWorkSheet(AWorksheet: OleVariant; ACBName: string; AIsCheck: Boolean);
var
  LCheckBox: OLEVariant;
  i: integer;
begin
//  LCheckBox := AWorkSheet.OLEObjects[ACBName].Object;
  LCheckBox := AWorkSheet.Shapes[ACBName].OLEFormat.Object;
//  LCheckBox := AWorkSheet.Shapes.Item(3).OLEFormat.Object;
//  LCheckBox := AWorkSheet.Shapes[ACBName];

//  for i := 1 to AWorkSheet.OLEObjects.Count do
//  for i := 1 to AWorkSheet.Shapes.Count do
//  begin
//    LCheckBox := AWorkSheet.Shapes.Item(i);
    ACBName := LCheckBox.Name;
//  end;
//    LCheckBox := i;

//  LCheckBox := AWorkSheet.Shapes.Item(1);

  if not VarIsNull(LCheckBox) then
    LCheckBox.Value := BoolToInt(AIsCheck);
end;

procedure SetValueCheckBoxByTextOnWorkSheet(AWorksheet: OleVariant; AText: string; AIsCheck: Boolean);
var
  LCheckBox, LOle: OLEVariant;
  i: integer;
begin
  if AText = '' then
    exit;

  LOle := GetCheckBoxByTextOnWorkSheet(AWorksheet, AText);

  LCheckBox := LOle.OLEFormat.Object;

  if not VarIsNull(LCheckBox) then
    LCheckBox.Value := BoolToInt(AIsCheck);
end;

function CheckWorksheetExistByName(AWorkBook: OleVariant; ASheetName: string): Boolean;
var
  i: integer;
begin
  Result := False;

  for i := 1 to AWorkBook.WorkSheets.Count do
  begin
    if AWorkBook.WorkSheets[i].Name = ASheetName then
    begin
      Result := True;
      Break;
    end;
  end;
end;

function AddSheet2WorkBookByName(AWorkBook: OleVariant; ASheetName: string;
  AIsCheckExist: Boolean): OleVariant;
begin
  Result := null;

  if AIsCheckExist then
  begin
    AIsCheckExist := CheckWorksheetExistByName(AWorkBook, ASheetName);

    //기존에 동일한 이름의 Sheet가 존재하면 skip
    if AIsCheckExist then
      exit;
  end;

  Result := AWorkBook.WorkSheets.Add(EmptyParam, EmptyParam, 1, xlWorkSheet);
end;

function CopySheet2WorkBookByName(AWorkBook: OleVariant; ASrcSheetName, ADestSheetName: string; AIsCheckExist: Boolean=True): OleVariant;
var
  LSrcSheet: OleVariant;
begin
  LSrcSheet := AWorkBook.WorkSheets[ASrcSheetName];
  Result := AWorkBook.Worksheets.Add(EmptyParam, LSrcSheet);
  LSrcSheet.Cells.Copy(Result.Cells);
  Result.Name := ADestSheetName;
end;

function DeleteSheetFromWorkBookByName(AWorkBook: OleVariant; ASheetName: string): Boolean;
var
  i: integer;
  LSheet: OleVariant;
begin
  for i := 1 to AWorkBook.Sheets.Count do
  begin
    LSheet := AWorkBook.Sheets[i];

    if LSheet.Name = ASheetName then
    begin
      LSheet.Delete;
      Break;
    end;
  end;
end;

function GetChcekBoxNameByTextOnWorkSheet(AWorksheet: OleVariant; AText: string): string;
var
  LShape: OLEVariant;
  i: integer;
begin
  Result := '';

  LShape := GetCheckBoxByTextOnWorkSheet(AWorksheet, AText);

  if VarIsNull(LShape) = False  then
    Result := LShape.Name;
end;

function GetCheckBoxByTextOnWorkSheet(AWorksheet: OleVariant; AText: string): OleVariant;
var
  LShape, LTextFrame, LCharacters: OLEVariant;
  LText: string;
  i: integer;
begin
  Result := null;

  for i := 1 to AWorkSheet.Shapes.Count do
  begin
    LShape := AWorkSheet.Shapes.Item(i);

    if not ((LShape.Type = msoFormControl) and (LShape.FormControlType = xlCheckBox)) then
      Continue;

//    LCharacters := LShape.OLEFormat;
//    LCharacters.Activate;

//    LText := LShape.Title;

//    if LShape.TextFrame2.HasText then
//    begin
//      LText := LShape.TextFrame2.TextRange.Text;

    LText := LShape.TextFrame.Characters.Text;
//    LTextFrame := LShape.TextFrame;
//    LCharacters := LTextFrame.Characters;
//    LText := LCharacters.Text;

      if LText = AText then
      begin
        Result := LShape;
      end;
//    end;
  end;
end;

function XlsRangeCopyNInsert2WS(AWorksheet: OleVariant; ASrcRangeStr, ADestRangeStr: string): OleVariant;
begin
//  LMSRange := 'A'+ IntToStr(LERow) + ':I' + IntToStr(LERow);
//  LPareDescRange := 'A'+ IntToStr(LERow+1)+ ':I' +  IntToStr(LERow+1);
  Result := AWorksheet.range[ASrcRangeStr];
  Result.Copy;
  Result := AWorksheet.range[ADestRangeStr];
  Result.Insert;
end;

function XlsRowCopyNInsert2WS(AWorksheet: OleVariant; ASrcRow, ADestRow: integer): OleVariant;
begin
  AWorkSheet.Rows[ASrcRow].Copy;
  AWorkSheet.Rows[ADestRow].Insert();//(Shift:=xlDown)
end;

end.

