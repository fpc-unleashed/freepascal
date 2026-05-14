program tuple_field_compute_raises_caught_01;

{$mode unleashed}

uses SysUtils;

function Compute(s: String): (Integer, String);
begin
  Result := (StrToInt(s), 'parsed:' + s);
end;

begin
  var (n, label_) := Compute('42');
  if n <> 42                     then halt(1);
  if label_ <> 'parsed:42'       then halt(2);

  var caught := false;
  try
    Compute('xyz');
  except
    caught := true;
  end;
  if not caught then halt(3);
end.
