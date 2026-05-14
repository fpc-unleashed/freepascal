program fam_pointer_to_pmessage_01;

{$mode unleashed}

type
  PMsg = ^TMsg;
  TMsg = packed record
    code: LongInt;
    len: LongInt;
    data: array[] of Byte;
  end;

procedure WriteHello(msg: PMsg);
const
  HELLO: array[0..4] of Byte = ($48, $65, $6C, $6C, $6F);   // 'Hello'
begin
  msg^.code := 1;
  msg^.len := 5;
  for var i := 0 to 4 do
    msg^.data[i] := HELLO[i];
end;

begin
  var m: PMsg;
  GetMem(m, SizeOf(TMsg) + 5);
  WriteHello(m);
  if m^.code <> 1 then halt(1);
  if m^.len  <> 5 then halt(2);
  if m^.data[0] <> $48 then halt(3);
  if m^.data[4] <> $6F then halt(4);
  FreeMem(m);
end.
