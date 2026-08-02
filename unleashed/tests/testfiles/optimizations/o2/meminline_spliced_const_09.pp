{ %OPT=-O3 }
program meminline_spliced_const_09;
{$mode unleashed}

// when an inlined body binds a by-ref formal to a literal, a Move over that
// formal sees a constant node with no address after splicing; the expansion
// must step aside and leave the RTL call to materialize it. This program
// failed to compile ("Can't take the address of constant expressions")
// before the valid_for_addr gate.

function CloneToHeap(const s: shortstring): PAnsiChar; inline;
var p: PAnsiChar;
begin
  GetMem(p, Length(s) + 1);
  Move(s[1], p^, Length(s));
  p[Length(s)] := #0;
  result := p;
end;

begin
  var q := CloneToHeap('abcdef');
  // the copied prefix must survive whatever path the compiler picked
  if q[0] <> 'a' then Halt(1);
  FreeMem(q);
end.
