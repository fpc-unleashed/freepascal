program triplequote_concat_with_var_01;

{$mode unleashed}

begin
  var name := 'World';
  var greeting :=
    '''
    Hello,
    '''
    + name + '!'
    + '''

    Bye.
    ''';
  if Pos('Hello,', greeting) = 0 then halt(1);
  if Pos('World!', greeting) = 0 then halt(2);
  if Pos('Bye.',   greeting) = 0 then halt(3);
end.
