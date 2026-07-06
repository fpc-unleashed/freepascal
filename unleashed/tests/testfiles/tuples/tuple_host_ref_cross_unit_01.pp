program tuple_host_ref_cross_unit_01;

{$mode unleashed}

// declaring a record after using a unit whose method implementation headers
// parse host-referencing tuples must not touch state left over from that
// unit's compilation (used to crash the compiler with an access violation)

uses
  tuple_host_ref_unit_01;

type
  TEmpty = record end;

var
  a: TCrossA;
  b: TCrossB;
  e: TEmpty;

begin
  a.x := 5;
  var qa := a.divMod;
  if qa.q.x <> 5 then halt(1);
  if qa.r.x <> 5 then halt(2);
  b.x := 9;
  b.y := true;
  var qb := b.divMod;
  if qb.s.x <> 9 then halt(3);
  if not qb.t.y then halt(4);
  e := Default(TEmpty);
end.
