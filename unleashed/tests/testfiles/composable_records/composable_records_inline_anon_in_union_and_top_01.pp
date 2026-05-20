program composable_records_inline_anon_in_union_and_top_01;

{$mode unleashed}

type
  { two inline-anon records under the same outer record, one directly
    in the body, one inside a union variant - both need unique carrier
    names. originally both fell back to "$compose$1" because the union
    variant's local symtable numbers from zero independently of the
    outer record, and `insertunionst` merged the carrier into the
    parent symtable where it collided. }
  THeader = record
    sig: longword;

    packed record
      cmd: byte;
      payload_size: word;
      flags: byte;
    end;

    union size 1
      BitField: byte;
      bitpacked record
        IsDirty:   boolean;
        IsLocked:  boolean;
        IsActive:  boolean;
      end;
    end;
  end;

var
  h: THeader;
begin
  h.sig := $deadbeef;
  h.cmd := $55;
  h.payload_size := $1234;
  h.flags := $aa;
  h.BitField := $07;
  if h.sig <> $deadbeef then halt(1);
  if h.cmd <> $55 then halt(2);
  if h.payload_size <> $1234 then halt(3);
  if h.flags <> $aa then halt(4);
  if h.BitField <> $07 then halt(5);
  if not h.IsDirty then halt(6);
  if not h.IsLocked then halt(7);
  if not h.IsActive then halt(8);
end.
