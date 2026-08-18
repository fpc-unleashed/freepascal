{ %FAIL }

{ a generic constraint that is not a class or interface type must be
  rejected without an internal error when the generic is specialized }

program tw41851;

{$mode objfpc}

type
  generic tfoo<T: longint> = class
  end;

  trec = record
  end;

var
  f: specialize tfoo<trec>;
begin
  f := specialize tfoo<trec>.Create;
end.
