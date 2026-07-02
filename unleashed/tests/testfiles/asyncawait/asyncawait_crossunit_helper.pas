{ %NORUN }
unit asyncawait_crossunit_helper;
{$mode unleashed}
interface
function make: future of string;
procedure take(f: future of string);
implementation
function worker: string;
begin
  result := 'xu';
end;
function make: future of string;
begin
  result := async worker;
end;
procedure take(f: future of string);
begin
  if await f <> 'xu' then halt(1);
end;
end.
