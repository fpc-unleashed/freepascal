program fam_pointer_uses_ok_01;

{ pointer to a FAM-record can be used as a field, parameter, return
  type, or array element; only the bare FAM-record itself is restricted }

{$mode unleashed}

type
  PNode = ^TNode;
  TNode = record
    next: PNode;
    n:    integer;
    payload: array[] of byte;
  end;

  TWrap = record
    head: PNode;
    tail: PNode;
  end;

  TArr = array[0..3] of PNode;

function make_node(extra: integer): PNode;
begin
  GetMem(result, sizeof(TNode) + extra);
  result^.next := nil;
  result^.n := extra;
end;

procedure consume(n: PNode);
begin
  if n <> nil then
    FreeMem(n);
end;

var
  w : TWrap;
  a : TArr;
  i : integer;
begin
  w.head := make_node(8);
  w.tail := make_node(16);
  for i := 0 to 3 do
    a[i] := make_node(i * 4);

  if w.head^.n <> 8 then halt(1);
  if a[3]^.n <> 12 then halt(2);

  consume(w.head);
  consume(w.tail);
  for i := 0 to 3 do
    consume(a[i]);

  writeln('ok');
end.
