program multihelpers_two_for_int_01;

{$mode unleashed}
{$modeswitch typehelpers}
{$modeswitch multihelpers}

type
  TIntDoubler = type helper for Integer
    function Doubled: Integer;
  end;

  TIntTripler = type helper(TIntDoubler) for Integer
    function Tripled: Integer;
  end;

function TIntDoubler.Doubled: Integer;
begin
  Result := Self * 2;
end;

function TIntTripler.Tripled: Integer;
begin
  Result := Self * 3;
end;

var
  n: Integer = 5;

begin
  // both helpers visible at the same time when multihelpers is on
  if n.Doubled <> 10 then halt(1);
  if n.Tripled <> 15 then halt(2);
end.
