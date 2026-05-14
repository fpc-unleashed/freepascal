{ %NORUN %CHECKBIN_HAS=TMsiKept %CHECKBIN_LACKS=TMsiInternal }
program modeswitch_inject_striprtti_01;

{$mode unleashed}
{$modeswitch striprtti}

// `expose` keyword is gated on m_unleashed; striprtti modeswitch is what
// makes `expose` actually do something on the binary
type
  TMsiInternal = class(TObject)
  end;

  expose TMsiKept = class(TObject)
  end;

begin
  with TMsiInternal.Create do Free;
  with TMsiKept.Create do Free;
end.
