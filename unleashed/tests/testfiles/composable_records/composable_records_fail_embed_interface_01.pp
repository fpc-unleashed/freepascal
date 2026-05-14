{ %FAIL }
program composable_records_fail_embed_interface_01;

{$mode unleashed}

type
  IFoo = interface
    ['{12345678-1234-1234-1234-123456789012}']
    procedure Bar;
  end;
  TRec = record
    embed IFoo;       { interface - pointer-based, no field layout }
  end;
begin
end.
