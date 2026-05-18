program inline_vars_inferred_array_string_widestring_01;
{$mode unleashed}
uses TypInfo;

// first element is a WideString var -> array of WideString

var w: WideString;
begin
  w := 'wide';
  var a := [w, 'two', 'three'];
  if Length(a) <> 3 then halt(1);
  if a[0] <> 'wide' then halt(2);
  if a[1] <> 'two' then halt(3);
  if GetTypeData(TypeInfo(a))^.elType^.Name <> 'WideString' then halt(4);
end.
