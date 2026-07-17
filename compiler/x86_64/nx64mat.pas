{
    Copyright (c) 1998-2002 by Florian Klaempfl

    Generate x86-64 assembler for math nodes

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
unit nx64mat;

{$i fpcdefs.inc}

interface

    uses
      node,nmat,nx86mat;

    type
      tx8664shlshrnode = class(tx86shlshrnode)
         function use_generic_int128ops: boolean; override;
         procedure pass_generate_code;override;
      end;

      tx8664unaryminusnode = class(tx86unaryminusnode)
         function use_generic_int128ops: boolean; override;
         procedure pass_generate_code;override;
      end;

      tx8664notnode = class(tx86notnode)
         function use_generic_int128ops: boolean; override;
         procedure pass_generate_code;override;
      end;

implementation

    uses
      globtype,globals,constexp,
      cutils,
      aasmbase,aasmdata,aasmcpu,
      pass_2,
      ncon,
      cpubase,
      cgbase,cgutils,cgobj,hlcgobj,cgx86,
      defutil;


{*****************************************************************************
                             TX8664SHLRSHRNODE
*****************************************************************************}


    function tx8664shlshrnode.use_generic_int128ops: boolean;
      begin
        result:=false;
      end;


    procedure tx8664shlshrnode.pass_generate_code;
      var
        op : topcg;
        opsize : tcgsize;
        mask : aint;
        shiftval : longint;
      begin
        if is_128bit(left.resultdef) then
          begin
            secondpass(left);
            secondpass(right);

            if nodetype=shln then
              op:=OP_SHL
            else
              op:=OP_SHR;

            { load the value into the result pair, shift in place }
            opsize:=def_cgsize(resultdef);
            location_reset(location,LOC_REGISTER,opsize);
            location.register128.reglo:=cg.getintregister(current_asmdata.CurrAsmList,OS_64);
            location.register128.reghi:=cg.getintregister(current_asmdata.CurrAsmList,OS_64);
            cg128.a_load128_loc_reg(current_asmdata.CurrAsmList,left.location,location.register128);

            if right.nodetype=ordconstn then
              begin
                shiftval:=longint(tordconstnode(right).value.svalue and 127);
                if shiftval<>0 then
                  begin
                    if shiftval>=64 then
                      begin
                        { the low half moves into the high half or back }
                        if op=OP_SHL then
                          begin
                            cg.a_load_reg_reg(current_asmdata.CurrAsmList,OS_64,OS_64,location.register128.reglo,location.register128.reghi);
                            if shiftval>64 then
                              current_asmdata.CurrAsmList.concat(taicpu.op_const_reg(A_SHL,S_Q,shiftval-64,location.register128.reghi));
                            current_asmdata.CurrAsmList.concat(taicpu.op_reg_reg(A_XOR,S_Q,location.register128.reglo,location.register128.reglo));
                          end
                        else
                          begin
                            cg.a_load_reg_reg(current_asmdata.CurrAsmList,OS_64,OS_64,location.register128.reghi,location.register128.reglo);
                            if shiftval>64 then
                              current_asmdata.CurrAsmList.concat(taicpu.op_const_reg(A_SHR,S_Q,shiftval-64,location.register128.reglo));
                            current_asmdata.CurrAsmList.concat(taicpu.op_reg_reg(A_XOR,S_Q,location.register128.reghi,location.register128.reghi));
                          end;
                      end
                    else
                      begin
                        if op=OP_SHL then
                          begin
                            current_asmdata.CurrAsmList.concat(taicpu.op_const_reg_reg(A_SHLD,S_Q,shiftval,location.register128.reglo,location.register128.reghi));
                            current_asmdata.CurrAsmList.concat(taicpu.op_const_reg(A_SHL,S_Q,shiftval,location.register128.reglo));
                          end
                        else
                          begin
                            current_asmdata.CurrAsmList.concat(taicpu.op_const_reg_reg(A_SHRD,S_Q,shiftval,location.register128.reghi,location.register128.reglo));
                            current_asmdata.CurrAsmList.concat(taicpu.op_const_reg(A_SHR,S_Q,shiftval,location.register128.reghi));
                          end;
                      end;
                  end;
              end
            else
              begin
                { variable count in a 64 bit register }
                if not(right.location.loc in [LOC_CREGISTER,LOC_REGISTER]) then
                  hlcg.location_force_reg(current_asmdata.CurrAsmList,right.location,right.resultdef,right.resultdef,true);
                cg128.a_op128_reg_reg(current_asmdata.CurrAsmList,op,opsize,
                  joinreg128(right.location.register,right.location.register),location.register128);
              end;
            exit;
          end;

        secondpass(left);
        secondpass(right);

        { determine operator }
        if nodetype=shln then
          op:=OP_SHL
        else
          op:=OP_SHR;

        opsize:=def_cgsize(resultdef);
        mask:=max(resultdef.size,4)*8-1;

        { load left operators in a register }
        if not(left.location.loc in [LOC_CREGISTER,LOC_REGISTER]) or
          { location_force_reg can be also used to change the size of a register }
          (left.location.size<>opsize) then
          hlcg.location_force_reg(current_asmdata.CurrAsmList,left.location,left.resultdef,cgsize_orddef(opsize),true);
        location_reset(location,LOC_REGISTER,opsize);
        location.register:=cg.getintregister(current_asmdata.CurrAsmList,opsize);

        { shifting by a constant directly coded: }
        if (right.nodetype=ordconstn) then
          cg.a_op_const_reg_reg(current_asmdata.CurrAsmList,op,location.size,
            tordconstnode(right).value.uvalue and mask,left.location.register,location.register)
        else
          begin
            { load right operators in a register - this
              is done since most target cpu which will use this
              node do not support a shift count in a mem. location (cec)
            }
            if not(right.location.loc in [LOC_CREGISTER,LOC_REGISTER]) or
               { location_force_reg can be also used to change the size of a register }
              (right.location.size<>opsize) then
              hlcg.location_force_reg(current_asmdata.CurrAsmList,right.location,right.resultdef,cgsize_orddef(opsize),true);

            cg.a_op_reg_reg_reg(current_asmdata.CurrAsmList,op,opsize,right.location.register,left.location.register,location.register);
          end;
      end;


{*****************************************************************************
                           TX8664UNARYMINUSNODE
*****************************************************************************}


    function tx8664unaryminusnode.use_generic_int128ops: boolean;
      begin
        { overflow-checked negation keeps the RTL helper }
        result:=cs_check_overflow in current_settings.localswitches;
      end;


    procedure tx8664unaryminusnode.pass_generate_code;
      begin
        if is_128bit(left.resultdef) then
          begin
            secondpass(left);
            if not(left.location.loc in [LOC_REGISTER,LOC_CREGISTER]) then
              hlcg.location_force_reg(current_asmdata.CurrAsmList,left.location,left.resultdef,resultdef,true);
            location_reset(location,LOC_REGISTER,def_cgsize(resultdef));
            location.register128.reglo:=cg.getintregister(current_asmdata.CurrAsmList,OS_64);
            location.register128.reghi:=cg.getintregister(current_asmdata.CurrAsmList,OS_64);
            cg128.a_op128_reg_reg(current_asmdata.CurrAsmList,OP_NEG,location.size,
              left.location.register128,location.register128);
            exit;
          end;
        inherited pass_generate_code;
      end;


{*****************************************************************************
                              TX8664NOTNODE
*****************************************************************************}


    function tx8664notnode.use_generic_int128ops: boolean;
      begin
        result:=false;
      end;


    procedure tx8664notnode.pass_generate_code;
      begin
        if is_128bit(left.resultdef) then
          begin
            secondpass(left);
            if not(left.location.loc in [LOC_REGISTER,LOC_CREGISTER]) then
              hlcg.location_force_reg(current_asmdata.CurrAsmList,left.location,left.resultdef,left.resultdef,true);
            location_reset(location,LOC_REGISTER,left.location.size);
            location.register128.reglo:=cg.getintregister(current_asmdata.CurrAsmList,OS_64);
            location.register128.reghi:=cg.getintregister(current_asmdata.CurrAsmList,OS_64);
            cg128.a_op128_reg_reg(current_asmdata.CurrAsmList,OP_NOT,location.size,
              left.location.register128,location.register128);
            exit;
          end;
        inherited pass_generate_code;
      end;


begin
   cunaryminusnode:=tx8664unaryminusnode;
   cmoddivnode:=tx86moddivnode;
   cshlshrnode:=tx8664shlshrnode;
   cnotnode:=tx8664notnode;
end.
