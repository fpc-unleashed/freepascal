program strinterp_types_array_01;

{$mode unleashed}

var
  a: array[0..2] of integer;
  s: string;
begin
  a[0] := 1; a[1] := 2; a[2] := 3;
  s := $'arr={a}';
  if s <> 'arr=[1, 2, 3]' then halt(1);

  // array literal
  s := $'lit={[10, 20, 30]}';
  if s <> 'lit=[10, 20, 30]' then halt(2);

  // single-element static array
  s := $'one={[42]}';
  if s <> 'one=[42]' then halt(3);
end.
