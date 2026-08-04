{ %FAIL }
program labels_fail_undefined_member_const_goto_01;

{$mode unleashed}

{ a user-written goto naming an undefined member by constant index is a
  hard error: Label used but not defined }

procedure run;
label
  st[0..1];
begin
  goto st[1];  // st[1] is never defined
  st[0]: ;
end;

begin
  run;
end.
