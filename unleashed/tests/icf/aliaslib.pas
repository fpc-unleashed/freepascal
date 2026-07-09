unit aliaslib;
{$mode objfpc}
interface
function Compute(a,b,c,d: longint): longint;
function ComputeTaken(a,b,c,d: longint): longint;
function PtrsDistinct: boolean;
implementation

{ Foo and Bar: byte-identical, addresses never taken -> ICF alias candidates. }
function Foo(a,b,c,d: longint): longint;
begin
  result:=a*b+c-d; result:=result*a; result:=result xor b;
  result:=result+c*d; result:=result-a*c; result:=result or d;
  result:=result*3+7; result:=result and $7f; result:=result shl 2;
end;
function Bar(a,b,c,d: longint): longint;
begin
  result:=a*b+c-d; result:=result*a; result:=result xor b;
  result:=result+c*d; result:=result-a*c; result:=result or d;
  result:=result*3+7; result:=result and $7f; result:=result shl 2;
end;

{ Ping and Pong: byte-identical, but their addresses ARE taken below, so ICF
  must fall back to a thunk and keep @Ping<>@Pong. }
function Ping(a,b,c,d: longint): longint;
begin
  result:=a+b+c+d; result:=result*a; result:=result xor b;
  result:=result+c*d; result:=result-a*c; result:=result or d;
  result:=result*5+1; result:=result and $3f; result:=result shl 1;
end;
function Pong(a,b,c,d: longint): longint;
begin
  result:=a+b+c+d; result:=result*a; result:=result xor b;
  result:=result+c*d; result:=result-a*c; result:=result or d;
  result:=result*5+1; result:=result and $3f; result:=result shl 1;
end;

type tfn = function(a,b,c,d: longint): longint;

function Compute(a,b,c,d: longint): longint;
begin
  result:=Foo(a,b,c,d)+Bar(a,b,c,d);
end;

function ComputeTaken(a,b,c,d: longint): longint;
begin
  result:=Ping(a,b,c,d)+Pong(a,b,c,d);
end;

function PtrsDistinct: boolean;
var p,q: tfn;
begin
  p:=@Ping; q:=@Pong;   { addresses taken -> thunk fallback preserves @Ping<>@Pong }
  PtrsDistinct:=(pointer(p)<>pointer(q)) and (p(1,2,3,4)=q(1,2,3,4));
end;
end.
