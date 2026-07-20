program composable_records_method_body_flat_field_01;

{ bare access to union-flattened fields from inside a method body:
  named array variant, inline packed anon record, and embed }

{$mode unleashed}

type
  TFoo = packed record align 8
  private
    procedure SetIt;
  public
    union
      Value: QWord;
      Bytes: array[8] of Byte;
    end;
  end;

  TBar = packed record align 8
  private
    procedure SetIt;
  public
    union
      Value: QWord;
      packed record
        b0, b1, b2, b3, b4, b5, b6, b7: Byte;
      end;
    end;
  end;

  TBaz = packed record align 8
  private
  type
    _Bytes = packed record
      b0, b1, b2, b3, b4, b5, b6, b7: Byte;
    end;
    procedure SetIt;
  public
    union
      Value: QWord;
      embed _Bytes;
    end;
  end;

procedure TFoo.SetIt; begin Bytes[0] := $AA; end;
procedure TBar.SetIt; begin b0 := $BB; end;
procedure TBaz.SetIt; begin b0 := $CC; end;

var
  f: TFoo;
  b: TBar;
  z: TBaz;
begin
  f.Value := 0; f.SetIt;
  if f.Value <> $AA then halt(1);
  b.Value := 0; b.SetIt;
  if b.Value <> $BB then halt(2);
  z.Value := 0; z.SetIt;
  if z.Value <> $CC then halt(3);
end.
