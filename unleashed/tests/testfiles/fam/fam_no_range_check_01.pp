program fam_no_range_check_01;

{ a flexible array member is not range-checked at compile time or at
  runtime, so accesses far past the declared "size" must work under {$R+} }

{$mode unleashed}
{$rangechecks on}

type
  PFam = ^TFam;
  TFam = record
    a: integer;
    data: array[] of byte;
  end;

var
  f : PFam;
  i : integer;
begin
  GetMem(f, sizeof(TFam) + 1024);
  f^.a := 7;
  for i := 0 to 1023 do
    f^.data[i] := byte(i);
  for i := 0 to 1023 do
    if f^.data[i] <> byte(i) then
      halt(1);
  if f^.a <> 7 then
    halt(2);
  FreeMem(f);
  writeln('ok');
end.
