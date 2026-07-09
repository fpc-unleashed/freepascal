{ %OPT="-O2 -OoFINALVALUE" }
{ -OoFINALVALUE whole-loop deletion: an empty-bodied counted loop whose counter
  is dead after the loop is deleted outright (it computes nothing observable).
  The function must still return its post-loop constant regardless of the trip
  count. See finalvalue_check.sh for the assembly-level proof the loop is gone. }
program fv_empty_delete_01;
{$mode objfpc}{$H+}

function empty_loop(n: longint): longint;
var i: longint;
begin
  for i:=1 to n do ;
  empty_loop:=42;
end;

function empty_down(a,b: longint): longint;
var i: longint;
begin
  for i:=a downto b do ;
  empty_down:=7;
end;

var n: longint;
begin
  for n:=-5 to 50 do
    begin
      if empty_loop(n) <> 42 then Halt(1);
      if empty_down(n,0) <> 7 then Halt(2);
    end;
  Halt(0);
end.
