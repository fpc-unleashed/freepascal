program strinterp_long_text_01;

{$mode unleashed}

var
  user, action, item: string;
  count: integer;
  s: string;
begin
  user := 'alice';
  action := 'bought';
  item := 'widget';
  count := 3;
  s := $'User {user} {action} {count} {item}(s) today.';
  if s <> 'User alice bought 3 widget(s) today.' then halt(1);

  // back-to-back placeholders (no separator)
  s := $'{user}{action}{item}';
  if s <> 'aliceboughtwidget' then halt(2);
end.
