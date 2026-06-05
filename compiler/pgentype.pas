{
    Copyright (c) 2015 by Sven Barth

    Contains different types that are used in the context of parsing generics.

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
unit pgentype;

{$i fpcdefs.inc}

interface

uses
  cclasses,
  tokens,
  globtype,
  symtype,symbase,
  symconst;

const
  inline_specialization_block_types = [bt_type,bt_var_type,bt_const_type,bt_body,bt_except];

type
  pspecializationstate = ^tspecializationstate;
  tspecializationstate = record
    oldsymtablestack      : tsymtablestack;
    oldextendeddefs       : tfphashobjectlist;
    oldgenericdummysyms   : tfphashobjectlist;
    oldspecializestate    : pspecializationstate;
    oldcurrent_genericdef : tdef;
    oldoptoken            : ttoken;
  end;

  tspecializationcontext=class
  public
    paramlist : tfpobjectlist;
    poslist : tfplist;
    prettyname : ansistring;
    specializename : ansistring;
    genname : ansistring;
    sym : tsym;
    symtable : tsymtable;
    forwarddef : tdef;
    { WLG extensions - populated when lightweight generics are enabled }
    shapeclass : tshapeclass;           // Resolved shape-class for the specialization
    identity_hash : ansistring;         // Compile-time identity hash (e.g., "WLG_W_POD_4_STDCMP")
    is_wlg_specialization : boolean;    // True if using WLG pipeline vs legacy monomorphization
    wlg_veneer_source : tdef;           // Source specialization to copy VMT code addresses from (for veneer VMTs)
    constructor create;
    destructor destroy;override;
    function getcopy:tspecializationcontext;
  end;


implementation

constructor tspecializationcontext.create;
begin
  paramlist:=tfpobjectlist.create(false);
  poslist:=tfplist.create;
end;

destructor tspecializationcontext.destroy;
begin
  paramlist.free;
  paramlist := nil;
  tfplist.FreeAndNilDisposing(poslist,TypeInfo(tfileposinfo));
  inherited destroy;
end;

function tspecializationcontext.getcopy:tspecializationcontext;
var
  posinfo : pfileposinfo;
  i : longint;
begin
  result:=tspecializationcontext.create;
  result.paramlist.capacity:=paramlist.count;
  for i:=0 to paramlist.count-1 do
    begin
      result.paramlist.add(paramlist[i]);
    end;
  result.poslist.capacity:=poslist.count;
  for i:=0 to poslist.count-1 do
    begin
      new(posinfo);
      posinfo^:=pfileposinfo(poslist[i])^;
      result.poslist.add(posinfo);
    end;
  result.prettyname:=prettyname;
  result.specializename:=specializename;
  result.genname:=genname;
  result.sym:=sym;
  result.symtable:=symtable;
  result.forwarddef:=forwarddef;
  { Copy WLG extension fields }
  result.shapeclass:=shapeclass;
  result.identity_hash:=identity_hash;
  result.is_wlg_specialization:=is_wlg_specialization;
  result.wlg_veneer_source:=wlg_veneer_source;
end;

end.

