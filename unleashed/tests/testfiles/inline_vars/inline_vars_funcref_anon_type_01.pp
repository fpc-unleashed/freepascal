program inline_vars_funcref_anon_type_01;
{$mode unleashed}

type
  TNamedRef = reference to procedure;

var
  counter: integer;

begin
  var s: TNamedRef := procedure begin counter := 1; end;
  var p: reference to procedure := s;
  p();
  if counter <> 1 then halt(1);
  var q: reference to function(x: integer): integer :=
    function(x: integer): integer begin result := x * 2; end;
  if q(21) <> 42 then halt(2);
end.
