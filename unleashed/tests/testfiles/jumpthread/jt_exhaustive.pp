{ %OPT="-O4 -OoJUMPTHREAD" }
{ Exhaustive small-domain soundness check for jump threading.
  Each t*_i is a nested-if pair the pass may fold; refcmp uses a
  runtime op selector the pass cannot fold => true semantics.
  Any wrong-way implication => mismatch => Halt(n). }
{$mode objfpc}
{$R-}{$Q-}
program jt_exhaustive;
function cmpL(v:longint;op:longint;c:longint):boolean;
begin
 case op of
  0: cmpL:=v=c;
  1: cmpL:=v<>c;
  2: cmpL:=v<c;
  3: cmpL:=v<=c;
  4: cmpL:=v>c;
  5: cmpL:=v>=c;
 else cmpL:=false; end;
end;
function refL(x:longint;oop:longint;oc:longint;iop:longint;ic:longint):longint;
begin
 if cmpL(x,oop,oc) then begin if cmpL(x,iop,ic) then refL:=2 else refL:=3; end
 else begin if cmpL(x,iop,ic) then refL:=11 else refL:=12; end;
end;
function cmpU(v:dword;op:longint;c:dword):boolean;
begin
 case op of
  0: cmpU:=v=c;
  1: cmpU:=v<>c;
  2: cmpU:=v<c;
  3: cmpU:=v<=c;
  4: cmpU:=v>c;
  5: cmpU:=v>=c;
 else cmpU:=false; end;
end;
function refU(x:dword;oop:longint;oc:dword;iop:longint;ic:dword):longint;
begin
 if cmpU(x,oop,oc) then begin if cmpU(x,iop,ic) then refU:=2 else refU:=3; end
 else begin if cmpU(x,iop,ic) then refU:=11 else refU:=12; end;
end;
function tlongint_0(x:longint):longint;
begin
 result:=0;
 if x = -3 then begin result:=1; if x = -3 then result:=2 else result:=3; end
 else begin result:=10; if x = -3 then result:=11 else result:=12; end;
end;
function tlongint_1(x:longint):longint;
begin
 result:=0;
 if x = -3 then begin result:=1; if x = 3 then result:=2 else result:=3; end
 else begin result:=10; if x = 3 then result:=11 else result:=12; end;
end;
function tlongint_2(x:longint):longint;
begin
 result:=0;
 if x = -3 then begin result:=1; if x = 5 then result:=2 else result:=3; end
 else begin result:=10; if x = 5 then result:=11 else result:=12; end;
end;
function tlongint_3(x:longint):longint;
begin
 result:=0;
 if x = -3 then begin result:=1; if x = 7 then result:=2 else result:=3; end
 else begin result:=10; if x = 7 then result:=11 else result:=12; end;
end;
function tlongint_4(x:longint):longint;
begin
 result:=0;
 if x = -3 then begin result:=1; if x <> -3 then result:=2 else result:=3; end
 else begin result:=10; if x <> -3 then result:=11 else result:=12; end;
end;
function tlongint_5(x:longint):longint;
begin
 result:=0;
 if x = -3 then begin result:=1; if x <> 3 then result:=2 else result:=3; end
 else begin result:=10; if x <> 3 then result:=11 else result:=12; end;
end;
function tlongint_6(x:longint):longint;
begin
 result:=0;
 if x = -3 then begin result:=1; if x <> 5 then result:=2 else result:=3; end
 else begin result:=10; if x <> 5 then result:=11 else result:=12; end;
end;
function tlongint_7(x:longint):longint;
begin
 result:=0;
 if x = -3 then begin result:=1; if x <> 7 then result:=2 else result:=3; end
 else begin result:=10; if x <> 7 then result:=11 else result:=12; end;
end;
function tlongint_8(x:longint):longint;
begin
 result:=0;
 if x = -3 then begin result:=1; if x < -3 then result:=2 else result:=3; end
 else begin result:=10; if x < -3 then result:=11 else result:=12; end;
end;
function tlongint_9(x:longint):longint;
begin
 result:=0;
 if x = -3 then begin result:=1; if x < 3 then result:=2 else result:=3; end
 else begin result:=10; if x < 3 then result:=11 else result:=12; end;
end;
function tlongint_10(x:longint):longint;
begin
 result:=0;
 if x = -3 then begin result:=1; if x < 5 then result:=2 else result:=3; end
 else begin result:=10; if x < 5 then result:=11 else result:=12; end;
end;
function tlongint_11(x:longint):longint;
begin
 result:=0;
 if x = -3 then begin result:=1; if x < 7 then result:=2 else result:=3; end
 else begin result:=10; if x < 7 then result:=11 else result:=12; end;
end;
function tlongint_12(x:longint):longint;
begin
 result:=0;
 if x = -3 then begin result:=1; if x <= -3 then result:=2 else result:=3; end
 else begin result:=10; if x <= -3 then result:=11 else result:=12; end;
end;
function tlongint_13(x:longint):longint;
begin
 result:=0;
 if x = -3 then begin result:=1; if x <= 3 then result:=2 else result:=3; end
 else begin result:=10; if x <= 3 then result:=11 else result:=12; end;
end;
function tlongint_14(x:longint):longint;
begin
 result:=0;
 if x = -3 then begin result:=1; if x <= 5 then result:=2 else result:=3; end
 else begin result:=10; if x <= 5 then result:=11 else result:=12; end;
end;
function tlongint_15(x:longint):longint;
begin
 result:=0;
 if x = -3 then begin result:=1; if x <= 7 then result:=2 else result:=3; end
 else begin result:=10; if x <= 7 then result:=11 else result:=12; end;
end;
function tlongint_16(x:longint):longint;
begin
 result:=0;
 if x = -3 then begin result:=1; if x > -3 then result:=2 else result:=3; end
 else begin result:=10; if x > -3 then result:=11 else result:=12; end;
end;
function tlongint_17(x:longint):longint;
begin
 result:=0;
 if x = -3 then begin result:=1; if x > 3 then result:=2 else result:=3; end
 else begin result:=10; if x > 3 then result:=11 else result:=12; end;
end;
function tlongint_18(x:longint):longint;
begin
 result:=0;
 if x = -3 then begin result:=1; if x > 5 then result:=2 else result:=3; end
 else begin result:=10; if x > 5 then result:=11 else result:=12; end;
end;
function tlongint_19(x:longint):longint;
begin
 result:=0;
 if x = -3 then begin result:=1; if x > 7 then result:=2 else result:=3; end
 else begin result:=10; if x > 7 then result:=11 else result:=12; end;
end;
function tlongint_20(x:longint):longint;
begin
 result:=0;
 if x = -3 then begin result:=1; if x >= -3 then result:=2 else result:=3; end
 else begin result:=10; if x >= -3 then result:=11 else result:=12; end;
end;
function tlongint_21(x:longint):longint;
begin
 result:=0;
 if x = -3 then begin result:=1; if x >= 3 then result:=2 else result:=3; end
 else begin result:=10; if x >= 3 then result:=11 else result:=12; end;
end;
function tlongint_22(x:longint):longint;
begin
 result:=0;
 if x = -3 then begin result:=1; if x >= 5 then result:=2 else result:=3; end
 else begin result:=10; if x >= 5 then result:=11 else result:=12; end;
end;
function tlongint_23(x:longint):longint;
begin
 result:=0;
 if x = -3 then begin result:=1; if x >= 7 then result:=2 else result:=3; end
 else begin result:=10; if x >= 7 then result:=11 else result:=12; end;
end;
function tlongint_24(x:longint):longint;
begin
 result:=0;
 if x = 0 then begin result:=1; if x = -3 then result:=2 else result:=3; end
 else begin result:=10; if x = -3 then result:=11 else result:=12; end;
end;
function tlongint_25(x:longint):longint;
begin
 result:=0;
 if x = 0 then begin result:=1; if x = 3 then result:=2 else result:=3; end
 else begin result:=10; if x = 3 then result:=11 else result:=12; end;
end;
function tlongint_26(x:longint):longint;
begin
 result:=0;
 if x = 0 then begin result:=1; if x = 5 then result:=2 else result:=3; end
 else begin result:=10; if x = 5 then result:=11 else result:=12; end;
end;
function tlongint_27(x:longint):longint;
begin
 result:=0;
 if x = 0 then begin result:=1; if x = 7 then result:=2 else result:=3; end
 else begin result:=10; if x = 7 then result:=11 else result:=12; end;
end;
function tlongint_28(x:longint):longint;
begin
 result:=0;
 if x = 0 then begin result:=1; if x <> -3 then result:=2 else result:=3; end
 else begin result:=10; if x <> -3 then result:=11 else result:=12; end;
end;
function tlongint_29(x:longint):longint;
begin
 result:=0;
 if x = 0 then begin result:=1; if x <> 3 then result:=2 else result:=3; end
 else begin result:=10; if x <> 3 then result:=11 else result:=12; end;
end;
function tlongint_30(x:longint):longint;
begin
 result:=0;
 if x = 0 then begin result:=1; if x <> 5 then result:=2 else result:=3; end
 else begin result:=10; if x <> 5 then result:=11 else result:=12; end;
end;
function tlongint_31(x:longint):longint;
begin
 result:=0;
 if x = 0 then begin result:=1; if x <> 7 then result:=2 else result:=3; end
 else begin result:=10; if x <> 7 then result:=11 else result:=12; end;
end;
function tlongint_32(x:longint):longint;
begin
 result:=0;
 if x = 0 then begin result:=1; if x < -3 then result:=2 else result:=3; end
 else begin result:=10; if x < -3 then result:=11 else result:=12; end;
end;
function tlongint_33(x:longint):longint;
begin
 result:=0;
 if x = 0 then begin result:=1; if x < 3 then result:=2 else result:=3; end
 else begin result:=10; if x < 3 then result:=11 else result:=12; end;
end;
function tlongint_34(x:longint):longint;
begin
 result:=0;
 if x = 0 then begin result:=1; if x < 5 then result:=2 else result:=3; end
 else begin result:=10; if x < 5 then result:=11 else result:=12; end;
end;
function tlongint_35(x:longint):longint;
begin
 result:=0;
 if x = 0 then begin result:=1; if x < 7 then result:=2 else result:=3; end
 else begin result:=10; if x < 7 then result:=11 else result:=12; end;
end;
function tlongint_36(x:longint):longint;
begin
 result:=0;
 if x = 0 then begin result:=1; if x <= -3 then result:=2 else result:=3; end
 else begin result:=10; if x <= -3 then result:=11 else result:=12; end;
end;
function tlongint_37(x:longint):longint;
begin
 result:=0;
 if x = 0 then begin result:=1; if x <= 3 then result:=2 else result:=3; end
 else begin result:=10; if x <= 3 then result:=11 else result:=12; end;
end;
function tlongint_38(x:longint):longint;
begin
 result:=0;
 if x = 0 then begin result:=1; if x <= 5 then result:=2 else result:=3; end
 else begin result:=10; if x <= 5 then result:=11 else result:=12; end;
end;
function tlongint_39(x:longint):longint;
begin
 result:=0;
 if x = 0 then begin result:=1; if x <= 7 then result:=2 else result:=3; end
 else begin result:=10; if x <= 7 then result:=11 else result:=12; end;
end;
function tlongint_40(x:longint):longint;
begin
 result:=0;
 if x = 0 then begin result:=1; if x > -3 then result:=2 else result:=3; end
 else begin result:=10; if x > -3 then result:=11 else result:=12; end;
end;
function tlongint_41(x:longint):longint;
begin
 result:=0;
 if x = 0 then begin result:=1; if x > 3 then result:=2 else result:=3; end
 else begin result:=10; if x > 3 then result:=11 else result:=12; end;
end;
function tlongint_42(x:longint):longint;
begin
 result:=0;
 if x = 0 then begin result:=1; if x > 5 then result:=2 else result:=3; end
 else begin result:=10; if x > 5 then result:=11 else result:=12; end;
end;
function tlongint_43(x:longint):longint;
begin
 result:=0;
 if x = 0 then begin result:=1; if x > 7 then result:=2 else result:=3; end
 else begin result:=10; if x > 7 then result:=11 else result:=12; end;
end;
function tlongint_44(x:longint):longint;
begin
 result:=0;
 if x = 0 then begin result:=1; if x >= -3 then result:=2 else result:=3; end
 else begin result:=10; if x >= -3 then result:=11 else result:=12; end;
end;
function tlongint_45(x:longint):longint;
begin
 result:=0;
 if x = 0 then begin result:=1; if x >= 3 then result:=2 else result:=3; end
 else begin result:=10; if x >= 3 then result:=11 else result:=12; end;
end;
function tlongint_46(x:longint):longint;
begin
 result:=0;
 if x = 0 then begin result:=1; if x >= 5 then result:=2 else result:=3; end
 else begin result:=10; if x >= 5 then result:=11 else result:=12; end;
end;
function tlongint_47(x:longint):longint;
begin
 result:=0;
 if x = 0 then begin result:=1; if x >= 7 then result:=2 else result:=3; end
 else begin result:=10; if x >= 7 then result:=11 else result:=12; end;
end;
function tlongint_48(x:longint):longint;
begin
 result:=0;
 if x = 5 then begin result:=1; if x = -3 then result:=2 else result:=3; end
 else begin result:=10; if x = -3 then result:=11 else result:=12; end;
end;
function tlongint_49(x:longint):longint;
begin
 result:=0;
 if x = 5 then begin result:=1; if x = 3 then result:=2 else result:=3; end
 else begin result:=10; if x = 3 then result:=11 else result:=12; end;
end;
function tlongint_50(x:longint):longint;
begin
 result:=0;
 if x = 5 then begin result:=1; if x = 5 then result:=2 else result:=3; end
 else begin result:=10; if x = 5 then result:=11 else result:=12; end;
end;
function tlongint_51(x:longint):longint;
begin
 result:=0;
 if x = 5 then begin result:=1; if x = 7 then result:=2 else result:=3; end
 else begin result:=10; if x = 7 then result:=11 else result:=12; end;
end;
function tlongint_52(x:longint):longint;
begin
 result:=0;
 if x = 5 then begin result:=1; if x <> -3 then result:=2 else result:=3; end
 else begin result:=10; if x <> -3 then result:=11 else result:=12; end;
end;
function tlongint_53(x:longint):longint;
begin
 result:=0;
 if x = 5 then begin result:=1; if x <> 3 then result:=2 else result:=3; end
 else begin result:=10; if x <> 3 then result:=11 else result:=12; end;
end;
function tlongint_54(x:longint):longint;
begin
 result:=0;
 if x = 5 then begin result:=1; if x <> 5 then result:=2 else result:=3; end
 else begin result:=10; if x <> 5 then result:=11 else result:=12; end;
end;
function tlongint_55(x:longint):longint;
begin
 result:=0;
 if x = 5 then begin result:=1; if x <> 7 then result:=2 else result:=3; end
 else begin result:=10; if x <> 7 then result:=11 else result:=12; end;
end;
function tlongint_56(x:longint):longint;
begin
 result:=0;
 if x = 5 then begin result:=1; if x < -3 then result:=2 else result:=3; end
 else begin result:=10; if x < -3 then result:=11 else result:=12; end;
end;
function tlongint_57(x:longint):longint;
begin
 result:=0;
 if x = 5 then begin result:=1; if x < 3 then result:=2 else result:=3; end
 else begin result:=10; if x < 3 then result:=11 else result:=12; end;
end;
function tlongint_58(x:longint):longint;
begin
 result:=0;
 if x = 5 then begin result:=1; if x < 5 then result:=2 else result:=3; end
 else begin result:=10; if x < 5 then result:=11 else result:=12; end;
end;
function tlongint_59(x:longint):longint;
begin
 result:=0;
 if x = 5 then begin result:=1; if x < 7 then result:=2 else result:=3; end
 else begin result:=10; if x < 7 then result:=11 else result:=12; end;
end;
function tlongint_60(x:longint):longint;
begin
 result:=0;
 if x = 5 then begin result:=1; if x <= -3 then result:=2 else result:=3; end
 else begin result:=10; if x <= -3 then result:=11 else result:=12; end;
end;
function tlongint_61(x:longint):longint;
begin
 result:=0;
 if x = 5 then begin result:=1; if x <= 3 then result:=2 else result:=3; end
 else begin result:=10; if x <= 3 then result:=11 else result:=12; end;
end;
function tlongint_62(x:longint):longint;
begin
 result:=0;
 if x = 5 then begin result:=1; if x <= 5 then result:=2 else result:=3; end
 else begin result:=10; if x <= 5 then result:=11 else result:=12; end;
end;
function tlongint_63(x:longint):longint;
begin
 result:=0;
 if x = 5 then begin result:=1; if x <= 7 then result:=2 else result:=3; end
 else begin result:=10; if x <= 7 then result:=11 else result:=12; end;
end;
function tlongint_64(x:longint):longint;
begin
 result:=0;
 if x = 5 then begin result:=1; if x > -3 then result:=2 else result:=3; end
 else begin result:=10; if x > -3 then result:=11 else result:=12; end;
end;
function tlongint_65(x:longint):longint;
begin
 result:=0;
 if x = 5 then begin result:=1; if x > 3 then result:=2 else result:=3; end
 else begin result:=10; if x > 3 then result:=11 else result:=12; end;
end;
function tlongint_66(x:longint):longint;
begin
 result:=0;
 if x = 5 then begin result:=1; if x > 5 then result:=2 else result:=3; end
 else begin result:=10; if x > 5 then result:=11 else result:=12; end;
end;
function tlongint_67(x:longint):longint;
begin
 result:=0;
 if x = 5 then begin result:=1; if x > 7 then result:=2 else result:=3; end
 else begin result:=10; if x > 7 then result:=11 else result:=12; end;
end;
function tlongint_68(x:longint):longint;
begin
 result:=0;
 if x = 5 then begin result:=1; if x >= -3 then result:=2 else result:=3; end
 else begin result:=10; if x >= -3 then result:=11 else result:=12; end;
end;
function tlongint_69(x:longint):longint;
begin
 result:=0;
 if x = 5 then begin result:=1; if x >= 3 then result:=2 else result:=3; end
 else begin result:=10; if x >= 3 then result:=11 else result:=12; end;
end;
function tlongint_70(x:longint):longint;
begin
 result:=0;
 if x = 5 then begin result:=1; if x >= 5 then result:=2 else result:=3; end
 else begin result:=10; if x >= 5 then result:=11 else result:=12; end;
end;
function tlongint_71(x:longint):longint;
begin
 result:=0;
 if x = 5 then begin result:=1; if x >= 7 then result:=2 else result:=3; end
 else begin result:=10; if x >= 7 then result:=11 else result:=12; end;
end;
function tlongint_72(x:longint):longint;
begin
 result:=0;
 if x <> -3 then begin result:=1; if x = -3 then result:=2 else result:=3; end
 else begin result:=10; if x = -3 then result:=11 else result:=12; end;
end;
function tlongint_73(x:longint):longint;
begin
 result:=0;
 if x <> -3 then begin result:=1; if x = 3 then result:=2 else result:=3; end
 else begin result:=10; if x = 3 then result:=11 else result:=12; end;
end;
function tlongint_74(x:longint):longint;
begin
 result:=0;
 if x <> -3 then begin result:=1; if x = 5 then result:=2 else result:=3; end
 else begin result:=10; if x = 5 then result:=11 else result:=12; end;
end;
function tlongint_75(x:longint):longint;
begin
 result:=0;
 if x <> -3 then begin result:=1; if x = 7 then result:=2 else result:=3; end
 else begin result:=10; if x = 7 then result:=11 else result:=12; end;
end;
function tlongint_76(x:longint):longint;
begin
 result:=0;
 if x <> -3 then begin result:=1; if x <> -3 then result:=2 else result:=3; end
 else begin result:=10; if x <> -3 then result:=11 else result:=12; end;
end;
function tlongint_77(x:longint):longint;
begin
 result:=0;
 if x <> -3 then begin result:=1; if x <> 3 then result:=2 else result:=3; end
 else begin result:=10; if x <> 3 then result:=11 else result:=12; end;
end;
function tlongint_78(x:longint):longint;
begin
 result:=0;
 if x <> -3 then begin result:=1; if x <> 5 then result:=2 else result:=3; end
 else begin result:=10; if x <> 5 then result:=11 else result:=12; end;
end;
function tlongint_79(x:longint):longint;
begin
 result:=0;
 if x <> -3 then begin result:=1; if x <> 7 then result:=2 else result:=3; end
 else begin result:=10; if x <> 7 then result:=11 else result:=12; end;
end;
function tlongint_80(x:longint):longint;
begin
 result:=0;
 if x <> -3 then begin result:=1; if x < -3 then result:=2 else result:=3; end
 else begin result:=10; if x < -3 then result:=11 else result:=12; end;
end;
function tlongint_81(x:longint):longint;
begin
 result:=0;
 if x <> -3 then begin result:=1; if x < 3 then result:=2 else result:=3; end
 else begin result:=10; if x < 3 then result:=11 else result:=12; end;
end;
function tlongint_82(x:longint):longint;
begin
 result:=0;
 if x <> -3 then begin result:=1; if x < 5 then result:=2 else result:=3; end
 else begin result:=10; if x < 5 then result:=11 else result:=12; end;
end;
function tlongint_83(x:longint):longint;
begin
 result:=0;
 if x <> -3 then begin result:=1; if x < 7 then result:=2 else result:=3; end
 else begin result:=10; if x < 7 then result:=11 else result:=12; end;
end;
function tlongint_84(x:longint):longint;
begin
 result:=0;
 if x <> -3 then begin result:=1; if x <= -3 then result:=2 else result:=3; end
 else begin result:=10; if x <= -3 then result:=11 else result:=12; end;
end;
function tlongint_85(x:longint):longint;
begin
 result:=0;
 if x <> -3 then begin result:=1; if x <= 3 then result:=2 else result:=3; end
 else begin result:=10; if x <= 3 then result:=11 else result:=12; end;
end;
function tlongint_86(x:longint):longint;
begin
 result:=0;
 if x <> -3 then begin result:=1; if x <= 5 then result:=2 else result:=3; end
 else begin result:=10; if x <= 5 then result:=11 else result:=12; end;
end;
function tlongint_87(x:longint):longint;
begin
 result:=0;
 if x <> -3 then begin result:=1; if x <= 7 then result:=2 else result:=3; end
 else begin result:=10; if x <= 7 then result:=11 else result:=12; end;
end;
function tlongint_88(x:longint):longint;
begin
 result:=0;
 if x <> -3 then begin result:=1; if x > -3 then result:=2 else result:=3; end
 else begin result:=10; if x > -3 then result:=11 else result:=12; end;
end;
function tlongint_89(x:longint):longint;
begin
 result:=0;
 if x <> -3 then begin result:=1; if x > 3 then result:=2 else result:=3; end
 else begin result:=10; if x > 3 then result:=11 else result:=12; end;
end;
function tlongint_90(x:longint):longint;
begin
 result:=0;
 if x <> -3 then begin result:=1; if x > 5 then result:=2 else result:=3; end
 else begin result:=10; if x > 5 then result:=11 else result:=12; end;
end;
function tlongint_91(x:longint):longint;
begin
 result:=0;
 if x <> -3 then begin result:=1; if x > 7 then result:=2 else result:=3; end
 else begin result:=10; if x > 7 then result:=11 else result:=12; end;
end;
function tlongint_92(x:longint):longint;
begin
 result:=0;
 if x <> -3 then begin result:=1; if x >= -3 then result:=2 else result:=3; end
 else begin result:=10; if x >= -3 then result:=11 else result:=12; end;
end;
function tlongint_93(x:longint):longint;
begin
 result:=0;
 if x <> -3 then begin result:=1; if x >= 3 then result:=2 else result:=3; end
 else begin result:=10; if x >= 3 then result:=11 else result:=12; end;
end;
function tlongint_94(x:longint):longint;
begin
 result:=0;
 if x <> -3 then begin result:=1; if x >= 5 then result:=2 else result:=3; end
 else begin result:=10; if x >= 5 then result:=11 else result:=12; end;
end;
function tlongint_95(x:longint):longint;
begin
 result:=0;
 if x <> -3 then begin result:=1; if x >= 7 then result:=2 else result:=3; end
 else begin result:=10; if x >= 7 then result:=11 else result:=12; end;
end;
function tlongint_96(x:longint):longint;
begin
 result:=0;
 if x <> 0 then begin result:=1; if x = -3 then result:=2 else result:=3; end
 else begin result:=10; if x = -3 then result:=11 else result:=12; end;
end;
function tlongint_97(x:longint):longint;
begin
 result:=0;
 if x <> 0 then begin result:=1; if x = 3 then result:=2 else result:=3; end
 else begin result:=10; if x = 3 then result:=11 else result:=12; end;
end;
function tlongint_98(x:longint):longint;
begin
 result:=0;
 if x <> 0 then begin result:=1; if x = 5 then result:=2 else result:=3; end
 else begin result:=10; if x = 5 then result:=11 else result:=12; end;
end;
function tlongint_99(x:longint):longint;
begin
 result:=0;
 if x <> 0 then begin result:=1; if x = 7 then result:=2 else result:=3; end
 else begin result:=10; if x = 7 then result:=11 else result:=12; end;
end;
function tlongint_100(x:longint):longint;
begin
 result:=0;
 if x <> 0 then begin result:=1; if x <> -3 then result:=2 else result:=3; end
 else begin result:=10; if x <> -3 then result:=11 else result:=12; end;
end;
function tlongint_101(x:longint):longint;
begin
 result:=0;
 if x <> 0 then begin result:=1; if x <> 3 then result:=2 else result:=3; end
 else begin result:=10; if x <> 3 then result:=11 else result:=12; end;
end;
function tlongint_102(x:longint):longint;
begin
 result:=0;
 if x <> 0 then begin result:=1; if x <> 5 then result:=2 else result:=3; end
 else begin result:=10; if x <> 5 then result:=11 else result:=12; end;
end;
function tlongint_103(x:longint):longint;
begin
 result:=0;
 if x <> 0 then begin result:=1; if x <> 7 then result:=2 else result:=3; end
 else begin result:=10; if x <> 7 then result:=11 else result:=12; end;
end;
function tlongint_104(x:longint):longint;
begin
 result:=0;
 if x <> 0 then begin result:=1; if x < -3 then result:=2 else result:=3; end
 else begin result:=10; if x < -3 then result:=11 else result:=12; end;
end;
function tlongint_105(x:longint):longint;
begin
 result:=0;
 if x <> 0 then begin result:=1; if x < 3 then result:=2 else result:=3; end
 else begin result:=10; if x < 3 then result:=11 else result:=12; end;
end;
function tlongint_106(x:longint):longint;
begin
 result:=0;
 if x <> 0 then begin result:=1; if x < 5 then result:=2 else result:=3; end
 else begin result:=10; if x < 5 then result:=11 else result:=12; end;
end;
function tlongint_107(x:longint):longint;
begin
 result:=0;
 if x <> 0 then begin result:=1; if x < 7 then result:=2 else result:=3; end
 else begin result:=10; if x < 7 then result:=11 else result:=12; end;
end;
function tlongint_108(x:longint):longint;
begin
 result:=0;
 if x <> 0 then begin result:=1; if x <= -3 then result:=2 else result:=3; end
 else begin result:=10; if x <= -3 then result:=11 else result:=12; end;
end;
function tlongint_109(x:longint):longint;
begin
 result:=0;
 if x <> 0 then begin result:=1; if x <= 3 then result:=2 else result:=3; end
 else begin result:=10; if x <= 3 then result:=11 else result:=12; end;
end;
function tlongint_110(x:longint):longint;
begin
 result:=0;
 if x <> 0 then begin result:=1; if x <= 5 then result:=2 else result:=3; end
 else begin result:=10; if x <= 5 then result:=11 else result:=12; end;
end;
function tlongint_111(x:longint):longint;
begin
 result:=0;
 if x <> 0 then begin result:=1; if x <= 7 then result:=2 else result:=3; end
 else begin result:=10; if x <= 7 then result:=11 else result:=12; end;
end;
function tlongint_112(x:longint):longint;
begin
 result:=0;
 if x <> 0 then begin result:=1; if x > -3 then result:=2 else result:=3; end
 else begin result:=10; if x > -3 then result:=11 else result:=12; end;
end;
function tlongint_113(x:longint):longint;
begin
 result:=0;
 if x <> 0 then begin result:=1; if x > 3 then result:=2 else result:=3; end
 else begin result:=10; if x > 3 then result:=11 else result:=12; end;
end;
function tlongint_114(x:longint):longint;
begin
 result:=0;
 if x <> 0 then begin result:=1; if x > 5 then result:=2 else result:=3; end
 else begin result:=10; if x > 5 then result:=11 else result:=12; end;
end;
function tlongint_115(x:longint):longint;
begin
 result:=0;
 if x <> 0 then begin result:=1; if x > 7 then result:=2 else result:=3; end
 else begin result:=10; if x > 7 then result:=11 else result:=12; end;
end;
function tlongint_116(x:longint):longint;
begin
 result:=0;
 if x <> 0 then begin result:=1; if x >= -3 then result:=2 else result:=3; end
 else begin result:=10; if x >= -3 then result:=11 else result:=12; end;
end;
function tlongint_117(x:longint):longint;
begin
 result:=0;
 if x <> 0 then begin result:=1; if x >= 3 then result:=2 else result:=3; end
 else begin result:=10; if x >= 3 then result:=11 else result:=12; end;
end;
function tlongint_118(x:longint):longint;
begin
 result:=0;
 if x <> 0 then begin result:=1; if x >= 5 then result:=2 else result:=3; end
 else begin result:=10; if x >= 5 then result:=11 else result:=12; end;
end;
function tlongint_119(x:longint):longint;
begin
 result:=0;
 if x <> 0 then begin result:=1; if x >= 7 then result:=2 else result:=3; end
 else begin result:=10; if x >= 7 then result:=11 else result:=12; end;
end;
function tlongint_120(x:longint):longint;
begin
 result:=0;
 if x <> 5 then begin result:=1; if x = -3 then result:=2 else result:=3; end
 else begin result:=10; if x = -3 then result:=11 else result:=12; end;
end;
function tlongint_121(x:longint):longint;
begin
 result:=0;
 if x <> 5 then begin result:=1; if x = 3 then result:=2 else result:=3; end
 else begin result:=10; if x = 3 then result:=11 else result:=12; end;
end;
function tlongint_122(x:longint):longint;
begin
 result:=0;
 if x <> 5 then begin result:=1; if x = 5 then result:=2 else result:=3; end
 else begin result:=10; if x = 5 then result:=11 else result:=12; end;
end;
function tlongint_123(x:longint):longint;
begin
 result:=0;
 if x <> 5 then begin result:=1; if x = 7 then result:=2 else result:=3; end
 else begin result:=10; if x = 7 then result:=11 else result:=12; end;
end;
function tlongint_124(x:longint):longint;
begin
 result:=0;
 if x <> 5 then begin result:=1; if x <> -3 then result:=2 else result:=3; end
 else begin result:=10; if x <> -3 then result:=11 else result:=12; end;
end;
function tlongint_125(x:longint):longint;
begin
 result:=0;
 if x <> 5 then begin result:=1; if x <> 3 then result:=2 else result:=3; end
 else begin result:=10; if x <> 3 then result:=11 else result:=12; end;
end;
function tlongint_126(x:longint):longint;
begin
 result:=0;
 if x <> 5 then begin result:=1; if x <> 5 then result:=2 else result:=3; end
 else begin result:=10; if x <> 5 then result:=11 else result:=12; end;
end;
function tlongint_127(x:longint):longint;
begin
 result:=0;
 if x <> 5 then begin result:=1; if x <> 7 then result:=2 else result:=3; end
 else begin result:=10; if x <> 7 then result:=11 else result:=12; end;
end;
function tlongint_128(x:longint):longint;
begin
 result:=0;
 if x <> 5 then begin result:=1; if x < -3 then result:=2 else result:=3; end
 else begin result:=10; if x < -3 then result:=11 else result:=12; end;
end;
function tlongint_129(x:longint):longint;
begin
 result:=0;
 if x <> 5 then begin result:=1; if x < 3 then result:=2 else result:=3; end
 else begin result:=10; if x < 3 then result:=11 else result:=12; end;
end;
function tlongint_130(x:longint):longint;
begin
 result:=0;
 if x <> 5 then begin result:=1; if x < 5 then result:=2 else result:=3; end
 else begin result:=10; if x < 5 then result:=11 else result:=12; end;
end;
function tlongint_131(x:longint):longint;
begin
 result:=0;
 if x <> 5 then begin result:=1; if x < 7 then result:=2 else result:=3; end
 else begin result:=10; if x < 7 then result:=11 else result:=12; end;
end;
function tlongint_132(x:longint):longint;
begin
 result:=0;
 if x <> 5 then begin result:=1; if x <= -3 then result:=2 else result:=3; end
 else begin result:=10; if x <= -3 then result:=11 else result:=12; end;
end;
function tlongint_133(x:longint):longint;
begin
 result:=0;
 if x <> 5 then begin result:=1; if x <= 3 then result:=2 else result:=3; end
 else begin result:=10; if x <= 3 then result:=11 else result:=12; end;
end;
function tlongint_134(x:longint):longint;
begin
 result:=0;
 if x <> 5 then begin result:=1; if x <= 5 then result:=2 else result:=3; end
 else begin result:=10; if x <= 5 then result:=11 else result:=12; end;
end;
function tlongint_135(x:longint):longint;
begin
 result:=0;
 if x <> 5 then begin result:=1; if x <= 7 then result:=2 else result:=3; end
 else begin result:=10; if x <= 7 then result:=11 else result:=12; end;
end;
function tlongint_136(x:longint):longint;
begin
 result:=0;
 if x <> 5 then begin result:=1; if x > -3 then result:=2 else result:=3; end
 else begin result:=10; if x > -3 then result:=11 else result:=12; end;
end;
function tlongint_137(x:longint):longint;
begin
 result:=0;
 if x <> 5 then begin result:=1; if x > 3 then result:=2 else result:=3; end
 else begin result:=10; if x > 3 then result:=11 else result:=12; end;
end;
function tlongint_138(x:longint):longint;
begin
 result:=0;
 if x <> 5 then begin result:=1; if x > 5 then result:=2 else result:=3; end
 else begin result:=10; if x > 5 then result:=11 else result:=12; end;
end;
function tlongint_139(x:longint):longint;
begin
 result:=0;
 if x <> 5 then begin result:=1; if x > 7 then result:=2 else result:=3; end
 else begin result:=10; if x > 7 then result:=11 else result:=12; end;
end;
function tlongint_140(x:longint):longint;
begin
 result:=0;
 if x <> 5 then begin result:=1; if x >= -3 then result:=2 else result:=3; end
 else begin result:=10; if x >= -3 then result:=11 else result:=12; end;
end;
function tlongint_141(x:longint):longint;
begin
 result:=0;
 if x <> 5 then begin result:=1; if x >= 3 then result:=2 else result:=3; end
 else begin result:=10; if x >= 3 then result:=11 else result:=12; end;
end;
function tlongint_142(x:longint):longint;
begin
 result:=0;
 if x <> 5 then begin result:=1; if x >= 5 then result:=2 else result:=3; end
 else begin result:=10; if x >= 5 then result:=11 else result:=12; end;
end;
function tlongint_143(x:longint):longint;
begin
 result:=0;
 if x <> 5 then begin result:=1; if x >= 7 then result:=2 else result:=3; end
 else begin result:=10; if x >= 7 then result:=11 else result:=12; end;
end;
function tlongint_144(x:longint):longint;
begin
 result:=0;
 if x < -3 then begin result:=1; if x = -3 then result:=2 else result:=3; end
 else begin result:=10; if x = -3 then result:=11 else result:=12; end;
end;
function tlongint_145(x:longint):longint;
begin
 result:=0;
 if x < -3 then begin result:=1; if x = 3 then result:=2 else result:=3; end
 else begin result:=10; if x = 3 then result:=11 else result:=12; end;
end;
function tlongint_146(x:longint):longint;
begin
 result:=0;
 if x < -3 then begin result:=1; if x = 5 then result:=2 else result:=3; end
 else begin result:=10; if x = 5 then result:=11 else result:=12; end;
end;
function tlongint_147(x:longint):longint;
begin
 result:=0;
 if x < -3 then begin result:=1; if x = 7 then result:=2 else result:=3; end
 else begin result:=10; if x = 7 then result:=11 else result:=12; end;
end;
function tlongint_148(x:longint):longint;
begin
 result:=0;
 if x < -3 then begin result:=1; if x <> -3 then result:=2 else result:=3; end
 else begin result:=10; if x <> -3 then result:=11 else result:=12; end;
end;
function tlongint_149(x:longint):longint;
begin
 result:=0;
 if x < -3 then begin result:=1; if x <> 3 then result:=2 else result:=3; end
 else begin result:=10; if x <> 3 then result:=11 else result:=12; end;
end;
function tlongint_150(x:longint):longint;
begin
 result:=0;
 if x < -3 then begin result:=1; if x <> 5 then result:=2 else result:=3; end
 else begin result:=10; if x <> 5 then result:=11 else result:=12; end;
end;
function tlongint_151(x:longint):longint;
begin
 result:=0;
 if x < -3 then begin result:=1; if x <> 7 then result:=2 else result:=3; end
 else begin result:=10; if x <> 7 then result:=11 else result:=12; end;
end;
function tlongint_152(x:longint):longint;
begin
 result:=0;
 if x < -3 then begin result:=1; if x < -3 then result:=2 else result:=3; end
 else begin result:=10; if x < -3 then result:=11 else result:=12; end;
end;
function tlongint_153(x:longint):longint;
begin
 result:=0;
 if x < -3 then begin result:=1; if x < 3 then result:=2 else result:=3; end
 else begin result:=10; if x < 3 then result:=11 else result:=12; end;
end;
function tlongint_154(x:longint):longint;
begin
 result:=0;
 if x < -3 then begin result:=1; if x < 5 then result:=2 else result:=3; end
 else begin result:=10; if x < 5 then result:=11 else result:=12; end;
end;
function tlongint_155(x:longint):longint;
begin
 result:=0;
 if x < -3 then begin result:=1; if x < 7 then result:=2 else result:=3; end
 else begin result:=10; if x < 7 then result:=11 else result:=12; end;
end;
function tlongint_156(x:longint):longint;
begin
 result:=0;
 if x < -3 then begin result:=1; if x <= -3 then result:=2 else result:=3; end
 else begin result:=10; if x <= -3 then result:=11 else result:=12; end;
end;
function tlongint_157(x:longint):longint;
begin
 result:=0;
 if x < -3 then begin result:=1; if x <= 3 then result:=2 else result:=3; end
 else begin result:=10; if x <= 3 then result:=11 else result:=12; end;
end;
function tlongint_158(x:longint):longint;
begin
 result:=0;
 if x < -3 then begin result:=1; if x <= 5 then result:=2 else result:=3; end
 else begin result:=10; if x <= 5 then result:=11 else result:=12; end;
end;
function tlongint_159(x:longint):longint;
begin
 result:=0;
 if x < -3 then begin result:=1; if x <= 7 then result:=2 else result:=3; end
 else begin result:=10; if x <= 7 then result:=11 else result:=12; end;
end;
function tlongint_160(x:longint):longint;
begin
 result:=0;
 if x < -3 then begin result:=1; if x > -3 then result:=2 else result:=3; end
 else begin result:=10; if x > -3 then result:=11 else result:=12; end;
end;
function tlongint_161(x:longint):longint;
begin
 result:=0;
 if x < -3 then begin result:=1; if x > 3 then result:=2 else result:=3; end
 else begin result:=10; if x > 3 then result:=11 else result:=12; end;
end;
function tlongint_162(x:longint):longint;
begin
 result:=0;
 if x < -3 then begin result:=1; if x > 5 then result:=2 else result:=3; end
 else begin result:=10; if x > 5 then result:=11 else result:=12; end;
end;
function tlongint_163(x:longint):longint;
begin
 result:=0;
 if x < -3 then begin result:=1; if x > 7 then result:=2 else result:=3; end
 else begin result:=10; if x > 7 then result:=11 else result:=12; end;
end;
function tlongint_164(x:longint):longint;
begin
 result:=0;
 if x < -3 then begin result:=1; if x >= -3 then result:=2 else result:=3; end
 else begin result:=10; if x >= -3 then result:=11 else result:=12; end;
end;
function tlongint_165(x:longint):longint;
begin
 result:=0;
 if x < -3 then begin result:=1; if x >= 3 then result:=2 else result:=3; end
 else begin result:=10; if x >= 3 then result:=11 else result:=12; end;
end;
function tlongint_166(x:longint):longint;
begin
 result:=0;
 if x < -3 then begin result:=1; if x >= 5 then result:=2 else result:=3; end
 else begin result:=10; if x >= 5 then result:=11 else result:=12; end;
end;
function tlongint_167(x:longint):longint;
begin
 result:=0;
 if x < -3 then begin result:=1; if x >= 7 then result:=2 else result:=3; end
 else begin result:=10; if x >= 7 then result:=11 else result:=12; end;
end;
function tlongint_168(x:longint):longint;
begin
 result:=0;
 if x < 0 then begin result:=1; if x = -3 then result:=2 else result:=3; end
 else begin result:=10; if x = -3 then result:=11 else result:=12; end;
end;
function tlongint_169(x:longint):longint;
begin
 result:=0;
 if x < 0 then begin result:=1; if x = 3 then result:=2 else result:=3; end
 else begin result:=10; if x = 3 then result:=11 else result:=12; end;
end;
function tlongint_170(x:longint):longint;
begin
 result:=0;
 if x < 0 then begin result:=1; if x = 5 then result:=2 else result:=3; end
 else begin result:=10; if x = 5 then result:=11 else result:=12; end;
end;
function tlongint_171(x:longint):longint;
begin
 result:=0;
 if x < 0 then begin result:=1; if x = 7 then result:=2 else result:=3; end
 else begin result:=10; if x = 7 then result:=11 else result:=12; end;
end;
function tlongint_172(x:longint):longint;
begin
 result:=0;
 if x < 0 then begin result:=1; if x <> -3 then result:=2 else result:=3; end
 else begin result:=10; if x <> -3 then result:=11 else result:=12; end;
end;
function tlongint_173(x:longint):longint;
begin
 result:=0;
 if x < 0 then begin result:=1; if x <> 3 then result:=2 else result:=3; end
 else begin result:=10; if x <> 3 then result:=11 else result:=12; end;
end;
function tlongint_174(x:longint):longint;
begin
 result:=0;
 if x < 0 then begin result:=1; if x <> 5 then result:=2 else result:=3; end
 else begin result:=10; if x <> 5 then result:=11 else result:=12; end;
end;
function tlongint_175(x:longint):longint;
begin
 result:=0;
 if x < 0 then begin result:=1; if x <> 7 then result:=2 else result:=3; end
 else begin result:=10; if x <> 7 then result:=11 else result:=12; end;
end;
function tlongint_176(x:longint):longint;
begin
 result:=0;
 if x < 0 then begin result:=1; if x < -3 then result:=2 else result:=3; end
 else begin result:=10; if x < -3 then result:=11 else result:=12; end;
end;
function tlongint_177(x:longint):longint;
begin
 result:=0;
 if x < 0 then begin result:=1; if x < 3 then result:=2 else result:=3; end
 else begin result:=10; if x < 3 then result:=11 else result:=12; end;
end;
function tlongint_178(x:longint):longint;
begin
 result:=0;
 if x < 0 then begin result:=1; if x < 5 then result:=2 else result:=3; end
 else begin result:=10; if x < 5 then result:=11 else result:=12; end;
end;
function tlongint_179(x:longint):longint;
begin
 result:=0;
 if x < 0 then begin result:=1; if x < 7 then result:=2 else result:=3; end
 else begin result:=10; if x < 7 then result:=11 else result:=12; end;
end;
function tlongint_180(x:longint):longint;
begin
 result:=0;
 if x < 0 then begin result:=1; if x <= -3 then result:=2 else result:=3; end
 else begin result:=10; if x <= -3 then result:=11 else result:=12; end;
end;
function tlongint_181(x:longint):longint;
begin
 result:=0;
 if x < 0 then begin result:=1; if x <= 3 then result:=2 else result:=3; end
 else begin result:=10; if x <= 3 then result:=11 else result:=12; end;
end;
function tlongint_182(x:longint):longint;
begin
 result:=0;
 if x < 0 then begin result:=1; if x <= 5 then result:=2 else result:=3; end
 else begin result:=10; if x <= 5 then result:=11 else result:=12; end;
end;
function tlongint_183(x:longint):longint;
begin
 result:=0;
 if x < 0 then begin result:=1; if x <= 7 then result:=2 else result:=3; end
 else begin result:=10; if x <= 7 then result:=11 else result:=12; end;
end;
function tlongint_184(x:longint):longint;
begin
 result:=0;
 if x < 0 then begin result:=1; if x > -3 then result:=2 else result:=3; end
 else begin result:=10; if x > -3 then result:=11 else result:=12; end;
end;
function tlongint_185(x:longint):longint;
begin
 result:=0;
 if x < 0 then begin result:=1; if x > 3 then result:=2 else result:=3; end
 else begin result:=10; if x > 3 then result:=11 else result:=12; end;
end;
function tlongint_186(x:longint):longint;
begin
 result:=0;
 if x < 0 then begin result:=1; if x > 5 then result:=2 else result:=3; end
 else begin result:=10; if x > 5 then result:=11 else result:=12; end;
end;
function tlongint_187(x:longint):longint;
begin
 result:=0;
 if x < 0 then begin result:=1; if x > 7 then result:=2 else result:=3; end
 else begin result:=10; if x > 7 then result:=11 else result:=12; end;
end;
function tlongint_188(x:longint):longint;
begin
 result:=0;
 if x < 0 then begin result:=1; if x >= -3 then result:=2 else result:=3; end
 else begin result:=10; if x >= -3 then result:=11 else result:=12; end;
end;
function tlongint_189(x:longint):longint;
begin
 result:=0;
 if x < 0 then begin result:=1; if x >= 3 then result:=2 else result:=3; end
 else begin result:=10; if x >= 3 then result:=11 else result:=12; end;
end;
function tlongint_190(x:longint):longint;
begin
 result:=0;
 if x < 0 then begin result:=1; if x >= 5 then result:=2 else result:=3; end
 else begin result:=10; if x >= 5 then result:=11 else result:=12; end;
end;
function tlongint_191(x:longint):longint;
begin
 result:=0;
 if x < 0 then begin result:=1; if x >= 7 then result:=2 else result:=3; end
 else begin result:=10; if x >= 7 then result:=11 else result:=12; end;
end;
function tlongint_192(x:longint):longint;
begin
 result:=0;
 if x < 5 then begin result:=1; if x = -3 then result:=2 else result:=3; end
 else begin result:=10; if x = -3 then result:=11 else result:=12; end;
end;
function tlongint_193(x:longint):longint;
begin
 result:=0;
 if x < 5 then begin result:=1; if x = 3 then result:=2 else result:=3; end
 else begin result:=10; if x = 3 then result:=11 else result:=12; end;
end;
function tlongint_194(x:longint):longint;
begin
 result:=0;
 if x < 5 then begin result:=1; if x = 5 then result:=2 else result:=3; end
 else begin result:=10; if x = 5 then result:=11 else result:=12; end;
end;
function tlongint_195(x:longint):longint;
begin
 result:=0;
 if x < 5 then begin result:=1; if x = 7 then result:=2 else result:=3; end
 else begin result:=10; if x = 7 then result:=11 else result:=12; end;
end;
function tlongint_196(x:longint):longint;
begin
 result:=0;
 if x < 5 then begin result:=1; if x <> -3 then result:=2 else result:=3; end
 else begin result:=10; if x <> -3 then result:=11 else result:=12; end;
end;
function tlongint_197(x:longint):longint;
begin
 result:=0;
 if x < 5 then begin result:=1; if x <> 3 then result:=2 else result:=3; end
 else begin result:=10; if x <> 3 then result:=11 else result:=12; end;
end;
function tlongint_198(x:longint):longint;
begin
 result:=0;
 if x < 5 then begin result:=1; if x <> 5 then result:=2 else result:=3; end
 else begin result:=10; if x <> 5 then result:=11 else result:=12; end;
end;
function tlongint_199(x:longint):longint;
begin
 result:=0;
 if x < 5 then begin result:=1; if x <> 7 then result:=2 else result:=3; end
 else begin result:=10; if x <> 7 then result:=11 else result:=12; end;
end;
function tlongint_200(x:longint):longint;
begin
 result:=0;
 if x < 5 then begin result:=1; if x < -3 then result:=2 else result:=3; end
 else begin result:=10; if x < -3 then result:=11 else result:=12; end;
end;
function tlongint_201(x:longint):longint;
begin
 result:=0;
 if x < 5 then begin result:=1; if x < 3 then result:=2 else result:=3; end
 else begin result:=10; if x < 3 then result:=11 else result:=12; end;
end;
function tlongint_202(x:longint):longint;
begin
 result:=0;
 if x < 5 then begin result:=1; if x < 5 then result:=2 else result:=3; end
 else begin result:=10; if x < 5 then result:=11 else result:=12; end;
end;
function tlongint_203(x:longint):longint;
begin
 result:=0;
 if x < 5 then begin result:=1; if x < 7 then result:=2 else result:=3; end
 else begin result:=10; if x < 7 then result:=11 else result:=12; end;
end;
function tlongint_204(x:longint):longint;
begin
 result:=0;
 if x < 5 then begin result:=1; if x <= -3 then result:=2 else result:=3; end
 else begin result:=10; if x <= -3 then result:=11 else result:=12; end;
end;
function tlongint_205(x:longint):longint;
begin
 result:=0;
 if x < 5 then begin result:=1; if x <= 3 then result:=2 else result:=3; end
 else begin result:=10; if x <= 3 then result:=11 else result:=12; end;
end;
function tlongint_206(x:longint):longint;
begin
 result:=0;
 if x < 5 then begin result:=1; if x <= 5 then result:=2 else result:=3; end
 else begin result:=10; if x <= 5 then result:=11 else result:=12; end;
end;
function tlongint_207(x:longint):longint;
begin
 result:=0;
 if x < 5 then begin result:=1; if x <= 7 then result:=2 else result:=3; end
 else begin result:=10; if x <= 7 then result:=11 else result:=12; end;
end;
function tlongint_208(x:longint):longint;
begin
 result:=0;
 if x < 5 then begin result:=1; if x > -3 then result:=2 else result:=3; end
 else begin result:=10; if x > -3 then result:=11 else result:=12; end;
end;
function tlongint_209(x:longint):longint;
begin
 result:=0;
 if x < 5 then begin result:=1; if x > 3 then result:=2 else result:=3; end
 else begin result:=10; if x > 3 then result:=11 else result:=12; end;
end;
function tlongint_210(x:longint):longint;
begin
 result:=0;
 if x < 5 then begin result:=1; if x > 5 then result:=2 else result:=3; end
 else begin result:=10; if x > 5 then result:=11 else result:=12; end;
end;
function tlongint_211(x:longint):longint;
begin
 result:=0;
 if x < 5 then begin result:=1; if x > 7 then result:=2 else result:=3; end
 else begin result:=10; if x > 7 then result:=11 else result:=12; end;
end;
function tlongint_212(x:longint):longint;
begin
 result:=0;
 if x < 5 then begin result:=1; if x >= -3 then result:=2 else result:=3; end
 else begin result:=10; if x >= -3 then result:=11 else result:=12; end;
end;
function tlongint_213(x:longint):longint;
begin
 result:=0;
 if x < 5 then begin result:=1; if x >= 3 then result:=2 else result:=3; end
 else begin result:=10; if x >= 3 then result:=11 else result:=12; end;
end;
function tlongint_214(x:longint):longint;
begin
 result:=0;
 if x < 5 then begin result:=1; if x >= 5 then result:=2 else result:=3; end
 else begin result:=10; if x >= 5 then result:=11 else result:=12; end;
end;
function tlongint_215(x:longint):longint;
begin
 result:=0;
 if x < 5 then begin result:=1; if x >= 7 then result:=2 else result:=3; end
 else begin result:=10; if x >= 7 then result:=11 else result:=12; end;
end;
function tlongint_216(x:longint):longint;
begin
 result:=0;
 if x <= -3 then begin result:=1; if x = -3 then result:=2 else result:=3; end
 else begin result:=10; if x = -3 then result:=11 else result:=12; end;
end;
function tlongint_217(x:longint):longint;
begin
 result:=0;
 if x <= -3 then begin result:=1; if x = 3 then result:=2 else result:=3; end
 else begin result:=10; if x = 3 then result:=11 else result:=12; end;
end;
function tlongint_218(x:longint):longint;
begin
 result:=0;
 if x <= -3 then begin result:=1; if x = 5 then result:=2 else result:=3; end
 else begin result:=10; if x = 5 then result:=11 else result:=12; end;
end;
function tlongint_219(x:longint):longint;
begin
 result:=0;
 if x <= -3 then begin result:=1; if x = 7 then result:=2 else result:=3; end
 else begin result:=10; if x = 7 then result:=11 else result:=12; end;
end;
function tlongint_220(x:longint):longint;
begin
 result:=0;
 if x <= -3 then begin result:=1; if x <> -3 then result:=2 else result:=3; end
 else begin result:=10; if x <> -3 then result:=11 else result:=12; end;
end;
function tlongint_221(x:longint):longint;
begin
 result:=0;
 if x <= -3 then begin result:=1; if x <> 3 then result:=2 else result:=3; end
 else begin result:=10; if x <> 3 then result:=11 else result:=12; end;
end;
function tlongint_222(x:longint):longint;
begin
 result:=0;
 if x <= -3 then begin result:=1; if x <> 5 then result:=2 else result:=3; end
 else begin result:=10; if x <> 5 then result:=11 else result:=12; end;
end;
function tlongint_223(x:longint):longint;
begin
 result:=0;
 if x <= -3 then begin result:=1; if x <> 7 then result:=2 else result:=3; end
 else begin result:=10; if x <> 7 then result:=11 else result:=12; end;
end;
function tlongint_224(x:longint):longint;
begin
 result:=0;
 if x <= -3 then begin result:=1; if x < -3 then result:=2 else result:=3; end
 else begin result:=10; if x < -3 then result:=11 else result:=12; end;
end;
function tlongint_225(x:longint):longint;
begin
 result:=0;
 if x <= -3 then begin result:=1; if x < 3 then result:=2 else result:=3; end
 else begin result:=10; if x < 3 then result:=11 else result:=12; end;
end;
function tlongint_226(x:longint):longint;
begin
 result:=0;
 if x <= -3 then begin result:=1; if x < 5 then result:=2 else result:=3; end
 else begin result:=10; if x < 5 then result:=11 else result:=12; end;
end;
function tlongint_227(x:longint):longint;
begin
 result:=0;
 if x <= -3 then begin result:=1; if x < 7 then result:=2 else result:=3; end
 else begin result:=10; if x < 7 then result:=11 else result:=12; end;
end;
function tlongint_228(x:longint):longint;
begin
 result:=0;
 if x <= -3 then begin result:=1; if x <= -3 then result:=2 else result:=3; end
 else begin result:=10; if x <= -3 then result:=11 else result:=12; end;
end;
function tlongint_229(x:longint):longint;
begin
 result:=0;
 if x <= -3 then begin result:=1; if x <= 3 then result:=2 else result:=3; end
 else begin result:=10; if x <= 3 then result:=11 else result:=12; end;
end;
function tlongint_230(x:longint):longint;
begin
 result:=0;
 if x <= -3 then begin result:=1; if x <= 5 then result:=2 else result:=3; end
 else begin result:=10; if x <= 5 then result:=11 else result:=12; end;
end;
function tlongint_231(x:longint):longint;
begin
 result:=0;
 if x <= -3 then begin result:=1; if x <= 7 then result:=2 else result:=3; end
 else begin result:=10; if x <= 7 then result:=11 else result:=12; end;
end;
function tlongint_232(x:longint):longint;
begin
 result:=0;
 if x <= -3 then begin result:=1; if x > -3 then result:=2 else result:=3; end
 else begin result:=10; if x > -3 then result:=11 else result:=12; end;
end;
function tlongint_233(x:longint):longint;
begin
 result:=0;
 if x <= -3 then begin result:=1; if x > 3 then result:=2 else result:=3; end
 else begin result:=10; if x > 3 then result:=11 else result:=12; end;
end;
function tlongint_234(x:longint):longint;
begin
 result:=0;
 if x <= -3 then begin result:=1; if x > 5 then result:=2 else result:=3; end
 else begin result:=10; if x > 5 then result:=11 else result:=12; end;
end;
function tlongint_235(x:longint):longint;
begin
 result:=0;
 if x <= -3 then begin result:=1; if x > 7 then result:=2 else result:=3; end
 else begin result:=10; if x > 7 then result:=11 else result:=12; end;
end;
function tlongint_236(x:longint):longint;
begin
 result:=0;
 if x <= -3 then begin result:=1; if x >= -3 then result:=2 else result:=3; end
 else begin result:=10; if x >= -3 then result:=11 else result:=12; end;
end;
function tlongint_237(x:longint):longint;
begin
 result:=0;
 if x <= -3 then begin result:=1; if x >= 3 then result:=2 else result:=3; end
 else begin result:=10; if x >= 3 then result:=11 else result:=12; end;
end;
function tlongint_238(x:longint):longint;
begin
 result:=0;
 if x <= -3 then begin result:=1; if x >= 5 then result:=2 else result:=3; end
 else begin result:=10; if x >= 5 then result:=11 else result:=12; end;
end;
function tlongint_239(x:longint):longint;
begin
 result:=0;
 if x <= -3 then begin result:=1; if x >= 7 then result:=2 else result:=3; end
 else begin result:=10; if x >= 7 then result:=11 else result:=12; end;
end;
function tlongint_240(x:longint):longint;
begin
 result:=0;
 if x <= 0 then begin result:=1; if x = -3 then result:=2 else result:=3; end
 else begin result:=10; if x = -3 then result:=11 else result:=12; end;
end;
function tlongint_241(x:longint):longint;
begin
 result:=0;
 if x <= 0 then begin result:=1; if x = 3 then result:=2 else result:=3; end
 else begin result:=10; if x = 3 then result:=11 else result:=12; end;
end;
function tlongint_242(x:longint):longint;
begin
 result:=0;
 if x <= 0 then begin result:=1; if x = 5 then result:=2 else result:=3; end
 else begin result:=10; if x = 5 then result:=11 else result:=12; end;
end;
function tlongint_243(x:longint):longint;
begin
 result:=0;
 if x <= 0 then begin result:=1; if x = 7 then result:=2 else result:=3; end
 else begin result:=10; if x = 7 then result:=11 else result:=12; end;
end;
function tlongint_244(x:longint):longint;
begin
 result:=0;
 if x <= 0 then begin result:=1; if x <> -3 then result:=2 else result:=3; end
 else begin result:=10; if x <> -3 then result:=11 else result:=12; end;
end;
function tlongint_245(x:longint):longint;
begin
 result:=0;
 if x <= 0 then begin result:=1; if x <> 3 then result:=2 else result:=3; end
 else begin result:=10; if x <> 3 then result:=11 else result:=12; end;
end;
function tlongint_246(x:longint):longint;
begin
 result:=0;
 if x <= 0 then begin result:=1; if x <> 5 then result:=2 else result:=3; end
 else begin result:=10; if x <> 5 then result:=11 else result:=12; end;
end;
function tlongint_247(x:longint):longint;
begin
 result:=0;
 if x <= 0 then begin result:=1; if x <> 7 then result:=2 else result:=3; end
 else begin result:=10; if x <> 7 then result:=11 else result:=12; end;
end;
function tlongint_248(x:longint):longint;
begin
 result:=0;
 if x <= 0 then begin result:=1; if x < -3 then result:=2 else result:=3; end
 else begin result:=10; if x < -3 then result:=11 else result:=12; end;
end;
function tlongint_249(x:longint):longint;
begin
 result:=0;
 if x <= 0 then begin result:=1; if x < 3 then result:=2 else result:=3; end
 else begin result:=10; if x < 3 then result:=11 else result:=12; end;
end;
function tlongint_250(x:longint):longint;
begin
 result:=0;
 if x <= 0 then begin result:=1; if x < 5 then result:=2 else result:=3; end
 else begin result:=10; if x < 5 then result:=11 else result:=12; end;
end;
function tlongint_251(x:longint):longint;
begin
 result:=0;
 if x <= 0 then begin result:=1; if x < 7 then result:=2 else result:=3; end
 else begin result:=10; if x < 7 then result:=11 else result:=12; end;
end;
function tlongint_252(x:longint):longint;
begin
 result:=0;
 if x <= 0 then begin result:=1; if x <= -3 then result:=2 else result:=3; end
 else begin result:=10; if x <= -3 then result:=11 else result:=12; end;
end;
function tlongint_253(x:longint):longint;
begin
 result:=0;
 if x <= 0 then begin result:=1; if x <= 3 then result:=2 else result:=3; end
 else begin result:=10; if x <= 3 then result:=11 else result:=12; end;
end;
function tlongint_254(x:longint):longint;
begin
 result:=0;
 if x <= 0 then begin result:=1; if x <= 5 then result:=2 else result:=3; end
 else begin result:=10; if x <= 5 then result:=11 else result:=12; end;
end;
function tlongint_255(x:longint):longint;
begin
 result:=0;
 if x <= 0 then begin result:=1; if x <= 7 then result:=2 else result:=3; end
 else begin result:=10; if x <= 7 then result:=11 else result:=12; end;
end;
function tlongint_256(x:longint):longint;
begin
 result:=0;
 if x <= 0 then begin result:=1; if x > -3 then result:=2 else result:=3; end
 else begin result:=10; if x > -3 then result:=11 else result:=12; end;
end;
function tlongint_257(x:longint):longint;
begin
 result:=0;
 if x <= 0 then begin result:=1; if x > 3 then result:=2 else result:=3; end
 else begin result:=10; if x > 3 then result:=11 else result:=12; end;
end;
function tlongint_258(x:longint):longint;
begin
 result:=0;
 if x <= 0 then begin result:=1; if x > 5 then result:=2 else result:=3; end
 else begin result:=10; if x > 5 then result:=11 else result:=12; end;
end;
function tlongint_259(x:longint):longint;
begin
 result:=0;
 if x <= 0 then begin result:=1; if x > 7 then result:=2 else result:=3; end
 else begin result:=10; if x > 7 then result:=11 else result:=12; end;
end;
function tlongint_260(x:longint):longint;
begin
 result:=0;
 if x <= 0 then begin result:=1; if x >= -3 then result:=2 else result:=3; end
 else begin result:=10; if x >= -3 then result:=11 else result:=12; end;
end;
function tlongint_261(x:longint):longint;
begin
 result:=0;
 if x <= 0 then begin result:=1; if x >= 3 then result:=2 else result:=3; end
 else begin result:=10; if x >= 3 then result:=11 else result:=12; end;
end;
function tlongint_262(x:longint):longint;
begin
 result:=0;
 if x <= 0 then begin result:=1; if x >= 5 then result:=2 else result:=3; end
 else begin result:=10; if x >= 5 then result:=11 else result:=12; end;
end;
function tlongint_263(x:longint):longint;
begin
 result:=0;
 if x <= 0 then begin result:=1; if x >= 7 then result:=2 else result:=3; end
 else begin result:=10; if x >= 7 then result:=11 else result:=12; end;
end;
function tlongint_264(x:longint):longint;
begin
 result:=0;
 if x <= 5 then begin result:=1; if x = -3 then result:=2 else result:=3; end
 else begin result:=10; if x = -3 then result:=11 else result:=12; end;
end;
function tlongint_265(x:longint):longint;
begin
 result:=0;
 if x <= 5 then begin result:=1; if x = 3 then result:=2 else result:=3; end
 else begin result:=10; if x = 3 then result:=11 else result:=12; end;
end;
function tlongint_266(x:longint):longint;
begin
 result:=0;
 if x <= 5 then begin result:=1; if x = 5 then result:=2 else result:=3; end
 else begin result:=10; if x = 5 then result:=11 else result:=12; end;
end;
function tlongint_267(x:longint):longint;
begin
 result:=0;
 if x <= 5 then begin result:=1; if x = 7 then result:=2 else result:=3; end
 else begin result:=10; if x = 7 then result:=11 else result:=12; end;
end;
function tlongint_268(x:longint):longint;
begin
 result:=0;
 if x <= 5 then begin result:=1; if x <> -3 then result:=2 else result:=3; end
 else begin result:=10; if x <> -3 then result:=11 else result:=12; end;
end;
function tlongint_269(x:longint):longint;
begin
 result:=0;
 if x <= 5 then begin result:=1; if x <> 3 then result:=2 else result:=3; end
 else begin result:=10; if x <> 3 then result:=11 else result:=12; end;
end;
function tlongint_270(x:longint):longint;
begin
 result:=0;
 if x <= 5 then begin result:=1; if x <> 5 then result:=2 else result:=3; end
 else begin result:=10; if x <> 5 then result:=11 else result:=12; end;
end;
function tlongint_271(x:longint):longint;
begin
 result:=0;
 if x <= 5 then begin result:=1; if x <> 7 then result:=2 else result:=3; end
 else begin result:=10; if x <> 7 then result:=11 else result:=12; end;
end;
function tlongint_272(x:longint):longint;
begin
 result:=0;
 if x <= 5 then begin result:=1; if x < -3 then result:=2 else result:=3; end
 else begin result:=10; if x < -3 then result:=11 else result:=12; end;
end;
function tlongint_273(x:longint):longint;
begin
 result:=0;
 if x <= 5 then begin result:=1; if x < 3 then result:=2 else result:=3; end
 else begin result:=10; if x < 3 then result:=11 else result:=12; end;
end;
function tlongint_274(x:longint):longint;
begin
 result:=0;
 if x <= 5 then begin result:=1; if x < 5 then result:=2 else result:=3; end
 else begin result:=10; if x < 5 then result:=11 else result:=12; end;
end;
function tlongint_275(x:longint):longint;
begin
 result:=0;
 if x <= 5 then begin result:=1; if x < 7 then result:=2 else result:=3; end
 else begin result:=10; if x < 7 then result:=11 else result:=12; end;
end;
function tlongint_276(x:longint):longint;
begin
 result:=0;
 if x <= 5 then begin result:=1; if x <= -3 then result:=2 else result:=3; end
 else begin result:=10; if x <= -3 then result:=11 else result:=12; end;
end;
function tlongint_277(x:longint):longint;
begin
 result:=0;
 if x <= 5 then begin result:=1; if x <= 3 then result:=2 else result:=3; end
 else begin result:=10; if x <= 3 then result:=11 else result:=12; end;
end;
function tlongint_278(x:longint):longint;
begin
 result:=0;
 if x <= 5 then begin result:=1; if x <= 5 then result:=2 else result:=3; end
 else begin result:=10; if x <= 5 then result:=11 else result:=12; end;
end;
function tlongint_279(x:longint):longint;
begin
 result:=0;
 if x <= 5 then begin result:=1; if x <= 7 then result:=2 else result:=3; end
 else begin result:=10; if x <= 7 then result:=11 else result:=12; end;
end;
function tlongint_280(x:longint):longint;
begin
 result:=0;
 if x <= 5 then begin result:=1; if x > -3 then result:=2 else result:=3; end
 else begin result:=10; if x > -3 then result:=11 else result:=12; end;
end;
function tlongint_281(x:longint):longint;
begin
 result:=0;
 if x <= 5 then begin result:=1; if x > 3 then result:=2 else result:=3; end
 else begin result:=10; if x > 3 then result:=11 else result:=12; end;
end;
function tlongint_282(x:longint):longint;
begin
 result:=0;
 if x <= 5 then begin result:=1; if x > 5 then result:=2 else result:=3; end
 else begin result:=10; if x > 5 then result:=11 else result:=12; end;
end;
function tlongint_283(x:longint):longint;
begin
 result:=0;
 if x <= 5 then begin result:=1; if x > 7 then result:=2 else result:=3; end
 else begin result:=10; if x > 7 then result:=11 else result:=12; end;
end;
function tlongint_284(x:longint):longint;
begin
 result:=0;
 if x <= 5 then begin result:=1; if x >= -3 then result:=2 else result:=3; end
 else begin result:=10; if x >= -3 then result:=11 else result:=12; end;
end;
function tlongint_285(x:longint):longint;
begin
 result:=0;
 if x <= 5 then begin result:=1; if x >= 3 then result:=2 else result:=3; end
 else begin result:=10; if x >= 3 then result:=11 else result:=12; end;
end;
function tlongint_286(x:longint):longint;
begin
 result:=0;
 if x <= 5 then begin result:=1; if x >= 5 then result:=2 else result:=3; end
 else begin result:=10; if x >= 5 then result:=11 else result:=12; end;
end;
function tlongint_287(x:longint):longint;
begin
 result:=0;
 if x <= 5 then begin result:=1; if x >= 7 then result:=2 else result:=3; end
 else begin result:=10; if x >= 7 then result:=11 else result:=12; end;
end;
function tlongint_288(x:longint):longint;
begin
 result:=0;
 if x > -3 then begin result:=1; if x = -3 then result:=2 else result:=3; end
 else begin result:=10; if x = -3 then result:=11 else result:=12; end;
end;
function tlongint_289(x:longint):longint;
begin
 result:=0;
 if x > -3 then begin result:=1; if x = 3 then result:=2 else result:=3; end
 else begin result:=10; if x = 3 then result:=11 else result:=12; end;
end;
function tlongint_290(x:longint):longint;
begin
 result:=0;
 if x > -3 then begin result:=1; if x = 5 then result:=2 else result:=3; end
 else begin result:=10; if x = 5 then result:=11 else result:=12; end;
end;
function tlongint_291(x:longint):longint;
begin
 result:=0;
 if x > -3 then begin result:=1; if x = 7 then result:=2 else result:=3; end
 else begin result:=10; if x = 7 then result:=11 else result:=12; end;
end;
function tlongint_292(x:longint):longint;
begin
 result:=0;
 if x > -3 then begin result:=1; if x <> -3 then result:=2 else result:=3; end
 else begin result:=10; if x <> -3 then result:=11 else result:=12; end;
end;
function tlongint_293(x:longint):longint;
begin
 result:=0;
 if x > -3 then begin result:=1; if x <> 3 then result:=2 else result:=3; end
 else begin result:=10; if x <> 3 then result:=11 else result:=12; end;
end;
function tlongint_294(x:longint):longint;
begin
 result:=0;
 if x > -3 then begin result:=1; if x <> 5 then result:=2 else result:=3; end
 else begin result:=10; if x <> 5 then result:=11 else result:=12; end;
end;
function tlongint_295(x:longint):longint;
begin
 result:=0;
 if x > -3 then begin result:=1; if x <> 7 then result:=2 else result:=3; end
 else begin result:=10; if x <> 7 then result:=11 else result:=12; end;
end;
function tlongint_296(x:longint):longint;
begin
 result:=0;
 if x > -3 then begin result:=1; if x < -3 then result:=2 else result:=3; end
 else begin result:=10; if x < -3 then result:=11 else result:=12; end;
end;
function tlongint_297(x:longint):longint;
begin
 result:=0;
 if x > -3 then begin result:=1; if x < 3 then result:=2 else result:=3; end
 else begin result:=10; if x < 3 then result:=11 else result:=12; end;
end;
function tlongint_298(x:longint):longint;
begin
 result:=0;
 if x > -3 then begin result:=1; if x < 5 then result:=2 else result:=3; end
 else begin result:=10; if x < 5 then result:=11 else result:=12; end;
end;
function tlongint_299(x:longint):longint;
begin
 result:=0;
 if x > -3 then begin result:=1; if x < 7 then result:=2 else result:=3; end
 else begin result:=10; if x < 7 then result:=11 else result:=12; end;
end;
function tlongint_300(x:longint):longint;
begin
 result:=0;
 if x > -3 then begin result:=1; if x <= -3 then result:=2 else result:=3; end
 else begin result:=10; if x <= -3 then result:=11 else result:=12; end;
end;
function tlongint_301(x:longint):longint;
begin
 result:=0;
 if x > -3 then begin result:=1; if x <= 3 then result:=2 else result:=3; end
 else begin result:=10; if x <= 3 then result:=11 else result:=12; end;
end;
function tlongint_302(x:longint):longint;
begin
 result:=0;
 if x > -3 then begin result:=1; if x <= 5 then result:=2 else result:=3; end
 else begin result:=10; if x <= 5 then result:=11 else result:=12; end;
end;
function tlongint_303(x:longint):longint;
begin
 result:=0;
 if x > -3 then begin result:=1; if x <= 7 then result:=2 else result:=3; end
 else begin result:=10; if x <= 7 then result:=11 else result:=12; end;
end;
function tlongint_304(x:longint):longint;
begin
 result:=0;
 if x > -3 then begin result:=1; if x > -3 then result:=2 else result:=3; end
 else begin result:=10; if x > -3 then result:=11 else result:=12; end;
end;
function tlongint_305(x:longint):longint;
begin
 result:=0;
 if x > -3 then begin result:=1; if x > 3 then result:=2 else result:=3; end
 else begin result:=10; if x > 3 then result:=11 else result:=12; end;
end;
function tlongint_306(x:longint):longint;
begin
 result:=0;
 if x > -3 then begin result:=1; if x > 5 then result:=2 else result:=3; end
 else begin result:=10; if x > 5 then result:=11 else result:=12; end;
end;
function tlongint_307(x:longint):longint;
begin
 result:=0;
 if x > -3 then begin result:=1; if x > 7 then result:=2 else result:=3; end
 else begin result:=10; if x > 7 then result:=11 else result:=12; end;
end;
function tlongint_308(x:longint):longint;
begin
 result:=0;
 if x > -3 then begin result:=1; if x >= -3 then result:=2 else result:=3; end
 else begin result:=10; if x >= -3 then result:=11 else result:=12; end;
end;
function tlongint_309(x:longint):longint;
begin
 result:=0;
 if x > -3 then begin result:=1; if x >= 3 then result:=2 else result:=3; end
 else begin result:=10; if x >= 3 then result:=11 else result:=12; end;
end;
function tlongint_310(x:longint):longint;
begin
 result:=0;
 if x > -3 then begin result:=1; if x >= 5 then result:=2 else result:=3; end
 else begin result:=10; if x >= 5 then result:=11 else result:=12; end;
end;
function tlongint_311(x:longint):longint;
begin
 result:=0;
 if x > -3 then begin result:=1; if x >= 7 then result:=2 else result:=3; end
 else begin result:=10; if x >= 7 then result:=11 else result:=12; end;
end;
function tlongint_312(x:longint):longint;
begin
 result:=0;
 if x > 0 then begin result:=1; if x = -3 then result:=2 else result:=3; end
 else begin result:=10; if x = -3 then result:=11 else result:=12; end;
end;
function tlongint_313(x:longint):longint;
begin
 result:=0;
 if x > 0 then begin result:=1; if x = 3 then result:=2 else result:=3; end
 else begin result:=10; if x = 3 then result:=11 else result:=12; end;
end;
function tlongint_314(x:longint):longint;
begin
 result:=0;
 if x > 0 then begin result:=1; if x = 5 then result:=2 else result:=3; end
 else begin result:=10; if x = 5 then result:=11 else result:=12; end;
end;
function tlongint_315(x:longint):longint;
begin
 result:=0;
 if x > 0 then begin result:=1; if x = 7 then result:=2 else result:=3; end
 else begin result:=10; if x = 7 then result:=11 else result:=12; end;
end;
function tlongint_316(x:longint):longint;
begin
 result:=0;
 if x > 0 then begin result:=1; if x <> -3 then result:=2 else result:=3; end
 else begin result:=10; if x <> -3 then result:=11 else result:=12; end;
end;
function tlongint_317(x:longint):longint;
begin
 result:=0;
 if x > 0 then begin result:=1; if x <> 3 then result:=2 else result:=3; end
 else begin result:=10; if x <> 3 then result:=11 else result:=12; end;
end;
function tlongint_318(x:longint):longint;
begin
 result:=0;
 if x > 0 then begin result:=1; if x <> 5 then result:=2 else result:=3; end
 else begin result:=10; if x <> 5 then result:=11 else result:=12; end;
end;
function tlongint_319(x:longint):longint;
begin
 result:=0;
 if x > 0 then begin result:=1; if x <> 7 then result:=2 else result:=3; end
 else begin result:=10; if x <> 7 then result:=11 else result:=12; end;
end;
function tlongint_320(x:longint):longint;
begin
 result:=0;
 if x > 0 then begin result:=1; if x < -3 then result:=2 else result:=3; end
 else begin result:=10; if x < -3 then result:=11 else result:=12; end;
end;
function tlongint_321(x:longint):longint;
begin
 result:=0;
 if x > 0 then begin result:=1; if x < 3 then result:=2 else result:=3; end
 else begin result:=10; if x < 3 then result:=11 else result:=12; end;
end;
function tlongint_322(x:longint):longint;
begin
 result:=0;
 if x > 0 then begin result:=1; if x < 5 then result:=2 else result:=3; end
 else begin result:=10; if x < 5 then result:=11 else result:=12; end;
end;
function tlongint_323(x:longint):longint;
begin
 result:=0;
 if x > 0 then begin result:=1; if x < 7 then result:=2 else result:=3; end
 else begin result:=10; if x < 7 then result:=11 else result:=12; end;
end;
function tlongint_324(x:longint):longint;
begin
 result:=0;
 if x > 0 then begin result:=1; if x <= -3 then result:=2 else result:=3; end
 else begin result:=10; if x <= -3 then result:=11 else result:=12; end;
end;
function tlongint_325(x:longint):longint;
begin
 result:=0;
 if x > 0 then begin result:=1; if x <= 3 then result:=2 else result:=3; end
 else begin result:=10; if x <= 3 then result:=11 else result:=12; end;
end;
function tlongint_326(x:longint):longint;
begin
 result:=0;
 if x > 0 then begin result:=1; if x <= 5 then result:=2 else result:=3; end
 else begin result:=10; if x <= 5 then result:=11 else result:=12; end;
end;
function tlongint_327(x:longint):longint;
begin
 result:=0;
 if x > 0 then begin result:=1; if x <= 7 then result:=2 else result:=3; end
 else begin result:=10; if x <= 7 then result:=11 else result:=12; end;
end;
function tlongint_328(x:longint):longint;
begin
 result:=0;
 if x > 0 then begin result:=1; if x > -3 then result:=2 else result:=3; end
 else begin result:=10; if x > -3 then result:=11 else result:=12; end;
end;
function tlongint_329(x:longint):longint;
begin
 result:=0;
 if x > 0 then begin result:=1; if x > 3 then result:=2 else result:=3; end
 else begin result:=10; if x > 3 then result:=11 else result:=12; end;
end;
function tlongint_330(x:longint):longint;
begin
 result:=0;
 if x > 0 then begin result:=1; if x > 5 then result:=2 else result:=3; end
 else begin result:=10; if x > 5 then result:=11 else result:=12; end;
end;
function tlongint_331(x:longint):longint;
begin
 result:=0;
 if x > 0 then begin result:=1; if x > 7 then result:=2 else result:=3; end
 else begin result:=10; if x > 7 then result:=11 else result:=12; end;
end;
function tlongint_332(x:longint):longint;
begin
 result:=0;
 if x > 0 then begin result:=1; if x >= -3 then result:=2 else result:=3; end
 else begin result:=10; if x >= -3 then result:=11 else result:=12; end;
end;
function tlongint_333(x:longint):longint;
begin
 result:=0;
 if x > 0 then begin result:=1; if x >= 3 then result:=2 else result:=3; end
 else begin result:=10; if x >= 3 then result:=11 else result:=12; end;
end;
function tlongint_334(x:longint):longint;
begin
 result:=0;
 if x > 0 then begin result:=1; if x >= 5 then result:=2 else result:=3; end
 else begin result:=10; if x >= 5 then result:=11 else result:=12; end;
end;
function tlongint_335(x:longint):longint;
begin
 result:=0;
 if x > 0 then begin result:=1; if x >= 7 then result:=2 else result:=3; end
 else begin result:=10; if x >= 7 then result:=11 else result:=12; end;
end;
function tlongint_336(x:longint):longint;
begin
 result:=0;
 if x > 5 then begin result:=1; if x = -3 then result:=2 else result:=3; end
 else begin result:=10; if x = -3 then result:=11 else result:=12; end;
end;
function tlongint_337(x:longint):longint;
begin
 result:=0;
 if x > 5 then begin result:=1; if x = 3 then result:=2 else result:=3; end
 else begin result:=10; if x = 3 then result:=11 else result:=12; end;
end;
function tlongint_338(x:longint):longint;
begin
 result:=0;
 if x > 5 then begin result:=1; if x = 5 then result:=2 else result:=3; end
 else begin result:=10; if x = 5 then result:=11 else result:=12; end;
end;
function tlongint_339(x:longint):longint;
begin
 result:=0;
 if x > 5 then begin result:=1; if x = 7 then result:=2 else result:=3; end
 else begin result:=10; if x = 7 then result:=11 else result:=12; end;
end;
function tlongint_340(x:longint):longint;
begin
 result:=0;
 if x > 5 then begin result:=1; if x <> -3 then result:=2 else result:=3; end
 else begin result:=10; if x <> -3 then result:=11 else result:=12; end;
end;
function tlongint_341(x:longint):longint;
begin
 result:=0;
 if x > 5 then begin result:=1; if x <> 3 then result:=2 else result:=3; end
 else begin result:=10; if x <> 3 then result:=11 else result:=12; end;
end;
function tlongint_342(x:longint):longint;
begin
 result:=0;
 if x > 5 then begin result:=1; if x <> 5 then result:=2 else result:=3; end
 else begin result:=10; if x <> 5 then result:=11 else result:=12; end;
end;
function tlongint_343(x:longint):longint;
begin
 result:=0;
 if x > 5 then begin result:=1; if x <> 7 then result:=2 else result:=3; end
 else begin result:=10; if x <> 7 then result:=11 else result:=12; end;
end;
function tlongint_344(x:longint):longint;
begin
 result:=0;
 if x > 5 then begin result:=1; if x < -3 then result:=2 else result:=3; end
 else begin result:=10; if x < -3 then result:=11 else result:=12; end;
end;
function tlongint_345(x:longint):longint;
begin
 result:=0;
 if x > 5 then begin result:=1; if x < 3 then result:=2 else result:=3; end
 else begin result:=10; if x < 3 then result:=11 else result:=12; end;
end;
function tlongint_346(x:longint):longint;
begin
 result:=0;
 if x > 5 then begin result:=1; if x < 5 then result:=2 else result:=3; end
 else begin result:=10; if x < 5 then result:=11 else result:=12; end;
end;
function tlongint_347(x:longint):longint;
begin
 result:=0;
 if x > 5 then begin result:=1; if x < 7 then result:=2 else result:=3; end
 else begin result:=10; if x < 7 then result:=11 else result:=12; end;
end;
function tlongint_348(x:longint):longint;
begin
 result:=0;
 if x > 5 then begin result:=1; if x <= -3 then result:=2 else result:=3; end
 else begin result:=10; if x <= -3 then result:=11 else result:=12; end;
end;
function tlongint_349(x:longint):longint;
begin
 result:=0;
 if x > 5 then begin result:=1; if x <= 3 then result:=2 else result:=3; end
 else begin result:=10; if x <= 3 then result:=11 else result:=12; end;
end;
function tlongint_350(x:longint):longint;
begin
 result:=0;
 if x > 5 then begin result:=1; if x <= 5 then result:=2 else result:=3; end
 else begin result:=10; if x <= 5 then result:=11 else result:=12; end;
end;
function tlongint_351(x:longint):longint;
begin
 result:=0;
 if x > 5 then begin result:=1; if x <= 7 then result:=2 else result:=3; end
 else begin result:=10; if x <= 7 then result:=11 else result:=12; end;
end;
function tlongint_352(x:longint):longint;
begin
 result:=0;
 if x > 5 then begin result:=1; if x > -3 then result:=2 else result:=3; end
 else begin result:=10; if x > -3 then result:=11 else result:=12; end;
end;
function tlongint_353(x:longint):longint;
begin
 result:=0;
 if x > 5 then begin result:=1; if x > 3 then result:=2 else result:=3; end
 else begin result:=10; if x > 3 then result:=11 else result:=12; end;
end;
function tlongint_354(x:longint):longint;
begin
 result:=0;
 if x > 5 then begin result:=1; if x > 5 then result:=2 else result:=3; end
 else begin result:=10; if x > 5 then result:=11 else result:=12; end;
end;
function tlongint_355(x:longint):longint;
begin
 result:=0;
 if x > 5 then begin result:=1; if x > 7 then result:=2 else result:=3; end
 else begin result:=10; if x > 7 then result:=11 else result:=12; end;
end;
function tlongint_356(x:longint):longint;
begin
 result:=0;
 if x > 5 then begin result:=1; if x >= -3 then result:=2 else result:=3; end
 else begin result:=10; if x >= -3 then result:=11 else result:=12; end;
end;
function tlongint_357(x:longint):longint;
begin
 result:=0;
 if x > 5 then begin result:=1; if x >= 3 then result:=2 else result:=3; end
 else begin result:=10; if x >= 3 then result:=11 else result:=12; end;
end;
function tlongint_358(x:longint):longint;
begin
 result:=0;
 if x > 5 then begin result:=1; if x >= 5 then result:=2 else result:=3; end
 else begin result:=10; if x >= 5 then result:=11 else result:=12; end;
end;
function tlongint_359(x:longint):longint;
begin
 result:=0;
 if x > 5 then begin result:=1; if x >= 7 then result:=2 else result:=3; end
 else begin result:=10; if x >= 7 then result:=11 else result:=12; end;
end;
function tlongint_360(x:longint):longint;
begin
 result:=0;
 if x >= -3 then begin result:=1; if x = -3 then result:=2 else result:=3; end
 else begin result:=10; if x = -3 then result:=11 else result:=12; end;
end;
function tlongint_361(x:longint):longint;
begin
 result:=0;
 if x >= -3 then begin result:=1; if x = 3 then result:=2 else result:=3; end
 else begin result:=10; if x = 3 then result:=11 else result:=12; end;
end;
function tlongint_362(x:longint):longint;
begin
 result:=0;
 if x >= -3 then begin result:=1; if x = 5 then result:=2 else result:=3; end
 else begin result:=10; if x = 5 then result:=11 else result:=12; end;
end;
function tlongint_363(x:longint):longint;
begin
 result:=0;
 if x >= -3 then begin result:=1; if x = 7 then result:=2 else result:=3; end
 else begin result:=10; if x = 7 then result:=11 else result:=12; end;
end;
function tlongint_364(x:longint):longint;
begin
 result:=0;
 if x >= -3 then begin result:=1; if x <> -3 then result:=2 else result:=3; end
 else begin result:=10; if x <> -3 then result:=11 else result:=12; end;
end;
function tlongint_365(x:longint):longint;
begin
 result:=0;
 if x >= -3 then begin result:=1; if x <> 3 then result:=2 else result:=3; end
 else begin result:=10; if x <> 3 then result:=11 else result:=12; end;
end;
function tlongint_366(x:longint):longint;
begin
 result:=0;
 if x >= -3 then begin result:=1; if x <> 5 then result:=2 else result:=3; end
 else begin result:=10; if x <> 5 then result:=11 else result:=12; end;
end;
function tlongint_367(x:longint):longint;
begin
 result:=0;
 if x >= -3 then begin result:=1; if x <> 7 then result:=2 else result:=3; end
 else begin result:=10; if x <> 7 then result:=11 else result:=12; end;
end;
function tlongint_368(x:longint):longint;
begin
 result:=0;
 if x >= -3 then begin result:=1; if x < -3 then result:=2 else result:=3; end
 else begin result:=10; if x < -3 then result:=11 else result:=12; end;
end;
function tlongint_369(x:longint):longint;
begin
 result:=0;
 if x >= -3 then begin result:=1; if x < 3 then result:=2 else result:=3; end
 else begin result:=10; if x < 3 then result:=11 else result:=12; end;
end;
function tlongint_370(x:longint):longint;
begin
 result:=0;
 if x >= -3 then begin result:=1; if x < 5 then result:=2 else result:=3; end
 else begin result:=10; if x < 5 then result:=11 else result:=12; end;
end;
function tlongint_371(x:longint):longint;
begin
 result:=0;
 if x >= -3 then begin result:=1; if x < 7 then result:=2 else result:=3; end
 else begin result:=10; if x < 7 then result:=11 else result:=12; end;
end;
function tlongint_372(x:longint):longint;
begin
 result:=0;
 if x >= -3 then begin result:=1; if x <= -3 then result:=2 else result:=3; end
 else begin result:=10; if x <= -3 then result:=11 else result:=12; end;
end;
function tlongint_373(x:longint):longint;
begin
 result:=0;
 if x >= -3 then begin result:=1; if x <= 3 then result:=2 else result:=3; end
 else begin result:=10; if x <= 3 then result:=11 else result:=12; end;
end;
function tlongint_374(x:longint):longint;
begin
 result:=0;
 if x >= -3 then begin result:=1; if x <= 5 then result:=2 else result:=3; end
 else begin result:=10; if x <= 5 then result:=11 else result:=12; end;
end;
function tlongint_375(x:longint):longint;
begin
 result:=0;
 if x >= -3 then begin result:=1; if x <= 7 then result:=2 else result:=3; end
 else begin result:=10; if x <= 7 then result:=11 else result:=12; end;
end;
function tlongint_376(x:longint):longint;
begin
 result:=0;
 if x >= -3 then begin result:=1; if x > -3 then result:=2 else result:=3; end
 else begin result:=10; if x > -3 then result:=11 else result:=12; end;
end;
function tlongint_377(x:longint):longint;
begin
 result:=0;
 if x >= -3 then begin result:=1; if x > 3 then result:=2 else result:=3; end
 else begin result:=10; if x > 3 then result:=11 else result:=12; end;
end;
function tlongint_378(x:longint):longint;
begin
 result:=0;
 if x >= -3 then begin result:=1; if x > 5 then result:=2 else result:=3; end
 else begin result:=10; if x > 5 then result:=11 else result:=12; end;
end;
function tlongint_379(x:longint):longint;
begin
 result:=0;
 if x >= -3 then begin result:=1; if x > 7 then result:=2 else result:=3; end
 else begin result:=10; if x > 7 then result:=11 else result:=12; end;
end;
function tlongint_380(x:longint):longint;
begin
 result:=0;
 if x >= -3 then begin result:=1; if x >= -3 then result:=2 else result:=3; end
 else begin result:=10; if x >= -3 then result:=11 else result:=12; end;
end;
function tlongint_381(x:longint):longint;
begin
 result:=0;
 if x >= -3 then begin result:=1; if x >= 3 then result:=2 else result:=3; end
 else begin result:=10; if x >= 3 then result:=11 else result:=12; end;
end;
function tlongint_382(x:longint):longint;
begin
 result:=0;
 if x >= -3 then begin result:=1; if x >= 5 then result:=2 else result:=3; end
 else begin result:=10; if x >= 5 then result:=11 else result:=12; end;
end;
function tlongint_383(x:longint):longint;
begin
 result:=0;
 if x >= -3 then begin result:=1; if x >= 7 then result:=2 else result:=3; end
 else begin result:=10; if x >= 7 then result:=11 else result:=12; end;
end;
function tlongint_384(x:longint):longint;
begin
 result:=0;
 if x >= 0 then begin result:=1; if x = -3 then result:=2 else result:=3; end
 else begin result:=10; if x = -3 then result:=11 else result:=12; end;
end;
function tlongint_385(x:longint):longint;
begin
 result:=0;
 if x >= 0 then begin result:=1; if x = 3 then result:=2 else result:=3; end
 else begin result:=10; if x = 3 then result:=11 else result:=12; end;
end;
function tlongint_386(x:longint):longint;
begin
 result:=0;
 if x >= 0 then begin result:=1; if x = 5 then result:=2 else result:=3; end
 else begin result:=10; if x = 5 then result:=11 else result:=12; end;
end;
function tlongint_387(x:longint):longint;
begin
 result:=0;
 if x >= 0 then begin result:=1; if x = 7 then result:=2 else result:=3; end
 else begin result:=10; if x = 7 then result:=11 else result:=12; end;
end;
function tlongint_388(x:longint):longint;
begin
 result:=0;
 if x >= 0 then begin result:=1; if x <> -3 then result:=2 else result:=3; end
 else begin result:=10; if x <> -3 then result:=11 else result:=12; end;
end;
function tlongint_389(x:longint):longint;
begin
 result:=0;
 if x >= 0 then begin result:=1; if x <> 3 then result:=2 else result:=3; end
 else begin result:=10; if x <> 3 then result:=11 else result:=12; end;
end;
function tlongint_390(x:longint):longint;
begin
 result:=0;
 if x >= 0 then begin result:=1; if x <> 5 then result:=2 else result:=3; end
 else begin result:=10; if x <> 5 then result:=11 else result:=12; end;
end;
function tlongint_391(x:longint):longint;
begin
 result:=0;
 if x >= 0 then begin result:=1; if x <> 7 then result:=2 else result:=3; end
 else begin result:=10; if x <> 7 then result:=11 else result:=12; end;
end;
function tlongint_392(x:longint):longint;
begin
 result:=0;
 if x >= 0 then begin result:=1; if x < -3 then result:=2 else result:=3; end
 else begin result:=10; if x < -3 then result:=11 else result:=12; end;
end;
function tlongint_393(x:longint):longint;
begin
 result:=0;
 if x >= 0 then begin result:=1; if x < 3 then result:=2 else result:=3; end
 else begin result:=10; if x < 3 then result:=11 else result:=12; end;
end;
function tlongint_394(x:longint):longint;
begin
 result:=0;
 if x >= 0 then begin result:=1; if x < 5 then result:=2 else result:=3; end
 else begin result:=10; if x < 5 then result:=11 else result:=12; end;
end;
function tlongint_395(x:longint):longint;
begin
 result:=0;
 if x >= 0 then begin result:=1; if x < 7 then result:=2 else result:=3; end
 else begin result:=10; if x < 7 then result:=11 else result:=12; end;
end;
function tlongint_396(x:longint):longint;
begin
 result:=0;
 if x >= 0 then begin result:=1; if x <= -3 then result:=2 else result:=3; end
 else begin result:=10; if x <= -3 then result:=11 else result:=12; end;
end;
function tlongint_397(x:longint):longint;
begin
 result:=0;
 if x >= 0 then begin result:=1; if x <= 3 then result:=2 else result:=3; end
 else begin result:=10; if x <= 3 then result:=11 else result:=12; end;
end;
function tlongint_398(x:longint):longint;
begin
 result:=0;
 if x >= 0 then begin result:=1; if x <= 5 then result:=2 else result:=3; end
 else begin result:=10; if x <= 5 then result:=11 else result:=12; end;
end;
function tlongint_399(x:longint):longint;
begin
 result:=0;
 if x >= 0 then begin result:=1; if x <= 7 then result:=2 else result:=3; end
 else begin result:=10; if x <= 7 then result:=11 else result:=12; end;
end;
function tlongint_400(x:longint):longint;
begin
 result:=0;
 if x >= 0 then begin result:=1; if x > -3 then result:=2 else result:=3; end
 else begin result:=10; if x > -3 then result:=11 else result:=12; end;
end;
function tlongint_401(x:longint):longint;
begin
 result:=0;
 if x >= 0 then begin result:=1; if x > 3 then result:=2 else result:=3; end
 else begin result:=10; if x > 3 then result:=11 else result:=12; end;
end;
function tlongint_402(x:longint):longint;
begin
 result:=0;
 if x >= 0 then begin result:=1; if x > 5 then result:=2 else result:=3; end
 else begin result:=10; if x > 5 then result:=11 else result:=12; end;
end;
function tlongint_403(x:longint):longint;
begin
 result:=0;
 if x >= 0 then begin result:=1; if x > 7 then result:=2 else result:=3; end
 else begin result:=10; if x > 7 then result:=11 else result:=12; end;
end;
function tlongint_404(x:longint):longint;
begin
 result:=0;
 if x >= 0 then begin result:=1; if x >= -3 then result:=2 else result:=3; end
 else begin result:=10; if x >= -3 then result:=11 else result:=12; end;
end;
function tlongint_405(x:longint):longint;
begin
 result:=0;
 if x >= 0 then begin result:=1; if x >= 3 then result:=2 else result:=3; end
 else begin result:=10; if x >= 3 then result:=11 else result:=12; end;
end;
function tlongint_406(x:longint):longint;
begin
 result:=0;
 if x >= 0 then begin result:=1; if x >= 5 then result:=2 else result:=3; end
 else begin result:=10; if x >= 5 then result:=11 else result:=12; end;
end;
function tlongint_407(x:longint):longint;
begin
 result:=0;
 if x >= 0 then begin result:=1; if x >= 7 then result:=2 else result:=3; end
 else begin result:=10; if x >= 7 then result:=11 else result:=12; end;
end;
function tlongint_408(x:longint):longint;
begin
 result:=0;
 if x >= 5 then begin result:=1; if x = -3 then result:=2 else result:=3; end
 else begin result:=10; if x = -3 then result:=11 else result:=12; end;
end;
function tlongint_409(x:longint):longint;
begin
 result:=0;
 if x >= 5 then begin result:=1; if x = 3 then result:=2 else result:=3; end
 else begin result:=10; if x = 3 then result:=11 else result:=12; end;
end;
function tlongint_410(x:longint):longint;
begin
 result:=0;
 if x >= 5 then begin result:=1; if x = 5 then result:=2 else result:=3; end
 else begin result:=10; if x = 5 then result:=11 else result:=12; end;
end;
function tlongint_411(x:longint):longint;
begin
 result:=0;
 if x >= 5 then begin result:=1; if x = 7 then result:=2 else result:=3; end
 else begin result:=10; if x = 7 then result:=11 else result:=12; end;
end;
function tlongint_412(x:longint):longint;
begin
 result:=0;
 if x >= 5 then begin result:=1; if x <> -3 then result:=2 else result:=3; end
 else begin result:=10; if x <> -3 then result:=11 else result:=12; end;
end;
function tlongint_413(x:longint):longint;
begin
 result:=0;
 if x >= 5 then begin result:=1; if x <> 3 then result:=2 else result:=3; end
 else begin result:=10; if x <> 3 then result:=11 else result:=12; end;
end;
function tlongint_414(x:longint):longint;
begin
 result:=0;
 if x >= 5 then begin result:=1; if x <> 5 then result:=2 else result:=3; end
 else begin result:=10; if x <> 5 then result:=11 else result:=12; end;
end;
function tlongint_415(x:longint):longint;
begin
 result:=0;
 if x >= 5 then begin result:=1; if x <> 7 then result:=2 else result:=3; end
 else begin result:=10; if x <> 7 then result:=11 else result:=12; end;
end;
function tlongint_416(x:longint):longint;
begin
 result:=0;
 if x >= 5 then begin result:=1; if x < -3 then result:=2 else result:=3; end
 else begin result:=10; if x < -3 then result:=11 else result:=12; end;
end;
function tlongint_417(x:longint):longint;
begin
 result:=0;
 if x >= 5 then begin result:=1; if x < 3 then result:=2 else result:=3; end
 else begin result:=10; if x < 3 then result:=11 else result:=12; end;
end;
function tlongint_418(x:longint):longint;
begin
 result:=0;
 if x >= 5 then begin result:=1; if x < 5 then result:=2 else result:=3; end
 else begin result:=10; if x < 5 then result:=11 else result:=12; end;
end;
function tlongint_419(x:longint):longint;
begin
 result:=0;
 if x >= 5 then begin result:=1; if x < 7 then result:=2 else result:=3; end
 else begin result:=10; if x < 7 then result:=11 else result:=12; end;
end;
function tlongint_420(x:longint):longint;
begin
 result:=0;
 if x >= 5 then begin result:=1; if x <= -3 then result:=2 else result:=3; end
 else begin result:=10; if x <= -3 then result:=11 else result:=12; end;
end;
function tlongint_421(x:longint):longint;
begin
 result:=0;
 if x >= 5 then begin result:=1; if x <= 3 then result:=2 else result:=3; end
 else begin result:=10; if x <= 3 then result:=11 else result:=12; end;
end;
function tlongint_422(x:longint):longint;
begin
 result:=0;
 if x >= 5 then begin result:=1; if x <= 5 then result:=2 else result:=3; end
 else begin result:=10; if x <= 5 then result:=11 else result:=12; end;
end;
function tlongint_423(x:longint):longint;
begin
 result:=0;
 if x >= 5 then begin result:=1; if x <= 7 then result:=2 else result:=3; end
 else begin result:=10; if x <= 7 then result:=11 else result:=12; end;
end;
function tlongint_424(x:longint):longint;
begin
 result:=0;
 if x >= 5 then begin result:=1; if x > -3 then result:=2 else result:=3; end
 else begin result:=10; if x > -3 then result:=11 else result:=12; end;
end;
function tlongint_425(x:longint):longint;
begin
 result:=0;
 if x >= 5 then begin result:=1; if x > 3 then result:=2 else result:=3; end
 else begin result:=10; if x > 3 then result:=11 else result:=12; end;
end;
function tlongint_426(x:longint):longint;
begin
 result:=0;
 if x >= 5 then begin result:=1; if x > 5 then result:=2 else result:=3; end
 else begin result:=10; if x > 5 then result:=11 else result:=12; end;
end;
function tlongint_427(x:longint):longint;
begin
 result:=0;
 if x >= 5 then begin result:=1; if x > 7 then result:=2 else result:=3; end
 else begin result:=10; if x > 7 then result:=11 else result:=12; end;
end;
function tlongint_428(x:longint):longint;
begin
 result:=0;
 if x >= 5 then begin result:=1; if x >= -3 then result:=2 else result:=3; end
 else begin result:=10; if x >= -3 then result:=11 else result:=12; end;
end;
function tlongint_429(x:longint):longint;
begin
 result:=0;
 if x >= 5 then begin result:=1; if x >= 3 then result:=2 else result:=3; end
 else begin result:=10; if x >= 3 then result:=11 else result:=12; end;
end;
function tlongint_430(x:longint):longint;
begin
 result:=0;
 if x >= 5 then begin result:=1; if x >= 5 then result:=2 else result:=3; end
 else begin result:=10; if x >= 5 then result:=11 else result:=12; end;
end;
function tlongint_431(x:longint):longint;
begin
 result:=0;
 if x >= 5 then begin result:=1; if x >= 7 then result:=2 else result:=3; end
 else begin result:=10; if x >= 7 then result:=11 else result:=12; end;
end;
function tdword_0(x:dword):longint;
begin
 result:=0;
 if x = 0 then begin result:=1; if x = 3 then result:=2 else result:=3; end
 else begin result:=10; if x = 3 then result:=11 else result:=12; end;
end;
function tdword_1(x:dword):longint;
begin
 result:=0;
 if x = 0 then begin result:=1; if x = 5 then result:=2 else result:=3; end
 else begin result:=10; if x = 5 then result:=11 else result:=12; end;
end;
function tdword_2(x:dword):longint;
begin
 result:=0;
 if x = 0 then begin result:=1; if x = 7 then result:=2 else result:=3; end
 else begin result:=10; if x = 7 then result:=11 else result:=12; end;
end;
function tdword_3(x:dword):longint;
begin
 result:=0;
 if x = 0 then begin result:=1; if x = 12 then result:=2 else result:=3; end
 else begin result:=10; if x = 12 then result:=11 else result:=12; end;
end;
function tdword_4(x:dword):longint;
begin
 result:=0;
 if x = 0 then begin result:=1; if x <> 3 then result:=2 else result:=3; end
 else begin result:=10; if x <> 3 then result:=11 else result:=12; end;
end;
function tdword_5(x:dword):longint;
begin
 result:=0;
 if x = 0 then begin result:=1; if x <> 5 then result:=2 else result:=3; end
 else begin result:=10; if x <> 5 then result:=11 else result:=12; end;
end;
function tdword_6(x:dword):longint;
begin
 result:=0;
 if x = 0 then begin result:=1; if x <> 7 then result:=2 else result:=3; end
 else begin result:=10; if x <> 7 then result:=11 else result:=12; end;
end;
function tdword_7(x:dword):longint;
begin
 result:=0;
 if x = 0 then begin result:=1; if x <> 12 then result:=2 else result:=3; end
 else begin result:=10; if x <> 12 then result:=11 else result:=12; end;
end;
function tdword_8(x:dword):longint;
begin
 result:=0;
 if x = 0 then begin result:=1; if x < 3 then result:=2 else result:=3; end
 else begin result:=10; if x < 3 then result:=11 else result:=12; end;
end;
function tdword_9(x:dword):longint;
begin
 result:=0;
 if x = 0 then begin result:=1; if x < 5 then result:=2 else result:=3; end
 else begin result:=10; if x < 5 then result:=11 else result:=12; end;
end;
function tdword_10(x:dword):longint;
begin
 result:=0;
 if x = 0 then begin result:=1; if x < 7 then result:=2 else result:=3; end
 else begin result:=10; if x < 7 then result:=11 else result:=12; end;
end;
function tdword_11(x:dword):longint;
begin
 result:=0;
 if x = 0 then begin result:=1; if x < 12 then result:=2 else result:=3; end
 else begin result:=10; if x < 12 then result:=11 else result:=12; end;
end;
function tdword_12(x:dword):longint;
begin
 result:=0;
 if x = 0 then begin result:=1; if x <= 3 then result:=2 else result:=3; end
 else begin result:=10; if x <= 3 then result:=11 else result:=12; end;
end;
function tdword_13(x:dword):longint;
begin
 result:=0;
 if x = 0 then begin result:=1; if x <= 5 then result:=2 else result:=3; end
 else begin result:=10; if x <= 5 then result:=11 else result:=12; end;
end;
function tdword_14(x:dword):longint;
begin
 result:=0;
 if x = 0 then begin result:=1; if x <= 7 then result:=2 else result:=3; end
 else begin result:=10; if x <= 7 then result:=11 else result:=12; end;
end;
function tdword_15(x:dword):longint;
begin
 result:=0;
 if x = 0 then begin result:=1; if x <= 12 then result:=2 else result:=3; end
 else begin result:=10; if x <= 12 then result:=11 else result:=12; end;
end;
function tdword_16(x:dword):longint;
begin
 result:=0;
 if x = 0 then begin result:=1; if x > 3 then result:=2 else result:=3; end
 else begin result:=10; if x > 3 then result:=11 else result:=12; end;
end;
function tdword_17(x:dword):longint;
begin
 result:=0;
 if x = 0 then begin result:=1; if x > 5 then result:=2 else result:=3; end
 else begin result:=10; if x > 5 then result:=11 else result:=12; end;
end;
function tdword_18(x:dword):longint;
begin
 result:=0;
 if x = 0 then begin result:=1; if x > 7 then result:=2 else result:=3; end
 else begin result:=10; if x > 7 then result:=11 else result:=12; end;
end;
function tdword_19(x:dword):longint;
begin
 result:=0;
 if x = 0 then begin result:=1; if x > 12 then result:=2 else result:=3; end
 else begin result:=10; if x > 12 then result:=11 else result:=12; end;
end;
function tdword_20(x:dword):longint;
begin
 result:=0;
 if x = 0 then begin result:=1; if x >= 3 then result:=2 else result:=3; end
 else begin result:=10; if x >= 3 then result:=11 else result:=12; end;
end;
function tdword_21(x:dword):longint;
begin
 result:=0;
 if x = 0 then begin result:=1; if x >= 5 then result:=2 else result:=3; end
 else begin result:=10; if x >= 5 then result:=11 else result:=12; end;
end;
function tdword_22(x:dword):longint;
begin
 result:=0;
 if x = 0 then begin result:=1; if x >= 7 then result:=2 else result:=3; end
 else begin result:=10; if x >= 7 then result:=11 else result:=12; end;
end;
function tdword_23(x:dword):longint;
begin
 result:=0;
 if x = 0 then begin result:=1; if x >= 12 then result:=2 else result:=3; end
 else begin result:=10; if x >= 12 then result:=11 else result:=12; end;
end;
function tdword_24(x:dword):longint;
begin
 result:=0;
 if x = 5 then begin result:=1; if x = 3 then result:=2 else result:=3; end
 else begin result:=10; if x = 3 then result:=11 else result:=12; end;
end;
function tdword_25(x:dword):longint;
begin
 result:=0;
 if x = 5 then begin result:=1; if x = 5 then result:=2 else result:=3; end
 else begin result:=10; if x = 5 then result:=11 else result:=12; end;
end;
function tdword_26(x:dword):longint;
begin
 result:=0;
 if x = 5 then begin result:=1; if x = 7 then result:=2 else result:=3; end
 else begin result:=10; if x = 7 then result:=11 else result:=12; end;
end;
function tdword_27(x:dword):longint;
begin
 result:=0;
 if x = 5 then begin result:=1; if x = 12 then result:=2 else result:=3; end
 else begin result:=10; if x = 12 then result:=11 else result:=12; end;
end;
function tdword_28(x:dword):longint;
begin
 result:=0;
 if x = 5 then begin result:=1; if x <> 3 then result:=2 else result:=3; end
 else begin result:=10; if x <> 3 then result:=11 else result:=12; end;
end;
function tdword_29(x:dword):longint;
begin
 result:=0;
 if x = 5 then begin result:=1; if x <> 5 then result:=2 else result:=3; end
 else begin result:=10; if x <> 5 then result:=11 else result:=12; end;
end;
function tdword_30(x:dword):longint;
begin
 result:=0;
 if x = 5 then begin result:=1; if x <> 7 then result:=2 else result:=3; end
 else begin result:=10; if x <> 7 then result:=11 else result:=12; end;
end;
function tdword_31(x:dword):longint;
begin
 result:=0;
 if x = 5 then begin result:=1; if x <> 12 then result:=2 else result:=3; end
 else begin result:=10; if x <> 12 then result:=11 else result:=12; end;
end;
function tdword_32(x:dword):longint;
begin
 result:=0;
 if x = 5 then begin result:=1; if x < 3 then result:=2 else result:=3; end
 else begin result:=10; if x < 3 then result:=11 else result:=12; end;
end;
function tdword_33(x:dword):longint;
begin
 result:=0;
 if x = 5 then begin result:=1; if x < 5 then result:=2 else result:=3; end
 else begin result:=10; if x < 5 then result:=11 else result:=12; end;
end;
function tdword_34(x:dword):longint;
begin
 result:=0;
 if x = 5 then begin result:=1; if x < 7 then result:=2 else result:=3; end
 else begin result:=10; if x < 7 then result:=11 else result:=12; end;
end;
function tdword_35(x:dword):longint;
begin
 result:=0;
 if x = 5 then begin result:=1; if x < 12 then result:=2 else result:=3; end
 else begin result:=10; if x < 12 then result:=11 else result:=12; end;
end;
function tdword_36(x:dword):longint;
begin
 result:=0;
 if x = 5 then begin result:=1; if x <= 3 then result:=2 else result:=3; end
 else begin result:=10; if x <= 3 then result:=11 else result:=12; end;
end;
function tdword_37(x:dword):longint;
begin
 result:=0;
 if x = 5 then begin result:=1; if x <= 5 then result:=2 else result:=3; end
 else begin result:=10; if x <= 5 then result:=11 else result:=12; end;
end;
function tdword_38(x:dword):longint;
begin
 result:=0;
 if x = 5 then begin result:=1; if x <= 7 then result:=2 else result:=3; end
 else begin result:=10; if x <= 7 then result:=11 else result:=12; end;
end;
function tdword_39(x:dword):longint;
begin
 result:=0;
 if x = 5 then begin result:=1; if x <= 12 then result:=2 else result:=3; end
 else begin result:=10; if x <= 12 then result:=11 else result:=12; end;
end;
function tdword_40(x:dword):longint;
begin
 result:=0;
 if x = 5 then begin result:=1; if x > 3 then result:=2 else result:=3; end
 else begin result:=10; if x > 3 then result:=11 else result:=12; end;
end;
function tdword_41(x:dword):longint;
begin
 result:=0;
 if x = 5 then begin result:=1; if x > 5 then result:=2 else result:=3; end
 else begin result:=10; if x > 5 then result:=11 else result:=12; end;
end;
function tdword_42(x:dword):longint;
begin
 result:=0;
 if x = 5 then begin result:=1; if x > 7 then result:=2 else result:=3; end
 else begin result:=10; if x > 7 then result:=11 else result:=12; end;
end;
function tdword_43(x:dword):longint;
begin
 result:=0;
 if x = 5 then begin result:=1; if x > 12 then result:=2 else result:=3; end
 else begin result:=10; if x > 12 then result:=11 else result:=12; end;
end;
function tdword_44(x:dword):longint;
begin
 result:=0;
 if x = 5 then begin result:=1; if x >= 3 then result:=2 else result:=3; end
 else begin result:=10; if x >= 3 then result:=11 else result:=12; end;
end;
function tdword_45(x:dword):longint;
begin
 result:=0;
 if x = 5 then begin result:=1; if x >= 5 then result:=2 else result:=3; end
 else begin result:=10; if x >= 5 then result:=11 else result:=12; end;
end;
function tdword_46(x:dword):longint;
begin
 result:=0;
 if x = 5 then begin result:=1; if x >= 7 then result:=2 else result:=3; end
 else begin result:=10; if x >= 7 then result:=11 else result:=12; end;
end;
function tdword_47(x:dword):longint;
begin
 result:=0;
 if x = 5 then begin result:=1; if x >= 12 then result:=2 else result:=3; end
 else begin result:=10; if x >= 12 then result:=11 else result:=12; end;
end;
function tdword_48(x:dword):longint;
begin
 result:=0;
 if x = 10 then begin result:=1; if x = 3 then result:=2 else result:=3; end
 else begin result:=10; if x = 3 then result:=11 else result:=12; end;
end;
function tdword_49(x:dword):longint;
begin
 result:=0;
 if x = 10 then begin result:=1; if x = 5 then result:=2 else result:=3; end
 else begin result:=10; if x = 5 then result:=11 else result:=12; end;
end;
function tdword_50(x:dword):longint;
begin
 result:=0;
 if x = 10 then begin result:=1; if x = 7 then result:=2 else result:=3; end
 else begin result:=10; if x = 7 then result:=11 else result:=12; end;
end;
function tdword_51(x:dword):longint;
begin
 result:=0;
 if x = 10 then begin result:=1; if x = 12 then result:=2 else result:=3; end
 else begin result:=10; if x = 12 then result:=11 else result:=12; end;
end;
function tdword_52(x:dword):longint;
begin
 result:=0;
 if x = 10 then begin result:=1; if x <> 3 then result:=2 else result:=3; end
 else begin result:=10; if x <> 3 then result:=11 else result:=12; end;
end;
function tdword_53(x:dword):longint;
begin
 result:=0;
 if x = 10 then begin result:=1; if x <> 5 then result:=2 else result:=3; end
 else begin result:=10; if x <> 5 then result:=11 else result:=12; end;
end;
function tdword_54(x:dword):longint;
begin
 result:=0;
 if x = 10 then begin result:=1; if x <> 7 then result:=2 else result:=3; end
 else begin result:=10; if x <> 7 then result:=11 else result:=12; end;
end;
function tdword_55(x:dword):longint;
begin
 result:=0;
 if x = 10 then begin result:=1; if x <> 12 then result:=2 else result:=3; end
 else begin result:=10; if x <> 12 then result:=11 else result:=12; end;
end;
function tdword_56(x:dword):longint;
begin
 result:=0;
 if x = 10 then begin result:=1; if x < 3 then result:=2 else result:=3; end
 else begin result:=10; if x < 3 then result:=11 else result:=12; end;
end;
function tdword_57(x:dword):longint;
begin
 result:=0;
 if x = 10 then begin result:=1; if x < 5 then result:=2 else result:=3; end
 else begin result:=10; if x < 5 then result:=11 else result:=12; end;
end;
function tdword_58(x:dword):longint;
begin
 result:=0;
 if x = 10 then begin result:=1; if x < 7 then result:=2 else result:=3; end
 else begin result:=10; if x < 7 then result:=11 else result:=12; end;
end;
function tdword_59(x:dword):longint;
begin
 result:=0;
 if x = 10 then begin result:=1; if x < 12 then result:=2 else result:=3; end
 else begin result:=10; if x < 12 then result:=11 else result:=12; end;
end;
function tdword_60(x:dword):longint;
begin
 result:=0;
 if x = 10 then begin result:=1; if x <= 3 then result:=2 else result:=3; end
 else begin result:=10; if x <= 3 then result:=11 else result:=12; end;
end;
function tdword_61(x:dword):longint;
begin
 result:=0;
 if x = 10 then begin result:=1; if x <= 5 then result:=2 else result:=3; end
 else begin result:=10; if x <= 5 then result:=11 else result:=12; end;
end;
function tdword_62(x:dword):longint;
begin
 result:=0;
 if x = 10 then begin result:=1; if x <= 7 then result:=2 else result:=3; end
 else begin result:=10; if x <= 7 then result:=11 else result:=12; end;
end;
function tdword_63(x:dword):longint;
begin
 result:=0;
 if x = 10 then begin result:=1; if x <= 12 then result:=2 else result:=3; end
 else begin result:=10; if x <= 12 then result:=11 else result:=12; end;
end;
function tdword_64(x:dword):longint;
begin
 result:=0;
 if x = 10 then begin result:=1; if x > 3 then result:=2 else result:=3; end
 else begin result:=10; if x > 3 then result:=11 else result:=12; end;
end;
function tdword_65(x:dword):longint;
begin
 result:=0;
 if x = 10 then begin result:=1; if x > 5 then result:=2 else result:=3; end
 else begin result:=10; if x > 5 then result:=11 else result:=12; end;
end;
function tdword_66(x:dword):longint;
begin
 result:=0;
 if x = 10 then begin result:=1; if x > 7 then result:=2 else result:=3; end
 else begin result:=10; if x > 7 then result:=11 else result:=12; end;
end;
function tdword_67(x:dword):longint;
begin
 result:=0;
 if x = 10 then begin result:=1; if x > 12 then result:=2 else result:=3; end
 else begin result:=10; if x > 12 then result:=11 else result:=12; end;
end;
function tdword_68(x:dword):longint;
begin
 result:=0;
 if x = 10 then begin result:=1; if x >= 3 then result:=2 else result:=3; end
 else begin result:=10; if x >= 3 then result:=11 else result:=12; end;
end;
function tdword_69(x:dword):longint;
begin
 result:=0;
 if x = 10 then begin result:=1; if x >= 5 then result:=2 else result:=3; end
 else begin result:=10; if x >= 5 then result:=11 else result:=12; end;
end;
function tdword_70(x:dword):longint;
begin
 result:=0;
 if x = 10 then begin result:=1; if x >= 7 then result:=2 else result:=3; end
 else begin result:=10; if x >= 7 then result:=11 else result:=12; end;
end;
function tdword_71(x:dword):longint;
begin
 result:=0;
 if x = 10 then begin result:=1; if x >= 12 then result:=2 else result:=3; end
 else begin result:=10; if x >= 12 then result:=11 else result:=12; end;
end;
function tdword_72(x:dword):longint;
begin
 result:=0;
 if x <> 0 then begin result:=1; if x = 3 then result:=2 else result:=3; end
 else begin result:=10; if x = 3 then result:=11 else result:=12; end;
end;
function tdword_73(x:dword):longint;
begin
 result:=0;
 if x <> 0 then begin result:=1; if x = 5 then result:=2 else result:=3; end
 else begin result:=10; if x = 5 then result:=11 else result:=12; end;
end;
function tdword_74(x:dword):longint;
begin
 result:=0;
 if x <> 0 then begin result:=1; if x = 7 then result:=2 else result:=3; end
 else begin result:=10; if x = 7 then result:=11 else result:=12; end;
end;
function tdword_75(x:dword):longint;
begin
 result:=0;
 if x <> 0 then begin result:=1; if x = 12 then result:=2 else result:=3; end
 else begin result:=10; if x = 12 then result:=11 else result:=12; end;
end;
function tdword_76(x:dword):longint;
begin
 result:=0;
 if x <> 0 then begin result:=1; if x <> 3 then result:=2 else result:=3; end
 else begin result:=10; if x <> 3 then result:=11 else result:=12; end;
end;
function tdword_77(x:dword):longint;
begin
 result:=0;
 if x <> 0 then begin result:=1; if x <> 5 then result:=2 else result:=3; end
 else begin result:=10; if x <> 5 then result:=11 else result:=12; end;
end;
function tdword_78(x:dword):longint;
begin
 result:=0;
 if x <> 0 then begin result:=1; if x <> 7 then result:=2 else result:=3; end
 else begin result:=10; if x <> 7 then result:=11 else result:=12; end;
end;
function tdword_79(x:dword):longint;
begin
 result:=0;
 if x <> 0 then begin result:=1; if x <> 12 then result:=2 else result:=3; end
 else begin result:=10; if x <> 12 then result:=11 else result:=12; end;
end;
function tdword_80(x:dword):longint;
begin
 result:=0;
 if x <> 0 then begin result:=1; if x < 3 then result:=2 else result:=3; end
 else begin result:=10; if x < 3 then result:=11 else result:=12; end;
end;
function tdword_81(x:dword):longint;
begin
 result:=0;
 if x <> 0 then begin result:=1; if x < 5 then result:=2 else result:=3; end
 else begin result:=10; if x < 5 then result:=11 else result:=12; end;
end;
function tdword_82(x:dword):longint;
begin
 result:=0;
 if x <> 0 then begin result:=1; if x < 7 then result:=2 else result:=3; end
 else begin result:=10; if x < 7 then result:=11 else result:=12; end;
end;
function tdword_83(x:dword):longint;
begin
 result:=0;
 if x <> 0 then begin result:=1; if x < 12 then result:=2 else result:=3; end
 else begin result:=10; if x < 12 then result:=11 else result:=12; end;
end;
function tdword_84(x:dword):longint;
begin
 result:=0;
 if x <> 0 then begin result:=1; if x <= 3 then result:=2 else result:=3; end
 else begin result:=10; if x <= 3 then result:=11 else result:=12; end;
end;
function tdword_85(x:dword):longint;
begin
 result:=0;
 if x <> 0 then begin result:=1; if x <= 5 then result:=2 else result:=3; end
 else begin result:=10; if x <= 5 then result:=11 else result:=12; end;
end;
function tdword_86(x:dword):longint;
begin
 result:=0;
 if x <> 0 then begin result:=1; if x <= 7 then result:=2 else result:=3; end
 else begin result:=10; if x <= 7 then result:=11 else result:=12; end;
end;
function tdword_87(x:dword):longint;
begin
 result:=0;
 if x <> 0 then begin result:=1; if x <= 12 then result:=2 else result:=3; end
 else begin result:=10; if x <= 12 then result:=11 else result:=12; end;
end;
function tdword_88(x:dword):longint;
begin
 result:=0;
 if x <> 0 then begin result:=1; if x > 3 then result:=2 else result:=3; end
 else begin result:=10; if x > 3 then result:=11 else result:=12; end;
end;
function tdword_89(x:dword):longint;
begin
 result:=0;
 if x <> 0 then begin result:=1; if x > 5 then result:=2 else result:=3; end
 else begin result:=10; if x > 5 then result:=11 else result:=12; end;
end;
function tdword_90(x:dword):longint;
begin
 result:=0;
 if x <> 0 then begin result:=1; if x > 7 then result:=2 else result:=3; end
 else begin result:=10; if x > 7 then result:=11 else result:=12; end;
end;
function tdword_91(x:dword):longint;
begin
 result:=0;
 if x <> 0 then begin result:=1; if x > 12 then result:=2 else result:=3; end
 else begin result:=10; if x > 12 then result:=11 else result:=12; end;
end;
function tdword_92(x:dword):longint;
begin
 result:=0;
 if x <> 0 then begin result:=1; if x >= 3 then result:=2 else result:=3; end
 else begin result:=10; if x >= 3 then result:=11 else result:=12; end;
end;
function tdword_93(x:dword):longint;
begin
 result:=0;
 if x <> 0 then begin result:=1; if x >= 5 then result:=2 else result:=3; end
 else begin result:=10; if x >= 5 then result:=11 else result:=12; end;
end;
function tdword_94(x:dword):longint;
begin
 result:=0;
 if x <> 0 then begin result:=1; if x >= 7 then result:=2 else result:=3; end
 else begin result:=10; if x >= 7 then result:=11 else result:=12; end;
end;
function tdword_95(x:dword):longint;
begin
 result:=0;
 if x <> 0 then begin result:=1; if x >= 12 then result:=2 else result:=3; end
 else begin result:=10; if x >= 12 then result:=11 else result:=12; end;
end;
function tdword_96(x:dword):longint;
begin
 result:=0;
 if x <> 5 then begin result:=1; if x = 3 then result:=2 else result:=3; end
 else begin result:=10; if x = 3 then result:=11 else result:=12; end;
end;
function tdword_97(x:dword):longint;
begin
 result:=0;
 if x <> 5 then begin result:=1; if x = 5 then result:=2 else result:=3; end
 else begin result:=10; if x = 5 then result:=11 else result:=12; end;
end;
function tdword_98(x:dword):longint;
begin
 result:=0;
 if x <> 5 then begin result:=1; if x = 7 then result:=2 else result:=3; end
 else begin result:=10; if x = 7 then result:=11 else result:=12; end;
end;
function tdword_99(x:dword):longint;
begin
 result:=0;
 if x <> 5 then begin result:=1; if x = 12 then result:=2 else result:=3; end
 else begin result:=10; if x = 12 then result:=11 else result:=12; end;
end;
function tdword_100(x:dword):longint;
begin
 result:=0;
 if x <> 5 then begin result:=1; if x <> 3 then result:=2 else result:=3; end
 else begin result:=10; if x <> 3 then result:=11 else result:=12; end;
end;
function tdword_101(x:dword):longint;
begin
 result:=0;
 if x <> 5 then begin result:=1; if x <> 5 then result:=2 else result:=3; end
 else begin result:=10; if x <> 5 then result:=11 else result:=12; end;
end;
function tdword_102(x:dword):longint;
begin
 result:=0;
 if x <> 5 then begin result:=1; if x <> 7 then result:=2 else result:=3; end
 else begin result:=10; if x <> 7 then result:=11 else result:=12; end;
end;
function tdword_103(x:dword):longint;
begin
 result:=0;
 if x <> 5 then begin result:=1; if x <> 12 then result:=2 else result:=3; end
 else begin result:=10; if x <> 12 then result:=11 else result:=12; end;
end;
function tdword_104(x:dword):longint;
begin
 result:=0;
 if x <> 5 then begin result:=1; if x < 3 then result:=2 else result:=3; end
 else begin result:=10; if x < 3 then result:=11 else result:=12; end;
end;
function tdword_105(x:dword):longint;
begin
 result:=0;
 if x <> 5 then begin result:=1; if x < 5 then result:=2 else result:=3; end
 else begin result:=10; if x < 5 then result:=11 else result:=12; end;
end;
function tdword_106(x:dword):longint;
begin
 result:=0;
 if x <> 5 then begin result:=1; if x < 7 then result:=2 else result:=3; end
 else begin result:=10; if x < 7 then result:=11 else result:=12; end;
end;
function tdword_107(x:dword):longint;
begin
 result:=0;
 if x <> 5 then begin result:=1; if x < 12 then result:=2 else result:=3; end
 else begin result:=10; if x < 12 then result:=11 else result:=12; end;
end;
function tdword_108(x:dword):longint;
begin
 result:=0;
 if x <> 5 then begin result:=1; if x <= 3 then result:=2 else result:=3; end
 else begin result:=10; if x <= 3 then result:=11 else result:=12; end;
end;
function tdword_109(x:dword):longint;
begin
 result:=0;
 if x <> 5 then begin result:=1; if x <= 5 then result:=2 else result:=3; end
 else begin result:=10; if x <= 5 then result:=11 else result:=12; end;
end;
function tdword_110(x:dword):longint;
begin
 result:=0;
 if x <> 5 then begin result:=1; if x <= 7 then result:=2 else result:=3; end
 else begin result:=10; if x <= 7 then result:=11 else result:=12; end;
end;
function tdword_111(x:dword):longint;
begin
 result:=0;
 if x <> 5 then begin result:=1; if x <= 12 then result:=2 else result:=3; end
 else begin result:=10; if x <= 12 then result:=11 else result:=12; end;
end;
function tdword_112(x:dword):longint;
begin
 result:=0;
 if x <> 5 then begin result:=1; if x > 3 then result:=2 else result:=3; end
 else begin result:=10; if x > 3 then result:=11 else result:=12; end;
end;
function tdword_113(x:dword):longint;
begin
 result:=0;
 if x <> 5 then begin result:=1; if x > 5 then result:=2 else result:=3; end
 else begin result:=10; if x > 5 then result:=11 else result:=12; end;
end;
function tdword_114(x:dword):longint;
begin
 result:=0;
 if x <> 5 then begin result:=1; if x > 7 then result:=2 else result:=3; end
 else begin result:=10; if x > 7 then result:=11 else result:=12; end;
end;
function tdword_115(x:dword):longint;
begin
 result:=0;
 if x <> 5 then begin result:=1; if x > 12 then result:=2 else result:=3; end
 else begin result:=10; if x > 12 then result:=11 else result:=12; end;
end;
function tdword_116(x:dword):longint;
begin
 result:=0;
 if x <> 5 then begin result:=1; if x >= 3 then result:=2 else result:=3; end
 else begin result:=10; if x >= 3 then result:=11 else result:=12; end;
end;
function tdword_117(x:dword):longint;
begin
 result:=0;
 if x <> 5 then begin result:=1; if x >= 5 then result:=2 else result:=3; end
 else begin result:=10; if x >= 5 then result:=11 else result:=12; end;
end;
function tdword_118(x:dword):longint;
begin
 result:=0;
 if x <> 5 then begin result:=1; if x >= 7 then result:=2 else result:=3; end
 else begin result:=10; if x >= 7 then result:=11 else result:=12; end;
end;
function tdword_119(x:dword):longint;
begin
 result:=0;
 if x <> 5 then begin result:=1; if x >= 12 then result:=2 else result:=3; end
 else begin result:=10; if x >= 12 then result:=11 else result:=12; end;
end;
function tdword_120(x:dword):longint;
begin
 result:=0;
 if x <> 10 then begin result:=1; if x = 3 then result:=2 else result:=3; end
 else begin result:=10; if x = 3 then result:=11 else result:=12; end;
end;
function tdword_121(x:dword):longint;
begin
 result:=0;
 if x <> 10 then begin result:=1; if x = 5 then result:=2 else result:=3; end
 else begin result:=10; if x = 5 then result:=11 else result:=12; end;
end;
function tdword_122(x:dword):longint;
begin
 result:=0;
 if x <> 10 then begin result:=1; if x = 7 then result:=2 else result:=3; end
 else begin result:=10; if x = 7 then result:=11 else result:=12; end;
end;
function tdword_123(x:dword):longint;
begin
 result:=0;
 if x <> 10 then begin result:=1; if x = 12 then result:=2 else result:=3; end
 else begin result:=10; if x = 12 then result:=11 else result:=12; end;
end;
function tdword_124(x:dword):longint;
begin
 result:=0;
 if x <> 10 then begin result:=1; if x <> 3 then result:=2 else result:=3; end
 else begin result:=10; if x <> 3 then result:=11 else result:=12; end;
end;
function tdword_125(x:dword):longint;
begin
 result:=0;
 if x <> 10 then begin result:=1; if x <> 5 then result:=2 else result:=3; end
 else begin result:=10; if x <> 5 then result:=11 else result:=12; end;
end;
function tdword_126(x:dword):longint;
begin
 result:=0;
 if x <> 10 then begin result:=1; if x <> 7 then result:=2 else result:=3; end
 else begin result:=10; if x <> 7 then result:=11 else result:=12; end;
end;
function tdword_127(x:dword):longint;
begin
 result:=0;
 if x <> 10 then begin result:=1; if x <> 12 then result:=2 else result:=3; end
 else begin result:=10; if x <> 12 then result:=11 else result:=12; end;
end;
function tdword_128(x:dword):longint;
begin
 result:=0;
 if x <> 10 then begin result:=1; if x < 3 then result:=2 else result:=3; end
 else begin result:=10; if x < 3 then result:=11 else result:=12; end;
end;
function tdword_129(x:dword):longint;
begin
 result:=0;
 if x <> 10 then begin result:=1; if x < 5 then result:=2 else result:=3; end
 else begin result:=10; if x < 5 then result:=11 else result:=12; end;
end;
function tdword_130(x:dword):longint;
begin
 result:=0;
 if x <> 10 then begin result:=1; if x < 7 then result:=2 else result:=3; end
 else begin result:=10; if x < 7 then result:=11 else result:=12; end;
end;
function tdword_131(x:dword):longint;
begin
 result:=0;
 if x <> 10 then begin result:=1; if x < 12 then result:=2 else result:=3; end
 else begin result:=10; if x < 12 then result:=11 else result:=12; end;
end;
function tdword_132(x:dword):longint;
begin
 result:=0;
 if x <> 10 then begin result:=1; if x <= 3 then result:=2 else result:=3; end
 else begin result:=10; if x <= 3 then result:=11 else result:=12; end;
end;
function tdword_133(x:dword):longint;
begin
 result:=0;
 if x <> 10 then begin result:=1; if x <= 5 then result:=2 else result:=3; end
 else begin result:=10; if x <= 5 then result:=11 else result:=12; end;
end;
function tdword_134(x:dword):longint;
begin
 result:=0;
 if x <> 10 then begin result:=1; if x <= 7 then result:=2 else result:=3; end
 else begin result:=10; if x <= 7 then result:=11 else result:=12; end;
end;
function tdword_135(x:dword):longint;
begin
 result:=0;
 if x <> 10 then begin result:=1; if x <= 12 then result:=2 else result:=3; end
 else begin result:=10; if x <= 12 then result:=11 else result:=12; end;
end;
function tdword_136(x:dword):longint;
begin
 result:=0;
 if x <> 10 then begin result:=1; if x > 3 then result:=2 else result:=3; end
 else begin result:=10; if x > 3 then result:=11 else result:=12; end;
end;
function tdword_137(x:dword):longint;
begin
 result:=0;
 if x <> 10 then begin result:=1; if x > 5 then result:=2 else result:=3; end
 else begin result:=10; if x > 5 then result:=11 else result:=12; end;
end;
function tdword_138(x:dword):longint;
begin
 result:=0;
 if x <> 10 then begin result:=1; if x > 7 then result:=2 else result:=3; end
 else begin result:=10; if x > 7 then result:=11 else result:=12; end;
end;
function tdword_139(x:dword):longint;
begin
 result:=0;
 if x <> 10 then begin result:=1; if x > 12 then result:=2 else result:=3; end
 else begin result:=10; if x > 12 then result:=11 else result:=12; end;
end;
function tdword_140(x:dword):longint;
begin
 result:=0;
 if x <> 10 then begin result:=1; if x >= 3 then result:=2 else result:=3; end
 else begin result:=10; if x >= 3 then result:=11 else result:=12; end;
end;
function tdword_141(x:dword):longint;
begin
 result:=0;
 if x <> 10 then begin result:=1; if x >= 5 then result:=2 else result:=3; end
 else begin result:=10; if x >= 5 then result:=11 else result:=12; end;
end;
function tdword_142(x:dword):longint;
begin
 result:=0;
 if x <> 10 then begin result:=1; if x >= 7 then result:=2 else result:=3; end
 else begin result:=10; if x >= 7 then result:=11 else result:=12; end;
end;
function tdword_143(x:dword):longint;
begin
 result:=0;
 if x <> 10 then begin result:=1; if x >= 12 then result:=2 else result:=3; end
 else begin result:=10; if x >= 12 then result:=11 else result:=12; end;
end;
function tdword_144(x:dword):longint;
begin
 result:=0;
 if x < 0 then begin result:=1; if x = 3 then result:=2 else result:=3; end
 else begin result:=10; if x = 3 then result:=11 else result:=12; end;
end;
function tdword_145(x:dword):longint;
begin
 result:=0;
 if x < 0 then begin result:=1; if x = 5 then result:=2 else result:=3; end
 else begin result:=10; if x = 5 then result:=11 else result:=12; end;
end;
function tdword_146(x:dword):longint;
begin
 result:=0;
 if x < 0 then begin result:=1; if x = 7 then result:=2 else result:=3; end
 else begin result:=10; if x = 7 then result:=11 else result:=12; end;
end;
function tdword_147(x:dword):longint;
begin
 result:=0;
 if x < 0 then begin result:=1; if x = 12 then result:=2 else result:=3; end
 else begin result:=10; if x = 12 then result:=11 else result:=12; end;
end;
function tdword_148(x:dword):longint;
begin
 result:=0;
 if x < 0 then begin result:=1; if x <> 3 then result:=2 else result:=3; end
 else begin result:=10; if x <> 3 then result:=11 else result:=12; end;
end;
function tdword_149(x:dword):longint;
begin
 result:=0;
 if x < 0 then begin result:=1; if x <> 5 then result:=2 else result:=3; end
 else begin result:=10; if x <> 5 then result:=11 else result:=12; end;
end;
function tdword_150(x:dword):longint;
begin
 result:=0;
 if x < 0 then begin result:=1; if x <> 7 then result:=2 else result:=3; end
 else begin result:=10; if x <> 7 then result:=11 else result:=12; end;
end;
function tdword_151(x:dword):longint;
begin
 result:=0;
 if x < 0 then begin result:=1; if x <> 12 then result:=2 else result:=3; end
 else begin result:=10; if x <> 12 then result:=11 else result:=12; end;
end;
function tdword_152(x:dword):longint;
begin
 result:=0;
 if x < 0 then begin result:=1; if x < 3 then result:=2 else result:=3; end
 else begin result:=10; if x < 3 then result:=11 else result:=12; end;
end;
function tdword_153(x:dword):longint;
begin
 result:=0;
 if x < 0 then begin result:=1; if x < 5 then result:=2 else result:=3; end
 else begin result:=10; if x < 5 then result:=11 else result:=12; end;
end;
function tdword_154(x:dword):longint;
begin
 result:=0;
 if x < 0 then begin result:=1; if x < 7 then result:=2 else result:=3; end
 else begin result:=10; if x < 7 then result:=11 else result:=12; end;
end;
function tdword_155(x:dword):longint;
begin
 result:=0;
 if x < 0 then begin result:=1; if x < 12 then result:=2 else result:=3; end
 else begin result:=10; if x < 12 then result:=11 else result:=12; end;
end;
function tdword_156(x:dword):longint;
begin
 result:=0;
 if x < 0 then begin result:=1; if x <= 3 then result:=2 else result:=3; end
 else begin result:=10; if x <= 3 then result:=11 else result:=12; end;
end;
function tdword_157(x:dword):longint;
begin
 result:=0;
 if x < 0 then begin result:=1; if x <= 5 then result:=2 else result:=3; end
 else begin result:=10; if x <= 5 then result:=11 else result:=12; end;
end;
function tdword_158(x:dword):longint;
begin
 result:=0;
 if x < 0 then begin result:=1; if x <= 7 then result:=2 else result:=3; end
 else begin result:=10; if x <= 7 then result:=11 else result:=12; end;
end;
function tdword_159(x:dword):longint;
begin
 result:=0;
 if x < 0 then begin result:=1; if x <= 12 then result:=2 else result:=3; end
 else begin result:=10; if x <= 12 then result:=11 else result:=12; end;
end;
function tdword_160(x:dword):longint;
begin
 result:=0;
 if x < 0 then begin result:=1; if x > 3 then result:=2 else result:=3; end
 else begin result:=10; if x > 3 then result:=11 else result:=12; end;
end;
function tdword_161(x:dword):longint;
begin
 result:=0;
 if x < 0 then begin result:=1; if x > 5 then result:=2 else result:=3; end
 else begin result:=10; if x > 5 then result:=11 else result:=12; end;
end;
function tdword_162(x:dword):longint;
begin
 result:=0;
 if x < 0 then begin result:=1; if x > 7 then result:=2 else result:=3; end
 else begin result:=10; if x > 7 then result:=11 else result:=12; end;
end;
function tdword_163(x:dword):longint;
begin
 result:=0;
 if x < 0 then begin result:=1; if x > 12 then result:=2 else result:=3; end
 else begin result:=10; if x > 12 then result:=11 else result:=12; end;
end;
function tdword_164(x:dword):longint;
begin
 result:=0;
 if x < 0 then begin result:=1; if x >= 3 then result:=2 else result:=3; end
 else begin result:=10; if x >= 3 then result:=11 else result:=12; end;
end;
function tdword_165(x:dword):longint;
begin
 result:=0;
 if x < 0 then begin result:=1; if x >= 5 then result:=2 else result:=3; end
 else begin result:=10; if x >= 5 then result:=11 else result:=12; end;
end;
function tdword_166(x:dword):longint;
begin
 result:=0;
 if x < 0 then begin result:=1; if x >= 7 then result:=2 else result:=3; end
 else begin result:=10; if x >= 7 then result:=11 else result:=12; end;
end;
function tdword_167(x:dword):longint;
begin
 result:=0;
 if x < 0 then begin result:=1; if x >= 12 then result:=2 else result:=3; end
 else begin result:=10; if x >= 12 then result:=11 else result:=12; end;
end;
function tdword_168(x:dword):longint;
begin
 result:=0;
 if x < 5 then begin result:=1; if x = 3 then result:=2 else result:=3; end
 else begin result:=10; if x = 3 then result:=11 else result:=12; end;
end;
function tdword_169(x:dword):longint;
begin
 result:=0;
 if x < 5 then begin result:=1; if x = 5 then result:=2 else result:=3; end
 else begin result:=10; if x = 5 then result:=11 else result:=12; end;
end;
function tdword_170(x:dword):longint;
begin
 result:=0;
 if x < 5 then begin result:=1; if x = 7 then result:=2 else result:=3; end
 else begin result:=10; if x = 7 then result:=11 else result:=12; end;
end;
function tdword_171(x:dword):longint;
begin
 result:=0;
 if x < 5 then begin result:=1; if x = 12 then result:=2 else result:=3; end
 else begin result:=10; if x = 12 then result:=11 else result:=12; end;
end;
function tdword_172(x:dword):longint;
begin
 result:=0;
 if x < 5 then begin result:=1; if x <> 3 then result:=2 else result:=3; end
 else begin result:=10; if x <> 3 then result:=11 else result:=12; end;
end;
function tdword_173(x:dword):longint;
begin
 result:=0;
 if x < 5 then begin result:=1; if x <> 5 then result:=2 else result:=3; end
 else begin result:=10; if x <> 5 then result:=11 else result:=12; end;
end;
function tdword_174(x:dword):longint;
begin
 result:=0;
 if x < 5 then begin result:=1; if x <> 7 then result:=2 else result:=3; end
 else begin result:=10; if x <> 7 then result:=11 else result:=12; end;
end;
function tdword_175(x:dword):longint;
begin
 result:=0;
 if x < 5 then begin result:=1; if x <> 12 then result:=2 else result:=3; end
 else begin result:=10; if x <> 12 then result:=11 else result:=12; end;
end;
function tdword_176(x:dword):longint;
begin
 result:=0;
 if x < 5 then begin result:=1; if x < 3 then result:=2 else result:=3; end
 else begin result:=10; if x < 3 then result:=11 else result:=12; end;
end;
function tdword_177(x:dword):longint;
begin
 result:=0;
 if x < 5 then begin result:=1; if x < 5 then result:=2 else result:=3; end
 else begin result:=10; if x < 5 then result:=11 else result:=12; end;
end;
function tdword_178(x:dword):longint;
begin
 result:=0;
 if x < 5 then begin result:=1; if x < 7 then result:=2 else result:=3; end
 else begin result:=10; if x < 7 then result:=11 else result:=12; end;
end;
function tdword_179(x:dword):longint;
begin
 result:=0;
 if x < 5 then begin result:=1; if x < 12 then result:=2 else result:=3; end
 else begin result:=10; if x < 12 then result:=11 else result:=12; end;
end;
function tdword_180(x:dword):longint;
begin
 result:=0;
 if x < 5 then begin result:=1; if x <= 3 then result:=2 else result:=3; end
 else begin result:=10; if x <= 3 then result:=11 else result:=12; end;
end;
function tdword_181(x:dword):longint;
begin
 result:=0;
 if x < 5 then begin result:=1; if x <= 5 then result:=2 else result:=3; end
 else begin result:=10; if x <= 5 then result:=11 else result:=12; end;
end;
function tdword_182(x:dword):longint;
begin
 result:=0;
 if x < 5 then begin result:=1; if x <= 7 then result:=2 else result:=3; end
 else begin result:=10; if x <= 7 then result:=11 else result:=12; end;
end;
function tdword_183(x:dword):longint;
begin
 result:=0;
 if x < 5 then begin result:=1; if x <= 12 then result:=2 else result:=3; end
 else begin result:=10; if x <= 12 then result:=11 else result:=12; end;
end;
function tdword_184(x:dword):longint;
begin
 result:=0;
 if x < 5 then begin result:=1; if x > 3 then result:=2 else result:=3; end
 else begin result:=10; if x > 3 then result:=11 else result:=12; end;
end;
function tdword_185(x:dword):longint;
begin
 result:=0;
 if x < 5 then begin result:=1; if x > 5 then result:=2 else result:=3; end
 else begin result:=10; if x > 5 then result:=11 else result:=12; end;
end;
function tdword_186(x:dword):longint;
begin
 result:=0;
 if x < 5 then begin result:=1; if x > 7 then result:=2 else result:=3; end
 else begin result:=10; if x > 7 then result:=11 else result:=12; end;
end;
function tdword_187(x:dword):longint;
begin
 result:=0;
 if x < 5 then begin result:=1; if x > 12 then result:=2 else result:=3; end
 else begin result:=10; if x > 12 then result:=11 else result:=12; end;
end;
function tdword_188(x:dword):longint;
begin
 result:=0;
 if x < 5 then begin result:=1; if x >= 3 then result:=2 else result:=3; end
 else begin result:=10; if x >= 3 then result:=11 else result:=12; end;
end;
function tdword_189(x:dword):longint;
begin
 result:=0;
 if x < 5 then begin result:=1; if x >= 5 then result:=2 else result:=3; end
 else begin result:=10; if x >= 5 then result:=11 else result:=12; end;
end;
function tdword_190(x:dword):longint;
begin
 result:=0;
 if x < 5 then begin result:=1; if x >= 7 then result:=2 else result:=3; end
 else begin result:=10; if x >= 7 then result:=11 else result:=12; end;
end;
function tdword_191(x:dword):longint;
begin
 result:=0;
 if x < 5 then begin result:=1; if x >= 12 then result:=2 else result:=3; end
 else begin result:=10; if x >= 12 then result:=11 else result:=12; end;
end;
function tdword_192(x:dword):longint;
begin
 result:=0;
 if x < 10 then begin result:=1; if x = 3 then result:=2 else result:=3; end
 else begin result:=10; if x = 3 then result:=11 else result:=12; end;
end;
function tdword_193(x:dword):longint;
begin
 result:=0;
 if x < 10 then begin result:=1; if x = 5 then result:=2 else result:=3; end
 else begin result:=10; if x = 5 then result:=11 else result:=12; end;
end;
function tdword_194(x:dword):longint;
begin
 result:=0;
 if x < 10 then begin result:=1; if x = 7 then result:=2 else result:=3; end
 else begin result:=10; if x = 7 then result:=11 else result:=12; end;
end;
function tdword_195(x:dword):longint;
begin
 result:=0;
 if x < 10 then begin result:=1; if x = 12 then result:=2 else result:=3; end
 else begin result:=10; if x = 12 then result:=11 else result:=12; end;
end;
function tdword_196(x:dword):longint;
begin
 result:=0;
 if x < 10 then begin result:=1; if x <> 3 then result:=2 else result:=3; end
 else begin result:=10; if x <> 3 then result:=11 else result:=12; end;
end;
function tdword_197(x:dword):longint;
begin
 result:=0;
 if x < 10 then begin result:=1; if x <> 5 then result:=2 else result:=3; end
 else begin result:=10; if x <> 5 then result:=11 else result:=12; end;
end;
function tdword_198(x:dword):longint;
begin
 result:=0;
 if x < 10 then begin result:=1; if x <> 7 then result:=2 else result:=3; end
 else begin result:=10; if x <> 7 then result:=11 else result:=12; end;
end;
function tdword_199(x:dword):longint;
begin
 result:=0;
 if x < 10 then begin result:=1; if x <> 12 then result:=2 else result:=3; end
 else begin result:=10; if x <> 12 then result:=11 else result:=12; end;
end;
function tdword_200(x:dword):longint;
begin
 result:=0;
 if x < 10 then begin result:=1; if x < 3 then result:=2 else result:=3; end
 else begin result:=10; if x < 3 then result:=11 else result:=12; end;
end;
function tdword_201(x:dword):longint;
begin
 result:=0;
 if x < 10 then begin result:=1; if x < 5 then result:=2 else result:=3; end
 else begin result:=10; if x < 5 then result:=11 else result:=12; end;
end;
function tdword_202(x:dword):longint;
begin
 result:=0;
 if x < 10 then begin result:=1; if x < 7 then result:=2 else result:=3; end
 else begin result:=10; if x < 7 then result:=11 else result:=12; end;
end;
function tdword_203(x:dword):longint;
begin
 result:=0;
 if x < 10 then begin result:=1; if x < 12 then result:=2 else result:=3; end
 else begin result:=10; if x < 12 then result:=11 else result:=12; end;
end;
function tdword_204(x:dword):longint;
begin
 result:=0;
 if x < 10 then begin result:=1; if x <= 3 then result:=2 else result:=3; end
 else begin result:=10; if x <= 3 then result:=11 else result:=12; end;
end;
function tdword_205(x:dword):longint;
begin
 result:=0;
 if x < 10 then begin result:=1; if x <= 5 then result:=2 else result:=3; end
 else begin result:=10; if x <= 5 then result:=11 else result:=12; end;
end;
function tdword_206(x:dword):longint;
begin
 result:=0;
 if x < 10 then begin result:=1; if x <= 7 then result:=2 else result:=3; end
 else begin result:=10; if x <= 7 then result:=11 else result:=12; end;
end;
function tdword_207(x:dword):longint;
begin
 result:=0;
 if x < 10 then begin result:=1; if x <= 12 then result:=2 else result:=3; end
 else begin result:=10; if x <= 12 then result:=11 else result:=12; end;
end;
function tdword_208(x:dword):longint;
begin
 result:=0;
 if x < 10 then begin result:=1; if x > 3 then result:=2 else result:=3; end
 else begin result:=10; if x > 3 then result:=11 else result:=12; end;
end;
function tdword_209(x:dword):longint;
begin
 result:=0;
 if x < 10 then begin result:=1; if x > 5 then result:=2 else result:=3; end
 else begin result:=10; if x > 5 then result:=11 else result:=12; end;
end;
function tdword_210(x:dword):longint;
begin
 result:=0;
 if x < 10 then begin result:=1; if x > 7 then result:=2 else result:=3; end
 else begin result:=10; if x > 7 then result:=11 else result:=12; end;
end;
function tdword_211(x:dword):longint;
begin
 result:=0;
 if x < 10 then begin result:=1; if x > 12 then result:=2 else result:=3; end
 else begin result:=10; if x > 12 then result:=11 else result:=12; end;
end;
function tdword_212(x:dword):longint;
begin
 result:=0;
 if x < 10 then begin result:=1; if x >= 3 then result:=2 else result:=3; end
 else begin result:=10; if x >= 3 then result:=11 else result:=12; end;
end;
function tdword_213(x:dword):longint;
begin
 result:=0;
 if x < 10 then begin result:=1; if x >= 5 then result:=2 else result:=3; end
 else begin result:=10; if x >= 5 then result:=11 else result:=12; end;
end;
function tdword_214(x:dword):longint;
begin
 result:=0;
 if x < 10 then begin result:=1; if x >= 7 then result:=2 else result:=3; end
 else begin result:=10; if x >= 7 then result:=11 else result:=12; end;
end;
function tdword_215(x:dword):longint;
begin
 result:=0;
 if x < 10 then begin result:=1; if x >= 12 then result:=2 else result:=3; end
 else begin result:=10; if x >= 12 then result:=11 else result:=12; end;
end;
function tdword_216(x:dword):longint;
begin
 result:=0;
 if x <= 0 then begin result:=1; if x = 3 then result:=2 else result:=3; end
 else begin result:=10; if x = 3 then result:=11 else result:=12; end;
end;
function tdword_217(x:dword):longint;
begin
 result:=0;
 if x <= 0 then begin result:=1; if x = 5 then result:=2 else result:=3; end
 else begin result:=10; if x = 5 then result:=11 else result:=12; end;
end;
function tdword_218(x:dword):longint;
begin
 result:=0;
 if x <= 0 then begin result:=1; if x = 7 then result:=2 else result:=3; end
 else begin result:=10; if x = 7 then result:=11 else result:=12; end;
end;
function tdword_219(x:dword):longint;
begin
 result:=0;
 if x <= 0 then begin result:=1; if x = 12 then result:=2 else result:=3; end
 else begin result:=10; if x = 12 then result:=11 else result:=12; end;
end;
function tdword_220(x:dword):longint;
begin
 result:=0;
 if x <= 0 then begin result:=1; if x <> 3 then result:=2 else result:=3; end
 else begin result:=10; if x <> 3 then result:=11 else result:=12; end;
end;
function tdword_221(x:dword):longint;
begin
 result:=0;
 if x <= 0 then begin result:=1; if x <> 5 then result:=2 else result:=3; end
 else begin result:=10; if x <> 5 then result:=11 else result:=12; end;
end;
function tdword_222(x:dword):longint;
begin
 result:=0;
 if x <= 0 then begin result:=1; if x <> 7 then result:=2 else result:=3; end
 else begin result:=10; if x <> 7 then result:=11 else result:=12; end;
end;
function tdword_223(x:dword):longint;
begin
 result:=0;
 if x <= 0 then begin result:=1; if x <> 12 then result:=2 else result:=3; end
 else begin result:=10; if x <> 12 then result:=11 else result:=12; end;
end;
function tdword_224(x:dword):longint;
begin
 result:=0;
 if x <= 0 then begin result:=1; if x < 3 then result:=2 else result:=3; end
 else begin result:=10; if x < 3 then result:=11 else result:=12; end;
end;
function tdword_225(x:dword):longint;
begin
 result:=0;
 if x <= 0 then begin result:=1; if x < 5 then result:=2 else result:=3; end
 else begin result:=10; if x < 5 then result:=11 else result:=12; end;
end;
function tdword_226(x:dword):longint;
begin
 result:=0;
 if x <= 0 then begin result:=1; if x < 7 then result:=2 else result:=3; end
 else begin result:=10; if x < 7 then result:=11 else result:=12; end;
end;
function tdword_227(x:dword):longint;
begin
 result:=0;
 if x <= 0 then begin result:=1; if x < 12 then result:=2 else result:=3; end
 else begin result:=10; if x < 12 then result:=11 else result:=12; end;
end;
function tdword_228(x:dword):longint;
begin
 result:=0;
 if x <= 0 then begin result:=1; if x <= 3 then result:=2 else result:=3; end
 else begin result:=10; if x <= 3 then result:=11 else result:=12; end;
end;
function tdword_229(x:dword):longint;
begin
 result:=0;
 if x <= 0 then begin result:=1; if x <= 5 then result:=2 else result:=3; end
 else begin result:=10; if x <= 5 then result:=11 else result:=12; end;
end;
function tdword_230(x:dword):longint;
begin
 result:=0;
 if x <= 0 then begin result:=1; if x <= 7 then result:=2 else result:=3; end
 else begin result:=10; if x <= 7 then result:=11 else result:=12; end;
end;
function tdword_231(x:dword):longint;
begin
 result:=0;
 if x <= 0 then begin result:=1; if x <= 12 then result:=2 else result:=3; end
 else begin result:=10; if x <= 12 then result:=11 else result:=12; end;
end;
function tdword_232(x:dword):longint;
begin
 result:=0;
 if x <= 0 then begin result:=1; if x > 3 then result:=2 else result:=3; end
 else begin result:=10; if x > 3 then result:=11 else result:=12; end;
end;
function tdword_233(x:dword):longint;
begin
 result:=0;
 if x <= 0 then begin result:=1; if x > 5 then result:=2 else result:=3; end
 else begin result:=10; if x > 5 then result:=11 else result:=12; end;
end;
function tdword_234(x:dword):longint;
begin
 result:=0;
 if x <= 0 then begin result:=1; if x > 7 then result:=2 else result:=3; end
 else begin result:=10; if x > 7 then result:=11 else result:=12; end;
end;
function tdword_235(x:dword):longint;
begin
 result:=0;
 if x <= 0 then begin result:=1; if x > 12 then result:=2 else result:=3; end
 else begin result:=10; if x > 12 then result:=11 else result:=12; end;
end;
function tdword_236(x:dword):longint;
begin
 result:=0;
 if x <= 0 then begin result:=1; if x >= 3 then result:=2 else result:=3; end
 else begin result:=10; if x >= 3 then result:=11 else result:=12; end;
end;
function tdword_237(x:dword):longint;
begin
 result:=0;
 if x <= 0 then begin result:=1; if x >= 5 then result:=2 else result:=3; end
 else begin result:=10; if x >= 5 then result:=11 else result:=12; end;
end;
function tdword_238(x:dword):longint;
begin
 result:=0;
 if x <= 0 then begin result:=1; if x >= 7 then result:=2 else result:=3; end
 else begin result:=10; if x >= 7 then result:=11 else result:=12; end;
end;
function tdword_239(x:dword):longint;
begin
 result:=0;
 if x <= 0 then begin result:=1; if x >= 12 then result:=2 else result:=3; end
 else begin result:=10; if x >= 12 then result:=11 else result:=12; end;
end;
function tdword_240(x:dword):longint;
begin
 result:=0;
 if x <= 5 then begin result:=1; if x = 3 then result:=2 else result:=3; end
 else begin result:=10; if x = 3 then result:=11 else result:=12; end;
end;
function tdword_241(x:dword):longint;
begin
 result:=0;
 if x <= 5 then begin result:=1; if x = 5 then result:=2 else result:=3; end
 else begin result:=10; if x = 5 then result:=11 else result:=12; end;
end;
function tdword_242(x:dword):longint;
begin
 result:=0;
 if x <= 5 then begin result:=1; if x = 7 then result:=2 else result:=3; end
 else begin result:=10; if x = 7 then result:=11 else result:=12; end;
end;
function tdword_243(x:dword):longint;
begin
 result:=0;
 if x <= 5 then begin result:=1; if x = 12 then result:=2 else result:=3; end
 else begin result:=10; if x = 12 then result:=11 else result:=12; end;
end;
function tdword_244(x:dword):longint;
begin
 result:=0;
 if x <= 5 then begin result:=1; if x <> 3 then result:=2 else result:=3; end
 else begin result:=10; if x <> 3 then result:=11 else result:=12; end;
end;
function tdword_245(x:dword):longint;
begin
 result:=0;
 if x <= 5 then begin result:=1; if x <> 5 then result:=2 else result:=3; end
 else begin result:=10; if x <> 5 then result:=11 else result:=12; end;
end;
function tdword_246(x:dword):longint;
begin
 result:=0;
 if x <= 5 then begin result:=1; if x <> 7 then result:=2 else result:=3; end
 else begin result:=10; if x <> 7 then result:=11 else result:=12; end;
end;
function tdword_247(x:dword):longint;
begin
 result:=0;
 if x <= 5 then begin result:=1; if x <> 12 then result:=2 else result:=3; end
 else begin result:=10; if x <> 12 then result:=11 else result:=12; end;
end;
function tdword_248(x:dword):longint;
begin
 result:=0;
 if x <= 5 then begin result:=1; if x < 3 then result:=2 else result:=3; end
 else begin result:=10; if x < 3 then result:=11 else result:=12; end;
end;
function tdword_249(x:dword):longint;
begin
 result:=0;
 if x <= 5 then begin result:=1; if x < 5 then result:=2 else result:=3; end
 else begin result:=10; if x < 5 then result:=11 else result:=12; end;
end;
function tdword_250(x:dword):longint;
begin
 result:=0;
 if x <= 5 then begin result:=1; if x < 7 then result:=2 else result:=3; end
 else begin result:=10; if x < 7 then result:=11 else result:=12; end;
end;
function tdword_251(x:dword):longint;
begin
 result:=0;
 if x <= 5 then begin result:=1; if x < 12 then result:=2 else result:=3; end
 else begin result:=10; if x < 12 then result:=11 else result:=12; end;
end;
function tdword_252(x:dword):longint;
begin
 result:=0;
 if x <= 5 then begin result:=1; if x <= 3 then result:=2 else result:=3; end
 else begin result:=10; if x <= 3 then result:=11 else result:=12; end;
end;
function tdword_253(x:dword):longint;
begin
 result:=0;
 if x <= 5 then begin result:=1; if x <= 5 then result:=2 else result:=3; end
 else begin result:=10; if x <= 5 then result:=11 else result:=12; end;
end;
function tdword_254(x:dword):longint;
begin
 result:=0;
 if x <= 5 then begin result:=1; if x <= 7 then result:=2 else result:=3; end
 else begin result:=10; if x <= 7 then result:=11 else result:=12; end;
end;
function tdword_255(x:dword):longint;
begin
 result:=0;
 if x <= 5 then begin result:=1; if x <= 12 then result:=2 else result:=3; end
 else begin result:=10; if x <= 12 then result:=11 else result:=12; end;
end;
function tdword_256(x:dword):longint;
begin
 result:=0;
 if x <= 5 then begin result:=1; if x > 3 then result:=2 else result:=3; end
 else begin result:=10; if x > 3 then result:=11 else result:=12; end;
end;
function tdword_257(x:dword):longint;
begin
 result:=0;
 if x <= 5 then begin result:=1; if x > 5 then result:=2 else result:=3; end
 else begin result:=10; if x > 5 then result:=11 else result:=12; end;
end;
function tdword_258(x:dword):longint;
begin
 result:=0;
 if x <= 5 then begin result:=1; if x > 7 then result:=2 else result:=3; end
 else begin result:=10; if x > 7 then result:=11 else result:=12; end;
end;
function tdword_259(x:dword):longint;
begin
 result:=0;
 if x <= 5 then begin result:=1; if x > 12 then result:=2 else result:=3; end
 else begin result:=10; if x > 12 then result:=11 else result:=12; end;
end;
function tdword_260(x:dword):longint;
begin
 result:=0;
 if x <= 5 then begin result:=1; if x >= 3 then result:=2 else result:=3; end
 else begin result:=10; if x >= 3 then result:=11 else result:=12; end;
end;
function tdword_261(x:dword):longint;
begin
 result:=0;
 if x <= 5 then begin result:=1; if x >= 5 then result:=2 else result:=3; end
 else begin result:=10; if x >= 5 then result:=11 else result:=12; end;
end;
function tdword_262(x:dword):longint;
begin
 result:=0;
 if x <= 5 then begin result:=1; if x >= 7 then result:=2 else result:=3; end
 else begin result:=10; if x >= 7 then result:=11 else result:=12; end;
end;
function tdword_263(x:dword):longint;
begin
 result:=0;
 if x <= 5 then begin result:=1; if x >= 12 then result:=2 else result:=3; end
 else begin result:=10; if x >= 12 then result:=11 else result:=12; end;
end;
function tdword_264(x:dword):longint;
begin
 result:=0;
 if x <= 10 then begin result:=1; if x = 3 then result:=2 else result:=3; end
 else begin result:=10; if x = 3 then result:=11 else result:=12; end;
end;
function tdword_265(x:dword):longint;
begin
 result:=0;
 if x <= 10 then begin result:=1; if x = 5 then result:=2 else result:=3; end
 else begin result:=10; if x = 5 then result:=11 else result:=12; end;
end;
function tdword_266(x:dword):longint;
begin
 result:=0;
 if x <= 10 then begin result:=1; if x = 7 then result:=2 else result:=3; end
 else begin result:=10; if x = 7 then result:=11 else result:=12; end;
end;
function tdword_267(x:dword):longint;
begin
 result:=0;
 if x <= 10 then begin result:=1; if x = 12 then result:=2 else result:=3; end
 else begin result:=10; if x = 12 then result:=11 else result:=12; end;
end;
function tdword_268(x:dword):longint;
begin
 result:=0;
 if x <= 10 then begin result:=1; if x <> 3 then result:=2 else result:=3; end
 else begin result:=10; if x <> 3 then result:=11 else result:=12; end;
end;
function tdword_269(x:dword):longint;
begin
 result:=0;
 if x <= 10 then begin result:=1; if x <> 5 then result:=2 else result:=3; end
 else begin result:=10; if x <> 5 then result:=11 else result:=12; end;
end;
function tdword_270(x:dword):longint;
begin
 result:=0;
 if x <= 10 then begin result:=1; if x <> 7 then result:=2 else result:=3; end
 else begin result:=10; if x <> 7 then result:=11 else result:=12; end;
end;
function tdword_271(x:dword):longint;
begin
 result:=0;
 if x <= 10 then begin result:=1; if x <> 12 then result:=2 else result:=3; end
 else begin result:=10; if x <> 12 then result:=11 else result:=12; end;
end;
function tdword_272(x:dword):longint;
begin
 result:=0;
 if x <= 10 then begin result:=1; if x < 3 then result:=2 else result:=3; end
 else begin result:=10; if x < 3 then result:=11 else result:=12; end;
end;
function tdword_273(x:dword):longint;
begin
 result:=0;
 if x <= 10 then begin result:=1; if x < 5 then result:=2 else result:=3; end
 else begin result:=10; if x < 5 then result:=11 else result:=12; end;
end;
function tdword_274(x:dword):longint;
begin
 result:=0;
 if x <= 10 then begin result:=1; if x < 7 then result:=2 else result:=3; end
 else begin result:=10; if x < 7 then result:=11 else result:=12; end;
end;
function tdword_275(x:dword):longint;
begin
 result:=0;
 if x <= 10 then begin result:=1; if x < 12 then result:=2 else result:=3; end
 else begin result:=10; if x < 12 then result:=11 else result:=12; end;
end;
function tdword_276(x:dword):longint;
begin
 result:=0;
 if x <= 10 then begin result:=1; if x <= 3 then result:=2 else result:=3; end
 else begin result:=10; if x <= 3 then result:=11 else result:=12; end;
end;
function tdword_277(x:dword):longint;
begin
 result:=0;
 if x <= 10 then begin result:=1; if x <= 5 then result:=2 else result:=3; end
 else begin result:=10; if x <= 5 then result:=11 else result:=12; end;
end;
function tdword_278(x:dword):longint;
begin
 result:=0;
 if x <= 10 then begin result:=1; if x <= 7 then result:=2 else result:=3; end
 else begin result:=10; if x <= 7 then result:=11 else result:=12; end;
end;
function tdword_279(x:dword):longint;
begin
 result:=0;
 if x <= 10 then begin result:=1; if x <= 12 then result:=2 else result:=3; end
 else begin result:=10; if x <= 12 then result:=11 else result:=12; end;
end;
function tdword_280(x:dword):longint;
begin
 result:=0;
 if x <= 10 then begin result:=1; if x > 3 then result:=2 else result:=3; end
 else begin result:=10; if x > 3 then result:=11 else result:=12; end;
end;
function tdword_281(x:dword):longint;
begin
 result:=0;
 if x <= 10 then begin result:=1; if x > 5 then result:=2 else result:=3; end
 else begin result:=10; if x > 5 then result:=11 else result:=12; end;
end;
function tdword_282(x:dword):longint;
begin
 result:=0;
 if x <= 10 then begin result:=1; if x > 7 then result:=2 else result:=3; end
 else begin result:=10; if x > 7 then result:=11 else result:=12; end;
end;
function tdword_283(x:dword):longint;
begin
 result:=0;
 if x <= 10 then begin result:=1; if x > 12 then result:=2 else result:=3; end
 else begin result:=10; if x > 12 then result:=11 else result:=12; end;
end;
function tdword_284(x:dword):longint;
begin
 result:=0;
 if x <= 10 then begin result:=1; if x >= 3 then result:=2 else result:=3; end
 else begin result:=10; if x >= 3 then result:=11 else result:=12; end;
end;
function tdword_285(x:dword):longint;
begin
 result:=0;
 if x <= 10 then begin result:=1; if x >= 5 then result:=2 else result:=3; end
 else begin result:=10; if x >= 5 then result:=11 else result:=12; end;
end;
function tdword_286(x:dword):longint;
begin
 result:=0;
 if x <= 10 then begin result:=1; if x >= 7 then result:=2 else result:=3; end
 else begin result:=10; if x >= 7 then result:=11 else result:=12; end;
end;
function tdword_287(x:dword):longint;
begin
 result:=0;
 if x <= 10 then begin result:=1; if x >= 12 then result:=2 else result:=3; end
 else begin result:=10; if x >= 12 then result:=11 else result:=12; end;
end;
function tdword_288(x:dword):longint;
begin
 result:=0;
 if x > 0 then begin result:=1; if x = 3 then result:=2 else result:=3; end
 else begin result:=10; if x = 3 then result:=11 else result:=12; end;
end;
function tdword_289(x:dword):longint;
begin
 result:=0;
 if x > 0 then begin result:=1; if x = 5 then result:=2 else result:=3; end
 else begin result:=10; if x = 5 then result:=11 else result:=12; end;
end;
function tdword_290(x:dword):longint;
begin
 result:=0;
 if x > 0 then begin result:=1; if x = 7 then result:=2 else result:=3; end
 else begin result:=10; if x = 7 then result:=11 else result:=12; end;
end;
function tdword_291(x:dword):longint;
begin
 result:=0;
 if x > 0 then begin result:=1; if x = 12 then result:=2 else result:=3; end
 else begin result:=10; if x = 12 then result:=11 else result:=12; end;
end;
function tdword_292(x:dword):longint;
begin
 result:=0;
 if x > 0 then begin result:=1; if x <> 3 then result:=2 else result:=3; end
 else begin result:=10; if x <> 3 then result:=11 else result:=12; end;
end;
function tdword_293(x:dword):longint;
begin
 result:=0;
 if x > 0 then begin result:=1; if x <> 5 then result:=2 else result:=3; end
 else begin result:=10; if x <> 5 then result:=11 else result:=12; end;
end;
function tdword_294(x:dword):longint;
begin
 result:=0;
 if x > 0 then begin result:=1; if x <> 7 then result:=2 else result:=3; end
 else begin result:=10; if x <> 7 then result:=11 else result:=12; end;
end;
function tdword_295(x:dword):longint;
begin
 result:=0;
 if x > 0 then begin result:=1; if x <> 12 then result:=2 else result:=3; end
 else begin result:=10; if x <> 12 then result:=11 else result:=12; end;
end;
function tdword_296(x:dword):longint;
begin
 result:=0;
 if x > 0 then begin result:=1; if x < 3 then result:=2 else result:=3; end
 else begin result:=10; if x < 3 then result:=11 else result:=12; end;
end;
function tdword_297(x:dword):longint;
begin
 result:=0;
 if x > 0 then begin result:=1; if x < 5 then result:=2 else result:=3; end
 else begin result:=10; if x < 5 then result:=11 else result:=12; end;
end;
function tdword_298(x:dword):longint;
begin
 result:=0;
 if x > 0 then begin result:=1; if x < 7 then result:=2 else result:=3; end
 else begin result:=10; if x < 7 then result:=11 else result:=12; end;
end;
function tdword_299(x:dword):longint;
begin
 result:=0;
 if x > 0 then begin result:=1; if x < 12 then result:=2 else result:=3; end
 else begin result:=10; if x < 12 then result:=11 else result:=12; end;
end;
function tdword_300(x:dword):longint;
begin
 result:=0;
 if x > 0 then begin result:=1; if x <= 3 then result:=2 else result:=3; end
 else begin result:=10; if x <= 3 then result:=11 else result:=12; end;
end;
function tdword_301(x:dword):longint;
begin
 result:=0;
 if x > 0 then begin result:=1; if x <= 5 then result:=2 else result:=3; end
 else begin result:=10; if x <= 5 then result:=11 else result:=12; end;
end;
function tdword_302(x:dword):longint;
begin
 result:=0;
 if x > 0 then begin result:=1; if x <= 7 then result:=2 else result:=3; end
 else begin result:=10; if x <= 7 then result:=11 else result:=12; end;
end;
function tdword_303(x:dword):longint;
begin
 result:=0;
 if x > 0 then begin result:=1; if x <= 12 then result:=2 else result:=3; end
 else begin result:=10; if x <= 12 then result:=11 else result:=12; end;
end;
function tdword_304(x:dword):longint;
begin
 result:=0;
 if x > 0 then begin result:=1; if x > 3 then result:=2 else result:=3; end
 else begin result:=10; if x > 3 then result:=11 else result:=12; end;
end;
function tdword_305(x:dword):longint;
begin
 result:=0;
 if x > 0 then begin result:=1; if x > 5 then result:=2 else result:=3; end
 else begin result:=10; if x > 5 then result:=11 else result:=12; end;
end;
function tdword_306(x:dword):longint;
begin
 result:=0;
 if x > 0 then begin result:=1; if x > 7 then result:=2 else result:=3; end
 else begin result:=10; if x > 7 then result:=11 else result:=12; end;
end;
function tdword_307(x:dword):longint;
begin
 result:=0;
 if x > 0 then begin result:=1; if x > 12 then result:=2 else result:=3; end
 else begin result:=10; if x > 12 then result:=11 else result:=12; end;
end;
function tdword_308(x:dword):longint;
begin
 result:=0;
 if x > 0 then begin result:=1; if x >= 3 then result:=2 else result:=3; end
 else begin result:=10; if x >= 3 then result:=11 else result:=12; end;
end;
function tdword_309(x:dword):longint;
begin
 result:=0;
 if x > 0 then begin result:=1; if x >= 5 then result:=2 else result:=3; end
 else begin result:=10; if x >= 5 then result:=11 else result:=12; end;
end;
function tdword_310(x:dword):longint;
begin
 result:=0;
 if x > 0 then begin result:=1; if x >= 7 then result:=2 else result:=3; end
 else begin result:=10; if x >= 7 then result:=11 else result:=12; end;
end;
function tdword_311(x:dword):longint;
begin
 result:=0;
 if x > 0 then begin result:=1; if x >= 12 then result:=2 else result:=3; end
 else begin result:=10; if x >= 12 then result:=11 else result:=12; end;
end;
function tdword_312(x:dword):longint;
begin
 result:=0;
 if x > 5 then begin result:=1; if x = 3 then result:=2 else result:=3; end
 else begin result:=10; if x = 3 then result:=11 else result:=12; end;
end;
function tdword_313(x:dword):longint;
begin
 result:=0;
 if x > 5 then begin result:=1; if x = 5 then result:=2 else result:=3; end
 else begin result:=10; if x = 5 then result:=11 else result:=12; end;
end;
function tdword_314(x:dword):longint;
begin
 result:=0;
 if x > 5 then begin result:=1; if x = 7 then result:=2 else result:=3; end
 else begin result:=10; if x = 7 then result:=11 else result:=12; end;
end;
function tdword_315(x:dword):longint;
begin
 result:=0;
 if x > 5 then begin result:=1; if x = 12 then result:=2 else result:=3; end
 else begin result:=10; if x = 12 then result:=11 else result:=12; end;
end;
function tdword_316(x:dword):longint;
begin
 result:=0;
 if x > 5 then begin result:=1; if x <> 3 then result:=2 else result:=3; end
 else begin result:=10; if x <> 3 then result:=11 else result:=12; end;
end;
function tdword_317(x:dword):longint;
begin
 result:=0;
 if x > 5 then begin result:=1; if x <> 5 then result:=2 else result:=3; end
 else begin result:=10; if x <> 5 then result:=11 else result:=12; end;
end;
function tdword_318(x:dword):longint;
begin
 result:=0;
 if x > 5 then begin result:=1; if x <> 7 then result:=2 else result:=3; end
 else begin result:=10; if x <> 7 then result:=11 else result:=12; end;
end;
function tdword_319(x:dword):longint;
begin
 result:=0;
 if x > 5 then begin result:=1; if x <> 12 then result:=2 else result:=3; end
 else begin result:=10; if x <> 12 then result:=11 else result:=12; end;
end;
function tdword_320(x:dword):longint;
begin
 result:=0;
 if x > 5 then begin result:=1; if x < 3 then result:=2 else result:=3; end
 else begin result:=10; if x < 3 then result:=11 else result:=12; end;
end;
function tdword_321(x:dword):longint;
begin
 result:=0;
 if x > 5 then begin result:=1; if x < 5 then result:=2 else result:=3; end
 else begin result:=10; if x < 5 then result:=11 else result:=12; end;
end;
function tdword_322(x:dword):longint;
begin
 result:=0;
 if x > 5 then begin result:=1; if x < 7 then result:=2 else result:=3; end
 else begin result:=10; if x < 7 then result:=11 else result:=12; end;
end;
function tdword_323(x:dword):longint;
begin
 result:=0;
 if x > 5 then begin result:=1; if x < 12 then result:=2 else result:=3; end
 else begin result:=10; if x < 12 then result:=11 else result:=12; end;
end;
function tdword_324(x:dword):longint;
begin
 result:=0;
 if x > 5 then begin result:=1; if x <= 3 then result:=2 else result:=3; end
 else begin result:=10; if x <= 3 then result:=11 else result:=12; end;
end;
function tdword_325(x:dword):longint;
begin
 result:=0;
 if x > 5 then begin result:=1; if x <= 5 then result:=2 else result:=3; end
 else begin result:=10; if x <= 5 then result:=11 else result:=12; end;
end;
function tdword_326(x:dword):longint;
begin
 result:=0;
 if x > 5 then begin result:=1; if x <= 7 then result:=2 else result:=3; end
 else begin result:=10; if x <= 7 then result:=11 else result:=12; end;
end;
function tdword_327(x:dword):longint;
begin
 result:=0;
 if x > 5 then begin result:=1; if x <= 12 then result:=2 else result:=3; end
 else begin result:=10; if x <= 12 then result:=11 else result:=12; end;
end;
function tdword_328(x:dword):longint;
begin
 result:=0;
 if x > 5 then begin result:=1; if x > 3 then result:=2 else result:=3; end
 else begin result:=10; if x > 3 then result:=11 else result:=12; end;
end;
function tdword_329(x:dword):longint;
begin
 result:=0;
 if x > 5 then begin result:=1; if x > 5 then result:=2 else result:=3; end
 else begin result:=10; if x > 5 then result:=11 else result:=12; end;
end;
function tdword_330(x:dword):longint;
begin
 result:=0;
 if x > 5 then begin result:=1; if x > 7 then result:=2 else result:=3; end
 else begin result:=10; if x > 7 then result:=11 else result:=12; end;
end;
function tdword_331(x:dword):longint;
begin
 result:=0;
 if x > 5 then begin result:=1; if x > 12 then result:=2 else result:=3; end
 else begin result:=10; if x > 12 then result:=11 else result:=12; end;
end;
function tdword_332(x:dword):longint;
begin
 result:=0;
 if x > 5 then begin result:=1; if x >= 3 then result:=2 else result:=3; end
 else begin result:=10; if x >= 3 then result:=11 else result:=12; end;
end;
function tdword_333(x:dword):longint;
begin
 result:=0;
 if x > 5 then begin result:=1; if x >= 5 then result:=2 else result:=3; end
 else begin result:=10; if x >= 5 then result:=11 else result:=12; end;
end;
function tdword_334(x:dword):longint;
begin
 result:=0;
 if x > 5 then begin result:=1; if x >= 7 then result:=2 else result:=3; end
 else begin result:=10; if x >= 7 then result:=11 else result:=12; end;
end;
function tdword_335(x:dword):longint;
begin
 result:=0;
 if x > 5 then begin result:=1; if x >= 12 then result:=2 else result:=3; end
 else begin result:=10; if x >= 12 then result:=11 else result:=12; end;
end;
function tdword_336(x:dword):longint;
begin
 result:=0;
 if x > 10 then begin result:=1; if x = 3 then result:=2 else result:=3; end
 else begin result:=10; if x = 3 then result:=11 else result:=12; end;
end;
function tdword_337(x:dword):longint;
begin
 result:=0;
 if x > 10 then begin result:=1; if x = 5 then result:=2 else result:=3; end
 else begin result:=10; if x = 5 then result:=11 else result:=12; end;
end;
function tdword_338(x:dword):longint;
begin
 result:=0;
 if x > 10 then begin result:=1; if x = 7 then result:=2 else result:=3; end
 else begin result:=10; if x = 7 then result:=11 else result:=12; end;
end;
function tdword_339(x:dword):longint;
begin
 result:=0;
 if x > 10 then begin result:=1; if x = 12 then result:=2 else result:=3; end
 else begin result:=10; if x = 12 then result:=11 else result:=12; end;
end;
function tdword_340(x:dword):longint;
begin
 result:=0;
 if x > 10 then begin result:=1; if x <> 3 then result:=2 else result:=3; end
 else begin result:=10; if x <> 3 then result:=11 else result:=12; end;
end;
function tdword_341(x:dword):longint;
begin
 result:=0;
 if x > 10 then begin result:=1; if x <> 5 then result:=2 else result:=3; end
 else begin result:=10; if x <> 5 then result:=11 else result:=12; end;
end;
function tdword_342(x:dword):longint;
begin
 result:=0;
 if x > 10 then begin result:=1; if x <> 7 then result:=2 else result:=3; end
 else begin result:=10; if x <> 7 then result:=11 else result:=12; end;
end;
function tdword_343(x:dword):longint;
begin
 result:=0;
 if x > 10 then begin result:=1; if x <> 12 then result:=2 else result:=3; end
 else begin result:=10; if x <> 12 then result:=11 else result:=12; end;
end;
function tdword_344(x:dword):longint;
begin
 result:=0;
 if x > 10 then begin result:=1; if x < 3 then result:=2 else result:=3; end
 else begin result:=10; if x < 3 then result:=11 else result:=12; end;
end;
function tdword_345(x:dword):longint;
begin
 result:=0;
 if x > 10 then begin result:=1; if x < 5 then result:=2 else result:=3; end
 else begin result:=10; if x < 5 then result:=11 else result:=12; end;
end;
function tdword_346(x:dword):longint;
begin
 result:=0;
 if x > 10 then begin result:=1; if x < 7 then result:=2 else result:=3; end
 else begin result:=10; if x < 7 then result:=11 else result:=12; end;
end;
function tdword_347(x:dword):longint;
begin
 result:=0;
 if x > 10 then begin result:=1; if x < 12 then result:=2 else result:=3; end
 else begin result:=10; if x < 12 then result:=11 else result:=12; end;
end;
function tdword_348(x:dword):longint;
begin
 result:=0;
 if x > 10 then begin result:=1; if x <= 3 then result:=2 else result:=3; end
 else begin result:=10; if x <= 3 then result:=11 else result:=12; end;
end;
function tdword_349(x:dword):longint;
begin
 result:=0;
 if x > 10 then begin result:=1; if x <= 5 then result:=2 else result:=3; end
 else begin result:=10; if x <= 5 then result:=11 else result:=12; end;
end;
function tdword_350(x:dword):longint;
begin
 result:=0;
 if x > 10 then begin result:=1; if x <= 7 then result:=2 else result:=3; end
 else begin result:=10; if x <= 7 then result:=11 else result:=12; end;
end;
function tdword_351(x:dword):longint;
begin
 result:=0;
 if x > 10 then begin result:=1; if x <= 12 then result:=2 else result:=3; end
 else begin result:=10; if x <= 12 then result:=11 else result:=12; end;
end;
function tdword_352(x:dword):longint;
begin
 result:=0;
 if x > 10 then begin result:=1; if x > 3 then result:=2 else result:=3; end
 else begin result:=10; if x > 3 then result:=11 else result:=12; end;
end;
function tdword_353(x:dword):longint;
begin
 result:=0;
 if x > 10 then begin result:=1; if x > 5 then result:=2 else result:=3; end
 else begin result:=10; if x > 5 then result:=11 else result:=12; end;
end;
function tdword_354(x:dword):longint;
begin
 result:=0;
 if x > 10 then begin result:=1; if x > 7 then result:=2 else result:=3; end
 else begin result:=10; if x > 7 then result:=11 else result:=12; end;
end;
function tdword_355(x:dword):longint;
begin
 result:=0;
 if x > 10 then begin result:=1; if x > 12 then result:=2 else result:=3; end
 else begin result:=10; if x > 12 then result:=11 else result:=12; end;
end;
function tdword_356(x:dword):longint;
begin
 result:=0;
 if x > 10 then begin result:=1; if x >= 3 then result:=2 else result:=3; end
 else begin result:=10; if x >= 3 then result:=11 else result:=12; end;
end;
function tdword_357(x:dword):longint;
begin
 result:=0;
 if x > 10 then begin result:=1; if x >= 5 then result:=2 else result:=3; end
 else begin result:=10; if x >= 5 then result:=11 else result:=12; end;
end;
function tdword_358(x:dword):longint;
begin
 result:=0;
 if x > 10 then begin result:=1; if x >= 7 then result:=2 else result:=3; end
 else begin result:=10; if x >= 7 then result:=11 else result:=12; end;
end;
function tdword_359(x:dword):longint;
begin
 result:=0;
 if x > 10 then begin result:=1; if x >= 12 then result:=2 else result:=3; end
 else begin result:=10; if x >= 12 then result:=11 else result:=12; end;
end;
function tdword_360(x:dword):longint;
begin
 result:=0;
 if x >= 0 then begin result:=1; if x = 3 then result:=2 else result:=3; end
 else begin result:=10; if x = 3 then result:=11 else result:=12; end;
end;
function tdword_361(x:dword):longint;
begin
 result:=0;
 if x >= 0 then begin result:=1; if x = 5 then result:=2 else result:=3; end
 else begin result:=10; if x = 5 then result:=11 else result:=12; end;
end;
function tdword_362(x:dword):longint;
begin
 result:=0;
 if x >= 0 then begin result:=1; if x = 7 then result:=2 else result:=3; end
 else begin result:=10; if x = 7 then result:=11 else result:=12; end;
end;
function tdword_363(x:dword):longint;
begin
 result:=0;
 if x >= 0 then begin result:=1; if x = 12 then result:=2 else result:=3; end
 else begin result:=10; if x = 12 then result:=11 else result:=12; end;
end;
function tdword_364(x:dword):longint;
begin
 result:=0;
 if x >= 0 then begin result:=1; if x <> 3 then result:=2 else result:=3; end
 else begin result:=10; if x <> 3 then result:=11 else result:=12; end;
end;
function tdword_365(x:dword):longint;
begin
 result:=0;
 if x >= 0 then begin result:=1; if x <> 5 then result:=2 else result:=3; end
 else begin result:=10; if x <> 5 then result:=11 else result:=12; end;
end;
function tdword_366(x:dword):longint;
begin
 result:=0;
 if x >= 0 then begin result:=1; if x <> 7 then result:=2 else result:=3; end
 else begin result:=10; if x <> 7 then result:=11 else result:=12; end;
end;
function tdword_367(x:dword):longint;
begin
 result:=0;
 if x >= 0 then begin result:=1; if x <> 12 then result:=2 else result:=3; end
 else begin result:=10; if x <> 12 then result:=11 else result:=12; end;
end;
function tdword_368(x:dword):longint;
begin
 result:=0;
 if x >= 0 then begin result:=1; if x < 3 then result:=2 else result:=3; end
 else begin result:=10; if x < 3 then result:=11 else result:=12; end;
end;
function tdword_369(x:dword):longint;
begin
 result:=0;
 if x >= 0 then begin result:=1; if x < 5 then result:=2 else result:=3; end
 else begin result:=10; if x < 5 then result:=11 else result:=12; end;
end;
function tdword_370(x:dword):longint;
begin
 result:=0;
 if x >= 0 then begin result:=1; if x < 7 then result:=2 else result:=3; end
 else begin result:=10; if x < 7 then result:=11 else result:=12; end;
end;
function tdword_371(x:dword):longint;
begin
 result:=0;
 if x >= 0 then begin result:=1; if x < 12 then result:=2 else result:=3; end
 else begin result:=10; if x < 12 then result:=11 else result:=12; end;
end;
function tdword_372(x:dword):longint;
begin
 result:=0;
 if x >= 0 then begin result:=1; if x <= 3 then result:=2 else result:=3; end
 else begin result:=10; if x <= 3 then result:=11 else result:=12; end;
end;
function tdword_373(x:dword):longint;
begin
 result:=0;
 if x >= 0 then begin result:=1; if x <= 5 then result:=2 else result:=3; end
 else begin result:=10; if x <= 5 then result:=11 else result:=12; end;
end;
function tdword_374(x:dword):longint;
begin
 result:=0;
 if x >= 0 then begin result:=1; if x <= 7 then result:=2 else result:=3; end
 else begin result:=10; if x <= 7 then result:=11 else result:=12; end;
end;
function tdword_375(x:dword):longint;
begin
 result:=0;
 if x >= 0 then begin result:=1; if x <= 12 then result:=2 else result:=3; end
 else begin result:=10; if x <= 12 then result:=11 else result:=12; end;
end;
function tdword_376(x:dword):longint;
begin
 result:=0;
 if x >= 0 then begin result:=1; if x > 3 then result:=2 else result:=3; end
 else begin result:=10; if x > 3 then result:=11 else result:=12; end;
end;
function tdword_377(x:dword):longint;
begin
 result:=0;
 if x >= 0 then begin result:=1; if x > 5 then result:=2 else result:=3; end
 else begin result:=10; if x > 5 then result:=11 else result:=12; end;
end;
function tdword_378(x:dword):longint;
begin
 result:=0;
 if x >= 0 then begin result:=1; if x > 7 then result:=2 else result:=3; end
 else begin result:=10; if x > 7 then result:=11 else result:=12; end;
end;
function tdword_379(x:dword):longint;
begin
 result:=0;
 if x >= 0 then begin result:=1; if x > 12 then result:=2 else result:=3; end
 else begin result:=10; if x > 12 then result:=11 else result:=12; end;
end;
function tdword_380(x:dword):longint;
begin
 result:=0;
 if x >= 0 then begin result:=1; if x >= 3 then result:=2 else result:=3; end
 else begin result:=10; if x >= 3 then result:=11 else result:=12; end;
end;
function tdword_381(x:dword):longint;
begin
 result:=0;
 if x >= 0 then begin result:=1; if x >= 5 then result:=2 else result:=3; end
 else begin result:=10; if x >= 5 then result:=11 else result:=12; end;
end;
function tdword_382(x:dword):longint;
begin
 result:=0;
 if x >= 0 then begin result:=1; if x >= 7 then result:=2 else result:=3; end
 else begin result:=10; if x >= 7 then result:=11 else result:=12; end;
end;
function tdword_383(x:dword):longint;
begin
 result:=0;
 if x >= 0 then begin result:=1; if x >= 12 then result:=2 else result:=3; end
 else begin result:=10; if x >= 12 then result:=11 else result:=12; end;
end;
function tdword_384(x:dword):longint;
begin
 result:=0;
 if x >= 5 then begin result:=1; if x = 3 then result:=2 else result:=3; end
 else begin result:=10; if x = 3 then result:=11 else result:=12; end;
end;
function tdword_385(x:dword):longint;
begin
 result:=0;
 if x >= 5 then begin result:=1; if x = 5 then result:=2 else result:=3; end
 else begin result:=10; if x = 5 then result:=11 else result:=12; end;
end;
function tdword_386(x:dword):longint;
begin
 result:=0;
 if x >= 5 then begin result:=1; if x = 7 then result:=2 else result:=3; end
 else begin result:=10; if x = 7 then result:=11 else result:=12; end;
end;
function tdword_387(x:dword):longint;
begin
 result:=0;
 if x >= 5 then begin result:=1; if x = 12 then result:=2 else result:=3; end
 else begin result:=10; if x = 12 then result:=11 else result:=12; end;
end;
function tdword_388(x:dword):longint;
begin
 result:=0;
 if x >= 5 then begin result:=1; if x <> 3 then result:=2 else result:=3; end
 else begin result:=10; if x <> 3 then result:=11 else result:=12; end;
end;
function tdword_389(x:dword):longint;
begin
 result:=0;
 if x >= 5 then begin result:=1; if x <> 5 then result:=2 else result:=3; end
 else begin result:=10; if x <> 5 then result:=11 else result:=12; end;
end;
function tdword_390(x:dword):longint;
begin
 result:=0;
 if x >= 5 then begin result:=1; if x <> 7 then result:=2 else result:=3; end
 else begin result:=10; if x <> 7 then result:=11 else result:=12; end;
end;
function tdword_391(x:dword):longint;
begin
 result:=0;
 if x >= 5 then begin result:=1; if x <> 12 then result:=2 else result:=3; end
 else begin result:=10; if x <> 12 then result:=11 else result:=12; end;
end;
function tdword_392(x:dword):longint;
begin
 result:=0;
 if x >= 5 then begin result:=1; if x < 3 then result:=2 else result:=3; end
 else begin result:=10; if x < 3 then result:=11 else result:=12; end;
end;
function tdword_393(x:dword):longint;
begin
 result:=0;
 if x >= 5 then begin result:=1; if x < 5 then result:=2 else result:=3; end
 else begin result:=10; if x < 5 then result:=11 else result:=12; end;
end;
function tdword_394(x:dword):longint;
begin
 result:=0;
 if x >= 5 then begin result:=1; if x < 7 then result:=2 else result:=3; end
 else begin result:=10; if x < 7 then result:=11 else result:=12; end;
end;
function tdword_395(x:dword):longint;
begin
 result:=0;
 if x >= 5 then begin result:=1; if x < 12 then result:=2 else result:=3; end
 else begin result:=10; if x < 12 then result:=11 else result:=12; end;
end;
function tdword_396(x:dword):longint;
begin
 result:=0;
 if x >= 5 then begin result:=1; if x <= 3 then result:=2 else result:=3; end
 else begin result:=10; if x <= 3 then result:=11 else result:=12; end;
end;
function tdword_397(x:dword):longint;
begin
 result:=0;
 if x >= 5 then begin result:=1; if x <= 5 then result:=2 else result:=3; end
 else begin result:=10; if x <= 5 then result:=11 else result:=12; end;
end;
function tdword_398(x:dword):longint;
begin
 result:=0;
 if x >= 5 then begin result:=1; if x <= 7 then result:=2 else result:=3; end
 else begin result:=10; if x <= 7 then result:=11 else result:=12; end;
end;
function tdword_399(x:dword):longint;
begin
 result:=0;
 if x >= 5 then begin result:=1; if x <= 12 then result:=2 else result:=3; end
 else begin result:=10; if x <= 12 then result:=11 else result:=12; end;
end;
function tdword_400(x:dword):longint;
begin
 result:=0;
 if x >= 5 then begin result:=1; if x > 3 then result:=2 else result:=3; end
 else begin result:=10; if x > 3 then result:=11 else result:=12; end;
end;
function tdword_401(x:dword):longint;
begin
 result:=0;
 if x >= 5 then begin result:=1; if x > 5 then result:=2 else result:=3; end
 else begin result:=10; if x > 5 then result:=11 else result:=12; end;
end;
function tdword_402(x:dword):longint;
begin
 result:=0;
 if x >= 5 then begin result:=1; if x > 7 then result:=2 else result:=3; end
 else begin result:=10; if x > 7 then result:=11 else result:=12; end;
end;
function tdword_403(x:dword):longint;
begin
 result:=0;
 if x >= 5 then begin result:=1; if x > 12 then result:=2 else result:=3; end
 else begin result:=10; if x > 12 then result:=11 else result:=12; end;
end;
function tdword_404(x:dword):longint;
begin
 result:=0;
 if x >= 5 then begin result:=1; if x >= 3 then result:=2 else result:=3; end
 else begin result:=10; if x >= 3 then result:=11 else result:=12; end;
end;
function tdword_405(x:dword):longint;
begin
 result:=0;
 if x >= 5 then begin result:=1; if x >= 5 then result:=2 else result:=3; end
 else begin result:=10; if x >= 5 then result:=11 else result:=12; end;
end;
function tdword_406(x:dword):longint;
begin
 result:=0;
 if x >= 5 then begin result:=1; if x >= 7 then result:=2 else result:=3; end
 else begin result:=10; if x >= 7 then result:=11 else result:=12; end;
end;
function tdword_407(x:dword):longint;
begin
 result:=0;
 if x >= 5 then begin result:=1; if x >= 12 then result:=2 else result:=3; end
 else begin result:=10; if x >= 12 then result:=11 else result:=12; end;
end;
function tdword_408(x:dword):longint;
begin
 result:=0;
 if x >= 10 then begin result:=1; if x = 3 then result:=2 else result:=3; end
 else begin result:=10; if x = 3 then result:=11 else result:=12; end;
end;
function tdword_409(x:dword):longint;
begin
 result:=0;
 if x >= 10 then begin result:=1; if x = 5 then result:=2 else result:=3; end
 else begin result:=10; if x = 5 then result:=11 else result:=12; end;
end;
function tdword_410(x:dword):longint;
begin
 result:=0;
 if x >= 10 then begin result:=1; if x = 7 then result:=2 else result:=3; end
 else begin result:=10; if x = 7 then result:=11 else result:=12; end;
end;
function tdword_411(x:dword):longint;
begin
 result:=0;
 if x >= 10 then begin result:=1; if x = 12 then result:=2 else result:=3; end
 else begin result:=10; if x = 12 then result:=11 else result:=12; end;
end;
function tdword_412(x:dword):longint;
begin
 result:=0;
 if x >= 10 then begin result:=1; if x <> 3 then result:=2 else result:=3; end
 else begin result:=10; if x <> 3 then result:=11 else result:=12; end;
end;
function tdword_413(x:dword):longint;
begin
 result:=0;
 if x >= 10 then begin result:=1; if x <> 5 then result:=2 else result:=3; end
 else begin result:=10; if x <> 5 then result:=11 else result:=12; end;
end;
function tdword_414(x:dword):longint;
begin
 result:=0;
 if x >= 10 then begin result:=1; if x <> 7 then result:=2 else result:=3; end
 else begin result:=10; if x <> 7 then result:=11 else result:=12; end;
end;
function tdword_415(x:dword):longint;
begin
 result:=0;
 if x >= 10 then begin result:=1; if x <> 12 then result:=2 else result:=3; end
 else begin result:=10; if x <> 12 then result:=11 else result:=12; end;
end;
function tdword_416(x:dword):longint;
begin
 result:=0;
 if x >= 10 then begin result:=1; if x < 3 then result:=2 else result:=3; end
 else begin result:=10; if x < 3 then result:=11 else result:=12; end;
end;
function tdword_417(x:dword):longint;
begin
 result:=0;
 if x >= 10 then begin result:=1; if x < 5 then result:=2 else result:=3; end
 else begin result:=10; if x < 5 then result:=11 else result:=12; end;
end;
function tdword_418(x:dword):longint;
begin
 result:=0;
 if x >= 10 then begin result:=1; if x < 7 then result:=2 else result:=3; end
 else begin result:=10; if x < 7 then result:=11 else result:=12; end;
end;
function tdword_419(x:dword):longint;
begin
 result:=0;
 if x >= 10 then begin result:=1; if x < 12 then result:=2 else result:=3; end
 else begin result:=10; if x < 12 then result:=11 else result:=12; end;
end;
function tdword_420(x:dword):longint;
begin
 result:=0;
 if x >= 10 then begin result:=1; if x <= 3 then result:=2 else result:=3; end
 else begin result:=10; if x <= 3 then result:=11 else result:=12; end;
end;
function tdword_421(x:dword):longint;
begin
 result:=0;
 if x >= 10 then begin result:=1; if x <= 5 then result:=2 else result:=3; end
 else begin result:=10; if x <= 5 then result:=11 else result:=12; end;
end;
function tdword_422(x:dword):longint;
begin
 result:=0;
 if x >= 10 then begin result:=1; if x <= 7 then result:=2 else result:=3; end
 else begin result:=10; if x <= 7 then result:=11 else result:=12; end;
end;
function tdword_423(x:dword):longint;
begin
 result:=0;
 if x >= 10 then begin result:=1; if x <= 12 then result:=2 else result:=3; end
 else begin result:=10; if x <= 12 then result:=11 else result:=12; end;
end;
function tdword_424(x:dword):longint;
begin
 result:=0;
 if x >= 10 then begin result:=1; if x > 3 then result:=2 else result:=3; end
 else begin result:=10; if x > 3 then result:=11 else result:=12; end;
end;
function tdword_425(x:dword):longint;
begin
 result:=0;
 if x >= 10 then begin result:=1; if x > 5 then result:=2 else result:=3; end
 else begin result:=10; if x > 5 then result:=11 else result:=12; end;
end;
function tdword_426(x:dword):longint;
begin
 result:=0;
 if x >= 10 then begin result:=1; if x > 7 then result:=2 else result:=3; end
 else begin result:=10; if x > 7 then result:=11 else result:=12; end;
end;
function tdword_427(x:dword):longint;
begin
 result:=0;
 if x >= 10 then begin result:=1; if x > 12 then result:=2 else result:=3; end
 else begin result:=10; if x > 12 then result:=11 else result:=12; end;
end;
function tdword_428(x:dword):longint;
begin
 result:=0;
 if x >= 10 then begin result:=1; if x >= 3 then result:=2 else result:=3; end
 else begin result:=10; if x >= 3 then result:=11 else result:=12; end;
end;
function tdword_429(x:dword):longint;
begin
 result:=0;
 if x >= 10 then begin result:=1; if x >= 5 then result:=2 else result:=3; end
 else begin result:=10; if x >= 5 then result:=11 else result:=12; end;
end;
function tdword_430(x:dword):longint;
begin
 result:=0;
 if x >= 10 then begin result:=1; if x >= 7 then result:=2 else result:=3; end
 else begin result:=10; if x >= 7 then result:=11 else result:=12; end;
end;
function tdword_431(x:dword):longint;
begin
 result:=0;
 if x >= 10 then begin result:=1; if x >= 12 then result:=2 else result:=3; end
 else begin result:=10; if x >= 12 then result:=11 else result:=12; end;
end;
var x,i,bad:longint;
const combL:array[0..431,0..3] of longint=(
(0,-3,0,-3),
(0,-3,0,3),
(0,-3,0,5),
(0,-3,0,7),
(0,-3,1,-3),
(0,-3,1,3),
(0,-3,1,5),
(0,-3,1,7),
(0,-3,2,-3),
(0,-3,2,3),
(0,-3,2,5),
(0,-3,2,7),
(0,-3,3,-3),
(0,-3,3,3),
(0,-3,3,5),
(0,-3,3,7),
(0,-3,4,-3),
(0,-3,4,3),
(0,-3,4,5),
(0,-3,4,7),
(0,-3,5,-3),
(0,-3,5,3),
(0,-3,5,5),
(0,-3,5,7),
(0,0,0,-3),
(0,0,0,3),
(0,0,0,5),
(0,0,0,7),
(0,0,1,-3),
(0,0,1,3),
(0,0,1,5),
(0,0,1,7),
(0,0,2,-3),
(0,0,2,3),
(0,0,2,5),
(0,0,2,7),
(0,0,3,-3),
(0,0,3,3),
(0,0,3,5),
(0,0,3,7),
(0,0,4,-3),
(0,0,4,3),
(0,0,4,5),
(0,0,4,7),
(0,0,5,-3),
(0,0,5,3),
(0,0,5,5),
(0,0,5,7),
(0,5,0,-3),
(0,5,0,3),
(0,5,0,5),
(0,5,0,7),
(0,5,1,-3),
(0,5,1,3),
(0,5,1,5),
(0,5,1,7),
(0,5,2,-3),
(0,5,2,3),
(0,5,2,5),
(0,5,2,7),
(0,5,3,-3),
(0,5,3,3),
(0,5,3,5),
(0,5,3,7),
(0,5,4,-3),
(0,5,4,3),
(0,5,4,5),
(0,5,4,7),
(0,5,5,-3),
(0,5,5,3),
(0,5,5,5),
(0,5,5,7),
(1,-3,0,-3),
(1,-3,0,3),
(1,-3,0,5),
(1,-3,0,7),
(1,-3,1,-3),
(1,-3,1,3),
(1,-3,1,5),
(1,-3,1,7),
(1,-3,2,-3),
(1,-3,2,3),
(1,-3,2,5),
(1,-3,2,7),
(1,-3,3,-3),
(1,-3,3,3),
(1,-3,3,5),
(1,-3,3,7),
(1,-3,4,-3),
(1,-3,4,3),
(1,-3,4,5),
(1,-3,4,7),
(1,-3,5,-3),
(1,-3,5,3),
(1,-3,5,5),
(1,-3,5,7),
(1,0,0,-3),
(1,0,0,3),
(1,0,0,5),
(1,0,0,7),
(1,0,1,-3),
(1,0,1,3),
(1,0,1,5),
(1,0,1,7),
(1,0,2,-3),
(1,0,2,3),
(1,0,2,5),
(1,0,2,7),
(1,0,3,-3),
(1,0,3,3),
(1,0,3,5),
(1,0,3,7),
(1,0,4,-3),
(1,0,4,3),
(1,0,4,5),
(1,0,4,7),
(1,0,5,-3),
(1,0,5,3),
(1,0,5,5),
(1,0,5,7),
(1,5,0,-3),
(1,5,0,3),
(1,5,0,5),
(1,5,0,7),
(1,5,1,-3),
(1,5,1,3),
(1,5,1,5),
(1,5,1,7),
(1,5,2,-3),
(1,5,2,3),
(1,5,2,5),
(1,5,2,7),
(1,5,3,-3),
(1,5,3,3),
(1,5,3,5),
(1,5,3,7),
(1,5,4,-3),
(1,5,4,3),
(1,5,4,5),
(1,5,4,7),
(1,5,5,-3),
(1,5,5,3),
(1,5,5,5),
(1,5,5,7),
(2,-3,0,-3),
(2,-3,0,3),
(2,-3,0,5),
(2,-3,0,7),
(2,-3,1,-3),
(2,-3,1,3),
(2,-3,1,5),
(2,-3,1,7),
(2,-3,2,-3),
(2,-3,2,3),
(2,-3,2,5),
(2,-3,2,7),
(2,-3,3,-3),
(2,-3,3,3),
(2,-3,3,5),
(2,-3,3,7),
(2,-3,4,-3),
(2,-3,4,3),
(2,-3,4,5),
(2,-3,4,7),
(2,-3,5,-3),
(2,-3,5,3),
(2,-3,5,5),
(2,-3,5,7),
(2,0,0,-3),
(2,0,0,3),
(2,0,0,5),
(2,0,0,7),
(2,0,1,-3),
(2,0,1,3),
(2,0,1,5),
(2,0,1,7),
(2,0,2,-3),
(2,0,2,3),
(2,0,2,5),
(2,0,2,7),
(2,0,3,-3),
(2,0,3,3),
(2,0,3,5),
(2,0,3,7),
(2,0,4,-3),
(2,0,4,3),
(2,0,4,5),
(2,0,4,7),
(2,0,5,-3),
(2,0,5,3),
(2,0,5,5),
(2,0,5,7),
(2,5,0,-3),
(2,5,0,3),
(2,5,0,5),
(2,5,0,7),
(2,5,1,-3),
(2,5,1,3),
(2,5,1,5),
(2,5,1,7),
(2,5,2,-3),
(2,5,2,3),
(2,5,2,5),
(2,5,2,7),
(2,5,3,-3),
(2,5,3,3),
(2,5,3,5),
(2,5,3,7),
(2,5,4,-3),
(2,5,4,3),
(2,5,4,5),
(2,5,4,7),
(2,5,5,-3),
(2,5,5,3),
(2,5,5,5),
(2,5,5,7),
(3,-3,0,-3),
(3,-3,0,3),
(3,-3,0,5),
(3,-3,0,7),
(3,-3,1,-3),
(3,-3,1,3),
(3,-3,1,5),
(3,-3,1,7),
(3,-3,2,-3),
(3,-3,2,3),
(3,-3,2,5),
(3,-3,2,7),
(3,-3,3,-3),
(3,-3,3,3),
(3,-3,3,5),
(3,-3,3,7),
(3,-3,4,-3),
(3,-3,4,3),
(3,-3,4,5),
(3,-3,4,7),
(3,-3,5,-3),
(3,-3,5,3),
(3,-3,5,5),
(3,-3,5,7),
(3,0,0,-3),
(3,0,0,3),
(3,0,0,5),
(3,0,0,7),
(3,0,1,-3),
(3,0,1,3),
(3,0,1,5),
(3,0,1,7),
(3,0,2,-3),
(3,0,2,3),
(3,0,2,5),
(3,0,2,7),
(3,0,3,-3),
(3,0,3,3),
(3,0,3,5),
(3,0,3,7),
(3,0,4,-3),
(3,0,4,3),
(3,0,4,5),
(3,0,4,7),
(3,0,5,-3),
(3,0,5,3),
(3,0,5,5),
(3,0,5,7),
(3,5,0,-3),
(3,5,0,3),
(3,5,0,5),
(3,5,0,7),
(3,5,1,-3),
(3,5,1,3),
(3,5,1,5),
(3,5,1,7),
(3,5,2,-3),
(3,5,2,3),
(3,5,2,5),
(3,5,2,7),
(3,5,3,-3),
(3,5,3,3),
(3,5,3,5),
(3,5,3,7),
(3,5,4,-3),
(3,5,4,3),
(3,5,4,5),
(3,5,4,7),
(3,5,5,-3),
(3,5,5,3),
(3,5,5,5),
(3,5,5,7),
(4,-3,0,-3),
(4,-3,0,3),
(4,-3,0,5),
(4,-3,0,7),
(4,-3,1,-3),
(4,-3,1,3),
(4,-3,1,5),
(4,-3,1,7),
(4,-3,2,-3),
(4,-3,2,3),
(4,-3,2,5),
(4,-3,2,7),
(4,-3,3,-3),
(4,-3,3,3),
(4,-3,3,5),
(4,-3,3,7),
(4,-3,4,-3),
(4,-3,4,3),
(4,-3,4,5),
(4,-3,4,7),
(4,-3,5,-3),
(4,-3,5,3),
(4,-3,5,5),
(4,-3,5,7),
(4,0,0,-3),
(4,0,0,3),
(4,0,0,5),
(4,0,0,7),
(4,0,1,-3),
(4,0,1,3),
(4,0,1,5),
(4,0,1,7),
(4,0,2,-3),
(4,0,2,3),
(4,0,2,5),
(4,0,2,7),
(4,0,3,-3),
(4,0,3,3),
(4,0,3,5),
(4,0,3,7),
(4,0,4,-3),
(4,0,4,3),
(4,0,4,5),
(4,0,4,7),
(4,0,5,-3),
(4,0,5,3),
(4,0,5,5),
(4,0,5,7),
(4,5,0,-3),
(4,5,0,3),
(4,5,0,5),
(4,5,0,7),
(4,5,1,-3),
(4,5,1,3),
(4,5,1,5),
(4,5,1,7),
(4,5,2,-3),
(4,5,2,3),
(4,5,2,5),
(4,5,2,7),
(4,5,3,-3),
(4,5,3,3),
(4,5,3,5),
(4,5,3,7),
(4,5,4,-3),
(4,5,4,3),
(4,5,4,5),
(4,5,4,7),
(4,5,5,-3),
(4,5,5,3),
(4,5,5,5),
(4,5,5,7),
(5,-3,0,-3),
(5,-3,0,3),
(5,-3,0,5),
(5,-3,0,7),
(5,-3,1,-3),
(5,-3,1,3),
(5,-3,1,5),
(5,-3,1,7),
(5,-3,2,-3),
(5,-3,2,3),
(5,-3,2,5),
(5,-3,2,7),
(5,-3,3,-3),
(5,-3,3,3),
(5,-3,3,5),
(5,-3,3,7),
(5,-3,4,-3),
(5,-3,4,3),
(5,-3,4,5),
(5,-3,4,7),
(5,-3,5,-3),
(5,-3,5,3),
(5,-3,5,5),
(5,-3,5,7),
(5,0,0,-3),
(5,0,0,3),
(5,0,0,5),
(5,0,0,7),
(5,0,1,-3),
(5,0,1,3),
(5,0,1,5),
(5,0,1,7),
(5,0,2,-3),
(5,0,2,3),
(5,0,2,5),
(5,0,2,7),
(5,0,3,-3),
(5,0,3,3),
(5,0,3,5),
(5,0,3,7),
(5,0,4,-3),
(5,0,4,3),
(5,0,4,5),
(5,0,4,7),
(5,0,5,-3),
(5,0,5,3),
(5,0,5,5),
(5,0,5,7),
(5,5,0,-3),
(5,5,0,3),
(5,5,0,5),
(5,5,0,7),
(5,5,1,-3),
(5,5,1,3),
(5,5,1,5),
(5,5,1,7),
(5,5,2,-3),
(5,5,2,3),
(5,5,2,5),
(5,5,2,7),
(5,5,3,-3),
(5,5,3,3),
(5,5,3,5),
(5,5,3,7),
(5,5,4,-3),
(5,5,4,3),
(5,5,4,5),
(5,5,4,7),
(5,5,5,-3),
(5,5,5,3),
(5,5,5,5),
(5,5,5,7));
const combU:array[0..431,0..3] of longint=(
(0,0,0,3),
(0,0,0,5),
(0,0,0,7),
(0,0,0,12),
(0,0,1,3),
(0,0,1,5),
(0,0,1,7),
(0,0,1,12),
(0,0,2,3),
(0,0,2,5),
(0,0,2,7),
(0,0,2,12),
(0,0,3,3),
(0,0,3,5),
(0,0,3,7),
(0,0,3,12),
(0,0,4,3),
(0,0,4,5),
(0,0,4,7),
(0,0,4,12),
(0,0,5,3),
(0,0,5,5),
(0,0,5,7),
(0,0,5,12),
(0,5,0,3),
(0,5,0,5),
(0,5,0,7),
(0,5,0,12),
(0,5,1,3),
(0,5,1,5),
(0,5,1,7),
(0,5,1,12),
(0,5,2,3),
(0,5,2,5),
(0,5,2,7),
(0,5,2,12),
(0,5,3,3),
(0,5,3,5),
(0,5,3,7),
(0,5,3,12),
(0,5,4,3),
(0,5,4,5),
(0,5,4,7),
(0,5,4,12),
(0,5,5,3),
(0,5,5,5),
(0,5,5,7),
(0,5,5,12),
(0,10,0,3),
(0,10,0,5),
(0,10,0,7),
(0,10,0,12),
(0,10,1,3),
(0,10,1,5),
(0,10,1,7),
(0,10,1,12),
(0,10,2,3),
(0,10,2,5),
(0,10,2,7),
(0,10,2,12),
(0,10,3,3),
(0,10,3,5),
(0,10,3,7),
(0,10,3,12),
(0,10,4,3),
(0,10,4,5),
(0,10,4,7),
(0,10,4,12),
(0,10,5,3),
(0,10,5,5),
(0,10,5,7),
(0,10,5,12),
(1,0,0,3),
(1,0,0,5),
(1,0,0,7),
(1,0,0,12),
(1,0,1,3),
(1,0,1,5),
(1,0,1,7),
(1,0,1,12),
(1,0,2,3),
(1,0,2,5),
(1,0,2,7),
(1,0,2,12),
(1,0,3,3),
(1,0,3,5),
(1,0,3,7),
(1,0,3,12),
(1,0,4,3),
(1,0,4,5),
(1,0,4,7),
(1,0,4,12),
(1,0,5,3),
(1,0,5,5),
(1,0,5,7),
(1,0,5,12),
(1,5,0,3),
(1,5,0,5),
(1,5,0,7),
(1,5,0,12),
(1,5,1,3),
(1,5,1,5),
(1,5,1,7),
(1,5,1,12),
(1,5,2,3),
(1,5,2,5),
(1,5,2,7),
(1,5,2,12),
(1,5,3,3),
(1,5,3,5),
(1,5,3,7),
(1,5,3,12),
(1,5,4,3),
(1,5,4,5),
(1,5,4,7),
(1,5,4,12),
(1,5,5,3),
(1,5,5,5),
(1,5,5,7),
(1,5,5,12),
(1,10,0,3),
(1,10,0,5),
(1,10,0,7),
(1,10,0,12),
(1,10,1,3),
(1,10,1,5),
(1,10,1,7),
(1,10,1,12),
(1,10,2,3),
(1,10,2,5),
(1,10,2,7),
(1,10,2,12),
(1,10,3,3),
(1,10,3,5),
(1,10,3,7),
(1,10,3,12),
(1,10,4,3),
(1,10,4,5),
(1,10,4,7),
(1,10,4,12),
(1,10,5,3),
(1,10,5,5),
(1,10,5,7),
(1,10,5,12),
(2,0,0,3),
(2,0,0,5),
(2,0,0,7),
(2,0,0,12),
(2,0,1,3),
(2,0,1,5),
(2,0,1,7),
(2,0,1,12),
(2,0,2,3),
(2,0,2,5),
(2,0,2,7),
(2,0,2,12),
(2,0,3,3),
(2,0,3,5),
(2,0,3,7),
(2,0,3,12),
(2,0,4,3),
(2,0,4,5),
(2,0,4,7),
(2,0,4,12),
(2,0,5,3),
(2,0,5,5),
(2,0,5,7),
(2,0,5,12),
(2,5,0,3),
(2,5,0,5),
(2,5,0,7),
(2,5,0,12),
(2,5,1,3),
(2,5,1,5),
(2,5,1,7),
(2,5,1,12),
(2,5,2,3),
(2,5,2,5),
(2,5,2,7),
(2,5,2,12),
(2,5,3,3),
(2,5,3,5),
(2,5,3,7),
(2,5,3,12),
(2,5,4,3),
(2,5,4,5),
(2,5,4,7),
(2,5,4,12),
(2,5,5,3),
(2,5,5,5),
(2,5,5,7),
(2,5,5,12),
(2,10,0,3),
(2,10,0,5),
(2,10,0,7),
(2,10,0,12),
(2,10,1,3),
(2,10,1,5),
(2,10,1,7),
(2,10,1,12),
(2,10,2,3),
(2,10,2,5),
(2,10,2,7),
(2,10,2,12),
(2,10,3,3),
(2,10,3,5),
(2,10,3,7),
(2,10,3,12),
(2,10,4,3),
(2,10,4,5),
(2,10,4,7),
(2,10,4,12),
(2,10,5,3),
(2,10,5,5),
(2,10,5,7),
(2,10,5,12),
(3,0,0,3),
(3,0,0,5),
(3,0,0,7),
(3,0,0,12),
(3,0,1,3),
(3,0,1,5),
(3,0,1,7),
(3,0,1,12),
(3,0,2,3),
(3,0,2,5),
(3,0,2,7),
(3,0,2,12),
(3,0,3,3),
(3,0,3,5),
(3,0,3,7),
(3,0,3,12),
(3,0,4,3),
(3,0,4,5),
(3,0,4,7),
(3,0,4,12),
(3,0,5,3),
(3,0,5,5),
(3,0,5,7),
(3,0,5,12),
(3,5,0,3),
(3,5,0,5),
(3,5,0,7),
(3,5,0,12),
(3,5,1,3),
(3,5,1,5),
(3,5,1,7),
(3,5,1,12),
(3,5,2,3),
(3,5,2,5),
(3,5,2,7),
(3,5,2,12),
(3,5,3,3),
(3,5,3,5),
(3,5,3,7),
(3,5,3,12),
(3,5,4,3),
(3,5,4,5),
(3,5,4,7),
(3,5,4,12),
(3,5,5,3),
(3,5,5,5),
(3,5,5,7),
(3,5,5,12),
(3,10,0,3),
(3,10,0,5),
(3,10,0,7),
(3,10,0,12),
(3,10,1,3),
(3,10,1,5),
(3,10,1,7),
(3,10,1,12),
(3,10,2,3),
(3,10,2,5),
(3,10,2,7),
(3,10,2,12),
(3,10,3,3),
(3,10,3,5),
(3,10,3,7),
(3,10,3,12),
(3,10,4,3),
(3,10,4,5),
(3,10,4,7),
(3,10,4,12),
(3,10,5,3),
(3,10,5,5),
(3,10,5,7),
(3,10,5,12),
(4,0,0,3),
(4,0,0,5),
(4,0,0,7),
(4,0,0,12),
(4,0,1,3),
(4,0,1,5),
(4,0,1,7),
(4,0,1,12),
(4,0,2,3),
(4,0,2,5),
(4,0,2,7),
(4,0,2,12),
(4,0,3,3),
(4,0,3,5),
(4,0,3,7),
(4,0,3,12),
(4,0,4,3),
(4,0,4,5),
(4,0,4,7),
(4,0,4,12),
(4,0,5,3),
(4,0,5,5),
(4,0,5,7),
(4,0,5,12),
(4,5,0,3),
(4,5,0,5),
(4,5,0,7),
(4,5,0,12),
(4,5,1,3),
(4,5,1,5),
(4,5,1,7),
(4,5,1,12),
(4,5,2,3),
(4,5,2,5),
(4,5,2,7),
(4,5,2,12),
(4,5,3,3),
(4,5,3,5),
(4,5,3,7),
(4,5,3,12),
(4,5,4,3),
(4,5,4,5),
(4,5,4,7),
(4,5,4,12),
(4,5,5,3),
(4,5,5,5),
(4,5,5,7),
(4,5,5,12),
(4,10,0,3),
(4,10,0,5),
(4,10,0,7),
(4,10,0,12),
(4,10,1,3),
(4,10,1,5),
(4,10,1,7),
(4,10,1,12),
(4,10,2,3),
(4,10,2,5),
(4,10,2,7),
(4,10,2,12),
(4,10,3,3),
(4,10,3,5),
(4,10,3,7),
(4,10,3,12),
(4,10,4,3),
(4,10,4,5),
(4,10,4,7),
(4,10,4,12),
(4,10,5,3),
(4,10,5,5),
(4,10,5,7),
(4,10,5,12),
(5,0,0,3),
(5,0,0,5),
(5,0,0,7),
(5,0,0,12),
(5,0,1,3),
(5,0,1,5),
(5,0,1,7),
(5,0,1,12),
(5,0,2,3),
(5,0,2,5),
(5,0,2,7),
(5,0,2,12),
(5,0,3,3),
(5,0,3,5),
(5,0,3,7),
(5,0,3,12),
(5,0,4,3),
(5,0,4,5),
(5,0,4,7),
(5,0,4,12),
(5,0,5,3),
(5,0,5,5),
(5,0,5,7),
(5,0,5,12),
(5,5,0,3),
(5,5,0,5),
(5,5,0,7),
(5,5,0,12),
(5,5,1,3),
(5,5,1,5),
(5,5,1,7),
(5,5,1,12),
(5,5,2,3),
(5,5,2,5),
(5,5,2,7),
(5,5,2,12),
(5,5,3,3),
(5,5,3,5),
(5,5,3,7),
(5,5,3,12),
(5,5,4,3),
(5,5,4,5),
(5,5,4,7),
(5,5,4,12),
(5,5,5,3),
(5,5,5,5),
(5,5,5,7),
(5,5,5,12),
(5,10,0,3),
(5,10,0,5),
(5,10,0,7),
(5,10,0,12),
(5,10,1,3),
(5,10,1,5),
(5,10,1,7),
(5,10,1,12),
(5,10,2,3),
(5,10,2,5),
(5,10,2,7),
(5,10,2,12),
(5,10,3,3),
(5,10,3,5),
(5,10,3,7),
(5,10,3,12),
(5,10,4,3),
(5,10,4,5),
(5,10,4,7),
(5,10,4,12),
(5,10,5,3),
(5,10,5,5),
(5,10,5,7),
(5,10,5,12));
begin
 bad:=0;
 for i:=0 to high(combL) do for x:=-20 to 20 do
   case i of
    0: if tlongint_0(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    1: if tlongint_1(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    2: if tlongint_2(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    3: if tlongint_3(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    4: if tlongint_4(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    5: if tlongint_5(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    6: if tlongint_6(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    7: if tlongint_7(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    8: if tlongint_8(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    9: if tlongint_9(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    10: if tlongint_10(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    11: if tlongint_11(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    12: if tlongint_12(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    13: if tlongint_13(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    14: if tlongint_14(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    15: if tlongint_15(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    16: if tlongint_16(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    17: if tlongint_17(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    18: if tlongint_18(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    19: if tlongint_19(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    20: if tlongint_20(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    21: if tlongint_21(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    22: if tlongint_22(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    23: if tlongint_23(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    24: if tlongint_24(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    25: if tlongint_25(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    26: if tlongint_26(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    27: if tlongint_27(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    28: if tlongint_28(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    29: if tlongint_29(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    30: if tlongint_30(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    31: if tlongint_31(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    32: if tlongint_32(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    33: if tlongint_33(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    34: if tlongint_34(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    35: if tlongint_35(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    36: if tlongint_36(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    37: if tlongint_37(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    38: if tlongint_38(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    39: if tlongint_39(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    40: if tlongint_40(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    41: if tlongint_41(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    42: if tlongint_42(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    43: if tlongint_43(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    44: if tlongint_44(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    45: if tlongint_45(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    46: if tlongint_46(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    47: if tlongint_47(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    48: if tlongint_48(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    49: if tlongint_49(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    50: if tlongint_50(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    51: if tlongint_51(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    52: if tlongint_52(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    53: if tlongint_53(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    54: if tlongint_54(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    55: if tlongint_55(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    56: if tlongint_56(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    57: if tlongint_57(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    58: if tlongint_58(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    59: if tlongint_59(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    60: if tlongint_60(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    61: if tlongint_61(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    62: if tlongint_62(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    63: if tlongint_63(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    64: if tlongint_64(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    65: if tlongint_65(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    66: if tlongint_66(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    67: if tlongint_67(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    68: if tlongint_68(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    69: if tlongint_69(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    70: if tlongint_70(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    71: if tlongint_71(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    72: if tlongint_72(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    73: if tlongint_73(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    74: if tlongint_74(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    75: if tlongint_75(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    76: if tlongint_76(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    77: if tlongint_77(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    78: if tlongint_78(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    79: if tlongint_79(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    80: if tlongint_80(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    81: if tlongint_81(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    82: if tlongint_82(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    83: if tlongint_83(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    84: if tlongint_84(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    85: if tlongint_85(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    86: if tlongint_86(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    87: if tlongint_87(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    88: if tlongint_88(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    89: if tlongint_89(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    90: if tlongint_90(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    91: if tlongint_91(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    92: if tlongint_92(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    93: if tlongint_93(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    94: if tlongint_94(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    95: if tlongint_95(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    96: if tlongint_96(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    97: if tlongint_97(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    98: if tlongint_98(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    99: if tlongint_99(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    100: if tlongint_100(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    101: if tlongint_101(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    102: if tlongint_102(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    103: if tlongint_103(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    104: if tlongint_104(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    105: if tlongint_105(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    106: if tlongint_106(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    107: if tlongint_107(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    108: if tlongint_108(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    109: if tlongint_109(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    110: if tlongint_110(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    111: if tlongint_111(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    112: if tlongint_112(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    113: if tlongint_113(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    114: if tlongint_114(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    115: if tlongint_115(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    116: if tlongint_116(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    117: if tlongint_117(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    118: if tlongint_118(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    119: if tlongint_119(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    120: if tlongint_120(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    121: if tlongint_121(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    122: if tlongint_122(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    123: if tlongint_123(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    124: if tlongint_124(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    125: if tlongint_125(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    126: if tlongint_126(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    127: if tlongint_127(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    128: if tlongint_128(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    129: if tlongint_129(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    130: if tlongint_130(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    131: if tlongint_131(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    132: if tlongint_132(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    133: if tlongint_133(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    134: if tlongint_134(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    135: if tlongint_135(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    136: if tlongint_136(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    137: if tlongint_137(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    138: if tlongint_138(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    139: if tlongint_139(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    140: if tlongint_140(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    141: if tlongint_141(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    142: if tlongint_142(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    143: if tlongint_143(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    144: if tlongint_144(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    145: if tlongint_145(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    146: if tlongint_146(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    147: if tlongint_147(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    148: if tlongint_148(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    149: if tlongint_149(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    150: if tlongint_150(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    151: if tlongint_151(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    152: if tlongint_152(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    153: if tlongint_153(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    154: if tlongint_154(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    155: if tlongint_155(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    156: if tlongint_156(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    157: if tlongint_157(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    158: if tlongint_158(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    159: if tlongint_159(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    160: if tlongint_160(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    161: if tlongint_161(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    162: if tlongint_162(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    163: if tlongint_163(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    164: if tlongint_164(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    165: if tlongint_165(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    166: if tlongint_166(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    167: if tlongint_167(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    168: if tlongint_168(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    169: if tlongint_169(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    170: if tlongint_170(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    171: if tlongint_171(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    172: if tlongint_172(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    173: if tlongint_173(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    174: if tlongint_174(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    175: if tlongint_175(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    176: if tlongint_176(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    177: if tlongint_177(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    178: if tlongint_178(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    179: if tlongint_179(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    180: if tlongint_180(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    181: if tlongint_181(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    182: if tlongint_182(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    183: if tlongint_183(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    184: if tlongint_184(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    185: if tlongint_185(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    186: if tlongint_186(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    187: if tlongint_187(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    188: if tlongint_188(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    189: if tlongint_189(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    190: if tlongint_190(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    191: if tlongint_191(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    192: if tlongint_192(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    193: if tlongint_193(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    194: if tlongint_194(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    195: if tlongint_195(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    196: if tlongint_196(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    197: if tlongint_197(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    198: if tlongint_198(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    199: if tlongint_199(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    200: if tlongint_200(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    201: if tlongint_201(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    202: if tlongint_202(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    203: if tlongint_203(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    204: if tlongint_204(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    205: if tlongint_205(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    206: if tlongint_206(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    207: if tlongint_207(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    208: if tlongint_208(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    209: if tlongint_209(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    210: if tlongint_210(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    211: if tlongint_211(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    212: if tlongint_212(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    213: if tlongint_213(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    214: if tlongint_214(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    215: if tlongint_215(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    216: if tlongint_216(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    217: if tlongint_217(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    218: if tlongint_218(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    219: if tlongint_219(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    220: if tlongint_220(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    221: if tlongint_221(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    222: if tlongint_222(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    223: if tlongint_223(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    224: if tlongint_224(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    225: if tlongint_225(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    226: if tlongint_226(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    227: if tlongint_227(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    228: if tlongint_228(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    229: if tlongint_229(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    230: if tlongint_230(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    231: if tlongint_231(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    232: if tlongint_232(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    233: if tlongint_233(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    234: if tlongint_234(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    235: if tlongint_235(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    236: if tlongint_236(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    237: if tlongint_237(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    238: if tlongint_238(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    239: if tlongint_239(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    240: if tlongint_240(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    241: if tlongint_241(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    242: if tlongint_242(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    243: if tlongint_243(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    244: if tlongint_244(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    245: if tlongint_245(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    246: if tlongint_246(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    247: if tlongint_247(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    248: if tlongint_248(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    249: if tlongint_249(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    250: if tlongint_250(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    251: if tlongint_251(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    252: if tlongint_252(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    253: if tlongint_253(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    254: if tlongint_254(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    255: if tlongint_255(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    256: if tlongint_256(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    257: if tlongint_257(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    258: if tlongint_258(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    259: if tlongint_259(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    260: if tlongint_260(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    261: if tlongint_261(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    262: if tlongint_262(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    263: if tlongint_263(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    264: if tlongint_264(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    265: if tlongint_265(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    266: if tlongint_266(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    267: if tlongint_267(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    268: if tlongint_268(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    269: if tlongint_269(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    270: if tlongint_270(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    271: if tlongint_271(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    272: if tlongint_272(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    273: if tlongint_273(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    274: if tlongint_274(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    275: if tlongint_275(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    276: if tlongint_276(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    277: if tlongint_277(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    278: if tlongint_278(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    279: if tlongint_279(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    280: if tlongint_280(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    281: if tlongint_281(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    282: if tlongint_282(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    283: if tlongint_283(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    284: if tlongint_284(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    285: if tlongint_285(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    286: if tlongint_286(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    287: if tlongint_287(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    288: if tlongint_288(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    289: if tlongint_289(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    290: if tlongint_290(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    291: if tlongint_291(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    292: if tlongint_292(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    293: if tlongint_293(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    294: if tlongint_294(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    295: if tlongint_295(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    296: if tlongint_296(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    297: if tlongint_297(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    298: if tlongint_298(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    299: if tlongint_299(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    300: if tlongint_300(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    301: if tlongint_301(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    302: if tlongint_302(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    303: if tlongint_303(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    304: if tlongint_304(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    305: if tlongint_305(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    306: if tlongint_306(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    307: if tlongint_307(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    308: if tlongint_308(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    309: if tlongint_309(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    310: if tlongint_310(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    311: if tlongint_311(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    312: if tlongint_312(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    313: if tlongint_313(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    314: if tlongint_314(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    315: if tlongint_315(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    316: if tlongint_316(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    317: if tlongint_317(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    318: if tlongint_318(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    319: if tlongint_319(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    320: if tlongint_320(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    321: if tlongint_321(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    322: if tlongint_322(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    323: if tlongint_323(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    324: if tlongint_324(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    325: if tlongint_325(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    326: if tlongint_326(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    327: if tlongint_327(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    328: if tlongint_328(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    329: if tlongint_329(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    330: if tlongint_330(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    331: if tlongint_331(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    332: if tlongint_332(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    333: if tlongint_333(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    334: if tlongint_334(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    335: if tlongint_335(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    336: if tlongint_336(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    337: if tlongint_337(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    338: if tlongint_338(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    339: if tlongint_339(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    340: if tlongint_340(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    341: if tlongint_341(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    342: if tlongint_342(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    343: if tlongint_343(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    344: if tlongint_344(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    345: if tlongint_345(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    346: if tlongint_346(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    347: if tlongint_347(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    348: if tlongint_348(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    349: if tlongint_349(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    350: if tlongint_350(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    351: if tlongint_351(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    352: if tlongint_352(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    353: if tlongint_353(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    354: if tlongint_354(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    355: if tlongint_355(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    356: if tlongint_356(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    357: if tlongint_357(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    358: if tlongint_358(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    359: if tlongint_359(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    360: if tlongint_360(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    361: if tlongint_361(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    362: if tlongint_362(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    363: if tlongint_363(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    364: if tlongint_364(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    365: if tlongint_365(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    366: if tlongint_366(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    367: if tlongint_367(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    368: if tlongint_368(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    369: if tlongint_369(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    370: if tlongint_370(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    371: if tlongint_371(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    372: if tlongint_372(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    373: if tlongint_373(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    374: if tlongint_374(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    375: if tlongint_375(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    376: if tlongint_376(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    377: if tlongint_377(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    378: if tlongint_378(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    379: if tlongint_379(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    380: if tlongint_380(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    381: if tlongint_381(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    382: if tlongint_382(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    383: if tlongint_383(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    384: if tlongint_384(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    385: if tlongint_385(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    386: if tlongint_386(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    387: if tlongint_387(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    388: if tlongint_388(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    389: if tlongint_389(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    390: if tlongint_390(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    391: if tlongint_391(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    392: if tlongint_392(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    393: if tlongint_393(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    394: if tlongint_394(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    395: if tlongint_395(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    396: if tlongint_396(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    397: if tlongint_397(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    398: if tlongint_398(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    399: if tlongint_399(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    400: if tlongint_400(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    401: if tlongint_401(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    402: if tlongint_402(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    403: if tlongint_403(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    404: if tlongint_404(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    405: if tlongint_405(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    406: if tlongint_406(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    407: if tlongint_407(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    408: if tlongint_408(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    409: if tlongint_409(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    410: if tlongint_410(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    411: if tlongint_411(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    412: if tlongint_412(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    413: if tlongint_413(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    414: if tlongint_414(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    415: if tlongint_415(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    416: if tlongint_416(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    417: if tlongint_417(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    418: if tlongint_418(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    419: if tlongint_419(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    420: if tlongint_420(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    421: if tlongint_421(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    422: if tlongint_422(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    423: if tlongint_423(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    424: if tlongint_424(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    425: if tlongint_425(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    426: if tlongint_426(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    427: if tlongint_427(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    428: if tlongint_428(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    429: if tlongint_429(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    430: if tlongint_430(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
    431: if tlongint_431(x)<>refL(x,combL[i,0],combL[i,1],combL[i,2],combL[i,3]) then bad:=bad+1;
   end;
 for i:=0 to high(combU) do for x:=0 to 40 do
   case i of
    0: if tdword_0(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    1: if tdword_1(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    2: if tdword_2(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    3: if tdword_3(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    4: if tdword_4(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    5: if tdword_5(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    6: if tdword_6(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    7: if tdword_7(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    8: if tdword_8(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    9: if tdword_9(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    10: if tdword_10(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    11: if tdword_11(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    12: if tdword_12(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    13: if tdword_13(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    14: if tdword_14(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    15: if tdword_15(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    16: if tdword_16(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    17: if tdword_17(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    18: if tdword_18(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    19: if tdword_19(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    20: if tdword_20(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    21: if tdword_21(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    22: if tdword_22(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    23: if tdword_23(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    24: if tdword_24(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    25: if tdword_25(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    26: if tdword_26(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    27: if tdword_27(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    28: if tdword_28(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    29: if tdword_29(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    30: if tdword_30(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    31: if tdword_31(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    32: if tdword_32(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    33: if tdword_33(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    34: if tdword_34(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    35: if tdword_35(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    36: if tdword_36(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    37: if tdword_37(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    38: if tdword_38(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    39: if tdword_39(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    40: if tdword_40(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    41: if tdword_41(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    42: if tdword_42(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    43: if tdword_43(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    44: if tdword_44(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    45: if tdword_45(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    46: if tdword_46(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    47: if tdword_47(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    48: if tdword_48(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    49: if tdword_49(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    50: if tdword_50(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    51: if tdword_51(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    52: if tdword_52(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    53: if tdword_53(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    54: if tdword_54(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    55: if tdword_55(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    56: if tdword_56(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    57: if tdword_57(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    58: if tdword_58(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    59: if tdword_59(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    60: if tdword_60(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    61: if tdword_61(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    62: if tdword_62(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    63: if tdword_63(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    64: if tdword_64(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    65: if tdword_65(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    66: if tdword_66(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    67: if tdword_67(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    68: if tdword_68(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    69: if tdword_69(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    70: if tdword_70(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    71: if tdword_71(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    72: if tdword_72(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    73: if tdword_73(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    74: if tdword_74(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    75: if tdword_75(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    76: if tdword_76(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    77: if tdword_77(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    78: if tdword_78(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    79: if tdword_79(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    80: if tdword_80(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    81: if tdword_81(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    82: if tdword_82(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    83: if tdword_83(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    84: if tdword_84(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    85: if tdword_85(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    86: if tdword_86(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    87: if tdword_87(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    88: if tdword_88(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    89: if tdword_89(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    90: if tdword_90(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    91: if tdword_91(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    92: if tdword_92(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    93: if tdword_93(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    94: if tdword_94(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    95: if tdword_95(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    96: if tdword_96(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    97: if tdword_97(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    98: if tdword_98(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    99: if tdword_99(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    100: if tdword_100(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    101: if tdword_101(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    102: if tdword_102(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    103: if tdword_103(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    104: if tdword_104(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    105: if tdword_105(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    106: if tdword_106(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    107: if tdword_107(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    108: if tdword_108(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    109: if tdword_109(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    110: if tdword_110(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    111: if tdword_111(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    112: if tdword_112(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    113: if tdword_113(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    114: if tdword_114(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    115: if tdword_115(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    116: if tdword_116(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    117: if tdword_117(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    118: if tdword_118(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    119: if tdword_119(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    120: if tdword_120(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    121: if tdword_121(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    122: if tdword_122(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    123: if tdword_123(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    124: if tdword_124(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    125: if tdword_125(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    126: if tdword_126(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    127: if tdword_127(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    128: if tdword_128(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    129: if tdword_129(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    130: if tdword_130(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    131: if tdword_131(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    132: if tdword_132(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    133: if tdword_133(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    134: if tdword_134(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    135: if tdword_135(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    136: if tdword_136(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    137: if tdword_137(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    138: if tdword_138(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    139: if tdword_139(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    140: if tdword_140(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    141: if tdword_141(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    142: if tdword_142(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    143: if tdword_143(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    144: if tdword_144(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    145: if tdword_145(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    146: if tdword_146(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    147: if tdword_147(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    148: if tdword_148(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    149: if tdword_149(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    150: if tdword_150(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    151: if tdword_151(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    152: if tdword_152(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    153: if tdword_153(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    154: if tdword_154(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    155: if tdword_155(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    156: if tdword_156(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    157: if tdword_157(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    158: if tdword_158(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    159: if tdword_159(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    160: if tdword_160(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    161: if tdword_161(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    162: if tdword_162(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    163: if tdword_163(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    164: if tdword_164(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    165: if tdword_165(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    166: if tdword_166(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    167: if tdword_167(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    168: if tdword_168(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    169: if tdword_169(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    170: if tdword_170(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    171: if tdword_171(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    172: if tdword_172(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    173: if tdword_173(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    174: if tdword_174(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    175: if tdword_175(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    176: if tdword_176(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    177: if tdword_177(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    178: if tdword_178(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    179: if tdword_179(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    180: if tdword_180(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    181: if tdword_181(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    182: if tdword_182(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    183: if tdword_183(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    184: if tdword_184(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    185: if tdword_185(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    186: if tdword_186(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    187: if tdword_187(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    188: if tdword_188(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    189: if tdword_189(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    190: if tdword_190(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    191: if tdword_191(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    192: if tdword_192(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    193: if tdword_193(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    194: if tdword_194(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    195: if tdword_195(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    196: if tdword_196(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    197: if tdword_197(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    198: if tdword_198(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    199: if tdword_199(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    200: if tdword_200(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    201: if tdword_201(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    202: if tdword_202(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    203: if tdword_203(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    204: if tdword_204(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    205: if tdword_205(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    206: if tdword_206(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    207: if tdword_207(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    208: if tdword_208(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    209: if tdword_209(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    210: if tdword_210(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    211: if tdword_211(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    212: if tdword_212(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    213: if tdword_213(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    214: if tdword_214(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    215: if tdword_215(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    216: if tdword_216(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    217: if tdword_217(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    218: if tdword_218(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    219: if tdword_219(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    220: if tdword_220(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    221: if tdword_221(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    222: if tdword_222(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    223: if tdword_223(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    224: if tdword_224(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    225: if tdword_225(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    226: if tdword_226(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    227: if tdword_227(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    228: if tdword_228(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    229: if tdword_229(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    230: if tdword_230(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    231: if tdword_231(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    232: if tdword_232(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    233: if tdword_233(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    234: if tdword_234(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    235: if tdword_235(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    236: if tdword_236(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    237: if tdword_237(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    238: if tdword_238(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    239: if tdword_239(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    240: if tdword_240(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    241: if tdword_241(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    242: if tdword_242(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    243: if tdword_243(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    244: if tdword_244(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    245: if tdword_245(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    246: if tdword_246(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    247: if tdword_247(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    248: if tdword_248(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    249: if tdword_249(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    250: if tdword_250(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    251: if tdword_251(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    252: if tdword_252(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    253: if tdword_253(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    254: if tdword_254(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    255: if tdword_255(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    256: if tdword_256(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    257: if tdword_257(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    258: if tdword_258(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    259: if tdword_259(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    260: if tdword_260(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    261: if tdword_261(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    262: if tdword_262(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    263: if tdword_263(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    264: if tdword_264(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    265: if tdword_265(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    266: if tdword_266(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    267: if tdword_267(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    268: if tdword_268(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    269: if tdword_269(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    270: if tdword_270(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    271: if tdword_271(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    272: if tdword_272(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    273: if tdword_273(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    274: if tdword_274(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    275: if tdword_275(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    276: if tdword_276(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    277: if tdword_277(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    278: if tdword_278(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    279: if tdword_279(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    280: if tdword_280(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    281: if tdword_281(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    282: if tdword_282(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    283: if tdword_283(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    284: if tdword_284(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    285: if tdword_285(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    286: if tdword_286(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    287: if tdword_287(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    288: if tdword_288(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    289: if tdword_289(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    290: if tdword_290(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    291: if tdword_291(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    292: if tdword_292(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    293: if tdword_293(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    294: if tdword_294(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    295: if tdword_295(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    296: if tdword_296(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    297: if tdword_297(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    298: if tdword_298(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    299: if tdword_299(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    300: if tdword_300(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    301: if tdword_301(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    302: if tdword_302(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    303: if tdword_303(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    304: if tdword_304(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    305: if tdword_305(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    306: if tdword_306(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    307: if tdword_307(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    308: if tdword_308(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    309: if tdword_309(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    310: if tdword_310(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    311: if tdword_311(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    312: if tdword_312(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    313: if tdword_313(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    314: if tdword_314(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    315: if tdword_315(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    316: if tdword_316(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    317: if tdword_317(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    318: if tdword_318(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    319: if tdword_319(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    320: if tdword_320(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    321: if tdword_321(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    322: if tdword_322(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    323: if tdword_323(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    324: if tdword_324(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    325: if tdword_325(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    326: if tdword_326(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    327: if tdword_327(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    328: if tdword_328(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    329: if tdword_329(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    330: if tdword_330(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    331: if tdword_331(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    332: if tdword_332(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    333: if tdword_333(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    334: if tdword_334(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    335: if tdword_335(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    336: if tdword_336(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    337: if tdword_337(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    338: if tdword_338(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    339: if tdword_339(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    340: if tdword_340(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    341: if tdword_341(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    342: if tdword_342(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    343: if tdword_343(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    344: if tdword_344(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    345: if tdword_345(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    346: if tdword_346(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    347: if tdword_347(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    348: if tdword_348(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    349: if tdword_349(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    350: if tdword_350(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    351: if tdword_351(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    352: if tdword_352(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    353: if tdword_353(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    354: if tdword_354(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    355: if tdword_355(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    356: if tdword_356(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    357: if tdword_357(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    358: if tdword_358(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    359: if tdword_359(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    360: if tdword_360(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    361: if tdword_361(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    362: if tdword_362(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    363: if tdword_363(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    364: if tdword_364(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    365: if tdword_365(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    366: if tdword_366(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    367: if tdword_367(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    368: if tdword_368(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    369: if tdword_369(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    370: if tdword_370(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    371: if tdword_371(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    372: if tdword_372(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    373: if tdword_373(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    374: if tdword_374(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    375: if tdword_375(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    376: if tdword_376(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    377: if tdword_377(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    378: if tdword_378(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    379: if tdword_379(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    380: if tdword_380(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    381: if tdword_381(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    382: if tdword_382(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    383: if tdword_383(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    384: if tdword_384(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    385: if tdword_385(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    386: if tdword_386(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    387: if tdword_387(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    388: if tdword_388(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    389: if tdword_389(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    390: if tdword_390(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    391: if tdword_391(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    392: if tdword_392(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    393: if tdword_393(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    394: if tdword_394(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    395: if tdword_395(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    396: if tdword_396(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    397: if tdword_397(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    398: if tdword_398(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    399: if tdword_399(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    400: if tdword_400(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    401: if tdword_401(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    402: if tdword_402(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    403: if tdword_403(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    404: if tdword_404(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    405: if tdword_405(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    406: if tdword_406(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    407: if tdword_407(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    408: if tdword_408(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    409: if tdword_409(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    410: if tdword_410(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    411: if tdword_411(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    412: if tdword_412(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    413: if tdword_413(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    414: if tdword_414(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    415: if tdword_415(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    416: if tdword_416(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    417: if tdword_417(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    418: if tdword_418(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    419: if tdword_419(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    420: if tdword_420(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    421: if tdword_421(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    422: if tdword_422(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    423: if tdword_423(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    424: if tdword_424(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    425: if tdword_425(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    426: if tdword_426(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    427: if tdword_427(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    428: if tdword_428(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    429: if tdword_429(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    430: if tdword_430(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
    431: if tdword_431(dword(x))<>refU(dword(x),combU[i,0],combU[i,1],combU[i,2],combU[i,3]) then bad:=bad+1;
   end;
 if bad<>0 then begin writeln('FAIL mismatches=',bad); Halt(1); end;
 writeln('OK combos L=',high(combL)+1,' U=',high(combU)+1); Halt(0);
end.
