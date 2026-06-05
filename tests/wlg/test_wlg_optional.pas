{
  Test: WLG Optional Test (FPCUnit)
  Verifies that the project's Optional.pas generic unit compiles and works correctly
  with Witness-Based Lightweight Generics.
  
  This test uses Optional.pas compiled as a separate unit (via -Fu path).
  Tests:
  1. TOptional<Integer> operations
  2. TOptional<AnsiString> operations
  3. TOptional<TObject> operations
  4. ValueOrDefault, Unpack, Empty, OfValue
  
  Build: ../../compiler/ppcx64 -n @../../compiler/fpc.cfg -Fu. wlg_testrunner.pas
}
unit test_wlg_optional;

{$mode objfpc}{$H+}

interface

uses
  fpcunit, testregistry, SysUtils, Optional;

type
  TTestWLGOptional = class(TTestCase)
  published
    procedure TestOptionalInteger;
    procedure TestOptionalString;
    procedure TestOptionalObject;
    procedure TestValueOrDefault;
    procedure TestUnpack;
    procedure TestEmptyAndOfValue;
  end;

implementation

{ TTestWLGOptional }

procedure TTestWLGOptional.TestOptionalInteger;
var
  O: specialize TOptional<Integer>;
begin
  { Default-constructed record should have no value (Initialize sets FHasValue := False) }
  AssertFalse('Should not have value initially', O.HasValue);
  
  { Assign via OfValue factory }
  O := specialize TOptional<Integer>.OfValue(42);
  AssertTrue('Should have value after OfValue', O.HasValue);
  AssertEquals('Value should be 42', 42, O.Value);
end;

procedure TTestWLGOptional.TestOptionalString;
var
  O: specialize TOptional<AnsiString>;
begin
  AssertFalse('Should not have value initially', O.HasValue);
  
  O := specialize TOptional<AnsiString>.OfValue('Hello');
  AssertTrue('Should have value after OfValue', O.HasValue);
  AssertEquals('Value should be Hello', 'Hello', O.Value);
  
  O := specialize TOptional<AnsiString>.OfValue('World');
  AssertEquals('Value after reassignment should be World', 'World', O.Value);
end;

procedure TTestWLGOptional.TestOptionalObject;
var
  O: specialize TOptional<TObject>;
  Obj: TObject;
begin
  AssertFalse('Should not have value initially', O.HasValue);
  
  Obj := TObject.Create;
  try
    O := specialize TOptional<TObject>.OfValue(Obj);
    AssertTrue('Should have value after OfValue', O.HasValue);
    AssertTrue('Value should be same instance', Obj = O.Value);
  finally
    Obj.Free;
  end;
end;

procedure TTestWLGOptional.TestValueOrDefault;
var
  O: specialize TOptional<Integer>;
begin
  { Test ValueOrDefault when no value }
  AssertEquals('ValueOrDefault should return default (0) when empty', 0, O.ValueOrDefault(0));
  AssertEquals('ValueOrDefault with fallback should return fallback', 99, O.ValueOrDefault(99));
  
  { Test ValueOrDefault when has value }
  O := specialize TOptional<Integer>.OfValue(42);
  AssertEquals('ValueOrDefault should return 42', 42, O.ValueOrDefault(0));
  AssertEquals('ValueOrDefault with fallback should return 42', 42, O.ValueOrDefault(99));
end;

procedure TTestWLGOptional.TestUnpack;
var
  O: specialize TOptional<Integer>;
  Dest: Integer;
begin
  { Test Unpack when no value }
  AssertFalse('Unpack should return false when empty', O.Unpack(Dest));
  
  { Test Unpack when has value }
  O := specialize TOptional<Integer>.OfValue(42);
  AssertTrue('Unpack should return true when has value', O.Unpack(Dest));
  AssertEquals('Dest should be 42', 42, Dest);
end;

procedure TTestWLGOptional.TestEmptyAndOfValue;
var
  E: specialize TOptional<Integer>;
  O: specialize TOptional<Integer>;
begin
  { Test Empty factory }
  E := specialize TOptional<Integer>.Empty;
  AssertFalse('Empty should not have value', E.HasValue);
  
  { Test OfValue factory }
  O := specialize TOptional<Integer>.OfValue(123);
  AssertTrue('OfValue should have value', O.HasValue);
  AssertEquals('OfValue value should be 123', 123, O.Value);
end;

initialization
  RegisterTest(TTestWLGOptional);
end.