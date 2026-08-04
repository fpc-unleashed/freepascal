{ %OPT=-O1 }

{ inline calls inside a finally block used to trip IE 200405231 on SEH
  targets: the finally body is outlined into an exception filter that
  shares the parent's temp allocator, and managed temps created by the
  inlined calls were only discovered after the parent had decided it
  needs no implicit finally frame }

program tw41842;

{$mode objfpc}{$H+}

type
  tbuf = class
    fstart, fposition: pchar;
    destructor destroy; override;
    function getansi: ansistring; inline;
    function getwide: unicodestring; inline;
    function getutf8: string; inline;
    property asansi: ansistring read getansi;
    property aswide: unicodestring read getwide;
    property asutf8: string read getutf8;
  end;

destructor tbuf.destroy;
begin
  freemem(fstart);
  inherited;
end;

function tbuf.getansi: ansistring;
begin
  result:={%H-}aswide;
end;

function tbuf.getwide: unicodestring;
begin
  result:=utf8decode(asutf8);
end;

function tbuf.getutf8: string;
begin
  setstring(result,fstart,fposition-fstart);
end;

function content: ansistring;
var
  buffer: tbuf;
begin
  buffer:=tbuf.create;
  try
    getmem(buffer.fstart,6);
    move('foobar',buffer.fstart^,6);
    buffer.fposition:=buffer.fstart+6;
  finally
    result:=buffer.asansi;
    buffer.destroy;
  end;
end;

begin
  if content<>'foobar' then
    halt(1);
  writeln('ok');
end.
