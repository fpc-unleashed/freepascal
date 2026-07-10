{ %OPT=-O2 }
program autofree_regvar_managed_finalize_01;

{$mode unleashed}

// at -O2 the autofree holder is promoted to a register variable; a managed
// var in the same routine adds an outer finalize frame around the desugared
// try..finally. the regvar setup used to leak stale reference data into the
// hi register slot and abort with an internal error. must compile and free
// the object exactly once.

type
  TFoo = class
    destructor Destroy; override;
  end;

var
  s: ansistring;
  freed: integer;

destructor TFoo.Destroy;
begin
  Inc(freed);
  inherited Destroy;
end;

begin
  freed := 0;
  begin
    var f := autofree TFoo.Create;
    if f = nil then halt(2);
  end;
  if freed <> 1 then halt(1);
end.
