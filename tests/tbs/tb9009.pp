{ %OPT=-O2 }
{ the MOVZX/CMP reordering peepholes must not narrow a compare consumed by
  a signed condition: after `movzbl %al,%eax / cmpl $192,%eax / jl`, the
  zero-extended value and the constant change sign when the compare is
  narrowed to byte size, flipping the branch for values with bit 7 set }
program tb9009;

{$mode objfpc}{$H+}

uses
  SysUtils;

function ReadByte(const d: TBytes; var p: Integer): Byte;
begin
  result := d[p];
  Inc(p);
end;

{ cmov shape: the register stays live after the compare, so the narrowing
  happens in the post-peephole stage }
function LenCmov(const d: TBytes; var p: Integer): Integer;
var
  o1: Integer;
begin
  o1 := ReadByte(d, p);
  if o1 < 192 then
    result := o1
  else if o1 < 255 then
    result := ((o1 - 192) shl 8) + ReadByte(d, p) + 192
  else
    result := -1;
end;

{ branch shape: the register dies at the compare, so the narrowing happens
  in the pass 2 movx data flow optimisation }
function LenBranch(const d: TBytes; var p: Integer): string;
var
  o1: Integer;
begin
  o1 := ReadByte(d, p);
  if o1 < 192 then
    result := 'small'
  else
    result := 'big';
end;

var
  d: TBytes;
  p: Integer;
begin
  d := TBytes.Create(2, 99, 200);

  p := 0;
  if LenCmov(d, p) <> 2 then
    Halt(1);

  p := 0;
  if LenBranch(d, p) <> 'small' then
    Halt(2);

  p := 2;
  if LenBranch(d, p) <> 'big' then
    Halt(3);

  writeln('ok');
end.
