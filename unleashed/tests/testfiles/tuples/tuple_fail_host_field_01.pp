{ %FAIL }
program tuple_fail_host_field_01;
// Type "THost" is not completely defined: a tuple record field embedding
// the host by value is an infinite size recursion

{$mode unleashed}

type
  THost = record
    t: (p: THost; e: Integer);
  end;

begin
end.
