{ %FAIL }

// `is not T` is only available in mode unleashed
// in other modes it parses as `obj is (not T)` which is invalid

program tb0300;

{$mode objfpc}

type
  tbase = class
  end;

  tfoo = class(tbase)
  end;

var
  obj : tbase;
begin
  obj := tfoo.create;
  if obj is not tfoo then
    obj.free;
end.
