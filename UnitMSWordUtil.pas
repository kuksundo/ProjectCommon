unit UnitMSWordUtil;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.AxCtrls,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ComObj,
  Vcl.StdCtrls, Vcl.Mask, JvExMask, JvToolEdit,
  Vcl.ComCtrls, Vcl.ExtCtrls, Word2010, Vcl.Menus, ActiveX,
  Db, Grids, DBGrids;

// Replace Flags
type
   TWordReplaceFlags = set of (wrfReplaceAll, wrfMatchCase, wrfMatchWildcards);

//const
//   wdFindContinue = 1;
//   wdReplaceOne = 1;
//   wdReplaceAll = 2;
//   wdDoNotSaveChanges = 0;

function GetActiveMSWordOleObject(ADocument: TFileName; AVisible: boolean) : Variant;
function GetActiveMSWordClass(AFileName: TFileName; AVisible: boolean) : WordApplication;
procedure Word_SaveAs(ADocument: _Document; ASaveFileName: TFileName; AFileKind: integer);
procedure Word_Quit(AWordApplication: WordApplication);
procedure Document_Close(ADocument: _Document);
function Word_StringReplace(ADocument: TFileName; SearchString, ReplaceString: string;
  Flags: TWordReplaceFlags): Boolean;
function Word_StringReplace2(WordApp: OLEVariant; SearchString, ReplaceString: string;
  Flags: TWordReplaceFlags): Boolean;
function Word_InsertImageFromClipboard(WordApp: OLEVariant;
  ATableIndex: integer=1; ACol: integer=1; ARow: integer=1): string;
procedure Word_InsertImageToCellFromClipboard(ACell: OLEVariant);
function Word_AddHeaderAndFooter(WordApp: OLEVariant; AHeaderText, AFooterText: String): string;
function Word_StringReplaceFooter(WordApp: OLEVariant; SearchString, ReplaceString: string;
  Flags: TWordReplaceFlags): Boolean;
function Word_StringFindNFontSize(WordApp: OLEVariant; SearchString: string; ASize: integer): Boolean;

procedure DBGridToWord (Grid :TDBGrid ; FormatNum :integer);
function FindTextInFile(const FileName, TextToFind: WideString): boolean;
function GetInstalledWordVersion: Integer;

implementation

function GetActiveMSWordOleObject(ADocument: TFileName; AVisible: boolean) : Variant;
//var
//   WordApp: OLEVariant;
begin
   { Check if file exists }
   if not FileExists(ADocument) then
   begin
     ShowMessage('Specified Document not found.');
     Exit;
   end;

   { Create the OLE Object }
   try
     Result := CreateOLEObject('Word.Application');
   except
     on E: Exception do
     begin
       E.Message := 'Word is not available.';
       raise;
     end;
   end;

   { Hide Word }
   Result.Visible := AVisible;
   { Open the document }
   Result.Documents.Open(ADocument);
end;

function GetActiveMSWordClass(AFileName: TFileName; AVisible: boolean) : WordApplication;
begin
//  Result := TWordApplication.Create(nil);
//  Result.Connect;
  try
   Result := CreateOLEObject('Word.Application') as WordApplication;
  except
   on E: Exception do
   begin
     E.Message := 'Word is not available.';
     raise;
   end;
  end;

  Result.Visible := AVisible;
  Result.Documents.Open(AFileName, EmptyParam, EmptyParam, EmptyParam,
                                   EmptyParam, EmptyParam, EmptyParam,
                                   EmptyParam, EmptyParam, EmptyParam,
                                   EmptyParam, EmptyParam, EmptyParam,
                                   EmptyParam, EmptyParam, EmptyParam);
end;

procedure Word_SaveAs(ADocument: _Document; ASaveFileName: TFileName; AFileKind: integer);
begin
  ADocument.SaveAs(ASaveFileName, AFileKind,
                                    EmptyParam, EmptyParam, EmptyParam,
                                    EmptyParam, EmptyParam, EmptyParam,
                                    EmptyParam, EmptyParam, EmptyParam,
                                    EmptyParam, EmptyParam, EmptyParam,
                                    EmptyParam, EmptyParam);
end;

procedure Word_Quit(AWordApplication: WordApplication);
begin
  AWordApplication.Quit(EmptyParam, EmptyParam, EmptyParam);
end;

procedure Document_Close(ADocument: _Document);
begin
  ADocument.Close(False, EmptyParam, EmptyParam);
end;

//예:Word_StringReplace('C:\Test.doc','Old String','New String',[wrfReplaceAll]);
function Word_StringReplace(ADocument: TFileName; SearchString, ReplaceString: string;
  Flags: TWordReplaceFlags): Boolean;
var
   WordApp: OLEVariant;
begin
   Result := False;

   { Check if file exists }
   if not FileExists(ADocument) then
   begin
     ShowMessage('Specified Document not found.');
     Exit;
   end;

   { Create the OLE Object }
   try
     WordApp := CreateOLEObject('Word.Application');
   except
     on E: Exception do
     begin
       E.Message := 'Word is not available.';
       raise;
     end;
   end;

   try
     { Hide Word }
//     WordApp.Visible := False;
     { Open the document }
     WordApp.Documents.Open(ADocument);
     { Initialize parameters}
     WordApp.Selection.Find.ClearFormatting;
     WordApp.Selection.Find.Text := SearchString;
     WordApp.Selection.Find.Replacement.Text := ReplaceString;
     WordApp.Selection.Find.Forward := True;
     WordApp.Selection.Find.Wrap := wdFindContinue;
//     WordApp.Selection.Find.Format := False;
     WordApp.Selection.Find.MatchCase := True;
     WordApp.Selection.Find.MatchWholeWord := True;
//     WordApp.Selection.Find.MatchWildcards := False;
//     WordApp.Selection.Find.MatchSoundsLike := False;
//     WordApp.Selection.Find.MatchAllWordForms := False;
     { Perform the search}
     if wrfReplaceAll in Flags then
       WordApp.Selection.Find.Execute(Replace := wdReplaceAll)
     else
       WordApp.Selection.Find.Execute(Replace := wdReplaceOne);
     { Save word }
//     WordApp.ActiveDocument.SaveAs(ADocument);
     { Assume that successful }
     Result := True;
     { Close the document }
//     WordApp.ActiveDocument.Close(wdDoNotSaveChanges);
   finally
     { Quit Word }
//     WordApp.Quit;
//     WordApp := Unassigned;
   end;
end;

function Word_StringReplace2(WordApp: OLEVariant; SearchString, ReplaceString: string;
  Flags: TWordReplaceFlags): Boolean;
begin
  WordApp.Selection.Find.ClearFormatting;
  WordApp.Selection.Find.Text := SearchString;
  WordApp.Selection.Find.Replacement.Text := ReplaceString;
  WordApp.Selection.Find.Forward := True;
  WordApp.Selection.Find.Wrap := wdFindContinue;
  WordApp.Selection.Find.Format := True;
  WordApp.Selection.Find.MatchCase := True;
  WordApp.Selection.Find.MatchWholeWord := True;
  WordApp.Selection.Find.MatchWildcards := False;
//  WordApp.Selection.Find.MatchSoundsLike := False;
//  WordApp.Selection.Find.MatchAllWordForms := False;
//  WordApp.Selection.Find.MatchFuzzy := False;

  { Perform the search}
  if wrfReplaceAll in Flags then
   WordApp.Selection.Find.Execute(Replace := wdReplaceAll)
  else
   WordApp.Selection.Find.Execute(Replace := wdReplaceOne);
end;

function Word_InsertImageFromClipboard(WordApp: OLEVariant;
  ATableIndex: integer=1; ACol: integer=1; ARow: integer=1): string;
var
  i,j: integer;
  LWordDocument: Variant;//WordDocument;
  LTable, LCell: Variant;//Shapes;//Variant;
//  LParagraphs:Paragraphs;
//  LParagraph: Paragraph;
begin
//  Word_StringReplace2(WordApp, 'QRCode', '', []);
//  WordApp.Selection.Paste;
  LWordDocument := WordApp.ActiveDocument;

  LTable := LWordDocument.Tables.Item(ATableIndex);
  LCell := LTable.Cell(ACol,ARow);
  Word_InsertImageToCellFromClipboard(LCell);
//  LCell.Range.Paste;

//  Result := IntToStr(LCell.Range.InLineShapes.Count);
//  for i := 1 to LWordDocument.InlineShapes.Count do
//  for i := 1 to LWordDocument.Shapes.Count do
//  for i := 1 to LWordDocument.BookMarks.Count do
//;  for i := 1 to LCell.Range.InLineShapes.Count do
//;  begin
//;    LTable := LCell.Range.InLineShapes.Item(i);
//    LShape := LWordDocument.BookMarks.Item(i);
//    LShape := LWordDocument.Tables.Item(1);
//    LCell := LShape.Cell(1,1);
//    LCell.Range.Paste;
//    LCell.Range.Selection.Height := 2;
//    LCell.Range.Selection.Width := 2;

//    if LInlineShape.Title = 'Emblem' then
//    else
//    Result := LShape.Title;
//    if Result <> '' then
//      Continue;

//    if LShape.Name = 'QRCode' then
//    if LShape.Name = 'Picture 3' then
//    begin
//      Result := FLoatToStr(LShape.Width);// := 2;//RelativeHorizontalSize
//      Result := FLoatToStr(LShape.Height);// := 2;//RelativeVerticalSize
//;      LTable.Width := 57;//RelativeHorizontalSize
//;      LTable.Height:= 57;//RelativeVerticalSize
//      LShape.Select;
//      WordApp.Selection.Paste;
//      LShape.Range.Paste;
//      Exit;
//    end;
//;  end;
end;

procedure Word_InsertImageToCellFromClipboard(ACell: OLEVariant);
var
  LShape: Variant;
begin
  ACell.Range.Paste;
  LShape := ACell.Range.InLineShapes.Item(1);
  LShape.Width := 57;
  LShape.Height:= 57;
end;

function Word_AddHeaderAndFooter(WordApp: OLEVariant; AHeaderText, AFooterText: String): string;
begin
  WordApp.ActiveDocument.Sections.Item(1).Headers.Item(1).Range.Select;
  WordApp.Selection.ParagraphFormat.TabStops.ClearAll;
  WordApp.Selection.TypeText(AHeaderText);
  WordApp.ActiveDocument.Sections.Item(1).Footers.Item(1).Range.Select;
  WordApp.Selection.ParagraphFormat.TabStops.ClearAll;
  WordApp.Selection.TypeText(AFooterText);

  Result := '';
end;

function Word_StringReplaceFooter(WordApp: OLEVariant; SearchString, ReplaceString: string;
  Flags: TWordReplaceFlags): Boolean;
begin
  WordApp.ActiveDocument.Sections.Item(1).Footers.Item(wdHeaderFooterPrimary).Range.Select;
  WordApp.Selection.Find.ClearFormatting;
  WordApp.Selection.Find.Text := SearchString;
  WordApp.Selection.Find.Replacement.Text := ReplaceString;
  WordApp.Selection.Find.Forward := True;
  WordApp.Selection.Find.Wrap := wdFindContinue;
  WordApp.Selection.Find.Format := False;
  WordApp.Selection.Find.MatchCase := wrfMatchCase in Flags;
  WordApp.Selection.Find.MatchWholeWord := False;
  WordApp.Selection.Find.MatchWildcards := wrfMatchWildcards in Flags;
  WordApp.Selection.Find.MatchSoundsLike := False;
  WordApp.Selection.Find.MatchAllWordForms := False;

  { Perform the search}
  if wrfReplaceAll in Flags then
   WordApp.Selection.Find.Execute(Replace := wdReplaceAll)
  else
   WordApp.Selection.Find.Execute(Replace := wdReplaceOne);

  WordApp.ActiveWindow.View.Type := wdPrintView;
//  WordApp.ActiveDocument.Sections.Item(1).Footers.Item(wdHeaderFooterPrimary).Range.Find.ClearFormatting;
//  WordApp.ActiveDocument.Sections.Item(1).Footers.Item(wdHeaderFooterPrimary).Range.Find.Text := SearchString;
//  WordApp.ActiveDocument.Sections.Item(1).Footers.Item(wdHeaderFooterPrimary).Range.Find.Replacement.Text := ReplaceString;
//  WordApp.ActiveDocument.Sections.Item(1).Footers.Item(wdHeaderFooterPrimary).Range.Find.Forward := True;
//  WordApp.ActiveDocument.Sections.Item(1).Footers.Item(wdHeaderFooterPrimary).Range.Find.Wrap := wdFindContinue;
//  WordApp.ActiveDocument.Sections.Item(1).Footers.Item(wdHeaderFooterPrimary).Range.Find.Format := False;
//  WordApp.ActiveDocument.Sections.Item(1).Footers.Item(wdHeaderFooterPrimary).Range.Find.MatchCase := wrfMatchCase in Flags;
//  WordApp.ActiveDocument.Sections.Item(1).Footers.Item(wdHeaderFooterPrimary).Range.Find.MatchWholeWord := False;
//  WordApp.ActiveDocument.Sections.Item(1).Footers.Item(wdHeaderFooterPrimary).Range.Find.MatchWildcards := wrfMatchWildcards in Flags;
//  WordApp.ActiveDocument.Sections.Item(1).Footers.Item(wdHeaderFooterPrimary).Range.Find.MatchSoundsLike := False;
//  WordApp.ActiveDocument.Sections.Item(1).Footers.Item(wdHeaderFooterPrimary).Range.Find.MatchAllWordForms := False;

//  if wrfReplaceAll in Flags then
//   WordApp.ActiveDocument.Sections.Item(1).Footers.Item(wdHeaderFooterPrimary).Range.Find.Execute(Replace := wdReplaceAll)
//  else
//   WordApp.ActiveDocument.Sections.Item(1).Footers.Item(wdHeaderFooterPrimary).Range.Find.Execute(Replace := wdReplaceOne);
end;

function Word_StringFindNFontSize(WordApp: OLEVariant; SearchString: string; ASize: integer): Boolean;
begin
  WordApp.Selection.Find.ClearFormatting;
  WordApp.Selection.Find.Text := SearchString;
  WordApp.Selection.Find.Forward := True;
  WordApp.Selection.Find.Wrap := wdFindContinue;//wdFindStop;
//  WordApp.Selection.Find.Format := False;
  WordApp.Selection.Find.MatchCase := True;
  WordApp.Selection.Find.MatchWholeWord := True;
//  WordApp.Selection.Find.MatchWildcards := False;
//  WordApp.Selection.Find.MatchSoundsLike := False;
//  WordApp.Selection.Find.MatchAllWordForms := False;

  if WordApp.Selection.Find.Execute then
  begin
    WordApp.Selection.Font.Size := ASize;
  end;
end;

//DBGrid의 내용을 MSWord의 테이블에 넣어주는 함수
procedure DBGridToWord (Grid :TDBGrid ; FormatNum :integer);
var
  x :integer ;
  y: integer ;
  Word : Olevariant ;
  GColCount : integer ;
  GRowCount : integer;
begin
  Word := CreateOLEobject('Word.Application') ;
  Word.Visible := True ;
  Word.Documents.Add ;
  GColCount := Grid.Columns.Count ;
  GRowCount := Grid.DataSource.DataSet.RecordCount ;
  Word.ActiveDocument.Range.Font.Size := Grid.Font.Size;
  Word.ActiveDocument.PageSetup.Orientation := 1 ;
  Word.ActiveDocument.Tables.Add( Word.ActiveDocument.Range,GRowCount+1,GColCount);
  Word.ActiveDocument.Range.InsertAfter('Date ' + Datetimetostr(Now));
  Word.ActiveDocument.Range.Tables.Item(1).AutoFormat(FormatNum,1,1,1,1,1,0,0,0,1);

  for y := 1 to GColCount do
    Word.ActiveDocument.Tables.Item(1).Cell(1,y).Range.InsertAfter(Grid.Columns[y-1].Title.Caption) ;

  x :=1 ;

  with Grid.DataSource.DataSet do
  begin
    First ;
    while not Eof do
    begin
      x := x + 1 ;
      for y := 1 to GColCount do
        Word.ActiveDocument.Tables.Item(1).Cell(x,y).Range.InsertAfter(FieldByName(Grid.Columns[y-1].FieldName).Asstring);
      Next ;
    end;
  end;

  Word.ActiveDocument.Range.Tables.Item(1).UpdateAutoFormat ;
end;

//COM의 Automation을 이용한 DOC 파일을 TXT 파일로
// 단, 노턴 안티바이러스 프로그램이 깔렸을 경우 불가능하다.
procedure ConvertDocToTxt(AFileName: string);
var
  MSWord: Variant;
const
  wdDoNotSaveChanges = $00;
  wdFormatText = $02;
begin
  Screen.Cursor := crHourGlass;

  MSWord := CreateOleObject('Word.Application');
  MSWord.Documents.Open(AFileName);
  MSWord.Documents.Item(1).SaveAs(ChangeFileExt
                               (AFileName, '.txt'), wdFormatText);
  MSWord.Documents.Item(1).Close(wdPromptToSaveChanges);
  MSWord.Quit;
  MSWord := VarNull;

  Screen.Cursor := crDefault;
end;

function FindTextInFile(const FileName, TextToFind: WideString): boolean;
var Root: IStorage;
    EnumStat: IEnumStatStg;
    Stat: TStatStg;
    iStm: IStream;
    Stream: TOleStream;
    DocTextString: WideString;
begin
  Result:=False;

  if not FileExists(FileName) then Exit;

  // Check to see if it's a structured storage file
  if StgIsStorageFile(PWideChar(FileName)) <> S_OK then Exit;

  // Open the file
  OleCheck(StgOpenStorage(PWideChar(FileName), nil,
            STGM_READ or STGM_SHARE_EXCLUSIVE, nil, 0, Root));

  // Enumerate the storage and stream objects contained within this file
  OleCheck(Root.EnumElements(0, nil, 0, EnumStat));

  // Check all objects in the storage
  while EnumStat.Next(1, Stat, nil) = S_OK do

    // Is it a stream with Word data
    if Stat.pwcsName = 'WordDocument' then

      // Try to get the stream "WordDocument"
      if Succeeded(Root.OpenStream(Stat.pwcsName, nil,
                    STGM_READ or STGM_SHARE_EXCLUSIVE, 0, iStm)) then
      begin
        Stream:=TOleStream.Create(iStm);
        try
          if Stream.Size > 0 then
          begin
            // Move text data to string variable
            SetLength(DocTextString, Stream.Size);
            Stream.Position:=0;
            Stream.Read(pChar(DocTextString)^, Stream.Size);

            // Find a necessary text
            Result:=(Pos(TextToFind, DocTextString) > 0);
          end;
        finally
          Stream.Free;
        end;
        Exit;
      end;
end;

procedure StringGrid2MSWordTable(AGrid: TStringGrid);
var
  WordApp, NewDoc, WordTable: OLEVariant;
  iRows, iCols, iGridRows, jGridCols: Integer;
begin
  try
    // Create a Word Instance
    // Word Instanz erzeugen
    WordApp := CreateOleObject('Word.Application');
  except
    // Error...
    // Fehler....
    Exit;
  end;

  // Show Word
  // Word anzeigen
  WordApp.Visible := True;

  // Add a new Doc
  // Neues Dok einfugen
  NewDoc := WordApp.Documents.Add;

  // Get number of columns, rows
  // Spalten, Reihen ermitteln
  iCols := AGrid.ColCount;
  iRows := AGrid.RowCount;

  // Add a Table
  // Tabelle einfugen
  WordTable := NewDoc.Tables.Add(WordApp.Selection.Range, iCols, iRows);

  // Fill up the word table with the Stringgrid contents
  // Tabelle ausfullen mit Stringgrid Daten
  for iGridRows := 1 to iRows do
    for jGridCols := 1 to iCols do
      WordTable.Cell(iGridRows, jGridCols).Range.Text :=
        AGrid.Cells[jGridCols - 1, iGridRows - 1];

  // Here you might want to Save the Doc, quit Word...
  // Hier evtl Word Doc speichern, beenden...

  // ...

  // Cleanup...
  WordApp := Unassigned;
  NewDoc := Unassigned;
  WordTable := Unassigned;
end;

{
const
  Wordversion97 = 8;
  Wordversion2000 = 9;
  WordversionXP = 10;
  Wordversion2003 = 11;
}

function GetInstalledWordVersion: Integer;
var
  word: OLEVariant;
begin
  word := CreateOLEObject('Word.Application');
  result := word.version;
  word.Quit;
  word := UnAssigned;
end;
end.
