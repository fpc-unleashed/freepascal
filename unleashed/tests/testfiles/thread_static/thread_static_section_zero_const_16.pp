program thread_static_section_zero_const_16;
{$mode unleashed}

// initializers that fold to all-zero bytes (`= 0`, `= ''`, `= false`,
// `= nil`) need no guard or assignment - the per-thread zero-init already
// provides them. behaviour must match the no-initializer form: the value
// persists across calls within a thread, starting from zero.

function Counter: Integer;
threadstatic
  n: Integer = 0;
begin
  Inc(n);
  Result := n;
end;

function Flag: Boolean;
threadstatic
  seen: Boolean = false;
begin
  Result := seen;   // false on first reach
  seen := true;
end;

function Ptr: Boolean;
threadstatic
  p: Pointer = nil;
begin
  Result := p = nil;   // nil on first reach
  p := @Ptr;
end;

function Acc: string;
threadstatic
  s: string = '';
begin
  s := s + 'a';
  Result := s;
end;

function MultiZero: Integer;
threadstatic
  a, b, c: Integer = 0;   // each its own zero copy
begin
  Inc(a); Inc(b, 2); Inc(c, 3);
  Result := a + b + c;
end;

begin
  if Counter <> 1 then halt(1);
  if Counter <> 2 then halt(2);
  if Flag then halt(3);           // first call false
  if not Flag then halt(4);       // second call true (persisted)
  if not Ptr then halt(5);        // first call nil
  if Ptr then halt(6);            // second call not nil (persisted)
  if Acc <> 'a' then halt(7);
  if Acc <> 'aa' then halt(8);
  if MultiZero <> 6 then halt(9);    // 1+2+3
  if MultiZero <> 12 then halt(10);  // 2+4+6
end.
