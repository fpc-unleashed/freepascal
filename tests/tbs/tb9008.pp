{ a 64 bit shl/shr downcast to 32 bit must not be reduced to a 32 bit
  shift when the count reaches the smaller width (it would get masked)
  or when the shifted value is sign-extended (shr pulls those bits in);
  inline expansion exposes this by substituting constant arguments }
program tb9008;

{$mode objfpc}
{$inline on}

procedure shrconst(q: qword; out r: dword); inline;
begin
  r := dword(q shr 32);
end;

procedure shrvar(q: qword; c: dword; out r: dword); inline;
begin
  r := dword(q shr c);
end;

procedure shrsigned(q: int64; out r: dword); inline;
begin
  r := dword(q shr 4);
end;

procedure shlconst(q: qword; out r: dword); inline;
begin
  r := dword(q shl 32);
end;

var
  r, c: dword;
begin
  shrconst(1, r);
  if r <> 0 then Halt(1);
  c := 40;
  shrvar(1000000, c, r);
  if r <> 0 then Halt(2);
  shrsigned(-1, r);
  if r <> $FFFFFFFF then Halt(3);
  shlconst(1, r);
  if r <> 0 then Halt(4);
end.
