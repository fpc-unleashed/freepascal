{ `obj as T`, `obj is T`, and explicit class-ref
  references (loadvmtaddrn) bake a per-T class identity into the
  body. those bodies must not share - subsequent specializations
  would inherit the first T's class ref and either misclassify
  the input or raise EInvalidCast }
program lightgenerics_ascast_fallback_18;
{$mode unleashed}
{$modeswitch lightgenerics}

uses SysUtils;

type
  TBase = class
    Tag: Integer;
  end;

  TFoo = class(TBase)
    constructor Create; reintroduce;
  end;

  TBar = class(TBase)
    constructor Create; reintroduce;
  end;

constructor TFoo.Create; begin inherited Create; Tag := 1; end;
constructor TBar.Create; begin inherited Create; Tag := 2; end;

type
  TCaster<T: TBase>=class(TObject)
    function Cast(obj: TBase): T;
  end;

function TCaster<T>.Cast(obj: TBase): T;
begin
  Result := obj as T;
end;

type
  TFooCaster = TCaster<TFoo>;
  TBarCaster = TCaster<TBar>;

var
  fc: TFooCaster;
  bc: TBarCaster;
  f: TFoo;
  b: TBar;
  raised: Boolean;
begin
  f := TFoo.Create;
  b := TBar.Create;
  fc := TFooCaster.Create;
  bc := TBarCaster.Create;

  if fc.Cast(f).Tag <> 1 then Halt(1);
  if bc.Cast(b).Tag <> 2 then Halt(2);

  { mixing - each spec must reject the wrong concrete type }
  raised := false;
  try
    fc.Cast(b);
  except
    on EInvalidCast do raised := true;
  end;
  if not raised then Halt(3);

  raised := false;
  try
    bc.Cast(f);
  except
    on EInvalidCast do raised := true;
  end;
  if not raised then Halt(4);

  fc.Free;
  bc.Free;
  f.Free;
  b.Free;
end.
