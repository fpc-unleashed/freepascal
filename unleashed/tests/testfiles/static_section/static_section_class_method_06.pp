program static_section_class_method_06;
{$mode unleashed}

type
  TFoo = class
    procedure Tick;
  end;

procedure TFoo.Tick;
static
  cnt: Integer = 0;
begin
  Inc(cnt);
  if cnt > 3 then halt(1);
end;

var
  f: TFoo;
begin
  f := TFoo.Create;
  try
    f.Tick;
    f.Tick;
    f.Tick;
  finally
    f.Free;
  end;
end.
