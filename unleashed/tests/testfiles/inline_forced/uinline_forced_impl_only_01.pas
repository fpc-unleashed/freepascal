unit uinline_forced_impl_only_01;

{$mode unleashed}

interface

function Bump(x: longint): longint;

implementation

// inline appearing only on the implementation stays a plain hint (mirrors
// stock behavior); the declaration did not bind any callers to it
function Bump(x: longint): longint; inline;
begin
  result := x + 1;
end;

end.
