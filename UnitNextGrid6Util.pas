unit UnitNextGrid6Util;

interface

uses SysUtils, StdCtrls,Classes, Graphics, Grids, ComObj, StrUtils,
    Variants, Dialogs, Forms, Excel2010,
    NxColumns6, NxGrid6, NxCells6,
    SynCommons;

function ChangeRowColorByIndex(AGrid: TNextGrid6; ARowIndex: integer; AColor: TColor): TColor;

implementation

uses UnitStringUtil;

function ChangeRowColorByIndex(AGrid: TNextGrid6; ARowIndex: integer; AColor: TColor): TColor;
var
  i: integer;
begin
  Result := AGrid.Cell[0, ARowIndex].Color;

  if Result <> AColor then
  begin
    for i := 0 to AGrid.Columns.Count - 1 do
    begin
      AGrid.Cell[i, ARowIndex].Color := AColor;
    end;
  end;
end;

end.
