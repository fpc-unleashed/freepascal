program type_intrinsic_non_ordinals_07;

{$mode unleashed}

type
  TRec = record
    a: Integer;
    b: AnsiString;
  end;
  TBase = class
    field: Integer;
  end;

var
  d: Double;
  s: AnsiString;
  rec: TRec;
  obj: TBase;

  d2: Type(d);
  s2: Type(s);
  rec2: Type(rec);
  obj2: Type(obj);
begin
  d := 3.14;
  d2 := d * 2.0;
  if d2 < 6.27 then Halt(1);

  s := 'pascal';
  s2 := s + '!';
  if s2 <> 'pascal!' then Halt(2);

  rec.a := 42;
  rec.b := 'hello';
  rec2 := rec;
  if (rec2.a <> 42) or (rec2.b <> 'hello') then Halt(3);

  obj := TBase.Create;
  obj.field := 100;
  obj2 := obj;
  if obj2.field <> 100 then Halt(4);
  obj.Free;
end.
