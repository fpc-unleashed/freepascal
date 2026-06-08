{ Shape_Managed bodies join the dedup set selectively.
  methods whose body contains a managed assignment (assignn whose result
  type is_managed_type) get poisoned and fall back to monomorphization;
  methods whose body never touches T as a value (e.g. plain getters
  on integer fields) safely share across all managed specializations }
program lightgenerics_managed_selective_17;
{$mode unleashed}
{$modeswitch lightgenerics}

type
  TBag<T>=class(TObject)
    FValue: T;
    FCount: Integer;
    function IsEmpty: Boolean;
    procedure SetValue(const A: T);
  end;

function TBag<T>.IsEmpty: Boolean;
begin
  Result := FCount = 0;
end;

procedure TBag<T>.SetValue(const A: T);
begin
  FValue := A;
  FCount := 1;
end;

type
  TByteArr = array of Byte;
  TBagStr = TBag<string>;
  TBagArr = TBag<TByteArr>;

procedure PickIsEmpty(klass_str: Boolean; out p: Pointer);
var
  s: TBagStr;
  a: TBagArr;
  m: TMethod;
begin
  if klass_str then
    begin s:=TBagStr.Create; m:=TMethod(@s.IsEmpty); p:=m.Code; s.Free; end
  else
    begin a:=TBagArr.Create; m:=TMethod(@a.IsEmpty); p:=m.Code; a.Free; end;
end;

procedure PickSetValue(klass_str: Boolean; out p: Pointer);
var
  s: TBagStr;
  a: TBagArr;
  m: TMethod;
begin
  if klass_str then
    begin s:=TBagStr.Create; m:=TMethod(@s.SetValue); p:=m.Code; s.Free; end
  else
    begin a:=TBagArr.Create; m:=TMethod(@a.SetValue); p:=m.Code; a.Free; end;
end;

var
  pe1, pe2, ps1, ps2: Pointer;
  s: TBagStr;
  a: TBagArr;
  buf: TByteArr;
begin
  PickIsEmpty(true, pe1);
  PickIsEmpty(false, pe2);
  PickSetValue(true, ps1);
  PickSetValue(false, ps2);
  { IsEmpty bodies share between managed specializations }
  if pe1 <> pe2 then Halt(1);
  { SetValue bodies do not share, each spec has its own monomorph copy }
  if ps1 = ps2 then Halt(2);

  { runtime integrity }
  s := TBagStr.Create;
  s.SetValue('hello');
  if s.FValue <> 'hello' then Halt(3);
  if s.IsEmpty then Halt(4);
  s.Free;

  a := TBagArr.Create;
  SetLength(buf, 2);
  buf[0] := 7; buf[1] := 8;
  a.SetValue(buf);
  if Length(a.FValue) <> 2 then Halt(5);
  if a.FValue[1] <> 8 then Halt(6);
  if a.IsEmpty then Halt(7);
  a.Free;
end.
