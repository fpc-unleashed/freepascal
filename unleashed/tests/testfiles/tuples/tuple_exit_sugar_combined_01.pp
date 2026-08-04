{$mode unleashed}
program tuple_exit_sugar_combined_01;

uses
  SysUtils;

{ Exit with tuple literal shorthand - no extra parentheses required }

function EarlyPositional(cond: Boolean): (Integer, Integer);
begin
  if cond then
    Exit(10, 20);
  Result := (100, 200);
end;

function EarlyNamed(cond: Boolean): (a, b: Integer);
begin
  if cond then
    Exit(a: 1, b: 2);
  Result := (a: 99, b: 88);
end;

function EarlyReorder(cond: Boolean): (a, b: Integer);
begin
  if cond then
    Exit(b: 77, a: 66);
  Result := (a: 1, b: 1);
end;

var
  cache: (Integer, Integer);

function ReturnSingle: (Integer, Integer);
begin
  Exit(cache);
end;

var
  p: (Integer, Integer);
  q: (a, b: Integer);
begin
  p := EarlyPositional(True);
  if (p._1 <> 10) or (p._2 <> 20) then Halt(1);

  p := EarlyPositional(False);
  if (p._1 <> 100) or (p._2 <> 200) then Halt(2);

  q := EarlyNamed(True);
  if (q.a <> 1) or (q.b <> 2) then Halt(3);

  q := EarlyNamed(False);
  if (q.a <> 99) or (q.b <> 88) then Halt(4);

  q := EarlyReorder(True);
  if (q.a <> 66) or (q.b <> 77) then Halt(5);

  cache := (777, 888);
  p := ReturnSingle;
  if (p._1 <> 777) or (p._2 <> 888) then Halt(6);

  WriteLn('OK');
end.
