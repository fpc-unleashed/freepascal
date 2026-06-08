program incfile_length_matches_size_02;
{$mode unleashed}

uses
  SysUtils;

{$incfile src 'incfile_length_matches_size_02.pp'}

var
  f: file;
  diskSize: Int64;
begin
  Assign(f, 'incfile_length_matches_size_02.pp');
  Reset(f, 1);
  diskSize := FileSize(f);
  Close(f);
  if length(src) <> diskSize then halt(1);
end.
