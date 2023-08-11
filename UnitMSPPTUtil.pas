unit UnitMSPPTUtil;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  ComObj, Vcl.Dialogs, PowerPoint2010, Office2010;

type
  TPPTReplaceFlags = set of (pptrfReplaceAll, pptrfMatchCase, pptrfMatchWildcards);

const
  PPTSlideHeight_A4 = 540;
  PPTSlideWidth_A4 = 780;

function GetActiveMSPPTOleObject(ADocument: TFileName; AVisible: boolean=True) : Variant;
function GetActiveMSPPTClass(AFileName: TFileName; AVisible: boolean) : PowerPointApplication;
function PPT_StringReplace(PPTApp: PowerPointApplication; SearchString, ReplaceString: string;
  Flags: TPPTReplaceFlags=[]): Boolean;
function PPT_StringReplaceFromSlide(ASlide: PowerPointSlide; SearchString, ReplaceString: string;
  Flags: TPPTReplaceFlags=[]): Boolean;
procedure PPT_InsertImageToPPTFromClipboard(APPTApp: PowerPointApplication;
  ASlideNo: integer; AImgHeight, AImgWidth, AImgTop, AImgLeft: single);
procedure PPT_InsertImageToSlideFromClipboard(ASlide: PowerPointSlide; ASlideHeight, ASlideWidth,
  AImgHeight, AImgWidth, AImgTop, AImgLeft: single);
procedure PPT_InsertImageToShapeFromClipboard(AShape: PowerPoint2010.Shape);
function PPT_CopySlideFromSrcSlide(ASlide: PowerPointSlide): SlideRange;
function PPT_CopySlideFromSlideIndex(PPTApp: PowerPointApplication; ASlideIndex: integer): PowerPointSlide;
function PPT_StringFindNFontSize(ASlide: PowerPointSlide; SearchString: string; ASize: integer): Boolean;
procedure PPT_SaveAsFormat(AOriginalFileName: string; AFileFormat: integer);

implementation

function GetActiveMSPPTOleObject(ADocument: TFileName; AVisible: boolean) : Variant;
begin
  { Check if file exists }
  if not FileExists(ADocument) then
  begin
    ShowMessage('Specified Document not found.');
    Exit;
  end;

  { Create the OLE Object }
  try
    Result := GetActiveOleObject('PowerPoint.Application');
  except
    try
      Result := CreateOLEObject('PowerPoint.Application');
    except
      on E: Exception do
      begin
        E.Message := 'PowerPoint is not available.';
        raise;
      end;
    end;
  end;

  Result.Visible := AVisible;
  Result.Presentations.Open(ADocument, False, False, True);
end;

function GetActiveMSPPTClass(AFileName: TFileName; AVisible: boolean) : PowerPointApplication;
begin
  { Check if file exists }
  if not FileExists(AFileName) then
  begin
    ShowMessage('Specified Document not found.');
    Exit;
  end;

  { Create the OLE Object }
  try
    Result := GetActiveOleObject('PowerPoint.Application') as PowerPointApplication;
  except
    try
      Result := CreateOLEObject('PowerPoint.Application') as PowerPointApplication;
    except
      on E: Exception do
      begin
        E.Message := 'PowerPoint is not available.';
        raise;
      end;
    end;
  end;

  Result.Visible := Ord(AVisible);
  Result.Presentations.Open(AFileName, msoFalse, msoFalse, msoTrue);
end;

function PPT_StringReplace(PPTApp: PowerPointApplication; SearchString, ReplaceString: string;
  Flags: TPPTReplaceFlags): Boolean;
var
  i, k: integer;
  LPPtSlide: PowerPointSlide;
  LPPtPresentation: PowerPointPresentation;
begin
  Result := False;

  for k := 1 to PPTApp.Presentations.Count do
  begin
    LPPtPresentation := PPTApp.Presentations.Item(k);

    for i := 1 to LPPtPresentation.Slides.Count do
    begin
      LPPtSlide := LPPtPresentation.Slides.Item(i);
      Result := PPT_StringReplaceFromSlide(LPPtSlide, SearchString, ReplaceString, Flags);
    end;//for i
  end;
end;

function PPT_StringReplaceFromSlide(ASlide: PowerPointSlide; SearchString, ReplaceString: string;
  Flags: TPPTReplaceFlags=[]): Boolean;
var
  j, LNewStartPos: integer;
  LShape: PowerPoint2010.Shape;
  LTextRange, LTempTextRange: TextRange;
begin
  Result := False;

  for j := 1 to ASlide.Shapes.Count do
  begin
    LShape := ASlide.Shapes.Item(j);

    if LShape.HasTextFrame = msoTrue then
    begin
      if LShape.TextFrame.HasText = msoTrue then
      begin
        LTextRange := LShape.TextFrame.TextRange;
        LTempTextRange := LTextRange.Replace(SearchString, ReplaceString, 0, msoFalse, msoFalse);

        if pptrfReplaceAll in Flags then
        begin
          while LTempTextRange.Text <> '' do
          begin
            LNewStartPos := LTempTextRange.Start + LTempTextRange.Length;
            LTempTextRange := LTextRange.Replace(SearchString, ReplaceString, LNewStartPos, msoFalse, msoFalse);
          end;//while
        end;
      end;
    end;
  end;//for j

  Result := True;
end;

procedure PPT_InsertImageToPPTFromClipboard(APPTApp: PowerPointApplication;
  ASlideNo: integer; AImgHeight, AImgWidth, AImgTop, AImgLeft: single);
var
  LPPtPresentation: PowerPointPresentation;
  LSlide: PowerPointSlide;
  LSlideHeight, LSlideWidth: Single;
begin
  LPPtPresentation := APPTApp.ActivePresentation;
  LSlideHeight := LPPtPresentation.PageSetup.SlideHeight;
  LSlideWidth := LPPtPresentation.PageSetup.SlideWidth;

  //첫번쨰 Slide 가져옴
  LSlide := LPPtPresentation.Slides.Item(ASlideNo);//(1);

  PPT_InsertImageToSlideFromClipboard(LSlide, LSlideHeight, LSlideWidth, AImgHeight, AImgWidth, AImgTop, AImgLeft);
end;

procedure PPT_InsertImageToSlideFromClipboard(ASlide: PowerPointSlide; ASlideHeight, ASlideWidth,
  AImgHeight, AImgWidth, AImgTop, AImgLeft: single);
var
  LShapeRange: PowerPoint2010.ShapeRange;
begin
  //Clipboard 내용을 Slikde에 붙여넣기 함(Shape가 자동 생성됨)
  LShapeRange := ASlide.Shapes.Paste;
  //위에서 복사한 Shape 크기 및 위치 조정
  LShapeRange.Height := AImgHeight;//60.0;
  LShapeRange.Width := AImgWidth;//60.0;
  LShapeRange.Top := AImgTop;
  LShapeRange.Left := AImgLeft;
//  LShapeRange.Top := ASlideHeight - (LShapeRange.Height * 2);
//  LShapeRange.Left := ASlideWidth - (LShapeRange.Width * 2);
end;

procedure PPT_InsertImageToShapeFromClipboard(AShape: PowerPoint2010.Shape);
begin
;//  AShape.Paste;
end;

function PPT_CopySlideFromSrcSlide(ASlide: PowerPointSlide): SlideRange;
begin
  Result := ASlide.Duplicate;
end;

function PPT_CopySlideFromSlideIndex(PPTApp: PowerPointApplication; ASlideIndex: integer): PowerPointSlide;
var
  LSrcSlide: PowerPointSlide;
  LSlideRange: SlideRange;
begin
  LSrcSlide := PPTApp.ActivePresentation.Slides.Item(ASlideIndex);
  LSlideRange := PPT_CopySlideFromSrcSlide(LSrcSlide);

  Result := LSlideRange.Item(1);
end;

function PPT_StringFindNFontSize(ASlide: PowerPointSlide; SearchString: string; ASize: integer): Boolean;
var
  i: integer;
  LShape: PowerPoint2010.Shape;
  LTextRange, LFoundTxtRange: TextRange;
begin
  for i := 1 to ASlide.Shapes.Count do
  begin
    LShape := ASlide.Shapes.Item(i);
    //만약 해당 슬라이드가 Text를 포함하고 있다면
    if LShape.HasTextFrame = msoTrue then
    begin
      if LShape.TextFrame.HasText = msoTrue then
      begin
        LTextRange := LShape.TextFrame.TextRange;

        LFoundTxtRange := LTextRange.Find(SearchString,0,msoFalse,msoTrue);

        if Assigned(LFoundTxtRange) then
        begin
          LFoundTxtRange.Font.Size := ASize;
        end;
      end;
    end;
  end;
end;

procedure PPT_SaveAsFormat(AOriginalFileName: string; AFileFormat: integer);
begin

end;

end.
