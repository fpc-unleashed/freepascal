program zeroinit_file_local_skipped_09;

{$mode unleashed}

// file locals keep their RTL init (proper closed state, which is not
// all-zeros); other locals in the same routine are still zeroed
procedure UseFile; zeroinit;
var
  t: Text;
  n: Integer;
begin
  if n <> 0 then halt(1);
  AssignFile(t, 'zeroinit_file_local_skipped_09_tmp.txt');
  Rewrite(t);
  writeln(t, 'ok');
  CloseFile(t);
  Erase(t);
end;

begin
  UseFile;
end.
