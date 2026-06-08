{ composite shape key. TPair<TFoo, TBar> shares with
  TPair<TFoo, TBaz> (both Ref_Ref) but not with TPair<TFoo, Integer>
  (Ref_POD_4) }
program lightgenerics_mixed_shape_share_09;
{$mode unleashed}
{$modeswitch lightgenerics}

type
  TPair<K, V>=class(TObject)
    FK: K;
    FV: V;
    procedure Put(const a: K; const b: V); virtual;
  end;

procedure TPair<K, V>.Put(const a: K; const b: V);
begin
  FK := a;
  FV := b;
end;

type
  TFoo = class end;
  TBar = class end;
  TBaz = class end;

  TPairFB = TPair<TFoo, TBar>;        // Ref_Ref
  TPairFZ = TPair<TFoo, TBaz>;        // Ref_Ref
  TPairFI = TPair<TFoo, Integer>;     // Ref_POD_4

procedure PickFB(out p: Pointer);
var o: TPairFB; m: TMethod;
begin o:=TPairFB.Create; m:=TMethod(@o.Put); p:=m.Code; o.Free; end;

procedure PickFZ(out p: Pointer);
var o: TPairFZ; m: TMethod;
begin o:=TPairFZ.Create; m:=TMethod(@o.Put); p:=m.Code; o.Free; end;

procedure PickFI(out p: Pointer);
var o: TPairFI; m: TMethod;
begin o:=TPairFI.Create; m:=TMethod(@o.Put); p:=m.Code; o.Free; end;

var
  pfb, pfz, pfi: Pointer;
begin
  PickFB(pfb);
  PickFZ(pfz);
  PickFI(pfi);
  if pfb = nil then Halt(10);
  if pfz = nil then Halt(11);
  if pfi = nil then Halt(12);
  if pfb <> pfz then Halt(1);    // same composite bucket
  if pfb = pfi then Halt(2);     // different bucket
end.
