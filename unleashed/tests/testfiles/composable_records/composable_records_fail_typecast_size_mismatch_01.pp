{ %FAIL }
program composable_records_fail_typecast_size_mismatch_01;
{ size-mismatched record typecast is rejected, matching stock FPC.
  `TOuter` has an embed plus extra fields, so sizeof differs from TInner;
  the cast is the same illegal conversion stock Pascal rejects between any
  two same-named-but-different-size records. intentional, not a follow-up. }

{$mode unleashed}

type
  TInner = record
    x, y: Integer;
  end;
  TOuter = record
    embed TInner;
    z: Integer;
  end;

procedure use_inner(const i: TInner);
begin
  if i.x <> 0 then halt(1);
end;

var
  o: TOuter;
begin
  o.x := 0; o.y := 0; o.z := 0;
  use_inner(TInner(o));
end.
