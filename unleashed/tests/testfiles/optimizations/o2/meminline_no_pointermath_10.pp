{ %OPT=-O2 }
program meminline_no_pointermath_10;
{$mode objfpc}

// the expansion offsets pointers internally; it must compile in modes
// where pointer arithmetic is rejected (no pointermath, no extsyntax
// relaxation), like an fcl-db unit calling FillChar on a record

type
  TRec = packed record
    name: array[0..31] of Char;
    size: Byte;
    prec: Byte;
    pad: array[0..12] of Byte;
  end;

var
  r: TRec;
  i, sum: Integer;
begin
  FillChar(r, SizeOf(r), #0);
  sum := 0;
  for i := 0 to SizeOf(r)-1 do
    sum := sum + PByte(@r)[i];
  if sum <> 0 then
    Halt(1);
  FillChar(r, SizeOf(r), $AB);
  sum := 0;
  for i := 0 to SizeOf(r)-1 do
    sum := sum + PByte(@r)[i];
  if sum <> SizeOf(r)*$AB then
    Halt(2);
  WriteLn('ok');
end.
