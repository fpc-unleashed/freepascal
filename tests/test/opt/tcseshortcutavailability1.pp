{ %OPT=-O2 }

program tcseshortcutavailability1;

{$mode objfpc}

type
  TPair = record
    A: LongInt;
    B: LongInt;
  end;
  PPair = ^TPair;

var
  Gate: LongInt;
  Pair: TPair;
  PairPointer: PPair;
  Events: array[0..3] of LongInt;

{$B-}
function ShortAnd: Boolean; inline;
begin
  Result := (Gate <> 0) and (Pair.B = 0);
end;

function ShortOr: Boolean; inline;
begin
  Result := (Gate = 0) or (Pair.B = 0);
end;

function ShortPointerAnd: Boolean; inline;
begin
  Result := (Gate <> 0) and (PairPointer^.B = 0);
end;

{$B+}
function FullAnd: Boolean; inline;
begin
  Result := (Gate <> 0) and (Pair.B = 0);
end;

function FullOr: Boolean; inline;
begin
  Result := (Gate = 0) or (Pair.B = 0);
end;

function ExpectedAnd(D,A,B: LongInt): Boolean; noinline;
begin
  Result:=False;
  if D<>0 then
    if B=0 then
      if A<>0 then
        Result:=True;
end;

function ExpectedOrAnd(D,A,B: LongInt): Boolean; noinline;
begin
  Result:=False;
  if D=0 then
    begin
      if A<>0 then
        Result:=True;
    end
  else if B=0 then
    if A<>0 then
      Result:=True;
end;

function ExpectedAndOr(D,A,B: LongInt): Boolean; noinline;
begin
  Result:=False;
  if A<>0 then
    Result:=True
  else if D<>0 then
    if B=0 then
      Result:=True;
end;

function Mark(Event: LongInt;Value: Boolean): Boolean; noinline;
begin
  Inc(Events[Event]);
  Result:=Value;
end;

function ShortEvents: Boolean; inline;
begin
  {$B-}
  Result:=Mark(1,False) and Mark(2,True);
end;

procedure Check(Value,Expected: Boolean;Code: LongInt); noinline;
begin
  if Value<>Expected then
    Halt(Code);
end;

procedure CheckPureMatrix;
var
  D,A,B: LongInt;
begin
  PairPointer:=@Pair;
  for D:=0 to 1 do
    for A:=0 to 1 do
      for B:=0 to 1 do
        begin
          Gate:=D;
          Pair.A:=A;
          Pair.B:=B;

          {$B-}
          Check(ShortAnd and (Pair.A<>0),ExpectedAnd(D,A,B),11);
          Check(ShortOr and (Pair.A<>0),ExpectedOrAnd(D,A,B),12);

          {$B+}
          Check(ShortAnd and (Pair.A<>0),ExpectedAnd(D,A,B),13);
          Check(ShortAnd or (Pair.A<>0),ExpectedAndOr(D,A,B),14);
          Check(ShortOr and (Pair.A<>0),ExpectedOrAnd(D,A,B),15);
          Check(FullAnd and (Pair.A<>0),ExpectedAnd(D,A,B),16);
          Check(FullOr and (Pair.A<>0),ExpectedOrAnd(D,A,B),17);
          Check(ShortPointerAnd and (PairPointer^.A<>0),ExpectedAnd(D,A,B),18);

          {$B-}
          Check(FullAnd and (Pair.A<>0),ExpectedAnd(D,A,B),19);
          Check(FullOr and (Pair.A<>0),ExpectedOrAnd(D,A,B),20);
        end;
end;

procedure CheckEvaluationEvents;
var
  Value: Boolean;
begin
  FillChar(Events,SizeOf(Events),0);
  {$B-}
  Value:=Mark(1,False) and Mark(2,True);
  Check(Value,False,31);
  if (Events[1]<>1) or (Events[2]<>0) then
    Halt(32);

  FillChar(Events,SizeOf(Events),0);
  {$B+}
  Value:=Mark(1,False) and Mark(2,True);
  Check(Value,False,33);
  if (Events[1]<>1) or (Events[2]<>1) then
    Halt(34);

  FillChar(Events,SizeOf(Events),0);
  {$B+}
  Value:=ShortEvents and Mark(3,True);
  Check(Value,False,35);
  if (Events[1]<>1) or (Events[2]<>0) or (Events[3]<>1) then
    Halt(36);
end;

begin
  CheckPureMatrix;
  CheckEvaluationEvents;
end.
