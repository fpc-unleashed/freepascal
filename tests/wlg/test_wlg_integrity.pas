{
  Test: WLG Integrity Test (FPCUnit)
  Verifies that generic containers work correctly with both POD and managed types
  when compiled with Witness-Based Lightweight Generics.
  
  This test checks:
  1. POD type (Integer) assignment and reading
  2. Managed type (AnsiString) assignment and reading
  3. Data isolation between specializations
  
  Build: fpc -dFPC_HAS_WITNESS_GENERICS wlg_testrunner.pas
}
unit test_wlg_integrity;

{$mode objfpc}{$H+}

interface

uses
  fpcunit, testregistry, SysUtils;

type
  { A simple generic container }
  generic TBox<T> = record
    Value: T;
    Count: Integer;
  end;

  TTestWLGIntegrity = class(TTestCase)
  published
    procedure TestPODType;
    procedure TestManagedType;
    procedure TestDataIsolation;
  end;

implementation

{ TTestWLGIntegrity }

procedure TTestWLGIntegrity.TestPODType;
var
  IntBox: specialize TBox<Integer>;
begin
  IntBox.Value := 42;
  IntBox.Count := 1;
  
  AssertEquals('POD value should be 42', 42, IntBox.Value);
  AssertEquals('POD count should be 1', 1, IntBox.Count);
  
  IntBox.Value := 100;
  AssertEquals('POD value after update should be 100', 100, IntBox.Value);
end;

procedure TTestWLGIntegrity.TestManagedType;
var
  StrBox: specialize TBox<AnsiString>;
begin
  StrBox.Value := 'FirstString';
  StrBox.Count := 2;
  
  AssertEquals('Managed value should be FirstString', 'FirstString', StrBox.Value);
  AssertEquals('Managed count should be 2', 2, StrBox.Count);
  
  StrBox.Value := 'SecondString';
  AssertEquals('Managed value after update should be SecondString', 'SecondString', StrBox.Value);
end;

procedure TTestWLGIntegrity.TestDataIsolation;
var
  IntBox: specialize TBox<Integer>;
  StrBox: specialize TBox<AnsiString>;
begin
  IntBox.Value := 999;
  StrBox.Value := 'SecondString';
  
  AssertEquals('IntBox should be 999', 999, IntBox.Value);
  AssertEquals('StrBox should be SecondString', 'SecondString', StrBox.Value);
end;

initialization
  RegisterTest(TTestWLGIntegrity);
end.