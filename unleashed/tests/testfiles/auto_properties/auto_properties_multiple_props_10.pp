program auto_properties_multiple_props_10;

{$mode unleashed}

// several auto-properties in one type each get their own distinct backing field
type
  TVec = class
    property A: Integer;
    property B: Integer;
    property C: Integer;
    function Sum: Integer;
  end;

function TVec.Sum: Integer;
begin
  Result := FA + FB + FC;
end;

var
  v: TVec;
begin
  v := TVec.Create;
  v.A := 1;
  v.B := 2;
  v.C := 3;
  if v.Sum <> 6 then halt(1);
  v.B := 20;
  if v.Sum <> 24 then halt(2);
  if (v.A <> 1) or (v.C <> 3) then halt(3);
  v.Free;
end.
