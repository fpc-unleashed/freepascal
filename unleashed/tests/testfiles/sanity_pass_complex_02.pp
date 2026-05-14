program sanity_pass_complex_02;

{$mode unleashed}

uses Classes, SysUtils;

// integration sanity #2: scoped-with form D + autofree + match-as-expr
// + tuples + numeric underscores + compound assign + for-step.
function Build: String;
begin
  var pieces: array of String := nil;
  for var i := 1 to 1_000 step 200 do
    pieces := pieces + [match
                          i = 1: 'one';
                          i > 800: 'big';
                          _:        'mid';
                        end];

  with var lst := autofree TStringList.Create do
  begin
    for var p in pieces do
      lst.Add(p);
    Result := IntToStr(lst.Count);
  end;
end;

begin
  // step 200 over [1..1000]: i = 1, 201, 401, 601, 801, 1001-stop
  // last in-range = 801, so 5 iterations
  if Build <> '5' then halt(1);
end.
