program composable_records_rtti_flatten_02;
{ cascade: A embeds B embeds C. extended RTTI on A exposes C's fields
  with the accumulated carrier offset. }

{$mode unleashed}
{$M+}
{$RTTI EXPLICIT FIELDS([vcPublic])}

uses TypInfo, Rtti;

type
  TInner = record
    a, b: Integer;
  end;
  TMid = record
    pre: Integer;
    embed TInner;
    post: Integer;
  end;
  TOuter = record
    head: Integer;
    embed TMid;
    tail: Integer;
  end;

var
  rttictx: TRttiContext;
  rtype: TRttiType;
  fld: TRttiField;
begin
  rttictx := TRttiContext.Create;
  rtype := rttictx.GetType(TypeInfo(TOuter));
  if rtype = nil then halt(1);
  { head:4 + TMid:16 + tail:4 -> sizeof(TOuter)=24 }
  { TMid: pre:4 + TInner:8 + post:4 = 16 }
  { TInner inside TMid is at offset 4, so a@4, b@8 inside TMid }
  { TMid sits inside TOuter at offset 4, so a@4+4=8, b@4+8=12 }
  fld := rtype.GetField('head');
  if fld = nil then halt(2);
  if fld.Offset <> 0 then halt(3);
  fld := rtype.GetField('pre');
  if fld = nil then halt(4);
  if fld.Offset <> 4 then halt(5);
  fld := rtype.GetField('a');
  if fld = nil then halt(6);
  if fld.Offset <> 8 then halt(7);
  fld := rtype.GetField('b');
  if fld = nil then halt(8);
  if fld.Offset <> 12 then halt(9);
  fld := rtype.GetField('post');
  if fld = nil then halt(10);
  if fld.Offset <> 16 then halt(11);
  fld := rtype.GetField('tail');
  if fld = nil then halt(12);
  if fld.Offset <> 20 then halt(13);
end.
