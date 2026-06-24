program embedstr_length_matches_size_03;
{$mode unleashed}

uses
  SysUtils;

{$embedstr src 'embedstr_length_matches_size_03.pp'}

var
  f: file;
  diskSize: Int64;
begin
  Assign(f, 'embedstr_length_matches_size_03.pp');
  Reset(f, 1);
  diskSize := FileSize(f);
  Close(f);
  if length(src) <> diskSize then halt(1);
end.
