{
    Copyright (c) 2007 by Daniel Mantione

    This unit implements a Tconstexprint type. This type simulates an integer
    type that can handle numbers from low(int128) to high(uint128) calculations.

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

 ****************************************************************************
}
unit constexp;

{$i fpcdefs.inc}
{$modeswitch advancedrecords}

interface

{Avoid dependency on cpuinfo because the cpu directory isn't
 searched during utils building.}
{$ifdef GENERIC_CPU}
type  bestreal=extended;
{$else}
{$ifdef x86}
type  bestreal=extended;
{$else}
type  bestreal=double;
{$endif}
{$endif}

{ The value is stored as a raw 128 bit two's complement payload in vlo/vhi.
  The signed flag keeps its historical meaning relative to the 64 bit low
  half: reading svalue/uvalue yields the low half, writing them sign/zero
  extends into the high half. Code that only deals with values in
  low(int64)..high(qword) behaves exactly as before. }
type  Tconstexprint=record
      strict private
        function getsvalue:int64;inline;
        procedure setsvalue(v:int64);inline;
        function getuvalue:qword;inline;
        procedure setuvalue(v:qword);inline;
      public
        function is_negative: boolean; inline;
        function extract_sign_abs(out abslo,abshi: qword): boolean;
        procedure div_or_mod(const by: Tconstexprint; isdiv: boolean; out r: Tconstexprint);
        function tobestreal: bestreal;
        { true when the value lies in low(int64)..high(qword), i.e. the range
          supported before 128 bit constants existed }
        function representable64: boolean;
        function fitsinint64: boolean;
        function fitsinqword: boolean;
      var
        overflow:boolean;
        signed:boolean;
        vlo,vhi:qword;
        property svalue:int64 read getsvalue write setsvalue;
        property uvalue:qword read getuvalue write setuvalue;
      end;

{ bounds of the 128 bit integer types }
function int128_low:Tconstexprint;
function int128_high:Tconstexprint;
function uint128_high:Tconstexprint;

{ shifts over the full 128 bit payload, for contexts where the result
  type is 128 bit; the shl/shr operators below keep the historical 64 bit
  window when both operands lie in it }
function shl128(const a,b:Tconstexprint):Tconstexprint;
function shr128(const a,b:Tconstexprint):Tconstexprint;

{ parses an integer literal in val syntax (optional sign, $/&/% prefixes)
  into a 128 bit value; error is set when malformed or out of range }
function str_to_tconstexprint(const s:shortstring;out error:boolean):Tconstexprint;

operator := (const u:qword):Tconstexprint;inline;
operator := (const s:int64):Tconstexprint;inline;
operator := (const c:Tconstexprint):qword;
operator := (const c:Tconstexprint):int64;
operator := (const c:Tconstexprint):bestreal;

operator + (const a,b:Tconstexprint):Tconstexprint;
operator - (const a,b:Tconstexprint):Tconstexprint;
operator - (const a:Tconstexprint):Tconstexprint;
operator * (const a,b:Tconstexprint):Tconstexprint;
operator div (const a,b:Tconstexprint):Tconstexprint; inline;
operator mod (const a,b:Tconstexprint):Tconstexprint; inline;
operator / (const a,b:Tconstexprint):bestreal;

operator = (const a,b:Tconstexprint):boolean;
operator > (const a,b:Tconstexprint):boolean; inline; { Are reformulated using <. }
operator >= (const a,b:Tconstexprint):boolean; inline;
operator < (const a,b:Tconstexprint):boolean;
operator <= (const a,b:Tconstexprint):boolean; inline;

operator and (const a,b:Tconstexprint):Tconstexprint;
operator or (const a,b:Tconstexprint):Tconstexprint;
operator xor (const a,b:Tconstexprint):Tconstexprint;
operator shl (const a,b:Tconstexprint):Tconstexprint;
operator shr (const a,b:Tconstexprint):Tconstexprint;

function tostr(const i:Tconstexprint):shortstring;overload;

{****************************************************************************}
implementation
{****************************************************************************}

uses
  cutils;

{****************************************************************************
                          128 bit primitives
****************************************************************************}

{$push} {$q-,r-}

{ unsigned 128 bit less-than on raw payloads }
function ltu128(const alo,ahi,blo,bhi:qword):boolean;inline;
begin
  result:=(ahi<bhi) or ((ahi=bhi) and (alo<blo));
end;

{ two's complement negation in place }
procedure neg128(var lo,hi:qword);
var
  carry:boolean;
begin
  carry:=lo=0;
  lo:=(not lo)+1;
  hi:=not hi;
  if carry then
    hi:=hi+1;
end;

{ full 64x64->128 multiplication }
procedure mul64to128(a,b:qword;out rlo,rhi:qword);
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

{ low 128 bits of an unsigned 128x128 product, ovf set when the true
  product does not fit in 128 bits }
procedure mulu128(alo,ahi,blo,bhi:qword;out rlo,rhi:qword;out ovf:boolean);
var
  c1lo,c1hi,c2lo,c2hi,t:qword;
begin
  mul64to128(alo,blo,rlo,rhi);
  mul64to128(alo,bhi,c1lo,c1hi);
  mul64to128(ahi,blo,c2lo,c2hi);
  ovf:=((ahi<>0) and (bhi<>0)) or (c1hi<>0) or (c2hi<>0);
  t:=rhi+c1lo;
  ovf:=ovf or (t<rhi);
  rhi:=t+c2lo;
  ovf:=ovf or (rhi<t);
end;

{ unsigned 128 bit division with remainder }
procedure divmodu128(alo,ahi,blo,bhi:qword;out qlo,qhi,rlo,rhi:qword);
var
  i:longint;
  borrow:boolean;
begin
  if (ahi=0) and (bhi=0) then
    begin
      { b<>0 is guaranteed by the caller }
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

{****************************************************************************
                             Tconstexprint
****************************************************************************}

function Tconstexprint.getsvalue:int64;
begin
  result:=int64(vlo);
end;

procedure Tconstexprint.setsvalue(v:int64);
begin
  vlo:=qword(v);
  if v<0 then
    vhi:=high(qword)
  else
    vhi:=0;
  signed:=true;
end;

function Tconstexprint.getuvalue:qword;
begin
  result:=vlo;
end;

procedure Tconstexprint.setuvalue(v:qword);
begin
  vlo:=v;
  vhi:=0;
  signed:=false;
end;

function Tconstexprint.is_negative: boolean;
begin
  result:=signed and (int64(vhi)<0);
end;

function Tconstexprint.extract_sign_abs(out abslo,abshi: qword): boolean;
begin
  result:=is_negative;
  abslo:=vlo;
  abshi:=vhi;
  if result then
    neg128(abslo,abshi);
end;

function Tconstexprint.fitsinint64: boolean;
begin
  if is_negative then
    result:=(vhi=high(qword)) and (int64(vlo)<0)
  else
    result:=(vhi=0) and (int64(vlo)>=0);
end;

function Tconstexprint.fitsinqword: boolean;
begin
  result:=(not is_negative) and (vhi=0);
end;

function Tconstexprint.representable64: boolean;
begin
  if is_negative then
    result:=(vhi=high(qword)) and (int64(vlo)<0)
  else
    result:=vhi=0;
end;

procedure Tconstexprint.div_or_mod(const by: Tconstexprint; isdiv: boolean; out r: Tconstexprint);
var
  aalo,aahi,bblo,bbhi,qlo,qhi,remlo,remhi: qword;
  negres: boolean;
begin
  if (by.vlo or by.vhi)=0 then
    begin
      r:=qword(-int64(isdiv)); { Something. All ones if div, all zeros if mod. }
      r.overflow:=true;
      exit;
    end;
  { the sign of a modulo operation only depends on the sign of the
    dividend }
  negres:=self.extract_sign_abs(aalo,aahi) xor by.extract_sign_abs(bblo,bbhi) and isdiv;
  r.overflow:=self.overflow or by.overflow;
  divmodu128(aalo,aahi,bblo,bbhi,qlo,qhi,remlo,remhi);
  if isdiv then
    begin
      r.vlo:=qlo;
      r.vhi:=qhi;
    end
  else
    begin
      r.vlo:=remlo;
      r.vhi:=remhi;
    end;
  r.signed:=negres or ((r.vhi=0) and (int64(r.vlo)>=0));
  if negres then
    begin
      neg128(r.vlo,r.vhi);
      r.overflow:=r.overflow or ((int64(r.vhi)>=0) and ((r.vlo or r.vhi)<>0)); { Strictly > 0! }
    end;
end;
{$pop}

function Tconstexprint.tobestreal: bestreal;
const
  two64: bestreal = 18446744073709551616.0;
var
  mlo,mhi: qword;
begin
  if overflow then
    internalerrorproc(200706095);
  if representable64 then
    begin
      if signed then
        result:=svalue
      else
        result:=uvalue;
    end
  else
    begin
      if extract_sign_abs(mlo,mhi) then
        result:=-(bestreal(mhi)*two64+bestreal(mlo))
      else
        result:=bestreal(mhi)*two64+bestreal(mlo);
    end;
end;

function int128_low:Tconstexprint;
begin
  result.overflow:=false;
  result.signed:=true;
  result.vlo:=0;
  result.vhi:=qword($8000000000000000);
end;

function int128_high:Tconstexprint;
begin
  result.overflow:=false;
  result.signed:=false;
  result.vlo:=high(qword);
  result.vhi:=qword($7fffffffffffffff);
end;

function uint128_high:Tconstexprint;
begin
  result.overflow:=false;
  result.signed:=false;
  result.vlo:=high(qword);
  result.vhi:=high(qword);
end;

operator := (const u:qword):Tconstexprint;

begin
  result.overflow:=false;
  result.signed:=false;
  result.vlo:=u;
  result.vhi:=0;
end;

operator := (const s:int64):Tconstexprint;

begin
  result.overflow:=false;
  result.signed:=true;
  result.vlo:=qword(s);
  if s<0 then
    result.vhi:=high(qword)
  else
    result.vhi:=0;
end;

operator := (const c:Tconstexprint):qword;

begin
  if c.overflow then
    internalerrorproc(200706091);
  if c.is_negative then
    internalerrorproc(200706092);
  if c.vhi<>0 then
    internalerrorproc(2026070701);
  result:=c.vlo;
end;

operator := (const c:Tconstexprint):int64;

begin
  if c.overflow then
    internalerrorproc(200706093);
  if c.is_negative then
    begin
      if (c.vhi<>high(qword)) or (int64(c.vlo)>=0) then
        internalerrorproc(2026070702);
    end
  else
    if (c.vhi<>0) or (int64(c.vlo)<0) then
      internalerrorproc(200706094);
  result:=int64(c.vlo);
end;

operator := (const c:Tconstexprint):bestreal;

begin
  result:=c.tobestreal;
end;

{$push} {$q-,r-}
operator + (const a,b:Tconstexprint):Tconstexprint;

var aneg,bneg,carry:boolean;

begin
  result.overflow:=a.overflow or b.overflow;
  result.vlo:=a.vlo+b.vlo;
  result.vhi:=a.vhi+b.vhi;
  if result.vlo<a.vlo then
    result.vhi:=result.vhi+1;
  carry:=ltu128(result.vlo,result.vhi,a.vlo,a.vhi);
  aneg:=a.is_negative;
  bneg:=b.is_negative;
  if aneg<>bneg then
    { Negative + positive: cannot overflow, negative when the positive
      operand does not reach the magnitude of the negative one. }
    result.signed:=not carry or ((result.vhi=0) and (int64(result.vlo)>=0))
  else if aneg then
    begin
      { Negative + negative: overflow if positive, always signed. }
      result.overflow:=result.overflow or (int64(result.vhi)>=0);
      result.signed:=true;
    end
  else
    begin
      { Positive + positive: overflow if became less, signed if fits. }
      result.overflow:=result.overflow or carry;
      result.signed:=(result.vhi=0) and (int64(result.vlo)>=0);
    end;
end;

operator - (const a,b:Tconstexprint):Tconstexprint;

var aneg,bneg,borrow,rneg:boolean;

begin
  result.overflow:=a.overflow or b.overflow;
  borrow:=ltu128(a.vlo,a.vhi,b.vlo,b.vhi);
  result.vlo:=a.vlo-b.vlo;
  result.vhi:=a.vhi-b.vhi;
  if a.vlo<b.vlo then
    result.vhi:=result.vhi-1;
  aneg:=a.is_negative;
  bneg:=b.is_negative;
  if aneg then
    begin
      { Negative - negative: cannot overflow, negative if abs(a)>abs(b).
        Negative - positive: overflow if b too big or result positive,
        always negative. }
      if bneg then
        rneg:=borrow
      else
        begin
          rneg:=true;
          result.overflow:=result.overflow or (int64(b.vhi)<0) or (int64(result.vhi)>=0);
        end;
    end
  else if bneg then
    begin
      { Positive - negative: overflow if became less, never negative. }
      rneg:=false;
      result.overflow:=result.overflow or ltu128(result.vlo,result.vhi,a.vlo,a.vhi);
    end
  else
    begin
      { Positive - positive: overflow if a < b but result is positive,
        negative on borrow. }
      rneg:=borrow;
      result.overflow:=result.overflow or (borrow and (int64(result.vhi)>=0));
    end;
  result.signed:=rneg or ((result.vhi=0) and (int64(result.vlo)>=0));
end;

operator - (const a:Tconstexprint):Tconstexprint;

var aneg:boolean;

begin
  aneg:=a.is_negative;
  result.vlo:=a.vlo;
  result.vhi:=a.vhi;
  neg128(result.vlo,result.vhi);
  { Will trigger on > -Low(int128). }
  result.overflow:=a.overflow or (not aneg and (int64(result.vhi)>=0) and ((result.vlo or result.vhi)<>0));
  { Unsigned only if negating Low(int128). }
  if aneg and (a.vhi=qword($8000000000000000)) and (a.vlo=0) then
    result.signed:=false
  else
    result.signed:=(not aneg and ((a.vlo or a.vhi)<>0)) or ((result.vhi=0) and (int64(result.vlo)>=0));
end;

operator * (const a,b:Tconstexprint):Tconstexprint;

var aalo,aahi,bblo,bbhi:qword;
    negres,mulovf:boolean;

begin
  negres:=a.extract_sign_abs(aalo,aahi) xor b.extract_sign_abs(bblo,bbhi);
  mulu128(aalo,aahi,bblo,bbhi,result.vlo,result.vhi,mulovf);
  result.overflow:=a.overflow or b.overflow or mulovf;
  if negres then
    begin
      { negated magnitude must not fall below low(int128) }
      result.overflow:=result.overflow or ((int64(result.vhi)<0) and
        ((result.vhi<>qword($8000000000000000)) or (result.vlo<>0)));
      neg128(result.vlo,result.vhi);
      result.signed:=true;
    end
  else
    result.signed:=(result.vhi=0) and (int64(result.vlo)>=0);
end;
{$pop}

operator div (const a,b:Tconstexprint):Tconstexprint;

begin
  a.div_or_mod(b,true,result);
end;

operator mod (const a,b:Tconstexprint):Tconstexprint;

begin
  a.div_or_mod(b,false,result);
end;

operator / (const a,b:Tconstexprint):bestreal;

begin
  result:=a.tobestreal/b.tobestreal;
end;

operator = (const a,b:Tconstexprint):boolean;

begin
  result:=(a.vlo=b.vlo) and (a.vhi=b.vhi) and (a.is_negative=b.is_negative);
end;

operator > (const a,b:Tconstexprint):boolean;

begin
  result:=b<a;
end;

operator >= (const a,b:Tconstexprint):boolean;

begin
  result:=not(a<b);
end;

operator < (const a,b:Tconstexprint):boolean;

begin
  result:=a.is_negative;
  if result=b.is_negative then
    result:=ltu128(a.vlo,a.vhi,b.vlo,b.vhi); { Works both with positive < positive and unsigned(negative) < unsigned(negative). }
end;

operator <= (const a,b:Tconstexprint):boolean;

begin
  result:=not(b<a);
end;

{$push} {$q-,r-}
{ the historical bitwise semantics work on the 64 bit payload and
  reinterpret the sign bit afterwards; this keeps that behavior for values
  in the old envelope and uses the raw 128 bit payload beyond it }
procedure signfill64(var r:Tconstexprint);
begin
  if r.signed and (int64(r.vlo)<0) then
    r.vhi:=high(qword)
  else
    r.vhi:=0;
end;

operator and (const a,b:Tconstexprint):Tconstexprint;

begin
  result.overflow:=false;
  result.signed:=a.signed or b.signed;
  result.vlo:=a.vlo and b.vlo;
  if a.representable64 and b.representable64 then
    signfill64(result)
  else
    result.vhi:=a.vhi and b.vhi;
end;

operator or (const a,b:Tconstexprint):Tconstexprint;

begin
  result.overflow:=false;
  result.signed:=a.signed or b.signed;
  result.vlo:=a.vlo or b.vlo;
  if a.representable64 and b.representable64 then
    signfill64(result)
  else
    result.vhi:=a.vhi or b.vhi;
end;

operator xor (const a,b:Tconstexprint):Tconstexprint;

begin
  result.overflow:=false;
  result.signed:=a.signed or b.signed;
  result.vlo:=a.vlo xor b.vlo;
  if a.representable64 and b.representable64 then
    signfill64(result)
  else
    result.vhi:=a.vhi xor b.vhi;
end;

operator shl (const a,b:Tconstexprint):Tconstexprint;

begin
  if a.representable64 then
    begin
      { historical semantics: 64 bit window }
      if (b.vhi<>0) or (b.vlo>=64) then
        exit(0);
      result.overflow:=false;
      result.signed:=a.signed; { signed(1) shl 63 does not fit into signed }
      result.vlo:=a.vlo shl b.vlo;
      signfill64(result);
    end
  else
    result:=shl128(a,b);
end;

operator shr (const a,b:Tconstexprint):Tconstexprint;

begin
  if a.representable64 then
    begin
      if (b.vhi<>0) or (b.vlo>=64) then
        exit(0);
      result.overflow:=false;
      result.signed:=a.signed;
      result.vlo:=a.vlo shr b.vlo;
      signfill64(result);
    end
  else
    result:=shr128(a,b);
end;

function shl128(const a,b:Tconstexprint):Tconstexprint;

begin
  if (b.vhi<>0) or (b.vlo>=128) then
    exit(0);
  result.overflow:=false;
  result.signed:=a.signed; { signed(1) shl 127 does not fit into signed }
  if b.vlo>=64 then
    begin
      result.vhi:=a.vlo shl (b.vlo-64);
      result.vlo:=0;
    end
  else if b.vlo=0 then
    begin
      result.vlo:=a.vlo;
      result.vhi:=a.vhi;
    end
  else
    begin
      result.vhi:=(a.vhi shl b.vlo) or (a.vlo shr (64-b.vlo));
      result.vlo:=a.vlo shl b.vlo;
    end;
end;

function shr128(const a,b:Tconstexprint):Tconstexprint;

begin
  if (b.vhi<>0) or (b.vlo>=128) then
    exit(0);
  result.overflow:=false;
  result.signed:=a.signed;
  if b.vlo>=64 then
    begin
      result.vlo:=a.vhi shr (b.vlo-64);
      result.vhi:=0;
    end
  else if b.vlo=0 then
    begin
      result.vlo:=a.vlo;
      result.vhi:=a.vhi;
    end
  else
    begin
      result.vlo:=(a.vlo shr b.vlo) or (a.vhi shl (64-b.vlo));
      result.vhi:=a.vhi shr b.vlo;
    end;
end;
{$pop}

function str_to_tconstexprint(const s:shortstring;out error:boolean):Tconstexprint;
var
  i:longint;
  base,digit:integer;
  c:char;
  neg:boolean;
begin
  result:=0;
  error:=true;
  i:=1;
  neg:=false;
  if length(s)=0 then
    exit;
  case s[1] of
    '-':
      begin
        neg:=true;
        inc(i);
      end;
    '+':
      inc(i);
    else
      ;
  end;
  base:=10;
  if (i<=length(s)) then
    case s[i] of
      '$':
        begin
          base:=16;
          inc(i);
        end;
      '&':
        begin
          base:=8;
          inc(i);
        end;
      '%':
        begin
          base:=2;
          inc(i);
        end;
      else
        ;
    end;
  if i>length(s) then
    exit;
  while i<=length(s) do
    begin
      c:=s[i];
      case c of
        '0'..'9':
          digit:=ord(c)-ord('0');
        'a'..'f':
          digit:=ord(c)-ord('a')+10;
        'A'..'F':
          digit:=ord(c)-ord('A')+10;
        else
          exit;
      end;
      if digit>=base then
        exit;
      result:=result*int64(base)+int64(digit);
      if result.overflow then
        exit;
      inc(i);
    end;
  if neg then
    begin
      result:=-result;
      if result.overflow then
        exit;
    end;
  error:=false;
end;

function tostr(const i:Tconstexprint):shortstring;overload;
var
  mlo,mhi,qlo,qhi,remlo,remhi:qword;
  digits:shortstring;
  neg:boolean;
begin
  if i.representable64 then
    begin
      if i.signed then
        str(i.svalue,result)
      else
        str(i.uvalue,result);
    end
  else
    begin
      neg:=i.extract_sign_abs(mlo,mhi);
      digits:='';
      while mhi<>0 do
        begin
          divmodu128(mlo,mhi,10,0,qlo,qhi,remlo,remhi);
          digits:=chr(ord('0')+longint(remlo))+digits;
          mlo:=qlo;
          mhi:=qhi;
        end;
      str(mlo,result);
      result:=result+digits;
      if neg then
        result:='-'+result;
    end;
end;

end.
