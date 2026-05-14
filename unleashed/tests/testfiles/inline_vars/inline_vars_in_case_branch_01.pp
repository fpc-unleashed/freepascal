program inline_vars_in_case_branch_01;

{$mode unleashed}

uses SysUtils;

function Render(n: Integer): String;
begin
  case n of
    0..9:
      begin
        var prefix := '0';
        Result := prefix + IntToStr(n);
      end;
    10..99:
      begin
        var width := 2;
        Result := IntToStr(n);
        if Length(Result) <> width then halt(99);
      end;
  else
    begin
      var marker := 'big-';
      Result := marker + IntToStr(n);
    end;
  end;
end;

begin
  if Render(7)   <> '07'    then halt(1);
  if Render(42)  <> '42'    then halt(2);
  if Render(123) <> 'big-123' then halt(3);
end.
