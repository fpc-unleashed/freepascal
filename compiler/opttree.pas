{
    General tree transformations

    Copyright (c) 2013 by Florian Klaempfl

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

{ $define DEBUG_NORMALIZE}

{ this unit implements routines to perform all-purpose tree transformations }
unit opttree;

{$i fpcdefs.inc}

  interface

    uses
      node;

    { tries to bring the tree in a normalized form:
       - expressions are free of control statements
       - callinitblock/callcleanupblocks are converted into statements

      rationale is that this simplifies data flow analysis

      returns true, if this was successful
    }
    function normalize(var n : tnode) : Boolean;

  implementation

    uses
      verbose,
      globtype,
      defutil,
      nbas,nld,ncal,
      nutils,
      pass_1;

    function searchstatements(var n : tnode;arg : pointer) : foreachnoderesult;forward;

    { normalization success flag, shared so that a nested statement context
      entered from searchblock can signal failure without threading a pointer
      through the tree walk }
    var
      normalizesuccessp : pboolean;

    function hasblock(var n : tnode;arg : pointer) : foreachnoderesult;
      begin
        result:=fen_false;
        if n.nodetype=blockn then
          result:=fen_norecurse_true;
      end;

    function searchblock(var n : tnode;arg : pointer) : foreachnoderesult;
      var
        hp,
        stmnt : tstatementnode;
        res : pnode;
      begin
        result:=fen_true;
        if n.nodetype in [addn,orn] then
          begin
            { so far we cannot fiddle with short boolean evaluations containing blocks }
            if doshortbooleval(n) and foreachnodestatic(n,@hasblock,nil) then
              begin
                result:=fen_norecurse_false;
                exit;
              end;
          end;
        case n.nodetype of
          statementn:
            begin
              { A nested statement list (e.g. the body of a loop or an if
                branch) reached while scanning the current statement's
                expression tree. Its block-expressions must NOT be hoisted out
                here: the insertion point of this scan is the enclosing
                statement, and moving loop-/branch-body code before the loop or
                if would be wrong. Stop the scan at this boundary; the nested
                statement list is normalized separately (see the second phase in
                searchstatements) with its own insertion point. }
              result:=fen_norecurse_true;
              exit;
            end;
          calln:
            begin
              if assigned(tcallnode(n).callinitblock) then
                begin
                  { create a new statement node and insert it }
                  hp:=cstatementnode.create(tcallnode(n).callinitblock,pnode(arg)^);
                  pnode(arg)^:=hp;
                  { tree moved }
                  tcallnode(n).callinitblock:=nil;
                  { process the newly generated block }
                  foreachnodestatic(pnode(arg)^,@searchstatements,nil);
                end;
              if assigned(tcallnode(n).callcleanupblock) then
                begin
                  { create a new statement node and append it }
                  hp:=cstatementnode.create(tcallnode(n).callcleanupblock,tstatementnode(pnode(arg)^).right);
                  tstatementnode(pnode(arg)^).right:=hp;
                  { tree moved }
                  tcallnode(n).callcleanupblock:=nil;
                  { process the newly generated block }
                  foreachnodestatic(tstatementnode(pnode(arg)^).right,@searchstatements,nil);
                end;
            end;
          blockn:
            begin
              if assigned(tblocknode(n).left) and (tblocknode(n).left.nodetype<>statementn) then
                internalerror(2013120502);

              stmnt:=tstatementnode(tblocknode(n).left);
              { search for the result of the block node }
              if assigned(stmnt) then
                begin
                  res:=nil;
                  hp:=tstatementnode(stmnt);
                  while assigned(hp) do
                    begin
                      if assigned(hp.left) then
                        res:=@hp.left;
                      hp:=tstatementnode(hp.right);
                    end;
                  { did we find a last node? }
                  if assigned(res^) then
                    begin
                      case res^.nodetype of
                        ordconstn,
                        realconstn,
                        stringconstn,
                        pointerconstn,
                        setconstn,
                        temprefn:
                          begin
                            { create a new statement node and insert it }
                            hp:=cstatementnode.create(n,pnode(arg)^);
                            pnode(arg)^:=hp;
                            { use the result node instead of the block node }
                            n:=res^;
                            { the old statement is not used anymore }
                            res^:=cnothingnode.create;
                            { process the newly generated statement }
                            foreachnodestatic(pnode(arg)^,@searchstatements,nil);
                          end
                        else if assigned(res^.resultdef) and not(is_void(res^.resultdef)) then
                          begin
                            { "move the whole block out of the expression": the
                              upstream code here builds a temp, assigns the block's
                              value node to it, replaces the *statement slot*
                              (pnode(arg)^) with a plain block node and absorbs the
                              rest of the statement chain into it.

                              That rewrite is structurally fragile -- the statement
                              slot no longer holds a statementn -- and for
                              block-expressions whose result is a managed value that
                              carries its own initialisation / cleanup (interface and
                              function-reference construction, some generic-intrinsic
                              results) the follow-up firstpass / re-normalisation
                              dereferences freed or mis-typed nodes and crashes the
                              compiler.

                              None of the constructs this pass actually needs to
                              normalise require it: statement expressions, inline
                              vars and match / if expressions all produce a temp-ref
                              or a constant as the block result and take the branch
                              above. So instead of performing the crashy transform,
                              declare the procedure "not normalizable". normalize()
                              then returns false and the dead-store pass is skipped
                              for it, leaving the block-expression exactly as it is
                              when the dead-store switch is off -- which is safe and
                              preserves its semantics. }
                            normalizesuccessp^:=false;
                          end;
                      end;
                    end;
                end;
            end;
          else
            ;
        end;
      end;

    var
      searchstatementsproc : staticforeachnodefunction;

    { second-phase walker: descend the current statement's (already hoisted)
      expression tree and normalize every nested statement list it contains
      (loop / if / case / try bodies, sub-blocks) as its own statement context.
      When a nested statement head is found it is fully processed here (including
      its siblings), so we stop the walk from descending into it again. }
    function searchnested(var n : tnode;arg : pointer) : foreachnoderesult;
      begin
        if n.nodetype=statementn then
          begin
            searchstatementsproc(n,nil);
            result:=fen_norecurse_false;
          end
        else
          result:=fen_false;
      end;

    function searchstatements(var n : tnode;arg : pointer) : foreachnoderesult;
      begin
        if n.nodetype=statementn then
          begin
            { phase 1: hoist block-expressions that live in this statement's own
              straight-line expression tree (searchblock stops at nested
              statement lists, so it never carries this insertion point across a
              control-flow boundary) }
            if not(foreachnodestatic(tstatementnode(n).left,@searchblock,@n)) then
              begin
                normalizesuccessp^:=false;
                result:=fen_norecurse_false;
                exit;
              end;
            result:=fen_norecurse_false;
            { searchblock may have replaced this statement slot with a plain
              block node (the "move the whole block out of the expression" case
              in searchblock, which absorbs the rest of the statement chain into
              the new block and already re-runs searchstatements over it). In
              that case n is no longer a statementn and its .right is not a
              sibling pointer -- reading it would walk garbage. The continuation
              has already been fully normalized, so there is nothing more to do
              here. }
            if n.nodetype<>statementn then
              exit;
            { phase 2: now that this statement's expression is stable, recurse
              into any nested statement lists it contains and normalize them with
              their own (correct) insertion point }
            foreachnodestatic(tstatementnode(n).left,@searchnested,nil);
            { do not recurse automatically, but continue with the next statement }
            foreachnodestatic(tstatementnode(n).right,searchstatementsproc,arg);
          end
        else
          result:=fen_false;
      end;


    function normalize(var n: tnode) : Boolean;
      var
        success : Boolean;
      begin
        success:=true;
        normalizesuccessp:=@success;
{$ifdef DEBUG_NORMALIZE}
        writeln('******************************************** Before ********************************************');
        printnode(output,n);
{$endif DEBUG_NORMALIZE}
        searchstatementsproc:=@searchstatements;
        foreachnodestatic(n,@searchstatements,@success);
{$ifdef DEBUG_NORMALIZE}
        if success then
          begin
            writeln('******************************************** After ********************************************');
            printnode(output,n);
          end
        else
          writeln('************************* Normalization not possible ********************************');
{$endif DEBUG_NORMALIZE}
        Result:=success;
      end;


end.

