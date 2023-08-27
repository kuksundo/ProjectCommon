unit UnitAddSystem_Types_XE7;

interface

uses System.Types;

type
  TPointHelper = record helper for TPoint
    class function zero: TPoint; static;
  end;

implementation

{ TPointHelper }

class function TPointHelper.zero: TPoint;
begin
  Result.X := 0;
  Result.Y := 0;
end;

end.
