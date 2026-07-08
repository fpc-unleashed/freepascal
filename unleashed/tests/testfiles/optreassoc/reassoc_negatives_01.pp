{ %OPT=-O4 }
{ Decline paths: shapes -OoREASSOC must NOT split (a non-inline call in the added
  expression, a two-statement body that also uses the accumulator, and a downto
  loop) each stay a plain serial reduction and must still compute the correct
  result. Checked against a strictly-sequential reference built in the array-fill
  loop (a multi-statement body the pass never touches). }
program reassoc_negatives_01;
{$mode objfpc}{$H+}
function twice(x: double): double; begin twice:=x*2.0; end;

{ call in expr -> declined }
function sum_call(const a: array of double): double;
var i: longint; s: double;
begin s:=0; for i:=0 to high(a) do s:=s+twice(a[i]); sum_call:=s; end;

{ downto loop -> declined }
function sum_down(const a: array of double): double;
var i: longint; s: double;
begin s:=0; for i:=high(a) downto 0 do s:=s+a[i]; sum_down:=s; end;

{ two-statement body that also stores the running sum -> declined (multi-stmt) }
procedure prefix(const a: array of double; var outp: array of double);
var i: longint; s: double;
begin
  s:=0;
  for i:=0 to high(a) do begin s:=s+a[i]; outp[i]:=s; end;
end;

var a,pf: array of double; i,n: longint; seq,run: double;
begin
  for n:=0 to 30 do
    begin
      SetLength(a,n); SetLength(pf,n);
      seq:=0;
      for i:=0 to n-1 do begin a[i]:=(i mod 6)*0.5-1.0; seq:=seq+a[i]; end;
      if sum_call(a)<>seq*2.0 then Halt(1);
      if sum_down(a)<>seq then Halt(2);
      prefix(a,pf);
      run:=0;
      for i:=0 to n-1 do begin run:=run+a[i]; if pf[i]<>run then Halt(3); end;
    end;
end.
