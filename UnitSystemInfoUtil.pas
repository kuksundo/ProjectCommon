unit UnitSystemInfoUtil;

interface

uses OnGuard, OgUtil, uSMBIOS, UnitSMBiosUtil;

function GetCPUId: int64;

implementation

function GetCPUId: int64;
begin
  Result := GetProcessorInfoUsingSMBios;

  //VM에서 실행할 경우 -1 반환됨
  if Result = -1 then
    Result := GenerateMachineModifierPrim;
end;

end.
