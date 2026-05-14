program sanity_pass_complex_01;

{$mode unleashed}

uses Classes, SysUtils;

// integration sanity: combine inline-var, autofree, defer, statement-expr,
// for-loop counter, compound-assign, and statement-expr in one routine.
function Build(n: Integer): String;
begin
  var list := autofree TStringList.Create;
  defer list.Sorted := true;
  for var i := 1 to n do
    list.Add('item-' + IntToStr(i));
  list.Add(if n mod 2 = 0 then 'even' else 'odd');
  Result := IntToStr(list.Count);
end;

begin
  if Build(1) <> '2' then halt(1);
  if Build(4) <> '5' then halt(2);
  if Build(0) <> '1' then halt(3);
end.
