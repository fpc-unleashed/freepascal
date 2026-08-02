{ %OPT=-O3 }
program autoinline_wrappers_02;
{$mode unleashed}

// bodies holding a single call qualify for automatic inlining: wrappers,
// default-argument overloads and raising guard helpers; results must match
// the non-inlined semantics, including side effects and recursion

uses SysUtils;

function Core(a, b: Integer): Integer;
begin
  result := a * 37 + b;
  if result > 1000000 then result := result mod 1000003;
end;

function Wrap(a: Integer): Integer;
begin
  result := Core(a, 11);
end;

function Chain(a: Integer): Integer;
begin
  result := Wrap(a) + 1;
end;

procedure Guard(p: Pointer);
begin
  if p = nil then raise Exception.Create('nil argument');
end;

function Recur(n: Integer): Integer;
begin
  if n < 2 then result := n else result := Recur(n - 1) + Recur(n - 2);
end;

var sideeffects: Integer = 0;

function Bump(x: Integer): Integer;
begin
  Inc(sideeffects);
  result := x + 1;
end;

function CallsBump(x: Integer): Integer;
begin
  result := Bump(x) * 2;
end;

// forwarding an own by-ref formal into another call is excluded from
// automatic inlining (splicing a literal actual would misbind it); the
// routine must still compute correctly as a plain call
function HeadByte(const s: shortstring): Byte;
var b: Byte;
begin
  Move(s[1], b, 1);
  result := b;
end;

begin
  if Wrap(100) <> 3711 then Halt(10);
  var acc := 0;
  for var i := 1 to 1000 do acc := (acc + Chain(i)) mod 1000003;
  if acc <> 530446 then Halt(11);

  Guard(@acc);
  var caught := false;
  try
    Guard(nil);
  except
    on E: Exception do caught := true;
  end;
  if not caught then Halt(20);

  if Recur(20) <> 6765 then Halt(30);

  sideeffects := 0;
  if CallsBump(5) <> 12 then Halt(40);
  if CallsBump(5) <> 12 then Halt(41);
  if sideeffects <> 2 then Halt(42);

  if HeadByte('xyz') <> Ord('x') then Halt(50);
end.
