{ %OPT=-O3 }

{ x86_64: the zero-upper-32 peephole scan kept substituting the source
  register for the target after an instruction partially wrote the target,
  so the snapshot compare in test() read the wrong register at -O3.

  The try-finally keeps the loop counter out of a regvar, which produces
  the mov+and pair that arms the scan; the hufWriteDesc call chain is
  needed for register pressure. Do not reduce further. }

program tw41813;

{$mode objfpc}
{$modeswitch advancedrecords}

type
  TFseEnc = record
    accLog: Integer;
    stateTab: array of Word;          // rank -> next state value
    dBits: array of Integer;          // per symbol
    dState: array of Integer;
  end;

  TForwBits = record
    dst: PByte;
    at: SizeInt;
    acc: QWord;
    cnt: Integer;
    procedure Open(adst: PByte; start: SizeInt);
    procedure Put(v: LongWord; n: Integer); inline;
    procedure Flush; inline;
    procedure Close;             // sentinel + zero pad to byte
  end;

const
  HUF_MAXBITS = 11;

procedure TForwBits.Open(adst: PByte; start: SizeInt);
begin
  dst := adst;
  at := start;
  acc := 0;
  cnt := 0;
end;

procedure TForwBits.Put(v: LongWord; n: Integer);
begin
  acc := acc or (QWord(v and ((QWord(1) shl n) - 1)) shl cnt);
  Inc(cnt, n);
  Flush;
end;

procedure TForwBits.Flush;
begin
  // whole dwords at a time; the byte tail is Close's job
  while cnt >= 32 do begin
    PLongWord(dst + at)^ := LongWord(acc);
    Inc(at, 4);
    acc := acc shr 32;
    Dec(cnt, 32);
  end;
end;

procedure TForwBits.Close;
begin
  Put(1, 1);
  while cnt > 0 do begin
    dst[at] := Byte(acc);
    Inc(at);
    acc := acc shr 8;
    Dec(cnt, 8);
  end;
  acc := 0;
  cnt := 0;
end;

function bitTop(v: LongWord): Integer; inline;
begin
  result := BsrDWord(v);
end;

{ scale raw counts to a power-of-two total; -1 marks "less than 1" }
function fseNormalize(const count: array of LongWord; total: SizeInt; nSym, accLog: Integer; out norm: array of SmallInt): Boolean;
var
  size, left, lowT, big, bigSym: Integer;
  n, s, s2, pick: Integer;
begin
  result := false;
  size := 1 shl accLog;
  left := size;
  lowT := total shr accLog;
  big := -1;
  bigSym := -1;
  for s := 0 to nSym - 1 do begin
    norm[s] := 0;
    if count[s] = 0 then continue;
    if Integer(count[s]) <= lowT then begin
      norm[s] := -1;
      Dec(left);
    end
    else begin
      n := (QWord(count[s]) * size) div QWord(total);
      if n = 0 then n := 1;
      norm[s] := n;
      Dec(left, n);
      if Integer(count[s]) > big then begin
        big := count[s];
        bigSym := s;
      end;
    end;
  end;
  if bigSym < 0 then exit;            // nothing above the low threshold
  if left > 0 then
    norm[bigSym] := norm[bigSym] + left
  else
    while left < 0 do begin
      // shave overflow off the heaviest entries, never below 1
      pick := -1;
      for s2 := 0 to nSym - 1 do
        if (norm[s2] > 1) and ((pick < 0) or (norm[s2] > norm[pick])) then
          pick := s2;
      if pick < 0 then exit;
      norm[pick] := norm[pick] - 1;
      Inc(left);
    end;
  result := true;
end;

function fseBuildEnc(var e: TFseEnc; const norm: array of SmallInt; nSym, accLog: Integer): Boolean;
var
  size, hiCells, pos, step, mask, total: Integer;
  spread: array of Byte;
  cumul: array[0..256] of Integer;
  freq: Integer;
  s, i, u, sp, mb: Integer;
begin
  result := false;
  size := 1 shl accLog;
  e.accLog := accLog;
  SetLength(e.stateTab, size);
  SetLength(e.dBits, nSym);
  SetLength(e.dState, nSym);
  SetLength(spread, size);
  // mirror of the decoder's layout: low-prob symbols park at the top
  hiCells := 0;
  for s := 0 to nSym - 1 do
    if norm[s] = -1 then begin
      Inc(hiCells);
      spread[size - hiCells] := s;
    end;
  step := (size shr 1) + (size shr 3) + 3;
  mask := size - 1;
  pos := 0;
  for s := 0 to nSym - 1 do
    for i := 1 to norm[s] do begin
      spread[pos] := s;
      repeat
        pos := (pos + step) and mask;
      until pos < size - hiCells;
    end;
  if pos <> 0 then exit;
  // rank -> state mapping
  cumul[0] := 0;
  for s := 0 to nSym - 1 do begin
    freq := norm[s];
    if freq < 0 then freq := 1;
    cumul[s + 1] := cumul[s] + freq;
  end;
  for u := 0 to size - 1 do begin
    sp := spread[u];
    e.stateTab[cumul[sp]] := size + u;
    Inc(cumul[sp]);
  end;
  // per-symbol transforms
  total := 0;
  for s := 0 to nSym - 1 do begin
    case norm[s] of
      0: begin
        e.dBits[s] := ((accLog + 1) shl 16) - size;  // never used
        e.dState[s] := 0;
      end;
      -1, 1: begin
        e.dBits[s] := (accLog shl 16) - size;
        e.dState[s] := total - 1;
        Inc(total);
      end;
      else begin
        mb := accLog - bitTop(norm[s] - 1);
        e.dBits[s] := (mb shl 16) - (norm[s] shl mb);
        e.dState[s] := total - norm[s];
        Inc(total, norm[s]);
      end;
    end;
  end;
  result := true;
end;

function fseEncInit(const e: TFseEnc; sym: Integer): Integer; inline;
var
  nb: Integer;
begin
  nb := (e.dBits[sym] + 32768) shr 16;
  result := e.stateTab[(((nb shl 16) - e.dBits[sym]) shr nb) + e.dState[sym]];
end;

procedure fseEncPush(const e: TFseEnc; var bw: TForwBits; var state: Integer; sym: Integer); inline;
var
  nb: Integer;
begin
  nb := (state + e.dBits[sym]) shr 16;
  bw.Put(state, nb);
  state := e.stateTab[(state shr nb) + e.dState[sym]];
end;

procedure fseEncFlush(const e: TFseEnc; var bw: TForwBits; state: Integer); inline;
begin
  bw.Put(state, e.accLog);
end;

{ serialize huffman weights (the final weight is implied); nW is the
  count of written weights; returns bytes or 0 when not encodable }
function hufWriteDesc(const weights: array of Byte; nW: Integer; dst: PByte): SizeInt;
var
  wCount: array[0..15] of LongWord;
  wNorm: array[0..15] of SmallInt;
  enc: TFseEnc;
  bw: TForwBits;
  accLog, maxW, distinctW: Integer;
  directLen, s1, s2, i, w: Integer;
  fseBody: array[0..511] of Byte;
  descLen: SizeInt;
begin
  result := 0;
  for w := 0 to 15 do wCount[w] := 0;
  maxW := 0;
  for i := 0 to nW - 1 do begin
    Inc(wCount[weights[i]]);
    if weights[i] > maxW then maxW := weights[i];
  end;
  directLen := 1 + (nW + 1) div 2;
  // fse-compressed weights, two interleaved states
  if nW >= 2 then begin
    distinctW := 0;
    for w := 0 to maxW do
      if wCount[w] > 0 then Inc(distinctW);
    accLog := 6;
    while (1 shl (accLog - 1)) > nW do Dec(accLog);
    if accLog < 5 then accLog := 5;
    if (distinctW >= 2) and
      fseNormalize(wCount, nW, maxW + 1, accLog, wNorm) then begin
      descLen := 1;
      if fseBuildEnc(enc, wNorm, maxW + 1, accLog) then begin
        bw.Open(@fseBody[0], descLen);
        if odd(nW) then begin
          s1 := fseEncInit(enc, weights[nW - 1]);
          s2 := fseEncInit(enc, weights[nW - 2]);
        end
        else begin
          s2 := fseEncInit(enc, weights[nW - 1]);
          s1 := fseEncInit(enc, weights[nW - 2]);
        end;
        for i := nW - 3 downto 0 do
          if odd(i) then
            fseEncPush(enc, bw, s2, weights[i])
          else
            fseEncPush(enc, bw, s1, weights[i]);
        fseEncFlush(enc, bw, s2);
        fseEncFlush(enc, bw, s1);
        bw.Close;
        if (bw.at <= 127) and (1 + bw.at < directLen) then begin
          dst[0] := Byte(bw.at);
          Move(fseBody[0], dst[1], bw.at);
          exit(1 + bw.at);
        end;
      end;
    end;
  end;

end;

procedure test;
var
  count: array[0..255] of LongWord;
  hlen: array[0..255] of Byte;
  code: array[0..255] of Word;
  weights: array[0..255] of Byte;
  codeSnap: array[0..255] of Word;
  hlenSnap: array[0..255] of Byte;
  pHufLen: array[0..255] of Byte;
  pHufCode: array[0..255] of Word;
  treeDesc: array[0..400] of Byte;
  maxBits, lastSym: Integer;
  treeLen: SizeInt;
  s: Integer;
  bitsOld, bitsNew: QWord;
  oldOk: Boolean;
begin
  try
    for s := 0 to 255 do begin
      pHufLen[s] := 8;
      pHufCode[s] := Word(s);
    end;
    for s := 0 to 255 do count[s] := LongWord(s mod 5);
    lastSym := 64;
    for s := 0 to lastSym do hlen[s] := 1 + (s mod 10);
    maxBits := 11;
    for s := 0 to 255 do code[s] := Word(s * 3);
    treeLen := hufWriteDesc(hlen, lastSym, @treeDesc[0]);
    if treeLen <= 0 then exit;
    begin
      bitsOld := 0;
      bitsNew := QWord(treeLen) * 8;
      oldOk := true;
      for s := 0 to lastSym do
        if count[s] > 0 then begin
          if pHufLen[s] = 0 then begin
            oldOk := false;
            break;
          end;
          bitsOld := bitsOld + QWord(count[s]) * pHufLen[s];
          bitsNew := bitsNew + QWord(count[s]) * hlen[s];
        end;
      if oldOk and (bitsOld <= bitsNew) then treeLen := 0;
    end;
    Move(code[0], codeSnap[0], 512);
    Move(hlen[0], hlenSnap[0], 256);
    for s := 0 to 255 do
      if (code[s] <> codeSnap[s]) or (hlen[s] <> hlenSnap[s]) then begin
        writeln('CLOBBER sym=', s, ': code=', code[s], ' snap=', codeSnap[s], ' hlen=', hlen[s], ' hsnap=', hlenSnap[s]);
        Halt(2);
      end;
    writeln('no clobber');
  finally
  end;
end;

begin
  test;
end.
