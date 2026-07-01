{ %FAIL }
program zeroinit_fail_external_07;

{$mode unleashed}

// zeroinit injects code into the body; external routines have no body
// so the combination is rejected
procedure DoNothing; external 'somelib.dll' name 'DoNothing'; zeroinit;

begin
end.
