{ standalone generic functions ride the same dedup path
  as methods. Echo<T> with T = class refs shares one body for
  every specialization }
program lightgenerics_standalone_fn_share_11;
{$mode unleashed}
{$modeswitch lightgenerics}

function Echo<T>(const v: T): T;
begin
  Result := v;
end;

type
  TFoo = class end;
  TBar = class end;

var
  f: TFoo;
  b: TBar;
  r1: TFoo;
  r2: TBar;
begin
  f := TFoo.Create;
  b := TBar.Create;
  r1 := Echo<TFoo>(f);
  r2 := Echo<TBar>(b);
  if r1 <> f then Halt(1);
  if r2 <> b then Halt(2);
  f.Free;
  b.Free;
end.
