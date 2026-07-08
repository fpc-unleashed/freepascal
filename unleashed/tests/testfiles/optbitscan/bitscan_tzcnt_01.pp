{ %OPT="-O4" }
{ Count-trailing-zeros bit-scan idiom (-OoBITIDIOM extension). The guarded
  clear-trailing-zeros loop

      if x <> 0 then while (x and 1) = 0 do begin inc(c); x := x shr 1 end;

  is lowered to a Bsf/Tzcnt-based intrinsic at -O4. This checks the rewrite is
  value-identical to the scalar loop for every single-bit value, dense/composite
  values, High/Low and the guarded x=0 no-op, for 32- and 64-bit unsigned x.
  The result is correct whether or not the pass fires. }
program bitscan_tzcnt_01;
{$mode objfpc}

{ optimized shape: dominating  if x<>0  proves the loop is finite }
function tz32(x: dword): longint;
var c: longint;
begin
  c := 0;
  if x <> 0 then
    while (x and 1) = 0 do begin inc(c); x := x shr 1 end;
  tz32 := c;
end;

function tz64(x: qword): longint;
var c: longint;
begin
  c := 0;
  if x <> 0 then
    while (x and 1) = 0 do begin inc(c); x := x shr 1 end;
  tz64 := c;
end;

{ reference: independent trailing-zero count, no shr loop shape }
function ref32(x: dword): longint;
var i: longint;
begin
  if x = 0 then exit(0);
  i := 0;
  while ((x shr i) and 1) = 0 do inc(i);
  ref32 := i;
end;

function ref64(x: qword): longint;
var i: longint;
begin
  if x = 0 then exit(0);
  i := 0;
  while ((x shr i) and 1) = 0 do inc(i);
  ref64 := i;
end;

var
  i: longint;
  x: qword;
begin
  { guarded x=0 -> no-op, c stays 0 }
  if tz32(0) <> 0 then Halt(1);
  if tz64(0) <> 0 then Halt(2);

  { every single-bit value }
  for i := 0 to 31 do
    if tz32(dword(1) shl i) <> i then Halt(10 + i);
  for i := 0 to 63 do
    if tz64(qword(1) shl i) <> i then Halt(100 + i);

  { High/Low and all-ones }
  if tz32(High(dword)) <> 0 then Halt(3);
  if tz64(High(qword)) <> 0 then Halt(4);
  if tz32($80000000) <> 31 then Halt(5);
  if tz64(qword($8000000000000000)) <> 63 then Halt(6);

  { dense/composite sweep against the reference }
  for i := 1 to 200000 do
    begin
      x := qword(i) * qword(2654435761) + qword(i shl 7);
      if x <> 0 then
        begin
          if tz64(x) <> ref64(x) then Halt(7);
          if tz32(dword(x)) <> ref32(dword(x)) then
            if dword(x) <> 0 then Halt(8);
        end;
    end;
end.
