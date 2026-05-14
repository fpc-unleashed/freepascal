program defer_and_autofree_combined_in_try_01;

{$mode unleashed}

uses Classes, SysUtils;

type
  TTracker = class
    Tag: String;
    constructor Create(const ATag: String);
    destructor Destroy; override;
  end;

var
  trace: String = '';

constructor TTracker.Create(const ATag: String);
begin
  Tag := ATag;
end;

destructor TTracker.Destroy;
begin
  trace := trace + 'D' + Tag + ';';
  inherited;
end;

procedure DoWork;
begin
  try
    var a := autofree TTracker.Create('A');
    defer trace := trace + 'def1;';
    var b := autofree TTracker.Create('B');
    defer trace := trace + 'def2;';
    raise Exception.Create('boom');
  except
    on E: Exception do
      trace := trace + 'caught;';
  end;
end;

begin
  DoWork;
  // verify all four cleanups happened, in some LIFO-ish order, then caught
  if Pos('def2;', trace) = 0 then halt(1);
  if Pos('DB;',   trace) = 0 then halt(2);
  if Pos('def1;', trace) = 0 then halt(3);
  if Pos('DA;',   trace) = 0 then halt(4);
  if Pos('caught;', trace) = 0 then halt(5);
  // caught must be after all cleanups
  if Pos('caught;', trace) < Pos('DA;', trace) then halt(6);
  // def2 before def1 (LIFO)
  if Pos('def2;', trace) > Pos('def1;', trace) then halt(7);
  // DB before DA (LIFO)
  if Pos('DB;', trace) > Pos('DA;', trace) then halt(8);
end.
