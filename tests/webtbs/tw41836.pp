{ %OPT=-O2 }

// taking the address of part of a parameter inside an inline routine, when
// the actual is a constant: the constant is spliced into the body, so s[1]
// used to fold to a one-character constant and the copy read that single
// byte plus adjacent stack garbage

program tw41836;

{$mode objfpc}

function CloneToHeap(s: shortstring): pchar; inline;
var
  p: pchar;
begin
  getmem(p, length(s)+1);
  move(s[1], p^, length(s));
  p[length(s)] := #0;
  result := p;
end;

function CloneToHeapConst(const s: shortstring): pchar; inline;
var
  p: pchar;
begin
  getmem(p, length(s)+1);
  move(s[1], p^, length(s));
  p[length(s)] := #0;
  result := p;
end;

function SumBytes(const a: array of byte): longint; inline;
var
  i: longint;
  buf: array[0..7] of byte;
begin
  fillchar(buf, sizeof(buf), 0);
  move(a[0], buf[0], length(a));
  result := 0;
  for i := 0 to length(a)-1 do
    inc(result, buf[i]);
end;

const
  bytes: array[0..3] of byte = (10, 20, 30, 40);

var
  q: pchar;
  s: shortstring;
begin
  { constant actual: the case that used to break }
  q := CloneToHeap('hello');
  if strpas(q) <> 'hello' then
    halt(1);
  freemem(q);

  q := CloneToHeapConst('hello');
  if strpas(q) <> 'hello' then
    halt(2);
  freemem(q);

  { a variable actual always worked, keep it covered }
  s := 'hello';
  q := CloneToHeap(s);
  if strpas(q) <> 'hello' then
    halt(3);
  freemem(q);

  { same shape over an array constant }
  if SumBytes(bytes) <> 100 then
    halt(4);

  { one byte only: correct even before the fix, guards against a fix that
    would break the trivial case }
  q := CloneToHeap('x');
  if strpas(q) <> 'x' then
    halt(5);
  freemem(q);
end.
