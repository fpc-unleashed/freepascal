{ %PRECOMPILE=uinline_forced_impl_only_01.pas }
program inline_forced_impl_only_hint_01;

{$mode unleashed}

uses uinline_forced_impl_only_01;

begin
  if Bump(41) <> 42 then halt(1);
end.
