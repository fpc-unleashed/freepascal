{ %FAIL }
program fam_two_in_one_record_rejected_01;

{$mode unleashed}

type
  TBad = packed record
    Header: LongInt;
    A: array[] of Byte;
    B: array[] of Byte;     // second FAM not allowed
  end;

begin
end.
