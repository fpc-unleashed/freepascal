{ %FAIL }
{ a local var may shadow a regular class member in unleashed mode (duplicate
  names allowed), but never the generic type parameter - `t` and `T` are the
  same identifier, so this must report "Duplicate identifier" not silently
  shadow the type the var itself uses }
program implicit_generics_fail_local_shadows_type_param_01;

{$mode unleashed}

type
  TBox<T> = class
    FA, FB: T;
    procedure Swap;
  end;

procedure TBox<T>.Swap;
var
  t: T;
begin
  t := FA;
  FA := FB;
  FB := t;
end;

begin
end.
