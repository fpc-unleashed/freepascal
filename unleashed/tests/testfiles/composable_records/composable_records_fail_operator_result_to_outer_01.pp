{ %FAIL }
program composable_records_fail_operator_result_to_outer_01;
{ operator auto-flatten through embed returns the embed's type, not the
  outer record. `c := a + b` with c: TLabelled and operator + defined on
  the embedded TVec is a normal type mismatch (TVec assigned to
  TLabelled). use `c.TVec := a + b` for slice assignment instead.
  intentional, not a follow-up. }

{$mode unleashed}

type
  TVec = record
    x, y: Integer;
    class operator + (a, b: TVec): TVec;
  end;
  TLabelled = record
    embed TVec;
    tag: AnsiString;
  end;

class operator TVec.+ (a, b: TVec): TVec;
begin
  result.x := a.x + b.x;
  result.y := a.y + b.y;
end;

var
  a, b, c: TLabelled;
begin
  a.x := 1; a.y := 2;
  b.x := 3; b.y := 4;
  c := a + b;
end.
