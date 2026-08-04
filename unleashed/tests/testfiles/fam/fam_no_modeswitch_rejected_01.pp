{ %FAIL }

program fam_no_modeswitch_rejected_01;

{ outside the m_flexible_arrays modeswitch, `array[]` is rejected }

{$mode objfpc}

type
  TBad = record
    a: integer;
    data: array[] of byte;
  end;

begin
end.
