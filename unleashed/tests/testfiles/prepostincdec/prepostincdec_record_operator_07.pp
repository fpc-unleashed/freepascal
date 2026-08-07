program prepostincdec_record_operator_07;
{$mode unleashed}
type
  trec = record
    x: Integer;
    class operator Inc(const a: trec): trec;
    class operator Dec(const a: trec): trec;
  end;

class operator trec.Inc(const a: trec): trec;
begin
  result.x := a.x + 100;
end;

class operator trec.Dec(const a: trec): trec;
begin
  result.x := a.x - 100;
end;

var
  r: trec;
begin
  r.x := 1;
  if PostInc(r).x <> 1 then halt(1);
  if r.x <> 101 then halt(2);
  if PreInc(r).x <> 201 then halt(3);
  if PostDec(r).x <> 201 then halt(4);
  if PreDec(r).x <> 1 then halt(5);
  if r.x <> 1 then halt(6);
end.
