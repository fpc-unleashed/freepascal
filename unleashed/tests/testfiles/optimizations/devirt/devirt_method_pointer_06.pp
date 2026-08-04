{ %OPT=-O2 }
program devirt_method_pointer_06;
{$mode unleashed}

// a method pointer carries a Self value along with the code address, so it
// is left alone; verify the right instance data is used

type
  TMeth = function(x: longint): longint of object;

  TScaler = class
    factor: longint;
    function Scale(x: longint): longint;
  end;

function TScaler.Scale(x: longint): longint;
begin
  result := x * factor;
end;

function Apply(m: TMeth; x: longint): longint; inline;
begin
  result := m(x);
end;

begin
  var a := TScaler.Create;
  var b := TScaler.Create;
  a.factor := 2;
  b.factor := 5;
  if Apply(@a.Scale, 10) <> 20 then halt(1);
  if Apply(@b.Scale, 10) <> 50 then halt(2);
  a.Free;
  b.Free;
  writeln('ok');
end.
