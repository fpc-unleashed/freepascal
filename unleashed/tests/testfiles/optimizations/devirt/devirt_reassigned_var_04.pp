{ %OPT=-O2 }
program devirt_reassigned_var_04;
{$mode unleashed}

// a procvar reassigned between two calls must not be resolved to a single
// target; each call has to reach the routine stored at that point

type
  TFn = function(x: longint): longint;

function Double(x: longint): longint; inline;
begin
  result := x * 2;
end;

function Square(x: longint): longint; inline;
begin
  result := x * x;
end;

function Apply(f: TFn; x: longint): longint; inline;
begin
  result := f(x);
end;

procedure check;
var
  f: TFn;
begin
  f := @Double;
  if Apply(f, 6) <> 12 then halt(1);
  if f(9) <> 18 then halt(2);
  f := @Square;
  if Apply(f, 6) <> 36 then halt(3);
  if f(9) <> 81 then halt(4);
end;

procedure Retarget(var g: TFn);
begin
  g := @Square;
end;

procedure check_var_param;
var
  f: TFn;
begin
  // a single visible store, but the var parameter can change the value:
  // the call must not be resolved to Double
  f := @Double;
  Retarget(f);
  if Apply(f, 4) <> 16 then halt(5);
  if f(7) <> 49 then halt(6);
end;

begin
  check;
  check_var_param;
  writeln('ok');
end.
