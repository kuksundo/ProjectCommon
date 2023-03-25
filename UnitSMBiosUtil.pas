unit UnitSMBiosUtil;

interface

uses uSMBIOS;

function GetProcessorInfoUsingSMBios: int64;

implementation

function GetProcessorInfoUsingSMBios: int64;
Var
  SMBios: TSMBios;
  i: integer;
  LProcessorInfo: TProcessorInformation;
begin
  Result := -1;

  SMBios := TSMBios.Create;
  try
    //Virtual Machine에서는 False임
    if SMBios.HasProcessorInfo then
    begin
      for i := Low(SMBios.ProcessorInfo) to High(SMBios.ProcessorInfo) do
      begin
        LProcessorInfo := SMBios.ProcessorInfo[i];
        Result := LProcessorInfo.RAWProcessorInformation^.ProcessorID;
        break;
      end;
    end;
  finally
    SMBios.Free;
  end;
end;

end.
