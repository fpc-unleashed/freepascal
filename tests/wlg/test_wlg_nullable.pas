{
  Test: WLG Nullable Test (FPCUnit)
  Verifies that FPC's nullable.pp generic unit compiles and works correctly
  with Witness-Based Lightweight Generics.
  
  This test uses nullable.pp compiled as a separate unit (via -Fu path).
  Tests:
  1. TNullable<Integer> operations
  2. TNullable<AnsiString> operations
  3. TNullable<TObject> operations
  4. Operator overloads (:=, Explicit, IsNull, etc.)
  
  Build: fpc -dFPC_HAS_WITNESS_GENERICS -Fu../../packages/rtl-objpas/src/inc wlg_testrunner.pas
}
unit test_wlg_nullable;

{$mode objfpc}{$H+}

interface

uses
  fpcunit, testregistry, SysUtils, nullable;

type
  TTestWLGNulLable = class(TTestCase)
  published
    procedure TestNullableInteger;
    procedure TestNullableString;
    procedure TestNullableObject;
    procedure TestOperators;
    procedure TestValueOrDefault;
    procedure TestUnpack;
    procedure TestClear;
  end;

implementation

{ TTestWLGNulLable }

procedure TTestWLGNulLable.TestNullableInteger;
var
  N: specialize TNullable<Integer>;
begin
  AssertTrue('Should be null initially', N.IsNull);
  AssertFalse('Should not have value initially', N.HasValue);
  
  N := 42;
  AssertFalse('Should not be null after assignment', N.IsNull);
  AssertTrue('Should have value after assignment', N.HasValue);
  AssertEquals('Value should be 42', 42, N.Value);
end;

procedure TTestWLGNulLable.TestNullableString;
var
  N: specialize TNullable<AnsiString>;
begin
  AssertTrue('Should be null initially', N.IsNull);
  
  N := 'Hello';
  AssertFalse('Should not be null after assignment', N.IsNull);
  AssertEquals('Value should be Hello', 'Hello', N.Value);
  
  N := 'World';
  AssertEquals('Value should be World after reassignment', 'World', N.Value);
end;

procedure TTestWLGNulLable.TestNullableObject;
var
  N: specialize TNullable<TObject>;
  Obj: TObject;
begin
  AssertTrue('Should be null initially', N.IsNull);
  
  Obj := TObject.Create;
  try
    N := Obj;
    AssertFalse('Should not be null after assignment', N.IsNull);
    AssertTrue('Value should be same instance', Obj = N.Value);
  finally
    Obj.Free;
  end;
end;

procedure TTestWLGNulLable.TestOperators;
var
  N: specialize TNullable<Integer>;
  M: specialize TNullable<Integer>;
  IntVal: Integer;
begin
  { Test := operator }
  N := 10;
  AssertEquals('N.Value should be 10', 10, N.Value);
  
  { Test Explicit conversion from T (using TNullable.Create pattern) }
  M := 20;
  AssertEquals('M.Value should be 20', 20, M.Value);
  
  { Test Explicit conversion to T (implicit via assignment) }
  IntVal := M;
  AssertEquals('Explicit to T should be 20', 20, IntVal);
  
  { Test = operator with null }
  N := null;
  AssertTrue('N should be null', N = null);
  
  { Test <> operator with null }
  N := 30;
  AssertTrue('N should not equal null', N <> null);
  
  { Test Not operator }
  AssertFalse('Not N should be false (N has value)', not N);
  
  N := null;
  AssertTrue('Not N should be true (N is null)', not N);
end;

procedure TTestWLGNulLable.TestValueOrDefault;
var
  N: specialize TNullable<Integer>;
begin
  { Test ValueOrDefault when null }
  AssertEquals('ValueOrDefault should return default (0) when null', 0, N.ValueOrDefault);
  AssertEquals('ValueOrDefault with fallback should return fallback', 99, N.ValueOr(99));
  
  { Test ValueOrDefault when has value }
  N := 42;
  AssertEquals('ValueOrDefault should return 42', 42, N.ValueOrDefault);
  AssertEquals('ValueOrDefault with fallback should return 42', 42, N.ValueOr(99));
end;

procedure TTestWLGNulLable.TestUnpack;
var
  N: specialize TNullable<Integer>;
  Dest: Integer;
begin
  { Test Unpack when null }
  AssertFalse('Unpack should return false when null', N.Unpack(Dest));
  
  { Test Unpack when has value }
  N := 42;
  AssertTrue('Unpack should return true when has value', N.Unpack(Dest));
  AssertEquals('Dest should be 42', 42, Dest);
end;

procedure TTestWLGNulLable.TestClear;
var
  N: specialize TNullable<Integer>;
begin
  N := 42;
  AssertTrue('Should have value', N.HasValue);
  
  N.Clear;
  AssertFalse('Should not have value after Clear', N.HasValue);
  AssertTrue('Should be null after Clear', N.IsNull);
end;

initialization
  RegisterTest(TTestWLGNulLable);
end.