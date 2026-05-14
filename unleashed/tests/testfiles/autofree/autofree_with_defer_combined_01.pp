program autofree_with_defer_combined_01;

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
  var a := autofree TTracker.Create('A');
  defer trace := trace + 'defer1;';
  var b := autofree TTracker.Create('B');
  defer trace := trace + 'defer2;';
end;

begin
  DoWork;
  // LIFO: defer2, DB, defer1, DA
  if trace <> 'defer2;DB;defer1;DA;' then halt(1);
end.
