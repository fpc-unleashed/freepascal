{ cross-module dedup via ppu-tracked canonicals.

  unit a declares `TBox<T> = class` and specializes `TBox<TFoo>` in
  its interface. the main program specializes `TBox<TBar>` (same
  shape: ref). without this support both modules emitted the canonical
  body and the linker rejected the multiply-defined symbol; now
  unit a writes its canonicals into its ppu and the main program
  skips re-emit.

  the canonical name uses the generic template's home module so
  every consumer agrees on it across modules. CHECKBIN_HAS pins
  one canonical, CHECKBIN_LACKS pins the per-spec legacy name
  for the TBar branch - if it appeared in the binary, the main
  program would have emitted its own body instead of routing
  through unit a's. }
{ %CHECKBIN_HAS=LIGHTGENERICS_CROSS_MODULE_DEDUP_A_$LWG_ref$_TBOX$1_SETVALUE$2_ref %CHECKBIN_LACKS=LIGHTGENERICS_CROSS_MODULE_DEDUP_A_$_$TBOX$1_$$_SETVALUE$TBAR }
program lightgenerics_cross_module_dedup_20;
{$mode unleashed}
{$modeswitch lightgenerics}

uses lightgenerics_cross_module_dedup_a;

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
