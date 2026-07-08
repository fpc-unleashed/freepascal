{ %OPT="-O4 -OoLOOPSPLIT -vn" }
{ Shapes the split pass must decline, each emitting a cg_n_loop_not_split (06072)
  note naming the reason, and each still computing the scalar result. Declines:
  equality/inequality conditions (not monotone in the IV), a bound that is not a
  simple invariant (an expression / memory), a fully loop-invariant condition
  (unswitch territory, IV on neither side), a multi-statement body, a break in a
  branch, a descending loop, and a 64-bit counter. }
program split_negatives_01;
{$mode objfpc}{$H+}

function base(i: longint): longint;
begin base:=100+i; end;

procedure eq(var a: array of longint; n,m: longint); var i: longint;
begin for i:=0 to n-1 do if i=m then a[i]:=1 else a[i]:=2; end;

procedure ne(var a: array of longint; n,m: longint); var i: longint;
begin for i:=0 to n-1 do if i<>m then a[i]:=1 else a[i]:=2; end;

{ bound is an expression (m+1 is not a simple invariant var/const) }
procedure expr(var a: array of longint; n,m: longint); var i: longint;
begin for i:=0 to n-1 do if i<(m+m) then a[i]:=1 else a[i]:=2; end;

{ fully invariant condition: IV on neither side (unswitch, not split) }
procedure inv(var a: array of longint; n,p,q: longint); var i: longint;
begin for i:=0 to n-1 do if p<q then a[i]:=100+i else a[i]:=200+i; end;

{ multi-statement body }
procedure multi(var a: array of longint; n,m: longint); var i,c: longint;
begin
  c:=0;
  for i:=0 to n-1 do begin if i<m then a[i]:=1 else a[i]:=2; inc(c); end;
  a[0]:=a[0]+c*0;
end;

{ break in a branch: original leaves the loop entirely; splitting is unsafe }
function withbreak(var a: array of longint; n,m: longint): longint; var i,c: longint;
begin
  c:=0;
  for i:=0 to n-1 do
    if i<m then begin a[i]:=100+i; c:=c+1; end else break;
  withbreak:=c;
end;

procedure desc(var a: array of longint; n,m: longint); var i: longint;
begin for i:=n-1 downto 0 do if i<m then a[i]:=100+i else a[i]:=200+i; end;

procedure wide(var a: array of longint; n,m: longint); var i: int64;
begin for i:=0 to n-1 do if i<m then a[i]:=100+i else a[i]:=200+i; end;

var a: array[0..15] of longint; i,n,m,ec: longint;
begin
  n:=10;
  for m:=-1 to 11 do
  begin
    for i:=0 to 15 do a[i]:=-1;
    eq(a,n,m);
    for i:=0 to n-1 do if a[i]<>(1+ord(i<>m)) then Halt(1);

    for i:=0 to 15 do a[i]:=-1;
    ne(a,n,m);
    for i:=0 to n-1 do if a[i]<>(1+ord(i=m)) then Halt(2);

    for i:=0 to 15 do a[i]:=-1;
    expr(a,n,m);
    for i:=0 to n-1 do if a[i]<>(1+ord(not(i<(m+m)))) then Halt(3);

    for i:=0 to 15 do a[i]:=-1;
    inv(a,n,m,5);
    for i:=0 to n-1 do
      if a[i]<>(100+i+100*ord(not(m<5))) then Halt(4);

    for i:=0 to 15 do a[i]:=-1;
    multi(a,n,m);
    for i:=0 to n-1 do if a[i]<>(1+ord(not(i<m))) then Halt(5);

    for i:=0 to 15 do a[i]:=-1;
    ec:=m; if ec<0 then ec:=0; if ec>n then ec:=n;
    if withbreak(a,n,m)<>ec then Halt(6);

    for i:=0 to 15 do a[i]:=-1;
    desc(a,n,m);
    for i:=0 to n-1 do if a[i]<>(100+i+100*ord(not(i<m))) then Halt(7);

    for i:=0 to 15 do a[i]:=-1;
    wide(a,n,m);
    for i:=0 to n-1 do if a[i]<>(100+i+100*ord(not(i<m))) then Halt(8);
  end;
  writeln('ok');
end.
