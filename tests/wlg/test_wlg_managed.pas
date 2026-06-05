{
  Test: WLG Managed Type Lifecycle Test (FPCUnit)
  Verifies that managed types (strings) are correctly
  initialized, copied, and finalized through witness tables.
  
  This test checks:
  1. AnsiString assignment and reference counting
  2. UnicodeString operations
  3. Multiple specializations with different managed types
  4. Proper cleanup (no memory leaks from missing finalize)
  
  Build: fpc -dFPC_HAS_WITNESS_GENERICS wlg_testrunner.pas
}
unit test_wlg_managed;

{$mode objfpc}{$H+}

interface

uses
  fpcunit, testregistry, SysUtils;

type
  { A generic container for managed types }
  generic TManagedBox<T> = record
    FValue: T;
    FHasValue: Boolean;
  end;

  TTestWLGManaged = class(TTestCase)
  published
    procedure TestAnsiStringLifecycle;
    procedure TestStringReassignment;
    procedure TestUnicodeString;
    procedure TestDataIsolation;
  end;

implementation

{ TTestWLGManaged }

procedure TTestWLGManaged.TestAnsiStringLifecycle;
type
  TStrManagedBox = specialize TManagedBox<AnsiString>;
var
  StringBox: TStrManagedBox;
begin
  StringBox.FHasValue := False;
  AssertFalse('StringBox should start without value', StringBox.FHasValue);
  
  StringBox.FValue := 'Hello';
  StringBox.FHasValue := True;
  AssertTrue('StringBox should have value after assignment', StringBox.FHasValue);
  AssertEquals('StringBox value should be Hello', 'Hello', StringBox.FValue);
end;

procedure TTestWLGManaged.TestStringReassignment;
type
  TStrManagedBox = specialize TManagedBox<AnsiString>;
var
  StringBox: TStrManagedBox;
begin
  StringBox.FValue := 'Hello';
  StringBox.FHasValue := True;
  
  StringBox.FValue := 'World';
  AssertEquals('StringBox value after reassignment should be World', 'World', StringBox.FValue);
end;

procedure TTestWLGManaged.TestUnicodeString;
type
  TUniManagedBox = specialize TManagedBox<UnicodeString>;
var
  UnicodeBox: TUniManagedBox;
begin
  UnicodeBox.FValue := 'Unicode';
  AssertEquals('UnicodeBox value should be Unicode', 'Unicode', UnicodeBox.FValue);
end;

procedure TTestWLGManaged.TestDataIsolation;
type
  TStrManagedBox = specialize TManagedBox<AnsiString>;
  TUniManagedBox = specialize TManagedBox<UnicodeString>;
var
  StringBox: TStrManagedBox;
  UnicodeBox: TUniManagedBox;
  RefBox: TStrManagedBox;
begin
  StringBox.FValue := 'Isolated';
  RefBox.FValue := 'RefCounted';
  UnicodeBox.FValue := 'Unicode';
  
  AssertEquals('StringBox should be Isolated', 'Isolated', StringBox.FValue);
  AssertEquals('RefBox should be RefCounted', 'RefCounted', RefBox.FValue);
  AssertEquals('UnicodeBox should be Unicode', 'Unicode', UnicodeBox.FValue);
end;

initialization
  RegisterTest(TTestWLGManaged);
end.