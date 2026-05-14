{ %NORUN }
program expose_without_modeswitch_no_op_01;

{$mode unleashed}

// `expose` keyword is gated on m_unleashed (always available in unleashed mode).
// Without {$modeswitch striprtti} the keyword is a no-op for the binary,
// but it still must compile cleanly so that turning striprtti off in a
// debug build doesn't break code carrying `expose` annotations.
type
  expose TPoint = record
    x, y: Integer;
  end;

  expose TForm1 = class
  end;

var
  pt: TPoint;
begin
  pt.x := 1;
  pt.y := 2;
  with TForm1.Create do Free;
end.
