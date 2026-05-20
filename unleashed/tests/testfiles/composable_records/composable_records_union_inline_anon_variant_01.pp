program composable_records_union_inline_anon_variant_01;

{$mode unleashed}

type
  TRec = record
    union
      record
        a, b: Word;
      end;
      l: LongWord;
    end;
  end;

var
  r: TRec;
begin
  r.l := $11112222;
  if r.a <> $2222 then halt(1);
  if r.b <> $1111 then halt(2);
end.
