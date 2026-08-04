{ %OPT=-O3 }
program procvar_devirt_correctness_01;
{$mode unleashed}

// a call through a procvar parameter holding a routine's address is
// rebound to a direct call when the wrapper is inlined; results must be
// identical to the plain indirect-call semantics in every shape below

type
  TFn = function(x: longint): longint;
  TAgg = function(const a: array of longint): longint;
  TObjFn = function(x: longint): longint of object;

  TAdder = class
    base: longint;
    function AddBase(x: longint): longint;
  end;

function TAdder.AddBase(x: longint): longint;
begin
  result := x + base;
end;

function Doubler(x: longint): longint;
begin
  result := x * 2;
end;

function Tripler(x: longint): longint;
begin
  result := x * 3;
end;

function Apply(f: TFn; x: longint): longint;
begin
  result := f(x);
end;

// parameter called twice: the spliced constant is duplicated per use
function ApplyTwice(f: TFn; x: longint): longint;
begin
  result := f(f(x));
end;

// parameter reassigned before the call: must call the new target
function ApplySwapped(f: TFn; x: longint): longint;
begin
  f := @Tripler;
  result := f(x);
end;

// address of the parameter taken: no splicing, still correct
function ApplyViaPtr(f: TFn; x: longint): longint;
var
  p: ^TFn;
begin
  p := @f;
  result := p^(x);
end;

// two levels of forwarding devirtualize level by level
function Forward1(f: TFn; x: longint): longint;
begin
  result := f(x);
end;

function Forward2(f: TFn; x: longint): longint;
begin
  result := Forward1(f, x);
end;

function SumArr(const a: array of longint): longint;
begin
  result := 0;
  for var i := 0 to high(a) do
    result := result + a[i];
end;

// procvar with an open array parameter (hidden high para in the chain)
function Aggregate(g: TAgg): longint;
begin
  result := g([1, 2, 3, 4]);
end;

// method procvar carries a self pointer: never devirtualized, stays correct
function ApplyObj(f: TObjFn; x: longint): longint;
begin
  result := f(x);
end;

var
  a: TAdder;
  p: TFn;
begin
  if Apply(@Doubler, 6) <> 12 then Halt(10);
  if ApplyTwice(@Doubler, 3) <> 12 then Halt(11);
  if ApplySwapped(@Doubler, 5) <> 15 then Halt(12);
  if ApplyViaPtr(@Doubler, 7) <> 14 then Halt(13);
  if Forward2(@Tripler, 4) <> 12 then Halt(14);
  if Aggregate(@SumArr) <> 10 then Halt(15);

  // a direct cast-and-call devirtualizes without any wrapper
  if TFn(@Doubler)(21) <> 42 then Halt(16);

  a := TAdder.Create;
  a.base := 100;
  if ApplyObj(@a.AddBase, 11) <> 111 then Halt(17);
  a.Free;

  // procvar held in a variable: no constant reaches the call site
  p := @Doubler;
  if p(5) <> 10 then Halt(18);
  p := @Tripler;
  if p(5) <> 15 then Halt(19);
end.
