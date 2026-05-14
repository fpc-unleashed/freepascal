program autofree_lifo_order_01;

{$mode unleashed}

type
  TTracker = class
  private
    FName: String;
  public
    constructor Create(const AName: String);
    destructor Destroy; override;
  end;

var
  Trace: String = '';

constructor TTracker.Create(const AName: String);
begin
  FName := AName;
  Trace := Trace + 'C' + FName + ';';
end;

destructor TTracker.Destroy;
begin
  Trace := Trace + 'D' + FName + ';';
  inherited;
end;

procedure DoWork;
begin
  var a := autofree TTracker.Create('A');
  var b := autofree TTracker.Create('B');
  var c := autofree TTracker.Create('C');
end;

begin
  DoWork;
  // LIFO destroy: registered A, B, C; destroyed C, B, A
  if Trace <> 'CA;CB;CC;DC;DB;DA;' then halt(1);
end.
