{ %FAIL }
program inline_static_fail_at_program_01;
{$mode unleashed}

// inline static at program top level must be rejected
begin
  static x := 5;
  WriteLn(x);
end.
