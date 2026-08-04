{ %FAIL }
program labels_fail_addr_bare_01;
// bare @ on an indexed label family: an index is required

{$mode unleashed}
{$goto on}

procedure p;
label
  t[0..1];
var
  q: pointer;
begin
  q := @t;
  goto q;

  t[0]: exit;
  t[1]: exit;
end;

begin
  p;
end.
