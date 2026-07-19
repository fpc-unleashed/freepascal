{ %OPT="-Pi386 -gs" }
program tuple_return_stabs_i386_01;
{$mode unleashed}

// tuple result types have no type symbol; their mangled name must be built
// structurally and stay assembler-safe, otherwise stabs line info emitted
// by the internal assembler dies with IE 2007032202 on i386

type
  TBox = record
    s: String;
    v: Integer;
  end;

function makePair(const a, b: TBox): (q, r: TBox);
begin
  result.q := a;
  result.r := b;
end;

var
  x, y: TBox;
begin
  x.s := 'first';
  x.v := 1;
  y.s := 'second';
  y.v := 2;
  var (q1, r1) := makePair(x, y);
  if q1.s <> 'first' then halt(1);
  if q1.v <> 1 then halt(2);
  if r1.s <> 'second' then halt(3);
  if r1.v <> 2 then halt(4);
end.
