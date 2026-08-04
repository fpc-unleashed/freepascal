{ %FAIL }

program fam_for_in_rejected_01;

{ for-in cannot iterate a FAM (no termination condition) }

{$mode unleashed}

type
  PRec = ^TRec;
  TRec = record
    n: integer;
    data: array[] of byte;
  end;

var
  r: PRec;
  b: byte;
begin
  GetMem(r, sizeof(TRec) + 4);
  for b in r^.data do
    writeln(b);
  FreeMem(r);
end.
