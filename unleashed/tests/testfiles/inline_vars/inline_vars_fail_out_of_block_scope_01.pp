{ %FAIL }
{ This test must FAIL to compile - it checks that inline vars are block-scoped }
{$mode unleashed}
program inline_vars_fail_out_of_block_scope_01;

begin
  begin
    var i := 2;
  end;
  WriteLn(i); { ERROR: i is out of scope here }
end.
