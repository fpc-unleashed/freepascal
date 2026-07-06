{ %NORUN }
unit tuple_host_ref_unit_01;
// support unit for tuple_host_ref_cross_unit_01.pp: two records whose
// methods return host-referencing tuples, parsed again from the method
// implementation headers

{$mode unleashed}

interface

type
  TCrossA = record
    x: LongWord;
    function divMod: (q, r: TCrossA);
  end;

  TCrossB = record
    x: LongWord;
    y: boolean;
    function divMod: (s, t: TCrossB);
  end;

implementation

function TCrossA.divMod: (q, r: TCrossA);
begin
  Exit(self, self);
end;

function TCrossB.divMod: (s, t: TCrossB);
begin
  Exit(self, self);
end;

end.
