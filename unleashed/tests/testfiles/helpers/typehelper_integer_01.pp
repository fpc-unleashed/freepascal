program typehelper_integer_01;

{$mode unleashed}
{$modeswitch typehelpers}

type
  TIntHelper = type helper for Integer
    function Doubled: Integer;
  end;

function TIntHelper.Doubled: Integer;
begin
  Result := Self * 2;
end;

var
  n: Integer = 21;

begin
  if n.Doubled <> 42 then halt(1);
  // method call directly on a literal integer is rejected by the parser
  // (lexer treats `5.Doubled` as start of a real literal). Use a variable.
  var m: Integer := 5;
  if m.Doubled <> 10 then halt(2);
end.
