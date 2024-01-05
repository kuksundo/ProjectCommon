unit UnitColorUtil;

interface

uses WinApi.Windows, System.Math, Vcl.Graphics;

type
  TRGB = record
      R: Integer;
      G: Integer;
      B: Integer;
  end;

  THLS = record
      H: Integer;
      L: Integer;
      S: Integer;
  end;

function ColorToRGB(PColor: TColor): TRGB;
function RGBToColor(PR,PG,PB: Integer): TColor;
function RGBToCol(PRGB: TRGB): TColor;
function RGBToHLS(PRGB: TRGB): THLS;
function HLSToRGB(PHLS: THLS): TRGB;
function CalcComplementalColor(AColor: TColor): TColor;

procedure HSVtoRGB (const H,S,V: double; var R,G,B: double);
procedure RGBToHSV (const R,G,B: Double; var H,S,V: Double);
function HSVtoColor(Const Hue, Saturation, Value: Integer): TColor;
procedure ColortoHSV(Const Color: TColor; Var Hue, Saturation, Value: Integer);
function Blend(Color1, Color2: TColor; A: Byte): TColor;

implementation

function maxTri(P1,P2,P3: double): Double;
begin
    Result := -1;
    if (P1 > P2) then begin
        if (P1 > P3) then begin
            Result := P1;
        end else begin
            Result := P3;
        end;
    end else if P2 > P3 then begin
        result := P2;
    end else result := P3;
end;

function minTri(P1,P2,P3: double): Double;
begin
    Result := -1;
    if (P1 < P2) then begin
        if (P1 < P3) then begin
            Result := P1;
        end else begin
            Result := P3;
        end;
    end else if P2 < P3 then begin
        result := P2;
    end else result := P3;
end;

function RGBToColor(PR,PG,PB: Integer): TColor;
begin
  Result := TColor((PB * 65536) + (PG * 256) + PR);
end;

function ColorToRGB(PColor: TColor): TRGB;
var
  i: Integer;
begin
  i := PColor;
  Result.R := 0;
  Result.G := 0;
  Result.B := 0;

  while i - 65536 >= 0 do
  begin
    i := i - 65536;
    Result.B := Result.B + 1;
  end;

  while i - 256 >= 0 do
  begin
    i := i - 256;
    Result.G := Result.G + 1;
  end;

  Result.R := i;
end;

function RGBToCol(PRGB: TRGB): TColor;
begin
  Result := RGBToColor(PRGB.R,PRGB.G,PRGB.B);
end;

function RGBToHLS(PRGB: TRGB): THLS;
var
  LR,LG,LB,LH,LL,LS,LMin,LMax: double;
  LHLS: THLS;
  i: Integer;
begin
  LR := PRGB.R / 256;
  LG := PRGB.G / 256;
  LB := PRGB.B / 256;
  LMin := minTri(LR,LG,LB);
  LMax := maxTri(LR,LG,LB);
  LL := (LMax + LMin)/2;

  if LMin = LMax then
  begin
    LH := 0;
    LS := 0;
    Result.H := round(LH * 256);
    Result.L := round(LL * 256);
    Result.S := round(LS * 256);
    exit;
  end;

  If LL < 0.5 then LS := (LMax - LMin) / (LMax + LMin);
  If LL >= 0.5 then LS := (LMax-LMin) / (2.0 - LMax - LMin);
  If LR = LMax then LH := (LG - LB)/(LMax - LMin);
  If LG = LMax then LH := 2.0 + (LB - LR) / (LMax - LMin);
  If LB = LMax then LH := 4.0 + (LR - LG) / (LMax - LMin);
  Result.H := round(LH * 42.6);
  Result.L := round(LL * 256);
  Result.S := round(LS * 256);
end;

function HLSToRGB(PHLS: THLS): TRGB;
var
  LR,LG,LB,LH,LL,LS: double;
  LHLS: THLS;
  L1,L2: Double;
begin
  LH := PHLS.H / 255;
  LL := PHLS.L / 255;
  LS := PHLS.S / 255;

  if LS = 0 then
  begin
      Result.R := PHLS.L;
      Result.G := PHLS.L;
      Result.B := PHLS.L;
      Exit;
  end;

  If LL < 0.5 then L2 := LL * (1.0 + LS);
  If LL >= 0.5 then L2 := LL + LS - LL * LS;
  L1 := 2.0 * LL - L2;
  LR := LH + 1.0/3.0;
  if LR < 0 then LR := LR + 1.0;
  if LR > 1 then LR := LR - 1.0;
  If 6.0 * LR < 1 then LR := L1+(L2 - L1) * 6.0 * LR
  Else if 2.0 * LR < 1 then LR := L2
  Else if 3.0*LR < 2 then LR := L1 + (L2 - L1) *
                                     ((2.0 / 3.0) - LR) * 6.0
  Else LR := L1;
  LG := LH;
  if LG < 0 then LG := LG + 1.0;
  if LG > 1 then LG := LG - 1.0;
  If 6.0 * LG < 1 then LG := L1+(L2 - L1) * 6.0 * LG
  Else if 2.0*LG < 1 then LG := L2
  Else if 3.0*LG < 2 then LG := L1 + (L2 - L1) *
                                     ((2.0 / 3.0) - LG) * 6.0
  Else LG := L1;
  LB := LH - 1.0/3.0;
  if LB < 0 then LB := LB + 1.0;
  if LB > 1 then LB := LB - 1.0;
  If 6.0 * LB < 1 then LB := L1+(L2 - L1) * 6.0 * LB
  Else if 2.0*LB < 1 then LB := L2
  Else if 3.0*LB < 2 then LB := L1 + (L2 - L1) *
                                     ((2.0 / 3.0) - LB) * 6.0
  Else LB := L1;
  Result.R := round(LR * 255);
  Result.G := round(LG * 255);
  Result.B := round(LB * 255);
end;

function CalcComplementalColor(AColor: TColor): TColor;
var
  LRGB: TRGB;
  LHLS: THLS;
begin
  LRGB := ColorToRGB(AColor);
{  LHLS := RGBToHLS(LRGB);

  LHLS.H := LHLS.H + $200;  //Hue, Add 180 deg (0x200 = 0x400 / 2)
  LHLS.H := LHLS.H and $7ff;//Hue, Mod 360 deg to Hue
  LRGB := HLSToRGB(LHLS);
  Result := RGBTOCol(LRGB);
}
  if AColor >= 0 then
    Result := RGB((255-LRGB.R),(255-LRGB.G),(255-LRGB.B))
  else
    Result := $00ffffff;
end;

procedure RGBToHSV (const R,G,B: Double; var H,S,V: Double);
var
  Delta: double;
  Min : double;
begin
  Min := MinValue( [R, G, B] );
  V := MaxValue( [R, G, B] );

  Delta := V - Min;

  // Calculate saturation: saturation is 0 if r, g and b are all 0
  if V = 0.0 then
    S := 0
  else
    S := Delta / V;

  if (S = 0.0) then
    H := NaN    // Achromatic: When s = 0, h is undefined
  else
  begin       // Chromatic
    if (R = V) then
    // between yellow and magenta [degrees]
      H := 60.0 * (G - B) / Delta
    else
      if (G = V) then
       // between cyan and yellow
        H := 120.0 + 60.0 * (B - R) / Delta
      else
        if (B = V) then
        // between magenta and cyan
          H := 240.0 + 60.0 * (R - G) / Delta;

    if (H < 0.0) then
      H := H + 360.0
  end;
end; {RGBtoHSV}

procedure HSVtoRGB (const H,S,V: double; var R,G,B: double);
var
  f : double;
  i : INTEGER;
  hTemp: double; // since H is CONST parameter
  p,q,t: double;
begin
  if (S = 0.0) then    // color is on black-and-white center line
  begin
    if IsNaN(H) then
    begin
      R := V;           // achromatic: shades of gray
      G := V;
      B := V
    end;
    //else
    //  raise;// EColorError.Create('HSVtoRGB: S = 0 and H has a value');
  end
  else
  begin // chromatic color
    if (H = 360.0) then         // 360 degrees same as 0 degrees
      hTemp := 0.0
    else
      hTemp := H;

    hTemp := hTemp / 60;     // h is now IN [0,6)
    i := TRUNC(hTemp);        // largest integer <= h
    f := hTemp - i;                  // fractional part of h

    p := V * (1.0 - S);
    q := V * (1.0 - (S * f));
    t := V * (1.0 - (S * (1.0 - f)));

    case i of
      0: begin R := V; G := t;  B := p  end;
      1: begin R := q; G := V; B := p  end;
      2: begin R := p; G := V; B := t   end;
      3: begin R := p; G := q; B := V  end;
      4: begin R := t;  G := p; B := V  end;
      5: begin R := V; G := p; B := q  end;
    end;
  end;
end; {HSVtoRGB}

function HSVtoColor(Const Hue, Saturation, Value: Integer): TColor;
Var
  Red, Green, Blue: double;
begin
  //HSVtoRGB(Hue, Saturation, Value, Red, Green, Blue);
  //Result := RGB(Red, Green, Blue);
end;

procedure ColortoHSV(Const Color: TColor; Var Hue, Saturation, Value: Integer);
Var
  RGB: LongWord;
begin
  //RGB := ColorToRGB(Color);
  //RGBtoHSV(GetRValue(RGB), GetGValue(RGB), GetBValue(RGB), Hue, Saturation, Value);
end;

// Usage  NewColor:= Blend(Color1, Color2, blending level 0 to 100);
function Blend(Color1, Color2: TColor; A: Byte): TColor;
var
  c1, c2: LongInt;
  r, g, b, v1, v2: byte;
begin
//  A:= Round(2.55 * A);
//  c1 := ColorToRGB(Color1);
//  c2 := ColorToRGB(Color2);
//  v1:= Byte(c1);
//  v2:= Byte(c2);
//  r:= A * (v1 - v2) shr 8 + v2;
//  v1:= Byte(c1 shr 8);
//  v2:= Byte(c2 shr 8);
//  g:= A * (v1 - v2) shr 8 + v2;
//  v1:= Byte(c1 shr 16);
//  v2:= Byte(c2 shr 16);
//  b:= A * (v1 - v2) shr 8 + v2;
//  Result := (b shl 16) + (g shl 8) + r;
end;

end.
