{
  Test: WLG Nested Generics Test (FPCUnit)
  Verifies that nested generic specializations compile and run correctly
  with Witness-Based Lightweight Generics.
  
  This test checks:
  1. Nested generic type: TList<TItem> where TItem is itself a specialized type
  2. Outer container operations (add, get, count)
  3. Inner container operations preserved through nesting
  
  Build: fpc -dFPC_HAS_WITNESS_GENERICS wlg_testrunner.pas
}
unit test_wlg_nested;

{$mode objfpc}{$H+}

interface

uses
  fpcunit, testregistry, SysUtils;

type
  { A simple generic list }
  generic TList<T> = class
  private
    FItems: array of T;
    FCount: Integer;
  public
    procedure Add(const Item: T);
    function Get(Index: Integer): T;
    function GetCount: Integer;
  end;

  { A generic wrapper around a value }
  generic TValueWrapper<T> = record
    Value: T;
    Valid: Boolean;
  end;

  TTestWLGNested = class(TTestCase)
  published
    procedure TestNestedListAdd;
    procedure TestNestedListRetrieve;
    procedure TestNestedDataIsolation;
  end;

implementation

{ TList }

procedure TList.Add(const Item: T);
begin
  if FCount = Length(FItems) then
    SetLength(FItems, (FCount + 1) * 2);
  FItems[FCount] := Item;
  Inc(FCount);
end;

function TList.Get(Index: Integer): T;
begin
  if (Index < 0) or (Index >= FCount) then
    raise Exception.Create('Index out of bounds');
  Result := FItems[Index];
end;

function TList.GetCount: Integer;
begin
  Result := FCount;
end;

{ TTestWLGNested }

procedure TTestWLGNested.TestNestedListAdd;
var
  NestedList: specialize TList<specialize TValueWrapper<Integer>>;
  Wrapper: specialize TValueWrapper<Integer>;
begin
  NestedList := specialize TList<specialize TValueWrapper<Integer>>.Create;
  try
    Wrapper.Value := 42;
    Wrapper.Valid := True;
    NestedList.Add(Wrapper);
    
    Wrapper.Value := 100;
    Wrapper.Valid := True;
    NestedList.Add(Wrapper);
    
    AssertEquals('Nested list count should be 2', 2, NestedList.GetCount);
  finally
    NestedList.Free;
  end;
end;

procedure TTestWLGNested.TestNestedListRetrieve;
var
  NestedList: specialize TList<specialize TValueWrapper<Integer>>;
  Wrapper, RetrievedWrapper: specialize TValueWrapper<Integer>;
begin
  NestedList := specialize TList<specialize TValueWrapper<Integer>>.Create;
  try
    Wrapper.Value := 42;
    Wrapper.Valid := True;
    NestedList.Add(Wrapper);
    
    Wrapper.Value := 100;
    Wrapper.Valid := True;
    NestedList.Add(Wrapper);
    
    RetrievedWrapper := NestedList.Get(0);
    AssertTrue('First wrapper should be valid', RetrievedWrapper.Valid);
    AssertEquals('First wrapper value should be 42', 42, RetrievedWrapper.Value);
    
    RetrievedWrapper := NestedList.Get(1);
    AssertEquals('Second wrapper value should be 100', 100, RetrievedWrapper.Value);
  finally
    NestedList.Free;
  end;
end;

procedure TTestWLGNested.TestNestedDataIsolation;
var
  NestedList: specialize TList<specialize TValueWrapper<Integer>>;
  Wrapper, RetrievedWrapper: specialize TValueWrapper<Integer>;
begin
  NestedList := specialize TList<specialize TValueWrapper<Integer>>.Create;
  try
    Wrapper.Value := 42;
    Wrapper.Valid := True;
    NestedList.Add(Wrapper);
    
    Wrapper.Value := 100;
    Wrapper.Valid := True;
    NestedList.Add(Wrapper);
    
    { Verify isolation - modifying retrieved copy shouldn't affect stored }
    RetrievedWrapper := NestedList.Get(1);
    RetrievedWrapper.Value := 999;
    
    { Records are value types, so stored value should remain unchanged }
    AssertEquals('Stored value should remain 100 (record copy)', 100, NestedList.Get(1).Value);
  finally
    NestedList.Free;
  end;
end;

initialization
  RegisterTest(TTestWLGNested);
end.