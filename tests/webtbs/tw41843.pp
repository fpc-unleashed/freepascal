{ with overflow checking off, constant folding after inline substitution
  must wrap like the run-time code it replaces instead of raising
  "Overflow in arithmetic operation" }

program tw41843;

{$mode objfpc}
{$r-,q-}

function addi(a, b: qword): qword; inline;
begin
  result:=a+b;
end;

function addv(a, b: qword): qword;
begin
  result:=a+b;
end;

function subi(a, b: qword): qword; inline;
begin
  result:=a-b;
end;

function subv(a, b: qword): qword;
begin
  result:=a-b;
end;

function muli(a, b: qword): qword; inline;
begin
  result:=a*b;
end;

function mulv(a, b: qword): qword;
begin
  result:=a*b;
end;

function smuli(a, b: int64): int64; inline;
begin
  result:=a*b;
end;

function smulv(a, b: int64): int64;
begin
  result:=a*b;
end;

begin
  if addi(high(qword),high(qword))<>addv(high(qword),high(qword)) then
    halt(1);
  if subi(1,(qword(1) shl 63)+2)<>subv(1,(qword(1) shl 63)+2) then
    halt(2);
  if muli(12345,4099276460824344803)<>mulv(12345,4099276460824344803) then
    halt(3);
  if smuli(-12345,4099276460824344803)<>smulv(-12345,4099276460824344803) then
    halt(4);
  writeln('ok');
end.
