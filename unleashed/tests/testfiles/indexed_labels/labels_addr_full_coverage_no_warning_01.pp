{ %OPT="-Sew -vw" }
program labels_addr_full_coverage_no_warning_01;

{$mode unleashed}

// @name[index] over a family covering the whole index type: the hidden
// dispatch carries a nil fallback by construction and must not warn about
// unreachable code (warnings are promoted to errors here)

type
  tidx = 0..3;

var
  resultV: integer = 0;

procedure run(i: tidx);
var
  q: pointer;
label
  op[0..3];
begin
  q := @op[i];
  goto q;

  op[0]: resultV := 1; exit;
  op[1]: resultV := 2; exit;
  op[2]: resultV := 3; exit;
  op[3]: resultV := 4; exit;
end;

begin
  run(2);
  if resultV <> 3 then halt(1);
  run(0);
  if resultV <> 1 then halt(2);
end.
