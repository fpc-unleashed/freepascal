{ %NORUN }
program auto_properties_dispinterface_property_21;

{$mode delphi}{$H+}

// regression: a dispinterface property carries a dispid, not an auto-property
// initializer; the synthesis path must leave dispinterfaces untouched. mirrors
// stdole2.pas, which crashed the compiler before the fix
type
  IFoo = dispinterface
    ['{D1E2C3B4-A5F6-4789-90AB-CDEF01234567}']
    property foo: WideString dispid 0;
    property bar: Integer dispid 2;
    property baz: WordBool dispid 3;
  end;

begin
end.
