program strinterp_as_in_writeln_01;

{$mode unleashed}

uses sysutils;

// passes the interp string through a function and verifies it round-trips
function identity(const s: string): string;
begin
  result := s;
end;

var
  name: string;
  out: string;
begin
  name := 'World';
  out := identity($'Hello {name}!');
  if out <> 'Hello World!' then halt(1);

  // interp string concatenated with regular string
  out := 'prefix:' + $'<{name}>';
  if out <> 'prefix:<World>' then halt(2);

  // mask-formatted in non-assignment context
  out := identity($'{42:%5d}');
  if out <> '   42' then halt(3);
end.
