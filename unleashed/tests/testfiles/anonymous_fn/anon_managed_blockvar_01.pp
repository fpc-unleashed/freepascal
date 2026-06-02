program anon_managed_blockvar_01;

{$mode unleashed}

{ regression: IE 2020050302. a managed inline-var (string) declared inside a
  nested begin..end block of an anonymous function. after the closure is
  reparented into a capturer method (normal_function_level), its block
  symtable kept the nested level it was anchored to at parse time, so the
  var's implicit finalization looked like a parent-frame access and tripped
  set_needs_parentfp. the swap below also checks the var actually lives on
  the closure's own frame. }

type
  TProc = reference to procedure;

var
  arr: array of string;
  p: TProc;

procedure setup;
begin
  p := procedure
       begin
         var i := 0;
         while i < high(arr) do begin
           var t := arr[i]; arr[i] := arr[i+1]; arr[i+1] := t;
           i += 1;
         end;
       end;
end;

begin
  setlength(arr, 3);
  arr[0] := 'a'; arr[1] := 'b'; arr[2] := 'c';
  setup;
  p();
  if arr[0] <> 'b' then halt(1);
  if arr[1] <> 'c' then halt(2);
  if arr[2] <> 'a' then halt(3);
end.
