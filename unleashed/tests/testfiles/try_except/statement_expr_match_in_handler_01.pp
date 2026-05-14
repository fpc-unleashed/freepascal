program statement_expr_match_in_handler_01;

{$mode unleashed}

uses SysUtils;

function Classify(s: String): String;
begin
  try
    var n := StrToInt(s);
    Result := match
                n > 0:  'positive';
                n = 0:  'zero';
                _:      'negative';
              end;
  except
    on E: EConvertError do
      Result := match
                  Length(s) = 0: 'empty';
                  _:             'malformed';
                end;
  end;
end;

begin
  if Classify('42')  <> 'positive'  then halt(1);
  if Classify('0')   <> 'zero'      then halt(2);
  if Classify('-5')  <> 'negative'  then halt(3);
  if Classify('')    <> 'empty'     then halt(4);
  if Classify('xyz') <> 'malformed' then halt(5);
end.
