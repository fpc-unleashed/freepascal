program inline_vars_inferred_array_string_unicode_01;
{$mode unleashed}
uses TypInfo;

// first element is a UnicodeString var -> array of UnicodeString;
// AnsiString literals after it convert into the unicode element type

var u: UnicodeString;
begin
  u := 'first';
  var a := [u, 'second', 'third'];
  if Length(a) <> 3 then halt(1);
  if a[0] <> 'first' then halt(2);
  if a[1] <> 'second' then halt(3);
  if a[2] <> 'third' then halt(4);
  if GetTypeData(TypeInfo(a))^.elType^.Name <> 'UnicodeString' then halt(5);
end.
