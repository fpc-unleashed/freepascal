program composable_records_class_var_union_nested_record_01;
{ inline packed record variant inside a `class var` union: the nested
  fields flatten into the record scope as static members aliasing the
  shared blob }

{$mode unleashed}

type
  TFoo = record
    class procedure Poke; static;
    class var
      union raw : DWord; packed record lo, mid, hi : Byte; end; end;
  end;

class procedure TFoo.Poke;
begin
  raw := $543210;
  if lo <> $10 then halt(1);
  if mid <> $32 then halt(2);
  if hi <> $54 then halt(3);
  lo := $AA;
end;

begin
  if SizeOf(TFoo) <> 0 then halt(4);
  TFoo.Poke;
  if TFoo.raw <> $5432AA then halt(5);
  TFoo.mid := $BB;
  if TFoo.raw <> $54BBAA then halt(6);
end.
