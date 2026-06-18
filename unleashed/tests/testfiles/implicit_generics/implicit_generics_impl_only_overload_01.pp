{ %NORUN }
{ a routine that is non-generic in the interface gains a same-named generic
  overload in the implementation; the interface dummy is marked generic after
  its derefs were built, so writing the unit ppu used to fire IE 2021010301 }
unit implicit_generics_impl_only_overload_01;

{$mode unleashed}

interface

function inArray(needle: Integer; const a: array of Integer; out idx: Integer): Boolean;

implementation

function inArray(needle: Integer; const a: array of Integer; out idx: Integer): Boolean;
begin
  idx := 0;
  result := false;
end;

function inArray<T>(needle: T; const a: array of T; out idx: Integer): Boolean;
begin
  idx := 0;
  result := false;
end;

end.
