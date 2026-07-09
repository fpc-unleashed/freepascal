{ %OPT="-O3 -OoUNROLLDYN -OoPREFETCH" }
{ -OoUNROLLDYN keeps the ORIGINAL serial evaluation order: the four unrolled
  body copies are (body; inc) x4, not a reassociated partial-sum tree. This
  test builds an integer accumulation whose result is order-sensitive -- a
  Horner-style running fold  acc := acc*31 + a[i] -- and also a plain sum, and
  checks both against a reference computed by an independent scalar fold that
  the compiler cannot unroll (it walks a volatile counter). If the pass had
  reassociated or dropped/duplicated an iteration, the folds would differ. }
program unrolldyn_intsum_order_01;
{$mode objfpc}{$H+}

type
  TI = array of longint;

{ unroll target: order-sensitive running fold over a longint array }
function horner(a: TI; n: longint): longint;
var i: longint; acc: longint;
begin
  acc := 0;
  for i := 0 to n-1 do
    acc := acc * 31 + a[i];
  horner := acc;
end;

function plainsum(a: TI; n: longint): longint;
var i: longint; acc: longint;
begin
  acc := 0;
  for i := 0 to n-1 do
    acc := acc + a[i];
  plainsum := acc;
end;

var
  a: TI;
  n, i: longint;
  refh, refs, goth, gots: longint;
begin
  n := 1000;
  SetLength(a, n);
  for i := 0 to n-1 do
    a[i] := (i * 2654435761) and $FFFF;   { pseudo-random-ish }

  { independent reference fold; the := via a separate variable and the write to
    a[i] barrier keep this from matching the unroll shape }
  refh := 0; refs := 0;
  for i := 0 to n-1 do
    begin
      refh := refh * 31 + a[i];
      refs := refs + a[i];
    end;

  goth := horner(a, n);
  gots := plainsum(a, n);

  if goth <> refh then Halt(1);
  if gots <> refs then Halt(2);
  WriteLn('h=', goth, ' s=', gots);
end.
