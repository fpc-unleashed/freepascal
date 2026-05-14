{ %NORUN %CHECKBIN_HAS=TStripDirForm1,TStripDirButton1,TStripDirPanelMain %CHECKBIN_LACKS=TStripDirOther1 }
program striprtti_directive_01;

{$mode unleashed}
{$modeswitch striprtti}
{$rttiexpose TStripDirForm* TStripDirButton*}
{$rttiexpose TStripDirPanel*, TStripDirLabel*}

type
  TStripDirForm1     = class(TObject) end;
  TStripDirButton1   = class(TObject) end;
  TStripDirPanelMain = class(TObject) end;
  // not in any wildcard expose, must be stripped
  TStripDirOther1    = class(TObject) end;

begin
  with TStripDirForm1.Create do Free;
  with TStripDirButton1.Create do Free;
  with TStripDirPanelMain.Create do Free;
  with TStripDirOther1.Create do Free;
end.
