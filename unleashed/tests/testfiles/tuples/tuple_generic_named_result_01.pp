{$mode unleashed}
program tuple_generic_named_result_01;

uses
  SysUtils;

{ generic type parameters in tuples }

function MakePair<A, B>(x: A; y: B): (A, B);
begin
  Result._1 := x;
  Result._2 := y;
end;

function MakeNamed<T>(val: T): (key: String; value: T);
begin
  Result.key := 'data';
  Result.value := val;
end;

var
  p: (Integer, String);
  n: (key: String; value: Integer);
begin
  p := MakePair<Integer, String>(42, 'hello');
  if (p._1 <> 42) or (p._2 <> 'hello') then Halt(1);

  n := MakeNamed<Integer>(100);
  if (n.key <> 'data') or (n.value <> 100) then Halt(2);

  WriteLn('OK');
end.
