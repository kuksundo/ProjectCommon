unit UnitHotSpotImgUtil;

interface

uses Winapi.Windows, System.SysUtils, Forms,
  HotSpotImage;

function GetHotSpotImgByName(AForm: TForm; AName: string): THotSpotImage;
procedure DisplayHotSpotByID(AHotSpotImg: THotSpotImage; AID: string);
procedure DisplayHotSpotByName(AHotSpotImg: THotSpotImage; AName: string);

implementation

function GetHotSpotImgByName(AForm: TForm; AName: string): THotSpotImage;
var
  i: integer;
begin
  Result := nil;

  with AForm do
  begin
    for i := 0 to ComponentCount - 1 do
    begin
      if Pos(AName, Components[i].Name) > 0 then
      begin
        Result := THotSpotImage(Components[i]);
        Break;
      end;
    end;//for
  end;//with
end;

procedure DisplayHotSpotByID(AHotSpotImg: THotSpotImage; AID: string);
var
  LHotspot: THotSpot;
begin
  LHotspot := AHotSpotImg.HotSpotByID(StrToIntDef(AID,0));

  if Assigned(LHotspot) then
  begin
    LHotspot.Blink := True;
  end;
end;

procedure DisplayHotSpotByName(AHotSpotImg: THotSpotImage; AName: string);
var
  LHotspot: THotSpot;
begin
  LHotspot := AHotSpotImg.HotSpotByName(AName);

  if Assigned(LHotspot) then
  begin
    LHotspot.Blink := True;
  end;
end;

end.
