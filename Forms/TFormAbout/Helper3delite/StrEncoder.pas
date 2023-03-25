unit StrEncoder;
{
2006.02.24.
Egy nagyon egyszerû titkosító a jogosult paraméterállítók jelszavainak
tárolásához. A digits konstansban megadott karakterekkel 2 jegyû számokká
alakítja az ascii kódot. A nehezítés kedvéért a kisebb helyi értékû számjegy
van elõször tárolva. Gyakorlatilag egy számrendszer átváltó.
}
//-----------?-----------?-----------?-----------?-----------?-----------?-----------?-
interface
//-----------?-----------?-----------?-----------?-----------?-----------?-----------?-
  Function StrEncode(s:string):string; // kódoló
  Function StrDecode(s:string):string; // dekódoló
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
