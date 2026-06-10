program strinterp_types_classref_01;

{$mode unleashed}

type
  TFoo = class(TObject) end;
  TBar = class(TFoo) end;

var
  cls: TClass;
  s: string;
begin
  cls := TFoo;
  s := $'cls={cls}';
  if s <> 'cls=TFoo' then halt(1);

  cls := TBar;
  s := $'{cls}';
  if s <> 'TBar' then halt(2);
end.
