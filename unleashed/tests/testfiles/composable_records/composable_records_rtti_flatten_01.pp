program composable_records_rtti_flatten_01;
{ extended RTTI exposes flattened embed members alongside the carrier:
  `GetField('x')` resolves x through the embedded TBase, returning the
  correct offset. matches stock FPC `{$RTTI EXPLICIT FIELDS}` semantics
  for the outer record. }

{$mode unleashed}
{$M+}
{$RTTI EXPLICIT FIELDS([vcPublic])}

uses TypInfo, Rtti;

type
  TBase = record
    x, y: Integer;
  end;
  TDerived = record
    embed TBase;
    z: Integer;
  end;

var
  rttictx: TRttiContext;
  rtype: TRttiType;
  fld: TRttiField;
begin
  rttictx := TRttiContext.Create;
  rtype := rttictx.GetType(TypeInfo(TDerived));
  if rtype = nil then halt(1);
  fld := rtype.GetField('x');
  if fld = nil then halt(2);
  if fld.Offset <> 0 then halt(3);
  fld := rtype.GetField('y');
  if fld = nil then halt(4);
  if fld.Offset <> 4 then halt(5);
  fld := rtype.GetField('z');
  if fld = nil then halt(6);
  if fld.Offset <> 8 then halt(7);
end.
