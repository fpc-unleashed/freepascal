{ %FAIL }
program fam_only_field_rejected_01;

{$mode unleashed}

type
  // FAM requires at least one preceding fixed field
  TBad = packed record
    Items: array[] of Byte;
  end;

begin
end.
