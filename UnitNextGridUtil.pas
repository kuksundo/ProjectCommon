unit UnitNextGridUtil;

interface

uses SysUtils, StdCtrls,Classes, Graphics, Grids, ComObj, StrUtils,
    Variants, Dialogs, Forms, Excel2010,
    NxColumnClasses, NxColumns, NxGrid, NxCells,
    SynCommons;

procedure NextGridToCsv(AFileName: string; ANextGrid: TNextGrid);
procedure AddNextGridColumnFromVariant(AGrid: TNextGrid; ADoc: Variant; AIsFromValue: Boolean=false);
function GetListFromVariant2NextGrid(AGrid: TNextGrid; ADoc: Variant;
  AIsAdd: Boolean; AIsArray: Boolean = False; AIsUsePosFunc: Boolean = False;
  AIsClearRow: Boolean=False): integer;
function NextGrid2Variant(AGrid: TNextGrid; ARemoveUnderBar: Boolean=False): variant;
function GetJsonFromSelectedRow(AGrid: TNextGrid; ARemoveUnderBar: Boolean=False): string;
procedure NextGridScrollToRow(AGrid: TNextGrid; ARow: integer=-1);
procedure DeleteSelectedRow(ANextGrid: TNextGrid);
procedure DeleteCurrentRow(ANextGrid: TNextGrid);
procedure MoveRowDown(ANextGrid: TNextGrid);
procedure MoveRowUp(ANextGrid: TNextGrid);
function ChangeRowColorByIndex(AGrid: TNextGrid; ARowIndex: integer; AColor: TColor): TColor;
procedure CsvFile2NextGrid(ACsvFileName: string; ANextGrid: TNextGrid);

implementation

uses UnitStringUtil;

procedure NextGridToCsv(AFileName: string; ANextGrid: TNextGrid);
var
  LColCount, i, j: integer;
  LCsv, LHeader: string;
  LStrList: TStringList;
begin
  LStrList := TStringList.Create;
  try
    for j := 0 to ANextGrid.RowCount - 1 do
    begin
      for i := 0 to ANextGrid.Columns.Count - 1 do
      begin
        if j = 0 then
          LHeader := LHeader + ANextGrid.Columns.Item[i].Header.Caption + ',';

        LCsv := LCsv + ANextGrid.Cells[i,j] + ',';
      end;

      if j = 0 then
      begin
        LHeader := LHeader.Remove(LHeader.Length-1);
        LStrList.Add(LHeader);
      end;

      LCsv := LCsv.Remove(LCsv.Length-1);
      LStrList.Add(LCsv);
      LCsv := '';
    end;

    LStrList.SaveToFile(AFileName);
  finally
    LStrList.Free;
  end;
end;

procedure AddNextGridColumnFromVariant(AGrid: TNextGrid; ADoc: Variant; AIsFromValue: Boolean=false);
var
  LnxTextColumn: TnxTextColumn;
  LNxComboBoxColumn: TNxComboBoxColumn;
  LnxIncrementColumn: TnxCustomColumn;
  i: integer;
  LTitle, LCompName: string;
  LStrList: TStringList;

  procedure SetTextColumn(ATitle, AName: string);
  begin
    LnxTextColumn := TnxTextColumn(AGrid.Columns.Add(TnxTextColumn, ATitle));
    LnxTextColumn.Name := AName;
    LnxTextColumn.Editing := True;
    LnxTextColumn.Header.Alignment := taCenter;
    LnxTextColumn.Alignment := taCenter;
    LnxTextColumn.Options := [coCanClick,coCanInput,coDisableMoving,coEditorAutoSelect,coPublicUsing,coShowTextFitHint];//,coEditing

    LStrList.Add(AName + ':' + 'TnxTextColumn;');
  end;
begin
  LStrList := TStringList.Create;
  try
    with AGrid do
    begin
      ClearRows;
      Columns.Clear;

      LnxIncrementColumn := Columns.Add(TnxIncrementColumn,'No');
      LnxIncrementColumn.Alignment := taCenter;
      LnxIncrementColumn.Header.Alignment := taCenter;
      LnxIncrementColumn.Width := 30;

  //    with TDocVariantData(ADoc) do
  //    begin
        for i := 0 to TDocVariantData(ADoc).Count - 1 do
        begin
          LCompName := TDocVariantData(ADoc).Names[i];

          if AIsFromValue then
            LTitle := TDocVariantData(ADoc).Values[i]
          else
            LTitle := LCompName;

          SetTextColumn(LTitle, LCompName);
        end;
  //    end;
    end;//with
  finally
    //NextGrid Column�� �߰��ϸ� TForm ����ο� ColumnName: ColumnType �� �߰� �ǹǷ�
    //Column �ڵ� ���� �� �Ʒ� ���� ������ �����Ͽ� TForm�� �߰��� �־�� ��
    LStrList.SaveToFile('c:\temp\NextGridTextColumnList.txt');
    LStrList.Free;
    ShowMessage('c:\temp\NextGridTextColumnList.txt is saved.' + #13#10 +
      'NextGrid Column�� �߰��ϸ� TForm ����ο� ColumnName: ColumnType �� �߰� �ǹǷ�' + #13#10 +
      'Column �ڵ� ���� �� �Ʒ� ���� ������ �����Ͽ� TForm�� �߰��� �־�� ��.');
  end;
end;

//ADoc�� �Ѱ��� ���ڵ忡 ���� Json ��
//AIsUsePosFunc : True = Pos�Լ��� ����Ͽ� LCompName�� Column Name�� ���ԵǾ� ������ ó��
//AIsArray : True = ADoc�� �������� ���ڵ���
function GetListFromVariant2NextGrid(AGrid: TNextGrid; ADoc: Variant;
  AIsAdd: Boolean; AIsArray: Boolean; AIsUsePosFunc: Boolean; AIsClearRow: Boolean): integer;
var
  i, j, LRow, LCount: integer;
  LCompName, LValue: string;
  LDynUtf8: TRawUTF8DynArray;
  LDynArr: TDynArray;
  LUtf8: RawUTF8;
  LDoc: variant;

  procedure AddRowFromVar(AJson: variant);
  var
    Li, Lj: integer;
  begin
    if AIsAdd then
      LRow := AGrid.AddRow
    else
      LRow := AGrid.SelectedRow;

    for Li := 0 to TDocVariantData(AJson).Count - 1 do
    begin
      LCompName := TDocVariantData(AJson).Names[Li];

      if AIsUsePosFunc then
      begin
        for Lj := 0 to AGrid.Columns.Count - 1 do
        begin
          if POS(LCompName, AGrid.Columns[Lj].Name) > 0 then
          begin
            //�ݵ�� String Type�� ���� �� ��
            AGrid.CellsByName[Lj, LRow] := TDocVariantData(AJson).Values[Li];
          end;
        end;
      end
      else if AGrid.Columns.IndexOf(AGrid.ColumnByName[LCompName]) > -1 then
      begin
        //�ݵ�� String Type�� ���� �� ��
        AGrid.CellsByName[LCompName, LRow] := TDocVariantData(AJson).Values[Li];
      end;
    end;
  end;
begin
  with AGrid do
  begin
    BeginUpdate;

    if AIsClearRow then
      ClearRows;

    try
      if AIsArray then
      begin
        LValue := ADoc;
        LUtf8 := StringToUTF8(LValue);
        LDynArr.Init(TypeInfo(TRawUTF8DynArray), LDynUtf8);
        LDynArr.LoadFromJSON(PUTF8Char(LUtf8));

        for i := 0 to LDynArr.Count - 1 do
        begin
          LDoc := _JSON(LDynUtf8[i]);
          AddRowFromVar(LDoc);
        end;
      end
      else
      begin
        AddRowFromVar(ADoc);
      end;
    finally
      EndUpdate;

      if AIsArray then
        Result :=  LDynArr.Count
      else
        Result :=  TDocVariantData(ADoc).Count;
    end;
  end;//with
end;

//Result�� [{"NextGrid.ColumnName": NextGrid.CelsByName}] Array �������� �����
function NextGrid2Variant(AGrid: TNextGrid; ARemoveUnderBar: Boolean): variant;
var
  i, j: integer;
  LColumnName: string;
  LUtf8: RawUTF8;
  LDynUtf8: TRawUTF8DynArray;
  LDynArr: TDynArray;
  LV: variant;
begin
  TDocVariant.New(Result);
  TDocVariant.New(LV);
  LDynArr.Init(TypeInfo(TRawUTF8DynArray), LDynUtf8);

  for i := 0 to AGrid.RowCount - 1 do
  begin
    for j := 0 to AGrid.Columns.Count - 1 do
    begin
      LColumnName := AGrid.Columns.Item[j].Name;

      if ARemoveUnderBar then
        LColumnName := strToken(LColumnName, '_');

      TDocVariantData(LV).Value[LColumnName] := AGrid.CellsByName[LColumnName, i];
    end;

    LUtf8 := LV;
    LDynArr.Add(LUtf8);
  end;

  Result := LDynArr.SaveToJSON;
end;

function GetJsonFromSelectedRow(AGrid: TNextGrid; ARemoveUnderBar: Boolean): string;
var
  i, j: integer;
  LColumnName: string;
  LV, LValue: variant;
begin
  TDocVariant.New(LV);

  for j := 0 to AGrid.Columns.Count - 1 do
  begin
    LColumnName := AGrid.Columns.Item[j].Name;

    if ARemoveUnderBar then
      LColumnName := strToken(LColumnName, '_');

    LValue := AGrid.Cells[j, AGrid.SelectedRow];
    TDocVariantData(LV).AddValue(LColumnName, LValue);
  end;//for

  Result := LV;
end;

procedure NextGridScrollToRow(AGrid: TNextGrid; ARow: integer);
begin
  if ARow = -1 then
    ARow := AGrid.SelectedRow;

  if ARow = -1 then
    exit;

  AGrid.ScrollToRow(ARow);
  AGrid.Row[ARow].Selected := True;
end;

procedure DeleteSelectedRow(ANextGrid: TNextGrid);
var
  i: Integer;
begin
  i := 0;
  while i < ANextGrid.RowCount do
  begin
    if ANextGrid.CellByName['check', i].AsBoolean then
    begin
      ANextGrid.DeleteRow(i);
    end else Inc(i);
  end;
end;

procedure DeleteCurrentRow(ANextGrid: TNextGrid);
begin
  ANextGrid.DeleteRow(ANextGrid.SelectedRow);
end;

procedure MoveRowDown(ANextGrid: TNextGrid);
begin
  ANextGrid.MoveRow(ANextGrid.SelectedRow, ANextGrid.SelectedRow + 1);
  ANextGrid.SelectedRow := ANextGrid.SelectedRow + 1;
end;

procedure MoveRowUp(ANextGrid: TNextGrid);
begin
  ANextGrid.MoveRow(ANextGrid.SelectedRow, ANextGrid.SelectedRow - 1);
  ANextGrid.SelectedRow := ANextGrid.SelectedRow - 1;
end;

function ChangeRowColorByIndex(AGrid: TNextGrid; ARowIndex: integer; AColor: TColor): TColor;
var
  i: integer;
begin
  Result := AGrid.Cell[0, ARowIndex].Color;

  for i := 0 to AGrid.Columns.Count - 1 do
  begin
    AGrid.Cell[i, ARowIndex].Color := AColor;
  end;
end;

procedure CsvFile2NextGrid(ACsvFileName: string; ANextGrid: TNextGrid);
var
  csv : TextFile;
  csvLine: String;
  vList: TStringList;
  iy, icnt, ix: Integer;
begin
  if not FileExists(ACsvFileName) then
    exit;

  vList := TStringList.Create;
  AssignFile(csv, ACsvFileName);
  Reset(csv);
  iy := 0;
  ix := 0;

  with ANextGrid do
  begin
    BeginUpdate;
    ClearRows;

    while not eof(csv) do
    Begin
      AddRow();
      Readln(csv, csvLine);
      csvLine := StringReplace(csvLine, ',', '","', [rfReplaceAll]);
      csvLine := '"' + csvLine;

      if csvLine[Length(csvLine)] <> '"' Then
        csvLine := csvLine + '"';

      vList.CommaText := csvLine;

      if (vLIst.Count+1) > ix Then
        ix := vLIst.Count+1;

      for icnt := 0 to vLIst.Count - 1 do
        Cells[icnt+1, iy] := vLIst.Strings[icnt];
      inc(iy);
    end;

  end;

  CloseFile(csv);
  vList.Free;
end;

end.
