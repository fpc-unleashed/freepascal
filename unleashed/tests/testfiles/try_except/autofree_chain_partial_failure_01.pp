program autofree_chain_partial_failure_01;

{$mode unleashed}

uses Classes, SysUtils;

type
  TBomb = class
    Tag: String;
    constructor Create(const ATag: String; explode: Boolean);
    destructor Destroy; override;
  end;

var
  trace: String = '';

constructor TBomb.Create(const ATag: String; explode: Boolean);
begin
  Tag := ATag;
  if explode then
    raise Exception.Create('ctor-' + Tag);
end;

destructor TBomb.Destroy;
begin
  trace := trace + 'D' + Tag + ';';
  inherited;
end;

procedure DoWork;
begin
  var a := autofree TBomb.Create('A', false);
  var b := autofree TBomb.Create('B', true);   // raises before the var binds
  halt(99);   // never reached
end;

begin
  try
    DoWork;
  except
    on E: Exception do ;
  end;
  // 'A' must be freed (autofree on a successfully bound var fires);
  // 'B' had its FPC-emitted ctor-failure cleanup path. We do not pin
  // the exact destroy count for 'B' (FPC handles partially-constructed
  // dispose internally) but 'A' must appear in the trace.
  if Pos('DA;', trace) = 0 then halt(1);
end.
