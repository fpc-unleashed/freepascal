program funcref_in_array_01;

{$mode unleashed}

type
  TIntFn = reference to function(x: Integer): Integer;

function Add1(x: Integer): Integer;  begin Result := x + 1; end;
function Mul2(x: Integer): Integer;  begin Result := x * 2; end;
function Neg(x: Integer):  Integer;  begin Result := -x;    end;

begin
  var ops: array of TIntFn := [@Add1, @Mul2, @Neg];
  if ops[0](10) <> 11   then halt(1);
  if ops[1](10) <> 20   then halt(2);
  if ops[2](10) <> -10  then halt(3);
end.
