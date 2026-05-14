program implicit_generics_two_params_01;

{$mode unleashed}
{$modeswitch implicitgenerics}

type
  TPair<A, B> = class
  private
    FA: A;
    FB: B;
  public
    constructor Create(va: A; vb: B);
    property First: A read FA;
    property Second: B read FB;
  end;

constructor TPair<A, B>.Create(va: A; vb: B);
begin
  FA := va;
  FB := vb;
end;

begin
  var p := autofree TPair<Integer, String>.Create(7, 'seven');
  if p.First  <> 7       then halt(1);
  if p.Second <> 'seven' then halt(2);

  var q := autofree TPair<String, Integer>.Create('answer', 42);
  if q.First  <> 'answer' then halt(3);
  if q.Second <> 42       then halt(4);
end.
