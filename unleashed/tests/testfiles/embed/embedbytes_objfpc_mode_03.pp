program embedbytes_objfpc_mode_03;
{$mode objfpc}{$H+}

// the directives are mode-agnostic and emit standard `array[0..N-1] of byte`,
// so the const must compile outside unleashed mode too
{$embedbytes data 'embedbytes_objfpc_mode_03.pp'}
{$embedstr   text 'embedbytes_objfpc_mode_03.pp'}

begin
  if length(data) < 100 then halt(1);
  if length(text) <> length(data) then halt(2);
  if data[0] <> ord('p') then halt(3);
end.
