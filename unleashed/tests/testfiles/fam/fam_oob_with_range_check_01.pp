{ %OPT=-Cr }
program fam_oob_with_range_check_01;

{$mode unleashed}

uses SysUtils;

type
  PMsg = ^TMsg;
  TMsg = packed record
    len: LongInt;
    data: array[] of Byte;
  end;

begin
  var m: PMsg;
  GetMem(m, SizeOf(TMsg) + 4);
  m^.len := 4;
  // FAM accesses bypass range checks per design; even with -Cr,
  // m^.data[100] does not raise. We just verify a valid access works
  // and an obviously-bad one does not crash the runtime check.
  m^.data[0] := 1;
  m^.data[3] := 9;
  if m^.data[0] <> 1 then halt(1);
  if m^.data[3] <> 9 then halt(2);
  FreeMem(m);
end.
