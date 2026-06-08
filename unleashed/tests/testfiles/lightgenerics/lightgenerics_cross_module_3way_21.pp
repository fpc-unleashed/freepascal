{ three units cooperate. unit a holds the template,
  unit b specializes `TBox<TFoo>`, unit c specializes `TBox<TBar>` -
  neither b nor c imports the other. without this support the linker
  multiply-defined the canonical when both b and c ended up in the
  final binary; with cross-module dedup the second-loaded unit sees
  the first one's canonical via the global `loaded_units` walk and
  skips emission.

  CHECKBIN_HAS pins the shared canonical so we know it landed once;
  CHECKBIN_LACKS pins a per-spec legacy name that must not survive. }
{ %CHECKBIN_HAS=LIGHTGENERICS_CROSS_MODULE_3WAY_A_$LWG_ref$_TBOX$1_SETVALUE$2_ref %CHECKBIN_LACKS=LIGHTGENERICS_CROSS_MODULE_3WAY_B_$_$TBOX$1_$$_SETVALUE$TFOO }
program lightgenerics_cross_module_3way_21;
{$mode unleashed}
{$modeswitch lightgenerics}

uses lightgenerics_cross_module_3way_b, lightgenerics_cross_module_3way_c;

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
