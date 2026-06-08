unit lightgenerics_cross_module_3way_b;
{$mode unleashed}
{$modeswitch lightgenerics}

interface

uses lightgenerics_cross_module_3way_a;

type
  TFoo = class end;
  TBoxFoo = TBox<TFoo>;

implementation

end.
