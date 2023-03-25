unit UnitSystemInfoUtil;

interface

uses OnGuard, OgUtil, uSMBIOS, UnitSMBiosUtil;

function GetCPUId: int64;

implementation

function GetCPUId: int64;
begin
  Result := GetProcessorInfoUsingSMBios;

  //VM���� ������ ��� -1 ��ȯ��
  if Result = -1 then
    Result := GenerateMachineModifierPrim;
end;

end.
