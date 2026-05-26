{ %FAIL }
program composable_records_fail_generic_embed_type_param_01;

{$mode unleashed}

type
  { per the doc: embedding a generic type parameter is rejected at
    the declaration site - the parser sees a non-record typesym and
    raises the "Record type expected after embed" diagnostic.
    Workaround: use a named subfield `item: T` instead. }
  TBad<T> = record
    embed T;
  end;

begin
end.
