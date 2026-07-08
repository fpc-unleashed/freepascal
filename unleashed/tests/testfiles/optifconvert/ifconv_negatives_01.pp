{ %OPT="-O4 -Cfsse64" }
{ Decline paths: shapes -OoIFCONVERT must NOT widen (double precision, an open-
  array parameter rather than a dynamic array, a two-statement two-sided clamp
  body, a downto loop, and a shifted a[i+1] index) each stay scalar and must
  still compute the correct result. This guards that a non-matching loop is left
  exactly as the compiler would otherwise emit it. }
program ifconv_negatives_01;
{$mode objfpc}{$H+}
uses Math;

{ double: in_max_double is not accepted (single-precision packing only) }
procedure relu_dbl(var a: array of double);
var i: longint;
begin
  for i:=0 to high(a) do if a[i]<0 then a[i]:=0;
end;

{ open-array parameter: base is not a dynamic-array variable -> declined }
procedure relu_open(var a: array of single);
var i: longint;
begin
  for i:=0 to high(a) do if a[i]<0 then a[i]:=0;
end;

var
  ds: array of single; dd: array of double;
  i,n: longint; x: single; xd: double;
begin
  for n:=0 to 11 do
    begin
      { two-sided clamp in one body: two statements -> not a single-stmt body }
      SetLength(ds,n);
      for i:=0 to n-1 do ds[i]:=(i-5)*1.3;
      for i:=0 to high(ds) do
        begin
          if ds[i]<-1.0 then ds[i]:=-1.0;
          if ds[i]> 2.0 then ds[i]:= 2.0;
        end;
      for i:=0 to n-1 do
        begin
          x:=(i-5)*1.3;
          if x<-1.0 then x:=-1.0;
          if x> 2.0 then x:= 2.0;
          if ds[i]<>x then Halt(1);
        end;

      { downto loop -> declined }
      for i:=0 to n-1 do ds[i]:=(i-4)*0.7;
      for i:=n-1 downto 0 do if ds[i]<0 then ds[i]:=0;
      for i:=0 to n-1 do
        begin x:=(i-4)*0.7; if x<0 then x:=0; if ds[i]<>x then Halt(2); end;

      { shifted index a[i+1] in the body -> declined; interior only }
      for i:=0 to n-1 do ds[i]:=(i-3)*0.5;
      for i:=0 to n-2 do if ds[i+1]<0 then ds[i+1]:=0;
      for i:=1 to n-1 do
        begin x:=(i-3)*0.5; if x<0 then x:=0; if ds[i]<>x then Halt(3); end;

      { double ReLU via helper -> declined, still correct }
      SetLength(dd,n);
      for i:=0 to n-1 do dd[i]:=(i-6)*2.0;
      relu_dbl(dd);
      for i:=0 to n-1 do
        begin xd:=(i-6)*2.0; if xd<0 then xd:=0; if dd[i]<>xd then Halt(4); end;

      { open-array ReLU -> declined, still correct }
      for i:=0 to n-1 do ds[i]:=(i-2)*0.9;
      relu_open(ds);
      for i:=0 to n-1 do
        begin x:=(i-2)*0.9; if x<0 then x:=0; if ds[i]<>x then Halt(5); end;
    end;
end.
