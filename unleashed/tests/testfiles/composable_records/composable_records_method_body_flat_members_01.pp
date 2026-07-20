program composable_records_method_body_flat_members_01;

{ bare access to an embedded type's field, method, function and
  property from inside the outer record's method body, including
  a nested routine }

{$mode unleashed}

type
  TInner = record
    x: LongInt;
    procedure Bump;
    function Doubled: LongInt;
    property PX: LongInt read x write x;
  end;

  TOuter = record
    embed TInner;
    y: LongInt;
    procedure Run;
    function SumNested: LongInt;
  end;

procedure TInner.Bump; begin Inc(x); end;
function TInner.Doubled: LongInt; begin Result := x * 2; end;

procedure TOuter.Run;
begin
  x := 5;
  Bump;
  PX := PX + 1;
  y := Doubled;
end;

function TOuter.SumNested: LongInt;

  function inner_sum: LongInt;
  begin
    Result := x + y;
  end;

begin
  Result := inner_sum;
end;

var
  o: TOuter;
begin
  o.Run;
  if o.x <> 7 then halt(1);
  if o.y <> 14 then halt(2);
  if o.SumNested <> 21 then halt(3);
end.
