program autofree_in_nested_block_01;

{$mode unleashed}

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
  var outer := autofree TTracker.Create('O');
  begin
    var inner := autofree TTracker.Create('I');
    trace := trace + 'inner-block-end;';
  end;
  // inner should have been freed at end of nested block
  if trace <> 'inner-block-end;DI;' then
  begin
    trace := trace + 'WRONG-AT-MID;';
    halt(1);
  end;
end;

begin
  DoWork;
  // outer freed at proc end
  if trace <> 'inner-block-end;DI;DO;' then halt(2);
end.
