program thread_static_section_inferred_10;
{$mode unleashed}

// section inferred form: `name := value` infers the type, single name
// per declaration. char-literal promotes to default string, sub-32-bit
// integer promotes to LongInt - same rules as inline var.
function Build: string;
threadstatic
  g := 'hi';
begin
  g := g + '!';
  Result := g;
end;

function Count: Integer;
threadstatic
  k := 0;
begin
  Inc(k);
  Result := k;
end;

begin
  if Build <> 'hi!' then halt(1);
  if Build <> 'hi!!' then halt(2);
  if Count <> 1 then halt(3);
  if Count <> 2 then halt(4);
end.
