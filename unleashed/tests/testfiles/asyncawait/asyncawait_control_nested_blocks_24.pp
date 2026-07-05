{ nested blocks: Cancelled binds to the innermost spawning future }
program asyncawait_control_nested_blocks_24;
{$mode unleashed}
uses SysUtils;
begin
  var outer := async begin
    var inner := async begin
      while not Cancelled do Sleep(1);
    end;
    inner.Cancel;
    await inner;
    if not inner.Cancelled then halt(1);
  end;
  await outer;
  if not outer.Done then halt(2);
  if outer.Cancelled then halt(3);
end.
