{ specializing the parent class only (without invoking the nested
  generic method) compiles; the spec inherits the method as a
  still-generic template }
program nested_generics_decl_only_02;
{$mode unleashed}

type
  TPair<A>=class
    procedure Combine<B>(const x: A; const y: B);
  end;

procedure TPair<A>.Combine<B>(const x: A; const y: B);
begin
end;

type
  TIntPair = TPair<Integer>;
  TStrPair = TPair<string>;

var
  ip: TIntPair;
  sp: TStrPair;
begin
  ip := TIntPair.Create;
  sp := TStrPair.Create;
  ip.Free;
  sp.Free;
end.
