// compile-time fold of `DWORD('abcd')`-style typecasts (stringordcast)
// verifies untyped const, typed const, global var initializer and inline-var
// all produce ordconstn; in-memory byte layout matches source order on any target

{$mode unleashed}
{$warn 6018 off} // unreachable code - constants fold at compile time

const
  cByte     = byte('A');                // 1-byte unsigned
  cShortint = shortint('B');            // 1-byte signed
  cWord     = word('HI');               // 2-byte unsigned
  cSmallint = smallint('no');           // 2-byte signed
  cDword    = dword('abcd');            // 4-byte unsigned
  cLongint  = longint('ABCD');          // 4-byte signed
  cCardinal = cardinal('RIFF');         // 4-byte unsigned alias
  cQword    = qword('12345678');        // 8-byte unsigned
  cInt64    = int64('abcdefgh');        // 8-byte signed
  cHex      = dword(#$DE#$AD#$BE#$EF);  // hex-encoded char literals
  cSingle   = byte(#65);                // single-char #-literal

var
  gDword: dword = dword('abcd');
  gQword: qword = qword('12345678');

// checks that N bytes starting at @actual equal the expected source sequence
// target endianness does not matter, byte layout is what stringordcast guarantees
procedure expect(var actual; const expected: array of byte; code: longint);
var
  i: longint;
begin
  for i:=0 to high(expected) do
    if pbyte(@actual)[i]<>expected[i] then halt(code);
end;

procedure check_inline;
begin
  var a := dword('abcd');
  var b: word := word('HI');
  expect(a, [$61,$62,$63,$64], 1);
  expect(b, [$48,$49],         2);
end;

begin
  // copy untyped consts into typed vars so their byte layout can be inspected
  var b1: byte     := cByte;
  var b2: shortint := cShortint;
  var w1: word     := cWord;
  var w2: smallint := cSmallint;
  var d1: dword    := cDword;
  var d2: longint  := cLongint;
  var d3: cardinal := cCardinal;
  var q1: qword    := cQword;
  var q2: int64    := cInt64;
  var d4: dword    := cHex;
  var b3: byte     := cSingle;

  expect(b1, [$41],                                 10);
  expect(b2, [$42],                                 11);
  expect(w1, [$48,$49],                             12);
  expect(w2, [$6E,$6F],                             13);
  expect(d1, [$61,$62,$63,$64],                     14);
  expect(d2, [$41,$42,$43,$44],                     15);
  expect(d3, [$52,$49,$46,$46],                     16);
  expect(q1, [$31,$32,$33,$34,$35,$36,$37,$38],     17);
  expect(q2, [$61,$62,$63,$64,$65,$66,$67,$68],     18);
  expect(d4, [$DE,$AD,$BE,$EF],                     19);
  expect(b3, [$41],                                 20);

  expect(gDword, [$61,$62,$63,$64],                 30);
  expect(gQword, [$31,$32,$33,$34,$35,$36,$37,$38], 31);

  check_inline;
end.
