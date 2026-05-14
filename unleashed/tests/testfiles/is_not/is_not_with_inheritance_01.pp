program is_not_with_inheritance_01;

{$mode unleashed}

type
  TAnimal = class end;
  TDog = class(TAnimal) end;
  TPoodle = class(TDog) end;
  TCat = class(TAnimal) end;

var
  a, p, c: TAnimal;

begin
  a := autofree TAnimal.Create;
  p := autofree TPoodle.Create;
  c := autofree TCat.Create;

  if p is not TAnimal then halt(1);
  if p is not TDog    then halt(2);
  if p is not TPoodle then halt(3);
  if c is not TAnimal then halt(4);
  if not (c is not TDog) then halt(5);
  if not (a is not TPoodle) then halt(6);
end.
