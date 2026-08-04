{ test word compound assignment operators without $COPERATORS }

{$COPERATORS OFF}

var
  i : LongInt;
  b : Boolean;
begin
  i:=10;
  i div= 3;
  if i<>3 then
    halt(1);

  i mod= 2;
  if i<>1 then
    halt(2);

  i:=6;
  i and= 3;
  if i<>2 then
    halt(3);

  i or= 4;
  if i<>6 then
    halt(4);

  i xor= 3;
  if i<>5 then
    halt(5);

  b:=true;
  b and= false;
  if b then
    halt(6);

  i:=1;
  i shl= 3;
  if i<>8 then
    halt(7);

  i shr= 2;
  if i<>2 then
    halt(8);
end.
