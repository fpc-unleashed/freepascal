program anon_capture_local_01;

{$mode unleashed}

type
  TIntFn = reference to function: Integer;

function MakeCounter: TIntFn;
var
  n: Integer;
begin
  n := 0;
  Result := function: Integer
            begin
              Inc(n);
              Result := n;
            end;
end;

begin
  var c := MakeCounter;
  if c() <> 1 then halt(1);
  if c() <> 2 then halt(2);
  if c() <> 3 then halt(3);

  // independent counter
  var d := MakeCounter;
  if d() <> 1 then halt(4);
  if c() <> 4 then halt(5);   // c continues
end.
