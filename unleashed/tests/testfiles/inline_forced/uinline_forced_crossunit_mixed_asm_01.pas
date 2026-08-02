unit uinline_forced_crossunit_mixed_asm_01;

{$mode unleashed}
{$asmmode intel}

interface

function MixedVal: DWord; inline;

implementation

// the mem,imm operand pair is direction-sensitive: reversed operands do
// not match any mov encoding, so an intel-order leak in the ppu image
// broke the consumer compile outright
function MixedVal: DWord;
var
  d: DWord;
begin
  asm
    mov [d], 123
  end;
  Result := d;
end;

end.
