program prepostincdec_property_06;
{$mode unleashed}
type
  tcounter = class
  private
    fval, fgets, fsets: Integer;
    function getval: Integer;
    procedure setval(v: Integer);
  public
    property val: Integer read getval write setval;
  end;

function tcounter.getval: Integer;
begin
  inc(fgets);
  result := fval;
end;

procedure tcounter.setval(v: Integer);
begin
  inc(fsets);
  fval := v;
end;

var
  c: tcounter;
begin
  c := tcounter.Create;
  c.fval := 50;
  // getter and setter run exactly once each
  if PostInc(c.val) <> 50 then halt(1);
  if c.fval <> 51 then halt(2);
  if (c.fgets <> 1) or (c.fsets <> 1) then halt(3);
  if PreInc(c.val, 9) <> 60 then halt(4);
  if c.fval <> 60 then halt(5);
  if (c.fgets <> 2) or (c.fsets <> 2) then halt(6);
  if PostDec(c.val, 10) <> 60 then halt(7);
  if PreDec(c.val) <> 49 then halt(8);
  if c.fval <> 49 then halt(9);
  c.Free;
end.
