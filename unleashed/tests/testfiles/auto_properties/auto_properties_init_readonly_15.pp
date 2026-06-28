program auto_properties_init_readonly_15;

{$mode unleashed}

// an initializer combines with a readonly directive: the field is seeded and
// the property exposes only the read side
type
  TThing = class
    property Tag: String = 'x'; readonly;
    function Peek: String;
  end;

function TThing.Peek: String;
begin
  Result := FTag;
end;

var
  t: TThing;
begin
  t := TThing.Create;
  if t.Tag <> 'x' then halt(1);
  if t.Peek <> 'x' then halt(2);
  t.Free;
end.
