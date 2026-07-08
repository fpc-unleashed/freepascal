{ %OPT="-O4 -OoJUMPTHREAD" %CHECKBIN_LACKS=JTDEADZZZ }
{$mode objfpc}
{ Evidence test: the else-arm of the nested re-test is unreachable once the
  dominating y>10 proves y>5, so jump threading deletes it and its unique
  string literal 'JTDEADZZZ' must be absent from the binary. }
program jt_evidence;
function f(y: longint): longint;
begin
  result:=0;
  if y>10 then
    begin
      if y>5 then result:=1 else writeln('JTDEADZZZ');   { else is dead -> folded away }
    end;
end;
begin
  writeln(f(ParamCount+50));
end.
