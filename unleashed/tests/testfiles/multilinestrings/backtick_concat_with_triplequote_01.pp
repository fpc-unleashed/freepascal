program backtick_concat_with_triplequote_01;

{$mode unleashed}

const
  HEAD = `===`;
  BODY =
    '''
    line1
    line2
    ''';
  COMBO = HEAD + ' ' + BODY + HEAD;

begin
  if Pos('===', COMBO) = 0 then halt(1);
  if Pos('line1', COMBO) = 0 then halt(2);
  if Pos('line2', COMBO) = 0 then halt(3);
end.
