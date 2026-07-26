program SwapValues_property_string_20;
{$mode unleashed}
// managed type through accessors: the hidden temporary must not leak a
// reference or drop one; after the swap each string has one owner again
type
  TBag = class
  public
    FS: string;
    function GetS: string;
    procedure SetS(const v: string);
    property S: string read GetS write SetS;
  end;

function TBag.GetS: string; begin Result := FS; end;
procedure TBag.SetS(const v: string); begin FS := v; end;

function NumStr(v: Integer): string;
begin
  Str(v, Result);
end;

var
  bag: TBag;
  plain: string;

procedure DoSwap;
begin
  SwapValues(bag.S, plain);
end;

begin
  bag := TBag.Create;
  bag.FS := 'alpha' + NumStr(1);
  plain := 'beta' + NumStr(2);
  DoSwap;
  // the swap temp lives inside DoSwap and is finalized on its exit
  if StringRefCount(bag.FS) <> 1 then halt(1);
  if StringRefCount(plain) <> 1 then halt(2);
  if bag.FS <> 'beta2' then halt(3);
  if plain <> 'alpha1' then halt(4);
  bag.Free;
end.
