program composable_records_class_var_union_generic_01;
{ class var union in a generic record: each specialization gets its own
  static blob with correct overlay for the instantiated type }

{$mode unleashed}

type
  TBox<T> = record
    class var
      union raw : T; packed record first : Byte; end; end;
  end;
  TBoxD = TBox<DWord>;
  TBoxW = TBox<Word>;

begin
  TBoxD.raw := $AABBCCDD;
  TBoxW.raw := $1122;
  if TBoxD.first <> $DD then halt(1);
  if TBoxW.first <> $22 then halt(2);
  if TBoxD.raw <> $AABBCCDD then halt(3);
  TBoxW.first := $33;
  if TBoxW.raw <> $1133 then halt(4);
  if TBoxD.raw <> $AABBCCDD then halt(5);
end.
