{
    Scalar replacement of aggregates (SRA)

    Copyright (c) 2026

    Splits a local record variable whose address never escapes into independent
    scalar temporaries, one per field, and rewrites every  rec.field  access to
    the corresponding temporary.  The fields then live in registers and feed the
    existing data-flow passes (constant propagation, DFA, dead-store elimination)
    instead of round-tripping through the stack frame.  Ported in spirit from
    gcc's -ftree-sra.

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
unit optsra;

{$i fpcdefs.inc}

  interface

    uses
      node,symdef;

    { Scalar-replace non-escaping local record aggregates in the routine body
      whose locals live in procdef.localst.  Returns true if any record was
      transformed. }
    function OptimizeSRA(var node : tnode; procdef : tprocdef) : boolean;

  implementation

    uses
      globtype,cutils,
      symconst,symtype,symsym,symtable,defutil,
      nbas,nld,nmem,ncal,nutils,pass_1;

    { unique-name counter so synthesized temp names never collide }
    var
      sra_seq : longint;

    type
      tfieldsymarray = array of tfieldvarsym;

      { one SRA candidate: a local record variable and the per-field temps
        that will replace its field accesses }
      tsracand = record
        recsym     : tlocalvarsym;
        recdef     : trecorddef;
        fieldsyms  : array of tfieldvarsym;
        fieldtemps : array of tlocalvarsym;
        disq       : boolean;   { escape analysis disqualified it }
        accesses   : longint;   { number of rewritten field accesses }
      end;
      psracand = ^tsracand;

    { ----- structural (type-level) gating -------------------------------- }

    { a field type we are willing to hold in a scalar temporary: an unmanaged
      register-sized ordinal / enum / float / pointer.  Record- and array-typed
      fields, managed fields and oversized fields cause the whole record to be
      declined (conservative v1 subset). }
    function simple_scalar_field(def : tdef) : boolean;
      begin
        result:=false;
        if not assigned(def) then
          exit;
        if is_managed_type(def) then
          exit;
        if not (def.typ in [orddef,enumdef,floatdef,pointerdef]) then
          exit;
        if not (def.size in [1,2,4,8]) then
          exit;
        result:=true;
      end;

    { collect the plain data fields of rd and verify the record is a flat,
      non-overlapping aggregate of simple scalar fields (declines unions,
      variant/case parts, absolute overlays and packed/bitpacked records). }
    function record_is_candidate(rd : trecorddef; out fsyms : tfieldsymarray) : boolean;
      var
        i,j,n : longint;
        sym   : tsym;
        fv    : tfieldvarsym;
        o1,o2 : asizeint;
      begin
        result:=false;
        SetLength(fsyms,0);
        if not assigned(rd) or not assigned(rd.symtable) then
          exit;
        if rd.isunion then
          exit;
        if assigned(rd.variantrecdesc) then
          exit;
        { packed / bitpacked records: field offsets may be sub-byte -> decline }
        if rd.is_packed then
          exit;
        n:=0;
        for i:=0 to rd.symtable.symlist.count-1 do
          begin
            sym:=tsym(rd.symtable.symlist[i]);
            if sym.typ<>fieldvarsym then
              continue;
            fv:=tfieldvarsym(sym);
            { external / class-var / static field -> decline (not an instance field) }
            if (sp_static in fv.symoptions) or (vo_is_external in fv.varoptions) then
              exit;
            if not simple_scalar_field(fv.vardef) then
              exit;
            SetLength(fsyms,n+1);
            fsyms[n]:=fv;
            inc(n);
          end;
        if n=0 then
          exit;
        { reject any overlapping field ranges (variant/case parts or absolute
          overlays share storage) }
        for i:=0 to n-1 do
          for j:=i+1 to n-1 do
            begin
              o1:=fsyms[i].fieldoffset;
              o2:=fsyms[j].fieldoffset;
              if o1<=o2 then
                begin
                  if o1+asizeint(fsyms[i].vardef.size)>o2 then
                    exit;
                end
              else
                begin
                  if o2+asizeint(fsyms[j].vardef.size)>o1 then
                    exit;
                end;
            end;
        result:=true;
      end;

    { ----- escape analysis ----------------------------------------------- }

    type
      pescaninfo = ^tescaninfo;
      tescaninfo = record
        cand       : tsym;
        allloads   : longint;   { every loadn of cand }
        fieldloads : longint;   { loadn of cand that is the direct base of a
                                  field subscript }
        disq       : boolean;
      end;

    { true if the subtree n contains any direct load of the symbol in arg }
    function node_refs_sym(var n : tnode; arg : pointer) : foreachnoderesult;
      begin
        result:=fen_false;
        if (n.nodetype=loadn) and (tloadnode(n).symtableentry=tsym(arg)) then
          result:=fen_norecurse_true;
      end;

    function subtree_references(n : tnode; sym : tsym) : boolean;
      begin
        subtree_references:=false;
        if assigned(n) then
          subtree_references:=foreachnodestatic(n,@node_refs_sym,sym);
      end;

    function escancb(var n : tnode; arg : pointer) : foreachnoderesult;
      var
        info : pescaninfo;
      begin
        result:=fen_true;
        info:=pescaninfo(arg);
        case n.nodetype of
          loadn:
            if tloadnode(n).symtableentry=info^.cand then
              inc(info^.allloads);
          subscriptn:
            if (tsubscriptnode(n).left.nodetype=loadn) and
               (tloadnode(tsubscriptnode(n).left).symtableentry=info^.cand) then
              inc(info^.fieldloads);
          addrn:
            { @rec or @rec.field: the record's storage escapes }
            if subtree_references(taddrnode(n).left,info^.cand) then
              info^.disq:=true;
          callparan:
            { by-reference argument (var/out/constref) aliases the field's
              storage in the callee -> decline }
            if assigned(tcallparanode(n).parasym) and
               (tcallparanode(n).parasym.varspez in [vs_var,vs_out,vs_constref]) and
               subtree_references(tcallparanode(n).left,info^.cand) then
              info^.disq:=true;
          else
            ;
        end;
      end;

    { returns true if cand survives escape analysis and has at least one field
      access.  A record survives only when EVERY load of it is the direct base
      of a field subscript (so whole-record assignment, whole-record value/var
      parameter passing, function-result stores, typecasts, method-self escapes,
      with-statements and Default()/FillChar all disqualify it), no address is
      taken of it or any field, and no field is passed by reference. }
    function candidate_survives(body : tnode; cand : tsym; out naccess : longint) : boolean;
      var
        info : tescaninfo;
      begin
        info.cand:=cand;
        info.allloads:=0;
        info.fieldloads:=0;
        info.disq:=false;
        foreachnodestatic(body,@escancb,@info);
        naccess:=info.fieldloads;
        candidate_survives:=(not info.disq) and
                            (info.fieldloads>0) and
                            (info.allloads=info.fieldloads);
      end;

    { ----- rewrite ------------------------------------------------------- }

    function rewritecb(var n : tnode; arg : pointer) : foreachnoderesult;
      var
        c    : psracand;
        i    : longint;
        nl   : tnode;
        base : tnode;
      begin
        result:=fen_true;
        if n.nodetype<>subscriptn then
          exit;
        base:=tsubscriptnode(n).left;
        c:=psracand(arg);
        if (base.nodetype<>loadn) or
           (tloadnode(base).symtableentry<>c^.recsym) then
          exit;
        for i:=0 to high(c^.fieldsyms) do
          if c^.fieldsyms[i]=tsubscriptnode(n).vs then
            begin
              nl:=cloadnode.create(c^.fieldtemps[i],c^.fieldtemps[i].owner);
              { carry the assignment-target / read-modify-write markers of the
                subscript we are replacing onto the fresh load so DFA still sees
                a definition here (otherwise an lvalue field access looks like a
                pure read and the temp scans as uninitialized) }
              if nf_write in n.flags then
                include(nl.flags,nf_write);
              if nf_modify in n.flags then
                include(nl.flags,nf_modify);
              { the surrounding tree is already typechecked/firstpassed, so the
                fresh load must be brought to the same state or codegen crashes
                on a nil resultdef (cf. the REASSOC substitution gotcha) }
              typecheckpass(nl);
              firstpass(nl);
              n.free;
              n:=nl;
              result:=fen_norecurse_true;
              exit;
            end;
      end;

    { ----- driver -------------------------------------------------------- }

    function OptimizeSRA(var node : tnode; procdef : tprocdef) : boolean;
      var
        i,j        : longint;
        sym        : tsym;
        lvs        : tlocalvarsym;
        fsyms      : tfieldsymarray;
        cand       : tsracand;
        naccess    : longint;
        tname      : string;
      begin
        OptimizeSRA:=false;
        if not assigned(procdef) or not assigned(procdef.localst) then
          exit;
        { iterate a snapshot count: we only append new temps, and a temp is a
          localvarsym whose vardef is never a candidate recorddef, so the added
          entries are skipped by the type test below anyway }
        i:=0;
        while i<procdef.localst.symlist.count do
          begin
            sym:=tsym(procdef.localst.symlist[i]);
            inc(i);
            if sym.typ<>localvarsym then
              continue;
            lvs:=tlocalvarsym(sym);
            if not assigned(lvs.vardef) or (lvs.vardef.typ<>recorddef) then
              continue;
            { synthesized SRA temps are scalars, never records, so they cannot
              re-enter here; still guard against internal aggregates }
            if (vo_is_funcret in lvs.varoptions) or
               (vo_is_external in lvs.varoptions) then
              continue;
            if not record_is_candidate(trecorddef(lvs.vardef),fsyms) then
              continue;
            if not candidate_survives(node,sym,naccess) then
              continue;

            { build the per-field scalar temporaries }
            cand.recsym:=lvs;
            cand.recdef:=trecorddef(lvs.vardef);
            cand.disq:=false;
            cand.accesses:=0;
            SetLength(cand.fieldsyms,length(fsyms));
            SetLength(cand.fieldtemps,length(fsyms));
            for j:=0 to high(fsyms) do
              begin
                cand.fieldsyms[j]:=fsyms[j];
                inc(sra_seq);
                tname:='$sra$'+tostr(sra_seq)+'$'+lvs.realname+'$'+fsyms[j].realname;
                cand.fieldtemps[j]:=clocalvarsym.create(tname,vs_value,fsyms[j].vardef,[]);
                cand.fieldtemps[j].register_sym;
                procdef.localst.insertsym(cand.fieldtemps[j]);
              end;

            { rewrite every rec.field access to its temp }
            foreachnodestatic(node,@rewritecb,@cand);

            OptimizeSRA:=true;
          end;
      end;

end.
