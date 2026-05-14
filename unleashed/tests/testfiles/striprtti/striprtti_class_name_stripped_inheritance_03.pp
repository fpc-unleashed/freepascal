{ %CHECKBIN_LACKS=TStripAnimal03,TStripCat03,TStripDog03 }
program striprtti_class_name_stripped_inheritance_03;
{$mode unleashed}
{$modeswitch striprtti}

// striprtti -> the type-name strings of the abstract base AND its descendants
// are stripped, but virtual dispatch and `is` still work because the VMT
// itself stays intact
type
  TStripAnimal03 = class
    function Sound: String; virtual; abstract;
  end;

  TStripCat03 = class(TStripAnimal03)
    function Sound: String; override;
  end;

  TStripDog03 = class(TStripAnimal03)
    function Sound: String; override;
  end;

function TStripCat03.Sound: String;
begin
  Result := 'meow';
end;

function TStripDog03.Sound: String;
begin
  Result := 'woof';
end;

var
  pets: array[0..1] of TStripAnimal03;
  i: Integer;
begin
  pets[0] := TStripCat03.Create;
  pets[1] := TStripDog03.Create;
  try
    if pets[0].Sound <> 'meow' then Halt(1);
    if pets[1].Sound <> 'woof' then Halt(2);
    if not (pets[0] is TStripCat03) then Halt(3);
    if not (pets[1] is TStripDog03) then Halt(4);
  finally
    for i := 0 to High(pets) do
      pets[i].Free;
  end;
end.
