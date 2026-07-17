{
    This file is part of the Free Pascal run time library.

    This file contains the helper routines for Int128 and UInt128.

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}
{$Q- no overflow checking }
{$R- no range checking }

    type
{$ifdef ENDIAN_LITTLE}
       tint128rec = packed record
         lo : qword;
         hi : qword;
       end;
{$endif ENDIAN_LITTLE}
{$ifdef ENDIAN_BIG}
       tint128rec = packed record
         hi : qword;
         lo : qword;
       end;
{$endif ENDIAN_BIG}

{ unsigned 128 bit less-than on split payloads }
function int128_ltu(const alo,ahi,blo,bhi:qword):boolean; inline;
begin
  int128_ltu:=(ahi<bhi) or ((ahi=bhi) and (alo<blo));
end;

{ two's complement negation in place }
procedure int128_neg(var lo,hi:qword);
var
  carry:boolean;
begin
  carry:=lo=0;
  lo:=(not lo)+1;
  hi:=not hi;
  if carry then
    hi:=hi+1;
end;

{ full 64x64->128 unsigned multiplication }
procedure int128_mul64(a,b:qword;out rlo,rhi:qword);
var
  a0,a1,b0,b1,m00,m01,m10,m11,mid:qword;
begin
  a0:=a and $ffffffff;
  a1:=a shr 32;
  b0:=b and $ffffffff;
  b1:=b shr 32;
  m00:=a0*b0;
  m01:=a0*b1;
  m10:=a1*b0;
  m11:=a1*b1;
  mid:=(m00 shr 32)+(m01 and $ffffffff)+(m10 and $ffffffff);
  rlo:=(m00 and $ffffffff) or (mid shl 32);
  rhi:=m11+(m01 shr 32)+(m10 shr 32)+(mid shr 32);
end;

{ low 128 bits of an unsigned 128x128 product; ovf set when the true
  product does not fit in 128 bits }
procedure int128_mulu(alo,ahi,blo,bhi:qword;out rlo,rhi:qword;out ovf:boolean);
var
  c1lo,c1hi,c2lo,c2hi,t:qword;
begin
  int128_mul64(alo,blo,rlo,rhi);
  int128_mul64(alo,bhi,c1lo,c1hi);
  int128_mul64(ahi,blo,c2lo,c2hi);
  ovf:=((ahi<>0) and (bhi<>0)) or (c1hi<>0) or (c2hi<>0);
  t:=rhi+c1lo;
  ovf:=ovf or (t<rhi);
  rhi:=t+c2lo;
  ovf:=ovf or (rhi<t);
end;

{ unsigned 128 bit division with remainder (binary long division) }
procedure int128_divmodu(alo,ahi,blo,bhi:qword;out qlo,qhi,rlo,rhi:qword);
var
  i:longint;
  borrow:boolean;
begin
  if (ahi=0) and (bhi=0) then
    begin
      qlo:=alo div blo;
      qhi:=0;
      rlo:=alo mod blo;
      rhi:=0;
      exit;
    end;
  qlo:=0;
  qhi:=0;
  rlo:=0;
  rhi:=0;
  for i:=127 downto 0 do
    begin
      rhi:=(rhi shl 1) or (rlo shr 63);
      rlo:=rlo shl 1;
      if i>=64 then
        rlo:=rlo or ((ahi shr (i-64)) and 1)
      else
        rlo:=rlo or ((alo shr i) and 1);
      if (rhi>bhi) or ((rhi=bhi) and (rlo>=blo)) then
        begin
          borrow:=rlo<blo;
          rlo:=rlo-blo;
          rhi:=rhi-bhi;
          if borrow then
            rhi:=rhi-1;
          if i>=64 then
            qhi:=qhi or (qword(1) shl (i-64))
          else
            qlo:=qlo or (qword(1) shl i);
        end;
    end;
end;

{ splits the magnitude of a signed 128 bit value; returns true when negative }
function int128_absneg(const lo,hi:qword;out mlo,mhi:qword):boolean;
begin
  mlo:=lo;
  mhi:=hi;
  int128_absneg:=int64(hi)<0;
  if int128_absneg then
    int128_neg(mlo,mhi);
end;

{ raw add/sub on split payloads; shared by the plain and checked variants,
  since a compilerproc cannot call another compilerproc by its Pascal name }
procedure int128_addraw(const alo,ahi,blo,bhi:qword;out rlo,rhi:qword);
begin
  rlo:=alo+blo;
  rhi:=ahi+bhi;
  if rlo<alo then
    rhi:=rhi+1;
end;

procedure int128_subraw(const alo,ahi,blo,bhi:qword;out rlo,rhi:qword);
begin
  rlo:=alo-blo;
  rhi:=ahi-bhi;
  if alo<blo then
    rhi:=rhi-1;
end;

{****************************************************************************
                           arithmetic (unchecked)
****************************************************************************}

function fpc_add_int128(a,b:Int128):Int128; [public,alias:'FPC_ADD_INT128']; compilerproc;
begin
  int128_addraw(tint128rec(a).lo,tint128rec(a).hi,tint128rec(b).lo,tint128rec(b).hi,
    tint128rec(result).lo,tint128rec(result).hi);
end;

function fpc_sub_int128(a,b:Int128):Int128; [public,alias:'FPC_SUB_INT128']; compilerproc;
begin
  int128_subraw(tint128rec(a).lo,tint128rec(a).hi,tint128rec(b).lo,tint128rec(b).hi,
    tint128rec(result).lo,tint128rec(result).hi);
end;

function fpc_mul_int128(a,b:Int128):Int128; [public,alias:'FPC_MUL_INT128']; compilerproc;
var
  ovf:boolean;
begin
  int128_mulu(tint128rec(a).lo,tint128rec(a).hi,tint128rec(b).lo,tint128rec(b).hi,
    tint128rec(result).lo,tint128rec(result).hi,ovf);
end;

function fpc_and_int128(a,b:Int128):Int128; [public,alias:'FPC_AND_INT128']; compilerproc;
begin
  tint128rec(result).lo:=tint128rec(a).lo and tint128rec(b).lo;
  tint128rec(result).hi:=tint128rec(a).hi and tint128rec(b).hi;
end;

function fpc_or_int128(a,b:Int128):Int128; [public,alias:'FPC_OR_INT128']; compilerproc;
begin
  tint128rec(result).lo:=tint128rec(a).lo or tint128rec(b).lo;
  tint128rec(result).hi:=tint128rec(a).hi or tint128rec(b).hi;
end;

function fpc_xor_int128(a,b:Int128):Int128; [public,alias:'FPC_XOR_INT128']; compilerproc;
begin
  tint128rec(result).lo:=tint128rec(a).lo xor tint128rec(b).lo;
  tint128rec(result).hi:=tint128rec(a).hi xor tint128rec(b).hi;
end;

function fpc_not_int128(a:Int128):Int128; [public,alias:'FPC_NOT_INT128']; compilerproc;
begin
  tint128rec(result).lo:=not tint128rec(a).lo;
  tint128rec(result).hi:=not tint128rec(a).hi;
end;

function fpc_neg_int128(a:Int128):Int128; [public,alias:'FPC_NEG_INT128']; compilerproc;
begin
  tint128rec(result).lo:=tint128rec(a).lo;
  tint128rec(result).hi:=tint128rec(a).hi;
  int128_neg(tint128rec(result).lo,tint128rec(result).hi);
end;

{****************************************************************************
                        arithmetic (overflow checked)
****************************************************************************}

function fpc_add_int128_checkoverflow(a,b:Int128):Int128; [public,alias:'FPC_ADD_INT128_CHECKOVERFLOW']; compilerproc;
var
  sa,sb,sr:boolean;
begin
  int128_addraw(tint128rec(a).lo,tint128rec(a).hi,tint128rec(b).lo,tint128rec(b).hi,
    tint128rec(result).lo,tint128rec(result).hi);
  sa:=int64(tint128rec(a).hi)<0;
  sb:=int64(tint128rec(b).hi)<0;
  sr:=int64(tint128rec(result).hi)<0;
  { same-signed operands whose result flips sign overflowed }
  if (sa=sb) and (sr<>sa) then
    HandleErrorAddrFrameInd(215,get_pc_addr,get_frame);
end;

function fpc_sub_int128_checkoverflow(a,b:Int128):Int128; [public,alias:'FPC_SUB_INT128_CHECKOVERFLOW']; compilerproc;
var
  sa,sb,sr:boolean;
begin
  int128_subraw(tint128rec(a).lo,tint128rec(a).hi,tint128rec(b).lo,tint128rec(b).hi,
    tint128rec(result).lo,tint128rec(result).hi);
  sa:=int64(tint128rec(a).hi)<0;
  sb:=int64(tint128rec(b).hi)<0;
  sr:=int64(tint128rec(result).hi)<0;
  { differently-signed operands whose result differs in sign from a overflowed }
  if (sa<>sb) and (sr<>sa) then
    HandleErrorAddrFrameInd(215,get_pc_addr,get_frame);
end;

function fpc_mul_int128_checkoverflow(a,b:Int128):Int128; [public,alias:'FPC_MUL_INT128_CHECKOVERFLOW']; compilerproc;
var
  aalo,aahi,bblo,bbhi,rlo,rhi:qword;
  ovf,negres:boolean;
begin
  negres:=int128_absneg(tint128rec(a).lo,tint128rec(a).hi,aalo,aahi) xor
          int128_absneg(tint128rec(b).lo,tint128rec(b).hi,bblo,bbhi);
  int128_mulu(aalo,aahi,bblo,bbhi,rlo,rhi,ovf);
  if negres then
    begin
      { magnitude must not exceed 2^127 (low(int128) is exactly -2^127) }
      if ovf or ((int64(rhi)<0) and ((rhi<>qword($8000000000000000)) or (rlo<>0))) then
        HandleErrorAddrFrameInd(215,get_pc_addr,get_frame);
      int128_neg(rlo,rhi);
    end
  else
    if ovf or (int64(rhi)<0) then
      HandleErrorAddrFrameInd(215,get_pc_addr,get_frame);
  tint128rec(result).lo:=rlo;
  tint128rec(result).hi:=rhi;
end;

function fpc_add_uint128_checkoverflow(a,b:UInt128):UInt128; [public,alias:'FPC_ADD_UINT128_CHECKOVERFLOW']; compilerproc;
begin
  int128_addraw(tint128rec(a).lo,tint128rec(a).hi,tint128rec(b).lo,tint128rec(b).hi,
    tint128rec(result).lo,tint128rec(result).hi);
  { carry out of bit 127 means the sum wrapped }
  if int128_ltu(tint128rec(result).lo,tint128rec(result).hi,tint128rec(a).lo,tint128rec(a).hi) then
    HandleErrorAddrFrameInd(215,get_pc_addr,get_frame);
end;

function fpc_sub_uint128_checkoverflow(a,b:UInt128):UInt128; [public,alias:'FPC_SUB_UINT128_CHECKOVERFLOW']; compilerproc;
begin
  if int128_ltu(tint128rec(a).lo,tint128rec(a).hi,tint128rec(b).lo,tint128rec(b).hi) then
    HandleErrorAddrFrameInd(215,get_pc_addr,get_frame);
  int128_subraw(tint128rec(a).lo,tint128rec(a).hi,tint128rec(b).lo,tint128rec(b).hi,
    tint128rec(result).lo,tint128rec(result).hi);
end;

function fpc_mul_uint128_checkoverflow(a,b:UInt128):UInt128; [public,alias:'FPC_MUL_UINT128_CHECKOVERFLOW']; compilerproc;
var
  ovf:boolean;
begin
  int128_mulu(tint128rec(a).lo,tint128rec(a).hi,tint128rec(b).lo,tint128rec(b).hi,
    tint128rec(result).lo,tint128rec(result).hi,ovf);
  if ovf then
    HandleErrorAddrFrameInd(215,get_pc_addr,get_frame);
end;

function fpc_neg_int128_checkoverflow(a:Int128):Int128; [public,alias:'FPC_NEG_INT128_CHECKOVERFLOW']; compilerproc;
begin
  { only -low(int128) overflows the signed range }
  if (tint128rec(a).hi=qword($8000000000000000)) and (tint128rec(a).lo=0) then
    HandleErrorAddrFrameInd(215,get_pc_addr,get_frame);
  tint128rec(result).lo:=tint128rec(a).lo;
  tint128rec(result).hi:=tint128rec(a).hi;
  int128_neg(tint128rec(result).lo,tint128rec(result).hi);
end;

function fpc_neg_uint128_checkoverflow(a:Int128):Int128; [public,alias:'FPC_NEG_UINT128_CHECKOVERFLOW']; compilerproc;
begin
  { negating any non-zero unsigned value leaves the unsigned range }
  if (tint128rec(a).lo<>0) or (tint128rec(a).hi<>0) then
    HandleErrorAddrFrameInd(215,get_pc_addr,get_frame);
  result:=a;
end;

{****************************************************************************
                              comparison
****************************************************************************}

function fpc_cmp_int128(a,b:Int128):longint; [public,alias:'FPC_CMP_INT128']; compilerproc;
begin
  if int64(tint128rec(a).hi)<int64(tint128rec(b).hi) then
    fpc_cmp_int128:=-1
  else if int64(tint128rec(a).hi)>int64(tint128rec(b).hi) then
    fpc_cmp_int128:=1
  else if tint128rec(a).lo<tint128rec(b).lo then
    fpc_cmp_int128:=-1
  else if tint128rec(a).lo>tint128rec(b).lo then
    fpc_cmp_int128:=1
  else
    fpc_cmp_int128:=0;
end;

function fpc_cmp_uint128(a,b:UInt128):longint; [public,alias:'FPC_CMP_UINT128']; compilerproc;
begin
  if tint128rec(a).hi<tint128rec(b).hi then
    fpc_cmp_uint128:=-1
  else if tint128rec(a).hi>tint128rec(b).hi then
    fpc_cmp_uint128:=1
  else if tint128rec(a).lo<tint128rec(b).lo then
    fpc_cmp_uint128:=-1
  else if tint128rec(a).lo>tint128rec(b).lo then
    fpc_cmp_uint128:=1
  else
    fpc_cmp_uint128:=0;
end;

{****************************************************************************
                              div and mod
    named like the int64 helpers: fpc_div_int128(n,z) returns z div n,
    n is the divisor (right operand), z is the dividend (left operand)
****************************************************************************}

function fpc_div_uint128(n,z:UInt128):UInt128; [public,alias:'FPC_DIV_UINT128']; compilerproc;
var
  qlo,qhi,rlo,rhi:qword;
begin
  if (tint128rec(n).lo=0) and (tint128rec(n).hi=0) then
    HandleErrorAddrFrameInd(200,get_pc_addr,get_frame);
  int128_divmodu(tint128rec(z).lo,tint128rec(z).hi,tint128rec(n).lo,tint128rec(n).hi,
    qlo,qhi,rlo,rhi);
  tint128rec(result).lo:=qlo;
  tint128rec(result).hi:=qhi;
end;

function fpc_mod_uint128(n,z:UInt128):UInt128; [public,alias:'FPC_MOD_UINT128']; compilerproc;
var
  qlo,qhi,rlo,rhi:qword;
begin
  if (tint128rec(n).lo=0) and (tint128rec(n).hi=0) then
    HandleErrorAddrFrameInd(200,get_pc_addr,get_frame);
  int128_divmodu(tint128rec(z).lo,tint128rec(z).hi,tint128rec(n).lo,tint128rec(n).hi,
    qlo,qhi,rlo,rhi);
  tint128rec(result).lo:=rlo;
  tint128rec(result).hi:=rhi;
end;

function fpc_div_int128(n,z:Int128):Int128; [public,alias:'FPC_DIV_INT128']; compilerproc;
var
  nlo,nhi,zlo,zhi,qlo,qhi,rlo,rhi:qword;
  negres:boolean;
begin
  if (tint128rec(n).lo=0) and (tint128rec(n).hi=0) then
    HandleErrorAddrFrameInd(200,get_pc_addr,get_frame);
  negres:=int128_absneg(tint128rec(z).lo,tint128rec(z).hi,zlo,zhi) xor
          int128_absneg(tint128rec(n).lo,tint128rec(n).hi,nlo,nhi);
  int128_divmodu(zlo,zhi,nlo,nhi,qlo,qhi,rlo,rhi);
  if negres then
    int128_neg(qlo,qhi)
  else
    { the only signed div overflow is low(Int128) div -1 = 2^127, which has no
      positive representation; trap it like int64 div does on every target }
    if int64(qhi)<0 then
      HandleErrorAddrFrameInd(215,get_pc_addr,get_frame);
  tint128rec(result).lo:=qlo;
  tint128rec(result).hi:=qhi;
end;

function fpc_mod_int128(n,z:Int128):Int128; [public,alias:'FPC_MOD_INT128']; compilerproc;
var
  nlo,nhi,zlo,zhi,qlo,qhi,rlo,rhi:qword;
  zneg:boolean;
begin
  if (tint128rec(n).lo=0) and (tint128rec(n).hi=0) then
    HandleErrorAddrFrameInd(200,get_pc_addr,get_frame);
  { the sign of a modulo follows the dividend only }
  zneg:=int128_absneg(tint128rec(z).lo,tint128rec(z).hi,zlo,zhi);
  int128_absneg(tint128rec(n).lo,tint128rec(n).hi,nlo,nhi);
  int128_divmodu(zlo,zhi,nlo,nhi,qlo,qhi,rlo,rhi);
  if zneg then
    int128_neg(rlo,rhi);
  tint128rec(result).lo:=rlo;
  tint128rec(result).hi:=rhi;
end;

{****************************************************************************
                              shifts
    shl/shr operate on the raw payload, so one signed entry point serves
    both signednesses; shr is a logical shift, matching Pascal semantics
****************************************************************************}

function fpc_shl_int128(value:Int128;shift:int64):Int128; [public,alias:'FPC_SHL_INT128']; compilerproc;
var
  s:longint;
begin
  s:=longint(shift and 127);
  if s=0 then
    begin
      tint128rec(result).lo:=tint128rec(value).lo;
      tint128rec(result).hi:=tint128rec(value).hi;
    end
  else if s>=64 then
    begin
      tint128rec(result).hi:=tint128rec(value).lo shl (s-64);
      tint128rec(result).lo:=0;
    end
  else
    begin
      tint128rec(result).hi:=(tint128rec(value).hi shl s) or (tint128rec(value).lo shr (64-s));
      tint128rec(result).lo:=tint128rec(value).lo shl s;
    end;
end;

function fpc_shr_int128(value:Int128;shift:int64):Int128; [public,alias:'FPC_SHR_INT128']; compilerproc;
var
  s:longint;
begin
  s:=longint(shift and 127);
  if s=0 then
    begin
      tint128rec(result).lo:=tint128rec(value).lo;
      tint128rec(result).hi:=tint128rec(value).hi;
    end
  else if s>=64 then
    begin
      tint128rec(result).lo:=tint128rec(value).hi shr (s-64);
      tint128rec(result).hi:=0;
    end
  else
    begin
      tint128rec(result).lo:=(tint128rec(value).lo shr s) or (tint128rec(value).hi shl (64-s));
      tint128rec(result).hi:=tint128rec(value).hi shr s;
    end;
end;

{****************************************************************************
                          int128 to double
****************************************************************************}

function fpc_int128_to_double(v:Int128):double; [public,alias:'FPC_INT128_TO_DOUBLE']; compilerproc;
const
  two64:double = 18446744073709551616.0;
var
  mlo,mhi:qword;
begin
  if int128_absneg(tint128rec(v).lo,tint128rec(v).hi,mlo,mhi) then
    fpc_int128_to_double:=-(double(mhi)*two64+double(mlo))
  else
    fpc_int128_to_double:=double(mhi)*two64+double(mlo);
end;

function fpc_uint128_to_double(v:UInt128):double; [public,alias:'FPC_UINT128_TO_DOUBLE']; compilerproc;
const
  two64:double = 18446744073709551616.0;
begin
  fpc_uint128_to_double:=double(tint128rec(v).hi)*two64+double(tint128rec(v).lo);
end;

{****************************************************************************
                          int64/qword widen to int128
    on targets without a 64 bit ALU the inline sign/zero extension is not
    available, so the widening goes through these helpers
****************************************************************************}

function fpc_int64_to_int128(v:int64):Int128; [public,alias:'FPC_INT64_TO_INT128']; compilerproc;
begin
  tint128rec(result).lo:=qword(v);
  if v<0 then
    tint128rec(result).hi:=high(qword)
  else
    tint128rec(result).hi:=0;
end;

function fpc_qword_to_uint128(v:qword):UInt128; [public,alias:'FPC_QWORD_TO_UINT128']; compilerproc;
begin
  tint128rec(result).lo:=v;
  tint128rec(result).hi:=0;
end;

{****************************************************************************
                          decimal conversion core
****************************************************************************}

{ unsigned 128 bit magnitude to its shortstring decimal digits }
procedure int128_udecimal(lo,hi:qword;out s:shortstring);
var
  qlo,qhi,rlo,rhi:qword;
  i,n:longint;
  tmp:array[0..39] of ansichar;
begin
  n:=0;
  repeat
    int128_divmodu(lo,hi,10,0,qlo,qhi,rlo,rhi);
    tmp[n]:=ansichar(ord('0')+longint(rlo));
    inc(n);
    lo:=qlo;
    hi:=qhi;
  until (lo=0) and (hi=0);
  s[0]:=ansichar(n);
  for i:=1 to n do
    s[i]:=tmp[n-i];
end;

procedure int128_str_unsigned(lo,hi:qword;len:SizeInt;out s:shortstring);
begin
  int128_udecimal(lo,hi,s);
  if length(s)<len then
    s:=space(len-length(s))+s;
end;

procedure int128_str_signed(lo,hi:qword;len:SizeInt;out s:shortstring);
var
  mlo,mhi:qword;
begin
  if int128_absneg(lo,hi,mlo,mhi) then
    begin
      int128_udecimal(mlo,mhi,s);
      s:='-'+s;
    end
  else
    int128_udecimal(mlo,mhi,s);
  if length(s)<len then
    s:=space(len-length(s))+s;
end;

procedure fpc_shortstr_uint128(v:UInt128;len:SizeInt;out s:shortstring); [public,alias:'FPC_SHORTSTR_UINT128']; compilerproc;
begin
  int128_str_unsigned(tint128rec(v).lo,tint128rec(v).hi,len,s);
end;

procedure fpc_shortstr_int128(v:Int128;len:SizeInt;out s:shortstring); [public,alias:'FPC_SHORTSTR_INT128']; compilerproc;
begin
  int128_str_signed(tint128rec(v).lo,tint128rec(v).hi,len,s);
end;

procedure fpc_chararray_uint128(v:UInt128;len:SizeInt;out a:array of AnsiChar); [public,alias:'FPC_CHARARRAY_UINT128']; compilerproc;
var
  ss:shortstring;
  maxlen:SizeInt;
begin
  int128_str_unsigned(tint128rec(v).lo,tint128rec(v).hi,len,ss);
  if length(ss)<high(a)+1 then
    maxlen:=length(ss)
  else
    maxlen:=high(a)+1;
  fpc_shortstr_chararray_intern_charmove(ss,a,maxlen);
end;

procedure fpc_chararray_int128(v:Int128;len:SizeInt;out a:array of AnsiChar); [public,alias:'FPC_CHARARRAY_INT128']; compilerproc;
var
  ss:shortstring;
  maxlen:SizeInt;
begin
  int128_str_signed(tint128rec(v).lo,tint128rec(v).hi,len,ss);
  if length(ss)<high(a)+1 then
    maxlen:=length(ss)
  else
    maxlen:=high(a)+1;
  fpc_shortstr_chararray_intern_charmove(ss,a,maxlen);
end;

{ parses digits of the given base into a 128 bit magnitude; returns false on
  overflow past 2^128-1 or on encountering a non-digit }
function int128_accumulate(const s:shortstring;start:SizeInt;base:byte;out lo,hi:qword):SizeInt;
var
  i:SizeInt;
  d:longint;
  c:ansichar;
  plo,phi,plo2,phi2,rlo,rhi:qword;
  ovf:boolean;
begin
  lo:=0;
  hi:=0;
  i:=start;
  while i<=length(s) do
    begin
      c:=s[i];
      case c of
        '0'..'9': d:=ord(c)-ord('0');
        'a'..'f': d:=ord(c)-ord('a')+10;
        'A'..'F': d:=ord(c)-ord('A')+10;
        else
          break;
      end;
      if d>=base then
        break;
      { value := value*base + d, with overflow detection }
      int128_mulu(lo,hi,base,0,plo,phi,ovf);
      if ovf then
        begin
          int128_accumulate:=i;
          exit;
        end;
      plo2:=plo+qword(d);
      phi2:=phi;
      if plo2<plo then
        inc(phi2);
      { carry past bit 127 means overflow }
      if int128_ltu(plo2,phi2,plo,phi) then
        begin
          int128_accumulate:=i;
          exit;
        end;
      rlo:=plo2; rhi:=phi2;
      lo:=rlo;
      hi:=rhi;
      inc(i);
    end;
  int128_accumulate:=i;
end;

{ shared Val core: parses [sign][base-prefix]digits; sets code to 0 on
  success or the 1-based position of the offending char; base is returned
  so the callers can apply base specific range rules }
procedure int128_val(const s:shortstring;out lo,hi:qword;out negative:boolean;out base:byte;out code:SizeInt);
var
  i,ns,stop:SizeInt;
begin
  lo:=0;
  hi:=0;
  negative:=false;
  ns:=length(s);
  i:=1;
  { leading spaces and tabs }
  while (i<=ns) and (s[i] in [' ',#9]) do
    inc(i);
  if i>ns then
    begin
      code:=i;
      exit;
    end;
  case s[i] of
    '-': begin negative:=true; inc(i); end;
    '+': inc(i);
  end;
  base:=10;
  if i<=ns then
    case s[i] of
      '$','x','X': begin base:=16; inc(i); end;
      '&': begin base:=8; inc(i); end;
      '%': begin base:=2; inc(i); end;
      '0':
        if (i<ns) and (s[i+1] in ['x','X']) then
          begin base:=16; inc(i,2); end;
    end;
  if i>ns then
    begin
      code:=i;
      exit;
    end;
  stop:=int128_accumulate(s,i,base,lo,hi);
  { a #0 terminates the string, like the int64 Val path }
  if (stop<=ns) and (s[stop]<>#0) then
    begin
      { trailing garbage or overflow position }
      code:=stop;
      lo:=0;
      hi:=0;
      negative:=false;
      exit;
    end;
  code:=0;
end;

function fpc_val_uint128_shortstr(const s:shortstring;out code:ValSInt):UInt128; [public,alias:'FPC_VAL_UINT128_SHORTSTR']; compilerproc;
var
  lo,hi:qword;
  negative:boolean;
  base:byte;
  cd:SizeInt;
begin
  int128_val(s,lo,hi,negative,base,cd);
  if (cd=0) and negative and ((lo<>0) or (hi<>0)) then
    { a negative value does not fit an unsigned target }
    cd:=1;
  code:=cd;
  if cd<>0 then
    begin
      fpc_val_uint128_shortstr:=0;
      exit;
    end;
  tint128rec(result).lo:=lo;
  tint128rec(result).hi:=hi;
end;

function fpc_val_int128_shortstr(const s:shortstring;out code:ValSInt):Int128; [public,alias:'FPC_VAL_INT128_SHORTSTR']; compilerproc;
var
  lo,hi:qword;
  negative:boolean;
  base:byte;
  cd:SizeInt;
begin
  int128_val(s,lo,hi,negative,base,cd);
  if cd=0 then
    begin
      if negative then
        begin
          { magnitude must not exceed 2^127 }
          if (hi>qword($8000000000000000)) or
             ((hi=qword($8000000000000000)) and (lo<>0)) then
            cd:=1
          else
            int128_neg(lo,hi);
        end
      else
        { decimal input must fit the positive range; the other bases
          accept the full bit pattern like the smaller signed types }
        if (base=10) and (int64(hi)<0) then
          cd:=1;
    end;
  code:=cd;
  if cd<>0 then
    begin
      fpc_val_int128_shortstr:=0;
      exit;
    end;
  tint128rec(result).lo:=lo;
  tint128rec(result).hi:=hi;
end;

{****************************************************************************
                    abs / sqr / odd (plain overloads)
    these lower to the operators above; no dedicated compiler support
****************************************************************************}

Function Abs(l:Int128):Int128;
begin
  if l<0 then
    Abs:=-l
  else
    Abs:=l;
end;

Function Sqr(l:Int128):Int128;
begin
  Sqr:=l*l;
end;

Function Sqr(l:UInt128):UInt128;
begin
  Sqr:=l*l;
end;

Function Odd(l:Int128):Boolean;
begin
  Odd:=odd(tint128rec(l).lo);
end;

Function Odd(l:UInt128):Boolean;
begin
  Odd:=odd(tint128rec(l).lo);
end;
