unit StrEncoder;
{
2006.02.24.
Egy nagyon egyszer� titkos�t� a jogosult param�ter�ll�t�k jelszavainak
t�rol�s�hoz. A digits konstansban megadott karakterekkel 2 jegy� sz�mokk�
alak�tja az ascii k�dot. A nehez�t�s kedv��rt a kisebb helyi �rt�k� sz�mjegy
van el�sz�r t�rolva. Gyakorlatilag egy sz�mrendszer �tv�lt�.
}
//-----------?-----------?-----------?-----------?-----------?-----------?-----------?-
interface
//-----------?-----------?-----------?-----------?-----------?-----------?-----------?-
  Function StrEncode(s:string):string; // k�dol�
  Function StrDecode(s:string):string; // dek�dol�
//-----------?-----------?-----------?-----------?-----------?-----------?-----------?-
implementation
//-----------?-----------?-----------?-----------?-----------?-----------?-----------?-
const
  digits= '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  Ldigits=Length(digits);
//-----------?-----------?-----------?-----------?-----------?-----------?-----------?-
Function StrEncode(s:string):string;
var
  i,j: Integer;
  ch:byte;
begin
  result:='';
  if s<>'' then
  begin
    for i:=1 to length(s) do
    begin
      ch:=ord(s[i]);
      for j:=1 to 2 do
      begin
        result:=result+digits[(ch mod Ldigits)+1];
        ch:=ch div Ldigits;
      end;
    end;
  end;
end;
//-----------?-----------?-----------?-----------?-----------?-----------?-----------?-
Function StrDecode(s:string):string;
var
  i: Integer;
  hi,lo:byte;
begin
  result:='';
  lo:=0;
  if s<>'' then
  begin
    for i:=1 to length(s) do
    begin
      if (i and 1)=1 then
      begin
        lo:=pos(s[i],digits)
      end else
      begin
        hi:=pos(s[i],digits);
        if (hi>0) and (lo>0) then
        begin
          result:=result+chr((hi-1)*Ldigits+(lo-1));
        end;
      end;
    end;
  end;
end;
//-----------?-----------?-----------?-----------?-----------?-----------?-----------?-
end.
