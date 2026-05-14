{ %CHECKBIN_HAS=TKeepBoxA02,TKeepBoxB02 }
program striprtti_class_name_kept_try_finally_02;
{$mode unleashed}

// no striprtti modeswitch -> RTTI keeps both type-name strings even when
// the instances are scoped inside try-finally with non-trivial cleanup
type
  TKeepBoxA02 = class
    Value: Integer;
  end;

  TKeepBoxB02 = class
    Name: String;
  end;

var
  a: TKeepBoxA02;
  b: TKeepBoxB02;
begin
  a := TKeepBoxA02.Create;
  try
    a.Value := 100;
    if a.Value <> 100 then Halt(1);
    b := TKeepBoxB02.Create;
    try
      b.Name := 'kept';
      if b.Name <> 'kept' then Halt(2);
    finally
      b.Free;
    end;
  finally
    a.Free;
  end;
end.
