{$mode unleashed}
program tuple_array_element_type_01;

uses
  SysUtils;

{ tuple as element type of array / array-of-tuple }

type
  TPairArr = array of (Integer, Integer);
  TNamedArr = array of (a, b: Integer);
  TMixedArr = array of (Integer, String);

var
  ap: TPairArr;
  an: TNamedArr;
  am: TMixedArr;
begin
  SetLength(ap, 2);
  ap[0]._1 := 1; ap[0]._2 := 2;
  ap[1]._1 := 3; ap[1]._2 := 4;
  if (ap[0]._1 <> 1) or (ap[0]._2 <> 2) then Halt(1);
  if (ap[1]._1 <> 3) or (ap[1]._2 <> 4) then Halt(2);

  SetLength(an, 2);
  an[0].a := 10; an[0].b := 20;
  an[1].a := 30; an[1].b := 40;
  if (an[0].a <> 10) or (an[0].b <> 20) then Halt(3);
  if (an[1].a <> 30) or (an[1].b <> 40) then Halt(4);

  SetLength(am, 2);
  am[0]._1 := 100; am[0]._2 := 'foo';
  am[1]._1 := 200; am[1]._2 := 'bar';
  if (am[0]._1 <> 100) or (am[0]._2 <> 'foo') then Halt(5);
  if (am[1]._1 <> 200) or (am[1]._2 <> 'bar') then Halt(6);

  WriteLn('OK');
end.
