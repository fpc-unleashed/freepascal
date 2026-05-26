program composable_records_generic_inline_anon_union_01;

{$mode unleashed}

type
  { inline anonymous record AS A UNION VARIANT inside a generic record
    - same crash path as the top-of-body case, exercises the spec hint
    flowing through the union variant path }
  TPacket<T> = record
    header: T;
    union
      raw: LongWord;
      record
        cmd, flags: Byte;
        ext: Word;
      end;
    end;
  end;

var
  p: TPacket<Byte>;
begin
  p.header := $AA;
  p.cmd := $11;
  p.flags := $22;
  p.ext := $4433;
  if p.header <> $AA then halt(1);
  if p.raw <> $44332211 then halt(2);
  if p.cmd <> $11 then halt(3);
end.
