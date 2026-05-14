program record_helper_with_assignment_01;

{$mode unleashed}

type
  TVec = record
    x, y: Integer;
  end;

  TVecHelper = record helper for TVec
    procedure Scale(factor: Integer);
    function Sum: Integer;
  end;

procedure TVecHelper.Scale(factor: Integer);
begin
  Self.x := Self.x * factor;
  Self.y := Self.y * factor;
end;

function TVecHelper.Sum: Integer;
begin
  Result := Self.x + Self.y;
end;

var
  v: TVec;

begin
  v.x := 3;
  v.y := 4;
  v.Scale(10);
  if v.x <> 30 then halt(1);
  if v.y <> 40 then halt(2);
  if v.Sum <> 70 then halt(3);
end.
