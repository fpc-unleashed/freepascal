program triplequote_basic_01;

{$mode unleashed}

const
  REPORT =
    '''
    sum     = 100
    largest = 50
    avg     = 12.50
    ''';

begin
  // triple-quote auto-trims indent based on closing delimiter column
  if Pos('sum     = 100', REPORT) = 0 then halt(1);
  // first line should not have leading 4-space indent
  if Copy(REPORT, 1, 4) = '    ' then halt(2);
end.
