{ instance constructor and destructor bodies are now part
  of the dedup set. each specialization's vmt prologue (slot setup)
  monomorphizes separately, but the body itself - which is what
  produces the actual machine code - shares across same-shape
  specializations }
program lightgenerics_ctor_dtor_share_15;
{$mode unleashed}
{$modeswitch lightgenerics}

type
  TBox<T>=class(TObject)
    FValue: T;
    Tag: Integer;
    constructor Create(const A: T);
    destructor Destroy; override;
  end;

constructor TBox<T>.Create(const A: T);
begin
  inherited Create;
  FValue := A;
  Tag := 1;
end;

destructor TBox<T>.Destroy;
begin
  Tag := -1;
  inherited Destroy;
end;

type
  TFoo = class end;
  TBar = class end;
  TBoxFoo = TBox<TFoo>;
  TBoxBar = TBox<TBar>;

var
  bf: TBoxFoo;
  bb: TBoxBar;
  f: TFoo;
  b: TBar;
  pd: Pointer;
  m: TMethod;
begin
  f := TFoo.Create;
  b := TBar.Create;
  bf := TBoxFoo.Create(f);
  bb := TBoxBar.Create(b);
  if bf.FValue <> f then Halt(1);
  if bb.FValue <> b then Halt(2);
  if bf.Tag <> 1 then Halt(3);
  if bb.Tag <> 1 then Halt(4);
  m := TMethod(@bf.Destroy); pd := m.Code;
  m := TMethod(@bb.Destroy);
  if m.Code <> pd then Halt(5);
  bf.Free;
  bb.Free;
end.
