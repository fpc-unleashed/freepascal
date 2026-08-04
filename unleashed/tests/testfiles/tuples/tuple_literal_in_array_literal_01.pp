{$mode unleashed}
program tuple_literal_in_array_literal_01;

uses
  SysUtils;

{ tuple literals inside array literals }

var
  ap: array of (Integer, Integer);
  am: array of (Integer, String);
  an: array of (a, b: Integer);
  i: Integer;
begin
  ap := [(1, 2), (3, 4), (5, 6)];
  if Length(ap) <> 3 then Halt(1);
  for i := 0 to 2 do
    if (ap[i]._1 <> i*2+1) or (ap[i]._2 <> (i+1)*2) then Halt(2);

  am := [(10, 'aa'), (20, 'bb'), (30, 'cc')];
  if Length(am) <> 3 then Halt(3);
  if (am[0]._1 <> 10) or (am[0]._2 <> 'aa') then Halt(4);
  if (am[1]._1 <> 20) or (am[1]._2 <> 'bb') then Halt(5);
  if (am[2]._1 <> 30) or (am[2]._2 <> 'cc') then Halt(6);

  an := [(100, 200), (300, 400)];
  if Length(an) <> 2 then Halt(7);
  if (an[0].a <> 100) or (an[0].b <> 200) then Halt(8);
  if (an[1].a <> 300) or (an[1].b <> 400) then Halt(9);

  WriteLn('OK');
end.
