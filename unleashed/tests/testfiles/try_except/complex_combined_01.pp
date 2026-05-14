program complex_combined_01;

{$mode unleashed}

uses Classes, SysUtils;

// kitchen-sink: autofree + defer + match + statement-expr + nested
// try-except + raise + re-raise + tuple destructure

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

function Step(n: Integer): (ok: Boolean; reason: String);
begin
  Result := (ok: false, reason: '');
  try
    var bag := autofree TBag.Create('S' + IntToStr(n));
    defer trace := trace + 'd' + IntToStr(n) + ';';

    match n of
      1: Result := (ok: true, reason: 'one');
      2: raise Exception.Create('two-fail');
      3: raise EConvertError.Create('three-fail');
      _: Result := (ok: true, reason: 'other');
    end;
  except
    on E: EConvertError do
      Result := (ok: false, reason: 'convert:' + E.Message);
    on E: Exception do
      Result := (ok: false, reason: 'generic:' + E.Message);
  end;
end;

begin
  var (ok1, reason1) := Step(1);
  if not ok1                 then halt(1);
  if reason1 <> 'one'        then halt(2);

  var (ok2, reason2) := Step(2);
  if ok2                                   then halt(3);
  if reason2 <> 'generic:two-fail'         then halt(4);

  var (ok3, reason3) := Step(3);
  if ok3                                   then halt(5);
  if reason3 <> 'convert:three-fail'       then halt(6);

  var (ok4, reason4) := Step(99);
  if not ok4                 then halt(7);
  if reason4 <> 'other'      then halt(8);

  // Each Step ran defer + autofree once. Trace should contain all four
  // markers in order of calls.
  if Pos('DS1;', trace) = 0 then halt(9);
  if Pos('DS2;', trace) = 0 then halt(10);
  if Pos('DS3;', trace) = 0 then halt(11);
  if Pos('DS99;',trace) = 0 then halt(12);
end.
