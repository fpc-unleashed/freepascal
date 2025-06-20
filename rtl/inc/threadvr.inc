{
    This file is part of the Free Pascal run time library.
    Copyright (c) 1999-2000 by Michael Van Canneyt
    member of the Free Pascal development team

    Threadvar support, platform independent part

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}


{*****************************************************************************
                           Threadvar support
*****************************************************************************}

{$ifndef FPC_SECTION_THREADVARS}
type
  pltvInitEntry = ^ltvInitEntry;
  ppltvInitEntry = ^pltvInitEntry;
  ltvInitEntry = {$ifndef FPC_ALIGNED_THREADVARTABLES}packed{$endif} record
     varaddr : {$ifdef cpu16}pword{$else}pdword{$endif};
     size    : longint;
  end;

  TltvInitTablesTable = {$ifndef FPC_ALIGNED_THREADVARTABLES}packed{$endif} record
    count  : dword;
    tables : {$ifndef FPC_ALIGNED_THREADVARTABLES}packed{$endif} array [1..{$ifdef cpu16}16{$else}32767{$endif}] of ppltvInitEntry;
  end;
  PltvInitTablesTable = ^TltvInitTablesTable;

{$ifndef FPC_HAS_INDIRECT_ENTRY_INFORMATION}
var
  ThreadvarTablesTable : TltvInitTablesTable; external name 'FPC_THREADVARTABLES';
{$endif FPC_HAS_INDIRECT_ENTRY_INFORMATION}

procedure init_unit_threadvars (tableEntry : pltvInitEntry);
begin
  while tableEntry^.varaddr <> nil do
   begin
     CurrentTM.InitThreadvar (tableEntry^.varaddr^, tableEntry^.size);
     inc (pansichar (tableEntry), sizeof (tableEntry^));
   end;
end;


procedure init_all_unit_threadvars;
var
  i : longint;
begin
{$ifdef FPC_HAS_INDIRECT_ENTRY_INFORMATION}
  with PltvInitTablesTable(EntryInformation.ThreadvarTablesTable)^ do
{$else FPC_HAS_INDIRECT_ENTRY_INFORMATION}
  with ThreadvarTablesTable do
{$endif FPC_HAS_INDIRECT_ENTRY_INFORMATION}
  begin
{$ifdef DEBUG_MT}
    WriteLn ('init_all_unit_threadvars (',count,') units');
{$endif}
    for i := 1 to count do
      init_unit_threadvars (tables[i]^);
  end;
end;


procedure copy_unit_threadvars (tableEntry : pltvInitEntry);
var
  oldp,
  newp : pointer;
begin
  while tableEntry^.varaddr <> nil do
   begin
     newp:=CurrentTM.RelocateThreadVar(tableEntry^.varaddr^);
     oldp:=pointer(pansichar(tableEntry^.varaddr)+sizeof(pointer));
     move(oldp^,newp^,tableEntry^.size);
     inc (pansichar (tableEntry), sizeof (tableEntry^));
   end;
end;


procedure copy_all_unit_threadvars;
var
  i: longint;
begin
{$ifdef FPC_HAS_INDIRECT_ENTRY_INFORMATION}
  with PltvInitTablesTable(EntryInformation.ThreadvarTablesTable)^ do
{$else FPC_HAS_INDIRECT_ENTRY_INFORMATION}
  with ThreadvarTablesTable do
{$endif FPC_HAS_INDIRECT_ENTRY_INFORMATION}
  begin
{$ifdef DEBUG_MT}
    WriteLn ('copy_all_unit_threadvars (',count,') units');
{$endif}
    for i := 1 to count do
      copy_unit_threadvars (tables[i]^);
  end;
end;
{$endif FPC_SECTION_THREADVARS}

procedure InitThreadVars(RelocProc : TRelocateThreadVarHandler);

begin
{$ifndef FPC_SECTION_THREADVARS}
   { initialize threadvars }
   init_all_unit_threadvars;
   { allocate mem for main thread threadvars }
   CurrentTM.AllocateThreadVars;
   { copy main thread threadvars }
   copy_all_unit_threadvars;
   { install threadvar handler }
   fpc_threadvar_relocate_proc:=RelocProc;
{$endif FPC_SECTION_THREADVARS}

{$if defined(FPC_HAS_FEATURE_HEAP) and not defined(HAS_MEMORYMANAGER)}
   RelocateHeap;
{$endif FPC_HAS_FEATURE_HEAP and not HAS_MEMORYMANAGER}
end;


