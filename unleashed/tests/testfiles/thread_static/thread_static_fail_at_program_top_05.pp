{ %FAIL }
program thread_static_fail_at_program_top_05;
{$mode unleashed}

// threadstatic is a statement form, only inside a body; in the
// program-level type/var area there is no body to attach to
threadstatic x := 5;

begin
end.
