program with_defer_inside_body_01;

{$mode unleashed}

uses Classes;

var
  trace: String = '';

type
  TTracker = class
  private
    FName: String;
  public
    constructor Create(const AName: String);
    destructor Destroy; override;
  end;

constructor TTracker.Create(const AName: String);
begin
  FName := AName;
end;

destructor TTracker.Destroy;
begin
  trace := trace + 'D' + FName + ';';
  inherited;
end;

begin
  with var t := autofree TTracker.Create('T') do
    defer trace := trace + 'cleanup;';
  // defer fires first (in scope of the with-body), then autofree DT
  if trace <> 'cleanup;DT;' then halt(1);
end.
