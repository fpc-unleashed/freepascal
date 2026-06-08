unit lightgenerics_cross_module_3way_c;
{$mode unleashed}
{$modeswitch lightgenerics}

interface

uses lightgenerics_cross_module_3way_a;

type
  TBar = class end;
  TBoxBar = TBox<TBar>;

implementation

end.
