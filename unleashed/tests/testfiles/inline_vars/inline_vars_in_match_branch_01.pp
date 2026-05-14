program inline_vars_in_match_branch_01;

{$mode unleashed}

uses SysUtils;

function Render(n: Integer): String;
begin
  match
    n > 0:
      begin
        var sign := '+';
        Result := sign + IntToStr(n);
      end;
    n < 0:
      begin
        var sign := '-';
        Result := sign + IntToStr(-n);
      end;
    _:
      Result := 'zero';
  end;
end;

begin
  if Render(10)  <> '+10'  then halt(1);
  if Render(-5)  <> '-5'   then halt(2);
  if Render(0)   <> 'zero' then halt(3);
end.
