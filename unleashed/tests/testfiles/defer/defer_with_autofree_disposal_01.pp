program defer_with_autofree_disposal_01;

{$mode unleashed}

uses Classes;

var
  trace: String = '';

type
  TTracker = class
    Tag: String;
    constructor Create(const ATag: String);
    destructor Destroy; override;
  end;

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
  var t := autofree TTracker.Create('T');
  defer trace := trace + 'after-T;';
  trace := trace + 'mid;';
end;

begin
  DoWork;
  // mid (body runs), then defer fires (after-T), then autofree fires (DT)
  if trace <> 'mid;after-T;DT;' then halt(1);
end.
