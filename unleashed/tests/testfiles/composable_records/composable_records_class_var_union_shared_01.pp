program composable_records_class_var_union_shared_01;
{ class var union storage is shared: writes through one instance are
  visible through another instance and through the type name }

{$mode unleashed}

type
  TFoo = record
    class var
      union raw : DWord; packed record lo, mid, hi : Byte; end; end;
  end;

var
  a, b : TFoo;

begin
  a.raw := $00445566;
  if b.lo <> $66 then halt(1);
  if TFoo.mid <> $55 then halt(2);
  b.hi := $77;
  if a.raw <> $00775566 then halt(3);
end.
