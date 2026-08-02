{ %FAIL }
program composable_records_fail_class_var_union_anon_enum_01;
{ anonymous enum constants inside a class var union would need a scope
  move out of the union symtable - rejected }

{$mode unleashed}

type
  TFoo = record
    class var
      union kind : (kOne, kTwo); end;
  end;

begin
end.
