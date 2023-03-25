unit XBaloon_Util;

interface

uses
  WinTypes, WinProcs, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,XBaloon;

  procedure DisplayXBaloon( Ctrl: TControl; Baloon:TXBaloon;X, Y: Integer;
                              Msg:string;FSize:Integer=10;FColor:TColor=clYellow;
                              CColor:TColor = ClNavy;FName:String='MS Sans Serif';
                              FStyle:TFontStyle=fsBold);

implementation

//XBaloon�� �������� �������� �ʰ� ��ϵ� ������Ʈ�� �̿��� ���
//���� �ҽ��� OnMouseDown Event�� �����Ѵ�.
{  if Button = mbLeft then
   begin
    Point.X := X + Label4.Left;
    Point.Y := Y + Label4.Top;
    Point := ClientToScreen(Point);
    Baloon.Font.Name := Label4.Font.Name;
    Baloon.Font.Size := Label4.Font.Size;
    Baloon.Font.Style := Label4.Font.Style;
    Baloon.Color := Label4.Font.Color;
    Baloon.Shape := sRectangle;
    Baloon.Align := alLeft;
    Baloon.Show(Point, Label4.Caption);
    Baloon.Align := alRight;
   end;
}
//Hint�� �����ְ� ���� ��Ʈ���� MouseDown Event���� �� �Լ��� ȣ���Ѵ�.
//Parameter ::
//            Ctro : ���콺�� Ŭ���� ��Ʈ�� �ڵ�
//            Baloon : �������� ������ TXBaloon_DynaCreate_pjh
//            X,Y : ���콺�� X,Y ������
//            Msg : ���÷����� �޼���
//            FSize : ��Ʈ ������
//            FColor : ��Ʈ ����
//            CColor : ��� ����
//            FName : ��Ʈ �̸�
//            FStyle : ��Ʈ ��Ÿ��=(fsBold, fsItalic, fsUnderline, fsStrikeOut);
//EX)   DisplayXBaloon( GradLabel1,
//                  XBaloon1,
//                  X,Y,
//                  GradLabel1.Caption,
//                  GradLabel1.Font.Size,
//                  GradLabel1.Font.Color,
//                 );
procedure DisplayXBaloon( Ctrl: TControl; Baloon:TXBaloon;X, Y: Integer;
                              Msg:string;FSize:Integer=10;FColor:TColor=clYellow;
                              CColor:TColor = ClNavy;FName:String='MS Sans Serif';
                              FStyle:TFontStyle=fsBold);
var Point: TPoint;
begin
  Point.X := X + Ctrl.Left;
  Point.Y := Y + Ctrl.Top;
  Point := Ctrl.Parent.ClientToScreen(Point);

  with Baloon do
  begin
    Font.Name := FName;
    Font.Size := FSize;
    Font.Style := TFontStyles(FStyle);
    //Font.Color := FColor;
    Color := CColor;
    //Shape := sRectangle;
    //Align := alLeft;
    //Show(Point, Msg);
    Show(Msg);
    //Align := alRight;
  end;//with
end;

end.
