{ %FAIL }
program labels_fail_single_value_index_01;

{$mode unleashed}

{ a single bare value is not a valid index spec: next to array[256] it reads
  as a count, but an index spec is a set of values - the compiler rejects it
  instead of silently declaring one label foo[256] }

label foo[256];

begin
  foo[256]: writeln('unreachable');
end.
