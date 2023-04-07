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
procedure PPT_InsertImageToPPTFromClipboard(APPTApp: PowerPointApplication;
  ASlideNo: integer; AImgHeight, AImgWidth, AImgTop, AImgLeft: single);
procedure PPT_InsertImageToSlideFromClipboard(ASlide: PowerPointSlide; ASlideHeight, ASlideWidth,
  AImgHeight, AImgWidth, AImgTop, AImgLeft: single);
procedure PPT_InsertImageToShapeFromClipboard(AShape: PowerPoint2010.Shape);

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
  i, j, k, LNewStartPos: integer;
  LPPtSlide: PowerPointSlide;
  LShape: PowerPoint2010.Shape;
  LPPtPresentation: PowerPointPresentation;
  LTextRange, LTempTextRange: TextRange;
begin
  for k := 1 to PPTApp.Presentations.Count do
  begin
    LPPtPresentation := PPTApp.Presentations.Item(k);

    for i := 1 to LPPtPresentation.Slides.Count do
    begin
      LPPtSlide := LPPtPresentation.Slides.Item(i);

      for j := 1 to LPPtSlide.Shapes.Count do
      begin
        LShape := LPPtSlide.Shapes.Item(j);

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
    end;//for i
  end;
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

  //ù���� Slide ������
  LSlide := LPPtPresentation.Slides.Item(ASlideNo);//(1);

  PPT_InsertImageToSlideFromClipboard(LSlide, LSlideHeight, LSlideWidth, AImgHeight, AImgWidth, AImgTop, AImgLeft);
end;

procedure PPT_InsertImageToSlideFromClipboard(ASlide: PowerPointSlide; ASlideHeight, ASlideWidth,
  AImgHeight, AImgWidth, AImgTop, AImgLeft: single);
var
  LShapeRange: PowerPoint2010.ShapeRange;
begin
  //Clipboard ������ Slikde�� �ٿ��ֱ� ��(Shape�� �ڵ� ������)
  LShapeRange := ASlide.Shapes.Paste;
  //������ ������ Shape ũ�� �� ��ġ ����
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

end.
