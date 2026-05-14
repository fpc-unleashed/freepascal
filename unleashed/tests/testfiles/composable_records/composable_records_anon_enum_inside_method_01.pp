program composable_records_anon_enum_inside_method_01;

{$mode unleashed}

type
  TFoo = record
    kind: (kA, kB, kC);
    procedure SetB;
    function IsA: Boolean;
  end;

procedure TFoo.SetB;
begin
  { inside a method the enumerators are reachable by bare name }
  kind := kB;
end;

function TFoo.IsA: Boolean;
begin
  Result := kind = kA;
end;

var
  f: TFoo;
begin
  f.kind := TFoo.kA;
  if not f.IsA then halt(1);
  f.SetB;
  if f.IsA then halt(2);
  if Ord(f.kind) <> 1 then halt(3);
end.
