program raise_in_match_branch_01;

{$mode unleashed}

uses SysUtils;

procedure Dispatch(n: Integer);
begin
  match n of
    1: raise Exception.Create('one');
    2: raise EConvertError.Create('two');
    _: ;
  end;
end;

begin
  var hits := 0;
  for var i := 0 to 3 do
  begin
    try
      Dispatch(i);
    except
      on E: EConvertError do
        if E.Message = 'two' then Inc(hits, 100);
      on E: Exception do
        if E.Message = 'one' then Inc(hits, 1);
    end;
  end;
  // i=0: no raise, i=1: 'one' (1), i=2: 'two' (100), i=3: no raise
  if hits <> 101 then halt(1);
end.
