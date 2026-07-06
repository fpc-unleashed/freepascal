{ %FAIL }
program tuple_fail_host_field_nested_01;
// Type "THost" is not completely defined: the host hides inside a nested
// tuple within the tuple field, still an infinite size recursion

{$mode unleashed}

type
  THost = record
    t: (x: (y: THost; z: Integer); w: Integer);
  end;

begin
end.
