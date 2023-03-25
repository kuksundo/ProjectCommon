unit UnitMQData;

interface

uses System.Classes, UnitEnumHelper;

type
  TMQProtocol = (rmqpNull, rmqpAMQP, rmqpSTOMP, rmqpMQTT,
    rmqpFinal);

  TMQInfoRec = record
    FUserId,
    FPasswd,
    FIPAddr,
    FPortNo,
    FTopic,
    FBindIPAddress: string;

    FIsEnableMQ: Boolean;
  end;

procedure SetMQInfoRec(AIPAddr,APortNo,AUserId,APasswd,ATopic: string;
  AIsMQEnable: Boolean; var ARec: TMQInfoRec);

const
  R_MQProtocol : array[Low(TMQProtocol)..High(TMQProtocol)] of string =
    ('', 'AMQP', 'STOMP', 'MQTT', '');

var
  g_MQProtocol: TLabelledEnum<TMQProtocol>;

implementation

procedure SetMQInfoRec(AIPAddr,APortNo,AUserId,APasswd,ATopic: string;
  AIsMQEnable: Boolean; var ARec: TMQInfoRec);
begin
  ARec.FIPAddr := AIPAddr;
  ARec.FPortNo := APortNo;
  ARec.FUserId := AUserId;
  ARec.FPasswd := APasswd;
  ARec.FTopic := ATopic;
  ARec.FIsEnableMQ := AIsMQEnable;
end;

initialization
  g_MQProtocol.InitArrayRecord(R_MQProtocol);

end.
