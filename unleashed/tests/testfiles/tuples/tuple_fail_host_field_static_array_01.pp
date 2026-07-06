{ %FAIL }
program tuple_fail_host_field_static_array_01;
// Type "THost" is not completely defined: the host hides behind a static
// array inside the tuple field, still an infinite size recursion

{$mode unleashed}

type
  THost = record
    t: (p: array[2] of THost; e: Integer);
  end;

begin
end.
