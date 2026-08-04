{ %OPT=-O2 }
program labels_addr_arg_of_inline_call_01;

{$mode unleashed}

// label addresses passed as arguments to an inline routine: inlining copies
// the argument trees, and the copied loads must keep referring to the labels
// defined in the caller (broken before: undefined asm labels at link time)

var
  deltas: array[0..3] of ptruint;
  hits: integer = 0;

function delta(const a, b: pointer): ptruint; inline;
var
  ua, ub: ptruint;
begin
  ua := ptruint(a);
  ub := ptruint(b);
  result := ub - ua;
end;

procedure run;
label
  op[0..3];
var
  i: integer;
  q: pointer;
begin
  for i := 0 to 3 do
    deltas[i] := delta(@op[0], @op[i]);
  for i := 0 to 3 do begin
    q := pointer(ptruint(@op[0]) + deltas[i]);
    goto q;
    op[0]: inc(hits, 1); continue;
    op[1]: inc(hits, 10); continue;
    op[2]: inc(hits, 100); continue;
    op[3]: inc(hits, 1000);
  end;
end;

begin
  run;
  if deltas[0] <> 0 then halt(1);
  if (deltas[1] = 0) or (deltas[2] <= deltas[1]) or (deltas[3] <= deltas[2]) then halt(2);
  if hits <> 1111 then halt(3);
end.
