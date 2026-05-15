program composable_records_rtti_total_field_count_01;
{ `embed TBase` is semantically `x, y` inlined, not a separate anonymous
  TBase subfield. RTTI must reflect the user-level view: TDerived with
  `embed TBase; z` reports 3 fields (x, y, z), not 2 (TBase-carrier, z).
  carriers `$compose$N` are an implementation detail and stay out of RTTI. }

{$mode unleashed}

uses TypInfo;

type
  TBase = record
    x, y: Integer;
  end;
  TDerived = record
    embed TBase;
    z: Integer;
  end;

var
  pinfo: PTypeInfo;
  td: PTypeData;
begin
  pinfo := TypeInfo(TDerived);
  if pinfo = nil then halt(1);
  if pinfo^.Kind <> tkRecord then halt(2);
  td := GetTypeData(pinfo);
  if td = nil then halt(3);
  if td^.RecSize <> 12 then halt(4);
  if td^.TotalFieldCount <> 3 then halt(5);
end.
