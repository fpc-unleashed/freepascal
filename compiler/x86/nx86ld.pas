{
    Copyright (c) 1998-2002,2015 by Florian Klaempfl

    Generate x86 assembler for in load nodes

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
unit nx86ld;

{$i fpcdefs.inc}

interface
    uses
      globtype,
      symtype,symsym,
      node,nld,ncgld;

    type
      tx86loadnode = class(tcgloadnode)
       protected
         procedure generate_win_relocate_inline(gvs: tstaticvarsym);
         procedure generate_threadvar_access(gvs: tstaticvarsym); override;
      end;

implementation

    uses
      globals,
      cutils,verbose,systems,
      fmodule,
      aasmbase,aasmtai,aasmdata,aasmcpu,
      cgutils,cgobj,hlcgobj,
      symconst,symdef,symtable,
      cgbase,cpubase,parabase,paramgr,
      procinfo;

{*****************************************************************************
                           TX86LOADNODE
*****************************************************************************}

    { Windows relocate model: the running thread's threadvar block pointer sits
      in the TEB TLS slot array (gs:[$1480] on x64, fs:[$0E10] on x86) indexed by
      the process-wide TLS key. Inline the fast path of FPC_THREADVAR_RELOCATE -
      read that pointer and add the variable's offset - and fall back to the
      helper only when the block is not allocated for this thread yet (or the key
      is in the expansion area). A nil relocate handler means single threaded, so
      the static address is used. }
    procedure tx86loadnode.generate_win_relocate_inline(gvs: tstaticvarsym);
      var
        pvd,fieldptrdef : tdef;
        tv_rec : trecorddef;
        tv_index_field,tv_non_mt_data_field : tsym;
        href,tvref : treference;
        relocreg,idxreg,blockreg,resultreg : tregister;
        norelocatelab,slowlab,donelab : tasmlabel;
        paraloc1,respara : tcgpara;
        tmpresloc : tlocation;
        indirect,issystemunit : boolean;
      begin
        tv_rec:=get_threadvar_record(resultdef,tv_index_field,tv_non_mt_data_field);
        fieldptrdef:=cpointerdef.getreusable(resultdef);
        current_asmdata.getjumplabel(norelocatelab);
        current_asmdata.getjumplabel(slowlab);
        current_asmdata.getjumplabel(donelab);
        pvd:=search_system_type('TRELOCATETHREADVARHANDLER').typedef;
        if pvd.typ<>procvardef then
          internalerror(2026060801);
        issystemunit:=(
                        assigned(current_module.globalsymtable) and
                        (current_module.globalsymtable=systemunit)
                      ) or
                      (
                        not assigned(current_module.globalsymtable) and
                        (current_module.localsymtable=systemunit)
                      );
        indirect:=(tf_supports_packages in target_info.flags) and
                    (target_info.system in systems_indirect_var_imports) and
                    (cs_imported_data in localswitches) and
                    not issystemunit;
        if not(vo_is_weak_external in gvs.varoptions) then
          reference_reset_symbol(tvref,current_asmdata.RefAsmSymbol(gvs.mangledname,AT_DATA,use_indirect_symbol(gvs)),0,sizeof(pint),[])
        else
          reference_reset_symbol(tvref,current_asmdata.WeakRefAsmSymbol(gvs.mangledname,AT_DATA),0,sizeof(pint),[]);

        resultreg:=cg.getaddressregister(current_asmdata.CurrAsmList);

        { relocate handler nil -> single threaded, use the static address }
        relocreg:=cg.getaddressregister(current_asmdata.CurrAsmList);
        reference_reset_symbol(href,current_asmdata.RefAsmSymbol('FPC_THREADVAR_RELOCATE',AT_DATA,indirect),0,sizeof(pint),[]);
        if not issystemunit then
          current_module.add_extern_asmsym('FPC_THREADVAR_RELOCATE',AB_EXTERNAL,AT_DATA);
        cg.a_load_ref_reg(current_asmdata.CurrAsmList,OS_ADDR,OS_ADDR,href,relocreg);
        cg.a_cmp_const_reg_label(current_asmdata.CurrAsmList,OS_ADDR,OC_EQ,0,relocreg,norelocatelab);

        { idxreg := TLSKey^ (process-wide TLS slot index) }
        idxreg:=cg.getaddressregister(current_asmdata.CurrAsmList);
        reference_reset_symbol(href,current_asmdata.RefAsmSymbol('_FPC_TlsKey',AT_DATA,false),0,sizeof(pint),[]);
        cg.a_load_ref_reg(current_asmdata.CurrAsmList,OS_ADDR,OS_ADDR,href,idxreg);
        reference_reset_base(href,idxreg,0,ctempposinvalid,4,[]);
        cg.a_load_ref_reg(current_asmdata.CurrAsmList,OS_32,OS_INT,href,idxreg);
        { only the 64 static TEB slots are inlined; expansion slots go slow }
        cg.a_cmp_const_reg_label(current_asmdata.CurrAsmList,OS_INT,OC_AE,64,idxreg,slowlab);

        { blockreg := TEB.TlsSlots[idxreg] }
        blockreg:=cg.getaddressregister(current_asmdata.CurrAsmList);
        reference_reset(href,sizeof(pint),[]);
{$ifdef x86_64}
        href.segment:=NR_GS;
        href.offset:=$1480;
{$else x86_64}
        href.segment:=NR_FS;
        href.offset:=$0e10;
{$endif x86_64}
        href.index:=idxreg;
        href.scalefactor:=sizeof(pint);
        cg.a_load_ref_reg(current_asmdata.CurrAsmList,OS_ADDR,OS_ADDR,href,blockreg);
        { block not allocated for this thread yet -> let the helper allocate it }
        cg.a_cmp_const_reg_label(current_asmdata.CurrAsmList,OS_ADDR,OC_EQ,0,blockreg,slowlab);

        { resultreg := blockreg + threadvar index (offset within the block) }
        href:=tvref;
        hlcg.g_set_addr_nonbitpacked_field_ref(current_asmdata.CurrAsmList,tv_rec,tfieldvarsym(tv_index_field),href);
        cg.a_load_ref_reg(current_asmdata.CurrAsmList,OS_32,OS_INT,href,resultreg);
        cg.a_op_reg_reg(current_asmdata.CurrAsmList,OP_ADD,OS_ADDR,blockreg,resultreg);
        cg.a_jmp_always(current_asmdata.CurrAsmList,donelab);

        { slow path: call the relocate helper with the threadvar index }
        cg.a_label(current_asmdata.CurrAsmList,slowlab);
        paraloc1.init;
        paramanager.getcgtempparaloc(current_asmdata.CurrAsmList,tprocvardef(pvd),1,paraloc1);
        href:=tvref;
        hlcg.g_set_addr_nonbitpacked_field_ref(current_asmdata.CurrAsmList,tv_rec,tfieldvarsym(tv_index_field),href);
        hlcg.a_load_ref_cgpara(current_asmdata.CurrAsmList,tfieldvarsym(tv_index_field).vardef,href,paraloc1);
        paramanager.freecgpara(current_asmdata.CurrAsmList,paraloc1);
        cg.allocallcpuregisters(current_asmdata.CurrAsmList);
        respara:=hlcg.a_call_reg(current_asmdata.CurrAsmList,tprocvardef(pvd),relocreg,[@paraloc1]);
        paraloc1.done;
        cg.deallocallcpuregisters(current_asmdata.CurrAsmList);
        location_reset(tmpresloc,LOC_REGISTER,OS_ADDR);
        tmpresloc.register:=resultreg;
        hlcg.gen_load_cgpara_loc(current_asmdata.CurrAsmList,fieldptrdef,respara,tmpresloc,true);
        respara.resetiftemp;
        cg.a_jmp_always(current_asmdata.CurrAsmList,donelab);

        { single-threaded: the value sits sizeof(pint) past the index field }
        cg.a_label(current_asmdata.CurrAsmList,norelocatelab);
        href:=tvref;
        hlcg.g_set_addr_nonbitpacked_field_ref(current_asmdata.CurrAsmList,tv_rec,tfieldvarsym(tv_non_mt_data_field),href);
        hlcg.a_loadaddr_ref_reg(current_asmdata.CurrAsmList,resultdef,fieldptrdef,href,resultreg);

        cg.a_label(current_asmdata.CurrAsmList,donelab);
        hlcg.reference_reset_base(location.reference,fieldptrdef,resultreg,0,ctempposinvalid,resultdef.alignment,[]);
      end;


    procedure tx86loadnode.generate_threadvar_access(gvs: tstaticvarsym);
      var
        paraloc1 : tcgpara;
        pd: tprocdef;
        href: treference;
        hregister : tregister;
        handled: boolean;
      begin
        handled:=false;
        if (tf_section_threadvars in target_info.flags) then
          begin
            if target_info.system in [system_i386_win32,system_x86_64_win64] then
              begin
                paraloc1.init;
                pd:=search_system_proc('fpc_tls_add');
                paramanager.getcgtempparaloc(current_asmdata.CurrAsmList,pd,1,paraloc1);
                if not(vo_is_weak_external in gvs.varoptions) then
                  reference_reset_symbol(href,current_asmdata.RefAsmSymbol(gvs.mangledname,AT_DATA,use_indirect_symbol(gvs)),0,sizeof(pint),[])
                else
                  reference_reset_symbol(href,current_asmdata.WeakRefAsmSymbol(gvs.mangledname,AT_DATA),0,sizeof(pint),[]);
                cg.a_loadaddr_ref_cgpara(current_asmdata.CurrAsmList,href,paraloc1);
                paramanager.freecgpara(current_asmdata.CurrAsmList,paraloc1);
                paraloc1.done;

                cg.g_call(current_asmdata.CurrAsmList,'FPC_TLS_ADD');
                cg.ungetcpuregister(current_asmdata.CurrAsmList,NR_FUNCTION_RESULT_REG);
                hregister:=cg.getaddressregister(current_asmdata.CurrAsmList);
                cg.a_load_reg_reg(current_asmdata.CurrAsmList,OS_ADDR,OS_ADDR,NR_FUNCTION_RESULT_REG,hregister);
                location.reference.base:=hregister;
                handled:=true;
              end;
          end
        else
          { relocate model: inline the helper's fast path (read this thread's
            threadvar block from the TEB and add the variable offset), so the
            common multithreaded access avoids the per-access call }
          if target_info.system in [system_i386_win32,system_x86_64_win64] then
            begin
              generate_win_relocate_inline(gvs);
              handled:=true;
            end;

        if not handled then
          inherited;

        if (tf_section_threadvars in target_info.flags) then
          begin
{$ifdef i386}
            case target_info.system of
              system_i386_linux,system_i386_android:
                begin
                  case current_settings.tlsmodel of
                    tlsm_local_exec:
                      begin
                        location.reference.segment:=NR_GS;
                        location.reference.refaddr:=addr_ntpoff;
                      end;
                    tlsm_global_dynamic:
                      begin
                        include(current_procinfo.flags,pi_needs_got);
                        reference_reset(href,0,[]);
                        location.reference.index:=current_procinfo.got;
                        location.reference.scalefactor:=1;
                        location.reference.refaddr:=addr_tlsgd;
                        cg.getcpuregister(current_asmdata.CurrAsmList,NR_EAX);
                        current_asmdata.CurrAsmList.concat(taicpu.op_ref_reg(A_LEA,S_L,location.reference,NR_EAX));
                        cg.g_call(current_asmdata.CurrAsmList,'___tls_get_addr');
                        cg.ungetcpuregister(current_asmdata.CurrAsmList,NR_EAX);
                        hregister:=cg.getaddressregister(current_asmdata.CurrAsmList);
                        cg.a_load_reg_reg(current_asmdata.CurrAsmList,OS_ADDR,OS_ADDR,NR_EAX,hregister);
                        reference_reset(location.reference,location.reference.alignment,location.reference.volatility);
                        location.reference.base:=hregister;
                      end;
                    else
                      Internalerror(2018110401);
                  end;
                end;
              else
                ;
            end;
{$endif i386}
{$ifdef x86_64}
            case target_info.system of
              system_x86_64_linux:
                begin
                  case current_settings.tlsmodel of
                    tlsm_local_exec:
                      begin
                        location.reference.segment:=NR_FS;
                        location.reference.refaddr:=addr_tpoff;
                      end;
                    tlsm_global_dynamic:
                      begin
                        current_asmdata.CurrAsmList.concat(tai_const.Create_8bit($66));
                        reference_reset(href,0,[]);
                        location.reference.base:=NR_RIP;
                        location.reference.scalefactor:=1;
                        location.reference.refaddr:=addr_tlsgd;
                        cg.getcpuregister(current_asmdata.CurrAsmList,NR_RDI);
                        current_asmdata.CurrAsmList.concat(taicpu.op_ref_reg(A_LEA,S_Q,location.reference,NR_RDI));
                        current_asmdata.CurrAsmList.concat(tai_const.Create_8bit($66));
                        current_asmdata.CurrAsmList.concat(tai_const.Create_8bit($66));
                        current_asmdata.CurrAsmList.concat(tai_const.Create_8bit($48));
                        cg.g_call(current_asmdata.CurrAsmList,'__tls_get_addr');
                        cg.ungetcpuregister(current_asmdata.CurrAsmList,NR_RDI);
                        cg.ungetcpuregister(current_asmdata.CurrAsmList,NR_EAX);
                        hregister:=cg.getaddressregister(current_asmdata.CurrAsmList);
                        cg.a_load_reg_reg(current_asmdata.CurrAsmList,OS_ADDR,OS_ADDR,NR_RAX,hregister);
                        reference_reset(location.reference,location.reference.alignment,location.reference.volatility);
                        location.reference.base:=hregister;
                      end;
                    else
                      Internalerror(2019012002);
                  end;
                end;
              else
                ;
            end;
{$endif x86_64}
          end;
      end;


begin
   cloadnode:=tx86loadnode;
end.
