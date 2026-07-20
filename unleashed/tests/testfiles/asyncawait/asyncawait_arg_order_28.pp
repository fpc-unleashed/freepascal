{ the snapshotted arguments reach the worker in their original order }
program asyncawait_arg_order_28;
{$mode unleashed}
uses SysUtils;
var trace: string;
function sub4(a, b, c, d: Integer): Integer;
begin
  result := ((a*10 + b)*10 + c)*10 + d;
end;
procedure tag(const x, y, z: string);
begin
  trace := x + y + z;
end;
procedure mixed(s: string; n: Integer; c: Char);
begin
  trace := s + IntToStr(n) + c;
end;
type
  TAcc = class
    base: Integer;
    function span(a, b, c: Integer): Integer;
  end;
  TSpanFn = function(a, b, c: Integer): Integer of object;
function TAcc.span(a, b, c: Integer): Integer;
begin
  result := ((base*10 + a)*10 + b)*10 + c;
end;
var
  obj: TAcc;
  pv: TSpanFn;
begin
  var f := async sub4(1, 2, 3, 4);
  if await f <> 1234 then halt(1);

  { same-typed arguments swap silently, so check the order through a trace }
  await async tag('a', 'b', 'c');
  if trace <> 'abc' then halt(2);

  await async mixed('x', 7, 'z');
  if trace <> 'x7z' then halt(3);

  obj := TAcc.Create;
  obj.base := 9;
  { a method call carries self next to the arguments }
  var m := async obj.span(1, 2, 3);
  if await m <> 9123 then halt(4);

  pv := @obj.span;
  var p := async pv(1, 2, 3);
  if await p <> 9123 then halt(5);

  obj.Free;
end.
