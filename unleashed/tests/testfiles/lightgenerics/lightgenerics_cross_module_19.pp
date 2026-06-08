{ a unit defines a generic class and one
  specialization; the main program uses another specialization
  of the same generic. canonical mangles include each module's
  own name so cross-module specializations link cleanly even
  though they do not literally share a body across units }
program lightgenerics_cross_module_19;
{$mode unleashed}
{$modeswitch lightgenerics}

uses lightgenerics_cross_module_a;

type
  TBar = class end;
  TBoxBar = TBox<TBar>;

var
  bf: TBoxFoo;
  bb: TBoxBar;
  f: TFoo;
  b: TBar;
begin
  f := TFoo.Create;
  b := TBar.Create;
  bf := TBoxFoo.Create;
  bb := TBoxBar.Create;
  bf.SetValue(f);
  bb.SetValue(b);
  if bf.GetValue <> f then Halt(1);
  if bb.GetValue <> b then Halt(2);
  bf.Free;
  bb.Free;
  f.Free;
  b.Free;
end.
