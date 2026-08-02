program inline_forced_inherited_procedure_01;
{$mode unleashed}

// a inline procedure (no result) calling an inherited procedure: this is
// the case the self-rewrite fix targets - it crashed before the fix

type
  TBase = class
    Acc: longint;
    procedure Store(x: longint); virtual;
  end;
  TChild = class(TBase)
    procedure StoreInl(x: longint); inline;
    procedure StoreCall(x: longint);
  end;

procedure TBase.Store(x: longint); begin Acc := x; end;
procedure TChild.StoreInl(x: longint); begin inherited Store(x); Acc := Acc + 1; end;
procedure TChild.StoreCall(x: longint); begin inherited Store(x); Acc := Acc + 1; end;

var
  a, b: TChild;
begin
  a := TChild.Create;
  b := TChild.Create;
  a.StoreInl(7);
  b.StoreCall(7);
  if a.Acc <> b.Acc then Halt(1);
  if a.Acc <> 8 then Halt(2);
  a.Free;
  b.Free;
end.
