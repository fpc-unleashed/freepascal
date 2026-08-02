program class_var_variant_after_method_01;
{$mode unleashed}

// a variant part after a method must be instance layout even when a
// `class var` section came before the method

type
  TValue = type cardinal;

  TBar = record
    class var Hook: function(v: TValue): longint;
    function ToText: string;
    case cardinal of
      0: (Value: TValue);
      1: (B, G, R, A: byte);
  end;

function TBar.ToText: string;
begin
  Result := hexstr(Value, 8);
end;

var
  b: TBar;
  v: TValue;
  size: longint;
begin
  size := SizeOf(TBar);
  if size <> 4 then
    halt(1);
  v := $11223344;
  b := TBar(v);
  if b.Value <> $11223344 then
    halt(2);
  if (b.A <> $11) or (b.R <> $22) or (b.G <> $33) or (b.B <> $44) then
    halt(3);
  if b.ToText <> '11223344' then
    halt(4);
end.
