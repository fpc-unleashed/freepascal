{ %OPT="-Sew -vw" }
program labels_goto_subrange_missing_member_no_warning_01;

{$mode unleashed}

// goto name[variable] with a subrange index and a missing member: the
// hidden dispatch is deliberately incomplete (falls through), so it must
// not warn about incomplete case coverage (warnings are errors here)

type
  tidx = 0..3;

var
  resultV: integer = 0;

procedure run(i: tidx);
label
  op[0..3];  // op[2] stays undefined
begin
  goto op[i];
  resultV := -1;
  exit;

  op[0]: resultV := 1; exit;
  op[1]: resultV := 2; exit;
  op[3]: resultV := 4; exit;
end;

begin
  run(1);
  if resultV <> 2 then halt(1);
  run(2);
  if resultV <> -1 then halt(2);
end.
