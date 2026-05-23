program composable_records_sizeof_perfield_override_01;
{ `SizeOf(record.field)` and `BitSizeOf(record.field)` honour the
  per-field `size N` / `bitsize N` override - they return the slot
  size in the surrounding record, matching what `OffsetOf` deltas
  imply. without the override they fall back to the type's natural
  size. mirrors the existing custom_bitsize behaviour. }

{$mode unleashed}

type
  TR = record
    a: integer size 32;                    { 4-byte type, 32-byte slot }
    b: byte;
    c: integer;                            { 4-byte type, 4-byte slot }
  end;
  TE = record
    kind: (kA, kB, kC) of Byte size 16;    { 1-byte type, 16-byte slot }
    tail: byte;
  end;

begin
  if SizeOf(TR.a) <> 32 then halt(1);                   { override }
  if BitSizeOf(TR.a) div 8 <> 32 then halt(2);          { override }
  if SizeOf(TR.c) <> 4 then halt(3);                    { natural }
  if BitSizeOf(TR.c) div 8 <> 4 then halt(4);           { natural }
  if SizeOf(integer) <> 4 then halt(5);                 { pure type, no field }
  if SizeOf(TE.kind) <> 16 then halt(6);                { override }
  if SizeOf(TE.kA) <> 1 then halt(7);                   { enum constant - type only }
  if OffsetOf(TR.b) <> 32 then halt(8);                 { slot really is 32 }
  if OffsetOf(TE.tail) <> 16 then halt(9);              { slot really is 16 }
end.
