program fam_end_to_end_01;

{ flexible array members work end-to-end: allocation, access, free }

{$mode unleashed}

type
  PMessage = ^TMessage;
  TMessage = packed record
    code:   integer;
    length: integer;
    data:   array[] of byte;
  end;

  PHeader = ^THeader;
  THeader = record
    count: longword;
    items: array[] of int64;
  end;

var
  msg : PMessage;
  hdr : PHeader;
  i   : integer;
begin
  if sizeof(TMessage) <> 8 then
    halt(1);

  GetMem(msg, sizeof(TMessage) + 32);
  msg^.code := $7EADBEEF;
  msg^.length := 32;
  for i := 0 to 31 do
    msg^.data[i] := byte(i);
  for i := 0 to 31 do
    if msg^.data[i] <> byte(i) then
      halt(2);
  if msg^.code <> $7EADBEEF then
    halt(3);
  FreeMem(msg);

  GetMem(hdr, sizeof(THeader) + 4 * sizeof(int64));
  hdr^.count := 4;
  hdr^.items[0] := -1;
  hdr^.items[1] := high(int64);
  hdr^.items[2] := low(int64);
  hdr^.items[3] := $1234567890ABCDEF;
  if hdr^.items[3] <> $1234567890ABCDEF then
    halt(4);
  FreeMem(hdr);

  writeln('ok');
end.
