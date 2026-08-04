{ %FAIL }

program fam_embedded_record_rejected_01;

{ a FAM-record cannot be embedded in another record }

{$mode unleashed}

type
  TInner = record
    code: integer;
    data: array[] of byte;
  end;

  TOuter = record
    inner: TInner;
    flag:  integer;
  end;

begin
end.
