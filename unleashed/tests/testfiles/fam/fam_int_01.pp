program fam_int_01;

{$mode unleashed}

type
  PSeq = ^TSeq;
  TSeq = packed record
    Count: LongInt;
    Items: array[] of Integer;
  end;

const
  N = 8;

var
  s: PSeq;

begin
  if SizeOf(TSeq) <> 4 then halt(1);   // header only (Count)
  GetMem(s, SizeOf(TSeq) + N * SizeOf(Integer));
  s^.Count := N;
  for var i := 0 to N - 1 do
    s^.Items[i] := i * i;
  for var i := 0 to N - 1 do
    if s^.Items[i] <> i * i then halt(2);
  FreeMem(s);
end.
