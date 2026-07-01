program zeroinit_anonymous_compound_skipped_08;

{$mode unleashed}

// anonymous compound types lack a typesym, so the zero-default lookup
// would crash; the implementation skips them silently to keep the
// rest of the locals from being affected
procedure CheckSimples; zeroinit;
var
  arr: array[0..3] of Integer; // anonymous - skipped
  i, j: Integer;               // covered
begin
  // i and j must be zero even though arr is not auto-zeroed
  if i <> 0 then halt(1);
  if j <> 0 then halt(2);
  // touch arr so it doesn't get optimised away
  arr[0] := 1;
  if arr[0] <> 1 then halt(3);
end;

begin
  CheckSimples;
end.
