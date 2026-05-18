program inline_vars_inferred_array_string_ansi_01;
{$mode unleashed}
uses TypInfo;

// string literals (no explicit string-type var first) -> array of AnsiString

begin
  var a := ['alpha', 'beta', 'gamma'];
  if Length(a) <> 3 then halt(1);
  if a[0] <> 'alpha' then halt(2);
  if a[1] <> 'beta' then halt(3);
  if a[2] <> 'gamma' then halt(4);
  if PTypeInfo(TypeInfo(a))^.Kind <> tkDynArray then halt(5);
  if GetTypeData(TypeInfo(a))^.elType^.Name <> 'AnsiString' then halt(6);
end.
