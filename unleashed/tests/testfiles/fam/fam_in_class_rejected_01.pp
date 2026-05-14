{ %FAIL }
program fam_in_class_rejected_01;

{$mode unleashed}

type
  // FAM only allowed in plain `record`, not in class/object
  TBad = class
    Tag:  LongInt;
    Data: array[] of Byte;
  end;

begin
end.
