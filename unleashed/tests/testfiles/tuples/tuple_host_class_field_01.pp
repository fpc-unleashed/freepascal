program tuple_host_class_field_01;

{$mode unleashed}

// a class reference inside a tuple field is pointer-sized, so a class can
// hold a tuple referencing itself

type
  TNode = class
    link: (next: TNode; weight: Integer);
  end;

var
  a, b: TNode;

begin
  a := TNode.Create;
  b := TNode.Create;
  a.link.next := b;
  a.link.weight := 7;
  b.link.next := nil;
  b.link.weight := 9;
  if a.link.next <> b then halt(1);
  if a.link.weight <> 7 then halt(2);
  if a.link.next.link.weight <> 9 then halt(3);
  if b.link.next <> nil then halt(4);
  b.Free;
  a.Free;
end.
