program nested_with_var_and_raise_01;

{$mode unleashed}

uses Classes, SysUtils;

type
  TBag = class
    Tag: String;
    constructor Create(const ATag: String);
    destructor Destroy; override;
  end;

var
  trace: String = '';

constructor TBag.Create(const ATag: String);
begin
  Tag := ATag;
end;

destructor TBag.Destroy;
begin
  trace := trace + 'D' + Tag + ';';
  inherited;
end;

procedure DoWork;
begin
  try
    with var outer := autofree TBag.Create('O') do
    begin
      with var inner := autofree TBag.Create('I') do
        raise Exception.Create('mid');
    end;
  except
    on E: Exception do
      trace := trace + 'caught;';
  end;
end;

begin
  DoWork;
  // Both autofrees must run; inner first (nearer scope), then outer
  if Pos('DI;', trace) = 0 then halt(1);
  if Pos('DO;', trace) = 0 then halt(2);
  if Pos('caught;', trace) = 0 then halt(3);
  if Pos('DI;', trace) > Pos('DO;', trace) then halt(4);
  if Pos('caught;', trace) < Pos('DO;', trace) then halt(5);
end.
