{$mode objfpc}

function FirstDWord(constref Value): UInt32;
var
  DWordValue: UInt32 absolute Value;
begin
  Result := DWordValue;
end;

function FirstByteAsDWord(constref Values): UInt32;
var
  Bytes: array[Byte] of Byte absolute Values;
begin
  Result := FirstDWord(Bytes[0]);
end;

var
  Data: array[Byte] of Byte;

begin
  Data[0] := $78;
  Data[1] := $56;
  Data[2] := $34;
  Data[3] := $12;
  if FirstByteAsDWord(Data) <> $12345678 then
    Halt(1);
end.
