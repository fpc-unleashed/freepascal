unit iparalib;

{ Auxiliary unit for the cross-unit -OoIPARA / shared-PPU-summary test
  (unleashed/tests/ipara_codegen_check.sh, cross-unit case). ADDONE is a tiny
  leaf routine that clobbers only one volatile integer register. Compiled WITH
  -OoIPARA its proven volatile-register clobber mask is serialized (guarded by a
  target/ABI/-Cf instruction-set signature) into iparalib.ppu, so a caller in
  another unit can narrow the caller-save registers it evacuates around the
  call. Compiled WITHOUT -OoIPARA the summary is absent and the caller must fall
  back to the full ABI caller-saved mask. Driven from a shell check script, so
  it lives outside testfiles/. }

{$mode objfpc}

interface

function addone(x: longint): longint;

implementation

function addone(x: longint): longint;
begin
  addone := x + 1;
end;

end.
