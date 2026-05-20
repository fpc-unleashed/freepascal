program composable_records_rtti_flatten_03;
{ inline anonymous record body: fields declared inside `record ... end;`
  without a name flatten into the outer record. RTTI reflects them by
  flattened name with the carrier's offset. }

{$mode unleashed}
{$M+}
{$RTTI EXPLICIT FIELDS([vcPublic])}

uses TypInfo, Rtti;

type
  TPacked = record
    head: Integer;
    record
      a, b: Integer;
    end;
    tail: Integer;
  end;

var
  rttictx: TRttiContext;
  rtype: TRttiType;
  fld: TRttiField;
begin
  rttictx := TRttiContext.Create;
  rtype := rttictx.GetType(TypeInfo(TPacked));
  if rtype = nil then halt(1);
  fld := rtype.GetField('head');
  if fld = nil then halt(2);
  if fld.Offset <> 0 then halt(3);
  fld := rtype.GetField('a');
  if fld = nil then halt(4);
  if fld.Offset <> 4 then halt(5);
  fld := rtype.GetField('b');
  if fld = nil then halt(6);
  if fld.Offset <> 8 then halt(7);
  fld := rtype.GetField('tail');
  if fld = nil then halt(8);
  if fld.Offset <> 12 then halt(9);
end.
