program fam_basic_byte_01;

{$mode unleashed}

type
  PMessage = ^TMessage;
  TMessage = packed record
    code:   LongInt;
    length: LongInt;
    data:   array[] of Byte;
  end;

var
  msg: PMessage;

begin
  if SizeOf(TMessage) <> 8 then halt(1);   // header only
  GetMem(msg, SizeOf(TMessage) + 1024);
  msg^.code := 42;
  msg^.length := 1024;
  for var i := 0 to 1023 do
    msg^.data[i] := Byte(i);
  if msg^.code      <> 42   then halt(2);
  if msg^.length    <> 1024 then halt(3);
  if msg^.data[0]   <> 0    then halt(4);
  if msg^.data[100] <> 100  then halt(5);
  if msg^.data[255] <> 255  then halt(6);
  if msg^.data[256] <> 0    then halt(7);
  FreeMem(msg);
end.
