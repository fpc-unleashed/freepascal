{ %CHECKBIN_HAS=TKeepAnimal03,TKeepCat03,TKeepDog03 }
program striprtti_class_name_kept_inheritance_03;
{$mode unleashed}

// no striprtti -> RTTI keeps every class in an inheritance chain, including
// the abstract base; virtual dispatch must still produce the right output
type
  TKeepAnimal03 = class
    function Sound: String; virtual; abstract;
  end;

  TKeepCat03 = class(TKeepAnimal03)
    function Sound: String; override;
  end;

  TKeepDog03 = class(TKeepAnimal03)
    function Sound: String; override;
  end;

function TKeepCat03.Sound: String;
begin
  Result := 'meow';
end;

function TKeepDog03.Sound: String;
begin
  Result := 'woof';
end;

var
  pets: array[0..1] of TKeepAnimal03;
  i: Integer;
begin
  pets[0] := TKeepCat03.Create;
  pets[1] := TKeepDog03.Create;
  try
    if pets[0].Sound <> 'meow' then Halt(1);
    if pets[1].Sound <> 'woof' then Halt(2);
    if not (pets[0] is TKeepCat03) then Halt(3);
    if not (pets[1] is TKeepDog03) then Halt(4);
  finally
    for i := 0 to High(pets) do
      pets[i].Free;
  end;
end.
