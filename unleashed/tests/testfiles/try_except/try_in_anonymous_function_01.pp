program try_in_anonymous_function_01;

{$mode unleashed}

uses SysUtils;

type
  TIntFn = reference to function(s: String): Integer;

begin
  var safe_parse: TIntFn := function(s: String): Integer
                            begin
                              try
                                Result := StrToInt(s);
                              except
                                on E: Exception do
                                  Result := -1;
                              end;
                            end;
  if safe_parse('42')  <> 42 then halt(1);
  if safe_parse('xyz') <> -1 then halt(2);
end.
