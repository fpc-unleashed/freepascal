{ %FAIL }
program composable_records_fail_embed_legacy_object_01;

{$mode unleashed}

type
  TObj = object
    a: Integer;
    procedure DoIt; virtual; abstract;
  end;
  TRec = record
    embed TObj;       { legacy object with VMT - hidden field messes up layout }
  end;
begin
end.
