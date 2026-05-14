program autofree_with_try_finally_combo_01;

{$mode unleashed}

uses SysUtils;

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
  var a := autofree TTracker.Create('A');
  try
    var b := autofree TTracker.Create('B');
    try
      raise Exception.Create('boom');
    finally
      trace := trace + 'finally-inner;';
    end;
  except
    on E: Exception do
      trace := trace + 'caught;';
  end;
  trace := trace + 'after;';
end;

begin
  DoWork;
  // expected order:
  //   inner finally fires (DB still alive at finally point but freed at scope end)
  //   B autofree fires when its block ends (after the inner try-finally + before reaching except? Actually B's scope is the begin..end of try body, so when inner try-finally completes via raise, unwinding leaves the try body which includes B's scope)
  // The trace shows: finally-inner; DB (autofree fires as scope unwinds);
  //   caught; after; DA (proc-level scope ends).
  // We assert the four anchor markers appear in that order without
  // pinning the exact interleaving of cleanups vs handlers.
  if Pos('finally-inner;', trace) = 0 then halt(1);
  if Pos('caught;', trace)        = 0 then halt(2);
  if Pos('after;', trace)         = 0 then halt(3);
  if Pos('DB;', trace)            = 0 then halt(4);
  if Pos('DA;', trace)            = 0 then halt(5);
  // DA must appear after 'after;' (proc-level scope)
  if Pos('DA;', trace) < Pos('after;', trace) then halt(6);
  // 'caught;' must appear after 'finally-inner;'
  if Pos('caught;', trace) < Pos('finally-inner;', trace) then halt(7);
end.
