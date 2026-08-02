program composable_records_class_var_union_01;
{ union in a `class var` section: variants overlay one static storage
  blob and contribute nothing to the instance layout }

{$mode unleashed}

type
  TFoo = record
    class procedure Poke; static;
    class var
      union raw : DWord; small : Word; end;
  end;

class procedure TFoo.Poke;
begin
  raw := $11223344;
end;

begin
  if SizeOf(TFoo) <> 0 then halt(1);
  TFoo.Poke;
  if TFoo.raw <> $11223344 then halt(2);
  if TFoo.small <> $3344 then halt(3);
  TFoo.small := $AABB;
  if TFoo.raw <> $1122AABB then halt(4);
end.
