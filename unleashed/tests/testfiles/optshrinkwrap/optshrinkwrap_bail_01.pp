{ %OPT=-O4 -OoSHRINKWRAP }
{ Shrink-wrapping must BAIL on constructs whose prologue/frame layout it does not
  model, and the code must stay correct.  Each function here carries a guard
  clause that superficially looks shrink-wrappable but is disqualified:
    * try/finally and raise/except -> exception frame (pi_uses_exceptions /
      implicit-finally): moving the prologue past a region that can unwind is
      unsound, so the pass leaves it alone;
    * a nested procedure that accesses the parent frame -> a frame pointer
      prologue, not the push-only shape the pass requires;
    * an inline asm block -> pi_has_assembler_block, an explicit bail.
  The pass must decline all of them and the observable results below must be
  correct on both the guard and non-guard paths.  Halt(nonzero) = failure. }
program optshrinkwrap_bail_01;
{$mode objfpc}{$H+}

uses
  sysutils;

var
  gcleaned: longint;

{ try/finally around the register-hungry body, plus an early guard exit }
function withfinally(p: PByte; n: longint): longint; noinline;
var
  i, a, b, c, d: longint;
begin
  Result := 0;
  if (p = nil) or (n <= 0) then
    exit(-1);
  a := 1; b := 2; c := 3; d := 4;
  try
    for i := 0 to n - 1 do
      begin
        a := a + p[i]; b := b xor a; c := c + b; d := d + c - a;
      end;
    Result := a + b + c + d;
  finally
    Inc(gcleaned);
  end;
end;

{ raise/except: guard early-exit then a body that may raise and recover }
function withexcept(n: longint): longint; noinline;
var
  a, b, c: longint;
begin
  if n <= 0 then
    exit(0);
  a := n; b := n * 2; c := n * 3;
  try
    if n = 13 then
      raise Exception.Create('boom');
    Result := a + b + c;
  except
    Result := -100;
  end;
end;

{ nested procedure accessing the parent's frame -> frame-pointer prologue }
function withnested(n: longint): longint; noinline;
var
  acc, x, y, z: longint;

  procedure bump(k: longint);
  begin
    acc := acc + k + x - y + z;   { touches parent locals -> parent frame }
  end;

begin
  if n <= 0 then
    exit(0);
  acc := 0; x := n; y := n div 2; z := n + 7;
  bump(1); bump(2); bump(3);
  withnested := acc + x + y + z;
end;

{ inline asm block -> pi_has_assembler_block }
function withasm(n: longint): longint; noinline;
var
  a, b, c: longint;
begin
  if n <= 0 then
    exit(0);
  a := n; b := n + 1; c := n + 2;
  asm
    nop
  end;
  withasm := a + b + c;
end;

begin
  gcleaned := 0;

  { withfinally: guard fast path (returns before the try) }
  if withfinally(nil, 5) <> -1 then Halt(1);
  if withfinally(nil, 0) <> -1 then Halt(2);

  { withexcept }
  if withexcept(0) <> 0 then Halt(3);
  if withexcept(5) <> (5 + 10 + 15) then Halt(4);
  if withexcept(13) <> -100 then Halt(5);   { raised & recovered }

  { withnested }
  if withnested(0) <> 0 then Halt(6);
  if withnested(4) <> (0 + (1 + 4 - 2 + 11) + (2 + 4 - 2 + 11) + (3 + 4 - 2 + 11)) + 4 + 2 + 11 then
    Halt(7);

  { withasm }
  if withasm(0) <> 0 then Halt(8);
  if withasm(10) <> (10 + 11 + 12) then Halt(9);

  Halt(0);
end.
