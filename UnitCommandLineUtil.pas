unit UnitCommandLineUtil;

interface

uses SysUtils, System.Rtti, system.Generics.Collections, GpCommandLineParser;

type
  TpjhCommandLine<T:Class> = class
  private
  public
    FCommandLine: T;

    function CreateInstance: T;
    function CommandLineParse(var AErrMsg: string): boolean;
  end;

implementation

{ TpjhCommandLine }

function TpjhCommandLine<T>.CommandLineParse(var AErrMsg: string): boolean;
var
  LStr: string;
begin
  Result := False;
  AErrMsg := '';
  FCommandLine := CreateInstance;
  try
//      CommandLineParser.Options := [opIgnoreUnknownSwitches];
    Result := CommandLineParser.Parse(FCommandLine);
  except
    on E: ECLPConfigurationError do begin
      AErrMsg := '*** Configuration error ***' + #13#10 +
        Format('%s, position = %d, name = %s',
          [E.ErrorInfo.Text, E.ErrorInfo.Position, E.ErrorInfo.SwitchName]);
      Exit;
    end;
  end;

  if not Result then
  begin
    AErrMsg := Format('%s, position = %d, name = %s',
      [CommandLineParser.ErrorInfo.Text, CommandLineParser.ErrorInfo.Position,
       CommandLineParser.ErrorInfo.SwitchName]) + #13#10;
    for LStr in CommandLineParser.Usage do
      AErrMsg := AErrMSg + LStr + #13#10;
  end
  else
  begin
  end;
end;

function TpjhCommandLine<T>.CreateInstance: T;
var
  LValue: TValue;
  ctx: TRttiContext;
  rType: TRttiType;
  LMethodCreate: TRttiMethod;
  LInstanceType: TRttiInstanceType;
begin
  ctx := TRttiContext.Create;
  rType :=  ctx.GetType(TypeInfo(T));
  LMethodCreate := rType.GetMethod('Create');

  if Assigned(LMethodCreate) and rType.IsInstance then
  begin
    LInstanceType := rType.AsInstance;
    LValue := LMethodCreate.Invoke(LInstanceType.MetaclassType, []);
    Result := LValue.AsType<T>;
  end;
end;

end.
