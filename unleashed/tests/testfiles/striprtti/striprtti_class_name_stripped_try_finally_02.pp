{ %CHECKBIN_LACKS=TStripBoxA02,TStripBoxB02 }
program striprtti_class_name_stripped_try_finally_02;
{$mode unleashed}
{$modeswitch striprtti}

// striprtti modeswitch strips both type-name strings even though the classes
// are exercised with constructors, field writes, and explicit Free in finally
type
  TStripBoxA02 = class
    Value: Integer;
  end;

  TStripBoxB02 = class
    Name: String;
  end;

var
  a: TStripBoxA02;
  b: TStripBoxB02;
begin
  a := TStripBoxA02.Create;
  try
    a.Value := 100;
    if a.Value <> 100 then Halt(1);
    b := TStripBoxB02.Create;
    try
      b.Name := 'stripped';
      if b.Name <> 'stripped' then Halt(2);
    finally
      b.Free;
    end;
  finally
    a.Free;
  end;
end.
