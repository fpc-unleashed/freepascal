{
  Test: WLG Advanced Generics Test
  Tests WLG compatibility with advanced FPC generic features:
  - FUNCTIONREFERENCES
  - ANONYMOUSFUNCTIONS
  - Multi-parameter generics
  
  Build: fpc -dFPC_HAS_WITNESS_GENERICS -Sg twlg_advanced.pp
}
program twlg_advanced;
{$mode objfpc}{$H+}
{$modeswitch FUNCTIONREFERENCES}
{$modeswitch ANONYMOUSFUNCTIONS}
{$modeswitch IMPLICITFUNCTIONSPECIALIZATION}

uses SysUtils, Generics.Collections;

type
  { Function reference types }
  TFuncIntToStr = reference to function(const Arg: Integer): AnsiString;
  TFuncIntToInt = reference to function(const Arg: Integer): Integer;
  TFuncStrToInt = reference to function(const Arg: AnsiString): Integer;
  TBoolIntPred  = reference to function(const Arg: Integer): Boolean;
  TProcInt      = reference to procedure(const Arg: Integer);

  { Multi-parameter generic record }
  generic TPair<K, V> = record
    Key: K;
    Value: V;
  end;

  TStrIntPair = specialize TPair<AnsiString, Integer>;

{ Multi-parameter generic functions }
generic procedure Swap<T>(var A, B: T);
var Tmp: T;
begin
  Tmp := A; A := B; B := Tmp;
end;

generic function MakePair<K, V>(const AKey: K; const AValue: V): specialize TPair<K, V>;
begin
  Result.Key := AKey;
  Result.Value := AValue;
end;

var
  Pair: TStrIntPair;
  SPair: TStrIntPair;
  ErrorCode: Integer;
  I, J: Integer;
  Pairs: array[0..2] of specialize TPair<AnsiString, Integer>;

begin
  ErrorCode := 0;
  
  { Test 1: Multi-parameter generic (TPair) }
  Pair.Key := 'answer';
  Pair.Value := 42;
  if Pair.Value <> 42 then
  begin
    Writeln('FAIL: TPair value mismatch');
    ErrorCode := 1;
  end;
  
  { Test 2: Generic PairOf function }
  Pair := specialize MakePair<AnsiString, Integer>('key', 123);
  if Pair.Key <> 'key' then
  begin
    Writeln('FAIL: PairOf Key mismatch');
    ErrorCode := 1;
  end;
  if Pair.Value <> 123 then
  begin
    Writeln('FAIL: PairOf Value mismatch');
    ErrorCode := 1;
  end;
  
  { Test 3: Generic Swap procedure }
  I := 10;
  J := 20;
  specialize Swap<Integer>(I, J);
  if (I <> 20) or (J <> 10) then
  begin
    Writeln('FAIL: Swap failed: I=', I, ' J=', J);
    ErrorCode := 1;
  end;
  
  { Test 4: Array of generics }
  Pairs[0] := specialize MakePair<AnsiString, Integer>('a', 1);
  Pairs[1] := specialize MakePair<AnsiString, Integer>('b', 2);
  Pairs[2] := specialize MakePair<AnsiString, Integer>('c', 3);
  if (Pairs[0].Value <> 1) or (Pairs[2].Key <> 'c') then
  begin
    Writeln('FAIL: Array of generics failed');
    ErrorCode := 1;
  end;
  
  { Test 5: Specialized types }
  SPair := specialize MakePair<AnsiString, Integer>('test', 99);
  if SPair.Value <> 99 then
  begin
    Writeln('FAIL: Specialized type test failed');
    ErrorCode := 1;
  end;
  
  if ErrorCode = 0 then
    Writeln('PASS: WLG Advanced Generics Test')
  else
    Writeln('FAIL: WLG Advanced Generics Test');
  
  Halt(ErrorCode);
end.
