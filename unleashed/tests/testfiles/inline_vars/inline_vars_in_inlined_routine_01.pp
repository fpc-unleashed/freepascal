{ %OPT="-O1 -OoREGVAR" }
program inline_vars_in_inlined_routine_01;

{$mode unleashed}

// block-scoped locals of an inline routine (the for-loop counter here) must
// be re-homed into the caller when the routine is inlined; they used to keep
// the stack offsets of the standalone copy and corrupted the caller's
// register-save slots

type
  PData = ^TData;
  TData = record
    buf: array[4] of Int64;
    len: Int64;
  end;

var
  calls: Int64;

procedure Touch;
begin
  inc(calls);
end;

procedure SetOne(dst: PInt64; var len: Int64; v: Int64); inline;
begin
  dst[0] := v;
  var m: Int64 := if v <> 0 then 1 else 0;
  for var i := m to 3 do dst[i] := 0;
  len := m;
end;

// the call keeps p and v in callee-saved registers whose save slots sit
// where the stale counter offset used to point
procedure AssignValue(p: PData; v: Int64);
begin
  Touch;
  SetOne(@p^.buf[0], p^.len, v);
end;

procedure Driver;
var
  d1, d2: TData;
  p, q: PData;
begin
  p := @d1;
  q := @d2;
  AssignValue(p, 1);
  AssignValue(q, 3);
  if p^.len + q^.len <> 2 then Halt(1);
  if d2.buf[0] <> 3 then Halt(2);
  if (d1.buf[1] <> 0) or (d2.buf[3] <> 0) then Halt(3);
  if calls <> 2 then Halt(4);
end;

begin
  Driver;
end.
