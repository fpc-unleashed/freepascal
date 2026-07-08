{ %OPT="-O4 -OoLOOPSPLIT -vn" }
{ The motivating shape: a 1-D stencil with a one-sided (right) border, where the
  interior -- the overwhelming majority of positions -- pays a per-element
  border test that splitting removes. Splitting at i=m yields a branch-free
  interior loop plus a short border epilogue. The split output must equal the
  scalar per-element result for a range of m values, including m below the range
  (all border) and m past the range (all interior). Every index stays inside the
  backing array so both versions read identical memory. }
program split_border_01;
{$mode objfpc}{$H+}

{ out[i] = in[i] + in[i+1] on the interior (i<m); on the border (i>=m) the
  forward neighbour is dropped and out[i] = in[i]. }
function scalar(const inp: array of double; i, m: longint): double;
begin
  if i<m then scalar:=inp[i] + inp[i+1]
  else scalar:=inp[i];
end;

procedure stencil(const inp: array of double; var outp: array of double; n, m: longint);
var i: longint;
begin
  for i:=0 to n-1 do
    if i<m then outp[i]:=inp[i] + inp[i+1]
    else outp[i]:=inp[i];
end;

var
  inp, outp: array[0..63] of double;
  i, n, m: longint;
begin
  n:=50;
  for i:=0 to 63 do inp[i]:=i*0.5 - 3.0;
  for m:=-2 to 52 do
    begin
      for i:=0 to 63 do outp[i]:=-999.0;
      stencil(inp, outp, n, m);
      for i:=0 to n-1 do
        if outp[i]<>scalar(inp, i, m) then Halt(1);
    end;
  writeln('ok');
end.
