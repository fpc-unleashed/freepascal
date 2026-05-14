{ %FAIL }
program fam_not_last_field_rejected_01;

{$mode unleashed}

type
  // FAM must be the last field
  TBad = packed record
    Header: LongInt;
    Data:   array[] of Byte;
    Trailer: LongInt;
  end;

begin
end.
