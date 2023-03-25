{$I iInclude.inc}
unit UnitGPFunction;

interface

uses
{$I iIncludeUses.inc}
  iTypes, iMath;

procedure DrawValveKnob(ACanvas: TCanvas; BackColor, ShawdowColor: TColor;
  ARect: TRect; ReverseColors: Boolean; AValveKind: integer=0);
procedure Line(Canvas: TCanvas; Left, Top, Right, Bottom: Integer);

implementation

function pjhGetRValue(rgb: DWORD): Byte;
begin
  Result := Byte(rgb);
end;

function pjhGetGValue(rgb: DWORD): Byte;
begin
  Result := Byte(rgb shr 8);
end;

function pjhGetBValue(rgb: DWORD): Byte;
begin
  Result := Byte(rgb shr 16);
end;

procedure Line(Canvas: TCanvas; Left, Top, Right, Bottom: Integer);
begin
  with Canvas do
  begin
    Polyline([Point(Left, Top), Point(Right, Bottom)]);
  end;
end;

procedure DrawValveKnob(ACanvas: TCanvas; BackColor, ShawdowColor: TColor;
  ARect: TRect; ReverseColors: Boolean; AValveKind: integer);
var
  Red, Green, Blue : Integer;
  StartRed         : Integer;
  StartGreen       : Integer;
  StartBlue        : Integer;
  StopRed          : Integer;
  StopGreen        : Integer;
  StopBlue         : Integer;
  i, x, y          : Integer;
  NumOfLines       : Integer;
  CenterPoint_      : TPoint;
  LastX            : Integer;
  Radius           : Integer;
begin
  with ACanvas, ARect do
  begin
    Pen.Style := psSolid;

    StartRed   := pjhGetRValue(ColorToRGB(clWhite));
    StartGreen := pjhGetGValue(ColorToRGB(clWhite));
    StartBlue  := pjhGetBValue(ColorToRGB(clWhite));

    StopRed    := pjhGetRValue(ShawdowColor);
    StopGreen  := pjhGetGValue(ShawdowColor);
    StopBlue   := pjhGetBValue(ShawdowColor);

    Radius      := (Right - Left + 1) div 2;
    NumOfLines  := Radius*4;

    if NumOfLines = 0 then Exit;

    for x := 0 to NumOfLines-1 do
    begin
      if ReverseColors then
      begin
        Red   := Round((x/NumOfLines*StartRed   + (NumOfLines-x)/NumOfLines*StopRed  ));
        Green := Round((x/NumOfLines*StartGreen + (NumOfLines-x)/NumOfLines*StopGreen));
        Blue  := Round((x/NumOfLines*StartBlue  + (NumOfLines-x)/NumOfLines*StopBlue ));
      end
      else
      begin
        Red   := Round((x/NumOfLines*StopRed    + (NumOfLines-x)/NumOfLines*StartRed  ));
        Green := Round((x/NumOfLines*StopGreen  + (NumOfLines-x)/NumOfLines*StartGreen));
        Blue  := Round((x/NumOfLines*StopBlue   + (NumOfLines-x)/NumOfLines*StartBlue ));
      end;

      Pen.Color := $02000000 + (Red + Green shl 8 + Blue shl 16);

      if x < (NumOfLines div 2) then
        Polyline([Point(Left+x, Top), Point(Left, Top+x)])
      else
        Polyline([Point(Right, Top + x - NumOfLines div 2), Point(Left+x - NumOfLines div 2, Bottom)])
    end;

    Pen.Color := BackColor;
    LastX         := - 1;
    CenterPoint_.X := (Left + Right ) div 2;
    CenterPoint_.Y := (Top  + Bottom) div 2;

    if AValveKind = 0 then //pvtManualPush
    begin
      for i := 0 to NumOfLines*2 do
      begin
        X := Round(Cos(DegToRad(90*i/(NumOfLines*2))) * Radius);
        Y := Round(Sin(DegToRad(90*i/(NumOfLines*2))) * Radius);
        if X = LastX then Continue;
        LastX := X;

        Polyline([Point(CenterPoint_.X + X, CenterPoint_.Y - Y), Point(CenterPoint_.X + X, Top-1       )]);
        Polyline([Point(CenterPoint_.X - X, CenterPoint_.Y - Y), Point(CenterPoint_.X - X, Top-1       )]);
        Polyline([Point(CenterPoint_.X + X, CenterPoint_.Y + Y), Point(CenterPoint_.X + X, ARect.Bottom)]);
        Polyline([Point(CenterPoint_.X - X, CenterPoint_.Y + Y), Point(CenterPoint_.X - X, ARect.Bottom)]);
      end;
    end;
  end;
end;

end.
