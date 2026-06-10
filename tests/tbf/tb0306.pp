{ %FAIL }

// a record field type that fails to parse (function without a result type)
// must report the syntax error without tripping internalerror 200601232 in
// the record symtable cleanup

program tb0306;

{$mode objfpc}{$H+}

type
  TImport = record
    f: function;
  end;

begin
end.
