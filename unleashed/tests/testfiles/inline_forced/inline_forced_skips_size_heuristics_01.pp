program inline_forced_skips_size_heuristics_01;
{$mode unleashed}

// deep chain of inline calls; the size heuristics would stop a plain
// inline chain at this depth, inline must expand every level

function C00(x: Integer): Integer; inline;
begin
  Result := x * 3 + (x div 5) - (x mod 7) + (x shl 1) - (x shr 2);
end;

function C01(x: Integer): Integer; inline;
begin
  Result := x xor (x * 11) + (x div 3) - (x mod 13) + C00(x);
end;

function C02(x: Integer): Integer; inline;
begin
  Result := x + (x * 17) - (x div 9) + (x mod 19) + C01(x);
end;

function C03(x: Integer): Integer; inline;
begin
  Result := x * 3 + (x div 5) - (x mod 7) + (x shl 1) + C02(x);
end;

function C04(x: Integer): Integer; inline;
begin
  Result := x xor (x * 11) + (x div 3) - (x mod 13) + C03(x);
end;

function C05(x: Integer): Integer; inline;
begin
  Result := x + (x * 17) - (x div 9) + (x mod 19) + C04(x);
end;

function C06(x: Integer): Integer; inline;
begin
  Result := x * 3 + (x div 5) - (x mod 7) + (x shl 1) + C05(x);
end;

function C07(x: Integer): Integer; inline;
begin
  Result := x xor (x * 11) + (x div 3) - (x mod 13) + C06(x);
end;

function C08(x: Integer): Integer; inline;
begin
  Result := x + (x * 17) - (x div 9) + (x mod 19) + C07(x);
end;

function C09(x: Integer): Integer; inline;
begin
  Result := x * 3 + (x div 5) - (x mod 7) + (x shl 1) + C08(x);
end;

function C10(x: Integer): Integer; inline;
begin
  Result := x xor (x * 11) + (x div 3) - (x mod 13) + C09(x);
end;

function C11(x: Integer): Integer; inline;
begin
  Result := x + (x * 17) - (x div 9) + (x mod 19) + C10(x);
end;

var
  r: Integer;
begin
  r := C11(1);
  if r <> C11(1) then Halt(1);
  if C00(1) <> 4 then Halt(2);
end.
