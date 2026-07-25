{ %OPT=-O3 }

// a read-modify-write of a variable captured by an anonymous function must
// keep its store: the capturer conversion used to drop nf_write/nf_modify
// from the converted load, so cse treated the assignment target as a plain
// read and redirected the write into a temp

program tw41828;

{$mode objfpc}{$H+}
{$modeswitch functionreferences}
{$modeswitch anonymousfunctions}

type
  tgetter = reference to function: longint;

// read-modify-write inside the closure body
function f1: tgetter;
var
  n: longint;
begin
  n := 5;
  result := function: longint begin n := n + 1; result := n; end;
end;

// nested routine writes a var that is also captured by a closure
function f2: tgetter;
var
  n: longint;

  procedure bump;
  begin
    n := n + 1;
  end;

begin
  n := 5;
  bump;
  result := function: longint begin result := n; end;
end;

// outer body writes the captured var after creating the closure
function f3: tgetter;
var
  n: longint;
begin
  n := 5;
  result := function: longint begin result := n; end;
  n := n + 1;
end;

var
  g: tgetter;
begin
  g := f1;
  if g() <> 6 then halt(1);
  if g() <> 7 then halt(2);
  g := f2;
  if g() <> 6 then halt(3);
  if g() <> 6 then halt(4);
  g := f3;
  if g() <> 6 then halt(5);
  writeln('ok');
end.
