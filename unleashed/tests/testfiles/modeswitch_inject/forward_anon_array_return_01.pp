program forward_anon_array_return_01;
{$mode unleashed}

// before this fix the impl re-declared `array of string` inline, creating
// a fresh anon tdef instance. the forward<->impl signature compare took
// pointer equality on the hidden funcret paravarsym, decided te_equal
// (not te_exact), and rejected the impl as a mismatched header. now the
// equal_signature helper recognises both sides as anonymous, repoints
// the impl's returndef + funcret paravarsym at the forward's def, and
// the match succeeds.

procedure callit; forward;

function test: array of string;
var
  res: array of string;
begin
  SetLength(res, 3);
  res[0] := 'one';
  res[1] := 'two';
  res[2] := 'three';
  test := res;
end;

procedure callit;
var arr: array of string;
begin
  arr := test;
  if Length(arr) <> 3 then Halt(1);
  if arr[0] <> 'one' then Halt(2);
  if arr[2] <> 'three' then Halt(3);
end;

begin
  callit;
end.
