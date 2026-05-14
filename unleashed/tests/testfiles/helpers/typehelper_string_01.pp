program typehelper_string_01;

{$mode unleashed}
{$modeswitch typehelpers}

uses SysUtils;

type
  TStringHelper = type helper for String
    function Twice: String;
  end;

function TStringHelper.Twice: String;
begin
  Result := Self + Self;
end;

begin
  var s := 'ab';
  if s.Twice <> 'abab' then halt(1);

  var t: String := 'x';
  if t.Twice <> 'xx' then halt(2);
end.
