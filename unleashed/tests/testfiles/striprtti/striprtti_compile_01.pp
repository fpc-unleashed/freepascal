{ %NORUN %CHECKBIN_HAS=TStripCompileKept %CHECKBIN_LACKS=TStripCompileInternal }
program striprtti_compile_01;

{$mode unleashed}
{$modeswitch striprtti}

type
  TStripCompileInternal = class(TObject)
  end;

  expose TStripCompileKept = class(TObject)
  end;

  expose TStripCompilePoint = record
    x, y: Integer;
  end;

var
  pt: TStripCompilePoint;
begin
  with TStripCompileInternal.Create do Free;
  with TStripCompileKept.Create do Free;
  pt.x := 1;
  pt.y := 2;
end.
