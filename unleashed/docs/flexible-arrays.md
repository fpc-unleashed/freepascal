# Flexible Array Members

Declare a record with a variable-length tail in C99 style: `data: array[] of T` as the last field. The record header has a fixed size, the tail extends as far as the allocation says it does, and `sizeof(rec)` reports only the fixed part.

Feature gated by modeswitch `FLEXIBLEARRAYS`, enabled by default in `{$mode unleashed}`.

```pas
{$mode objfpc}
{$modeswitch flexiblearrays}
```

## What it does

A flexible array member (FAM) is the last field of a record, declared with empty brackets and no upper bound:

```pas
type
  PMessage = ^TMessage;
  TMessage = packed record
    code:   integer;
    length: integer;
    data:   array[] of byte;   // flexible array member
  end;
```

The record has the same memory layout as one ending after `length`, plus whatever payload you allocate behind it. There is no separate buffer, no pointer chase, no managed lifetime. The compiler does not track the run-time length, so indexing skips both compile-time and runtime range checks even under `{$rangechecks on}`.

## Allocation and use

The record and its tail live in one block. You allocate the fixed part plus payload in a single `GetMem`, write the trailing data through the FAM field by index, and free the whole block in one `FreeMem`:

```pas
var
  msg: PMessage;
  i:   integer;
begin
  GetMem(msg, sizeof(TMessage) + 1024);
  msg^.code   := 42;
  msg^.length := 1024;
  for i := 0 to 1023 do
    msg^.data[i] := byte(i);
  // ... use msg ...
  FreeMem(msg);
end;
```

`sizeof(TMessage)` returns 8 here (just `code` and `length`). The FAM contributes nothing to the static size, so the math at the call site is the obvious `sizeof(rec) + payload`, with no off-by-one for a phantom one-element tail.

## Memory layout

```
            +----------+----------+----------+ ... +----------+
GetMem ---> | code (4) | length(4)| data[0]  |     | data[N]  |
            +----------+----------+----------+ ... +----------+
            ^                     ^
            msg                   msg^.data
            |<-- sizeof(rec) -->|<-- payload bytes -->|
```

The FAM starts at the offset that natural alignment gives the element type after the last fixed field. For `array[] of int64` after a 4-byte field on a 64-bit target, the compiler inserts the usual 4 bytes of padding before the FAM, exactly like for any other field.

## Why a FAM and not the alternatives

Three patterns are commonly used today; each loses something the FAM keeps:

| Pattern                                  | Problem                                                      |
|------------------------------------------|--------------------------------------------------------------|
| `data: array[0..0] of byte` (the C "struct hack") | `{$rangechecks on}` rejects every access past index 0; `sizeof` is one element too large; padding is implicit. |
| `data: PByte` to a separate buffer       | Two allocations, two frees, an extra indirection on every access, breaks single-block layout used by Win32 structures. |
| `case integer of 0: (data: array[0..high(integer)-X] of byte)` | `sizeof` rolls over, `high()` lies, and the compiler has no idea what the actual extent is. |

The FAM gives you the inline layout, honest `sizeof`, working range-check setting, and a single allocation in one feature.

## Restrictions

These are enforced at parse time. Each rule has a dedicated error message (parser_e_fam_*).

1. **The FAM must be the last field of the record.** No fields can follow it.
2. **The record must have at least one preceding field.** A record consisting only of a FAM has no defined layout.
3. **Only one FAM per record, and only one identifier per FAM declaration.** `one, two: array[] of byte` is rejected for the same reason that two FAMs in separate declarations are.
4. **A FAM is allowed only as a plain instance field of a plain `record`.** Not in a `class`, not in an `object`, not as `class var`, not as `threadvar`, not inside a `case` (variant part).
5. **A record containing a FAM cannot be embedded in another structured type.** Use a pointer to the FAM-record as the field type instead.
6. **A record containing a FAM cannot be the element type of an array.** Per-element size would be undefined.
7. **A FAM-record cannot be a stand-alone variable, value parameter, or function result.** Allocate via `GetMem` and use a pointer (`PFamRec`).

Reference parameters (`var`, `const`, `constref`, `out`) of FAM-record type stay legal; they pass an address, no copy is involved. Pointer-to-FAM-record (`PFamRec`) is unrestricted and may appear as a field of any type, an array element, a parameter of any kind, and a function result.

## Use cases

The pattern shows up wherever a fixed header is followed by a variable-length tail in one block of memory:

- **Win32 structures.** `BITMAPINFO`, `LOGPALETTE`, `TOKEN_GROUPS`, `TOKEN_PRIVILEGES`, `SOCKET_ADDRESS_LIST`, `SP_DRVINFO_DETAIL_DATA`, and many more declare a trailing array as `array[0..0]` or `ANYSIZE_ARRAY` today, with all the problems above.
- **Network protocol frames.** TCP/UDP packets, WebSocket frames, MQTT messages, custom IPC payloads, anything where a header carries a length and the body follows in the same block.
- **File formats.** BMP, WAV chunks, custom containers with a header and inline body.
- **Inline strings or buffers in records.** Storing a payload at the tail of a node avoids a second allocation and improves cache locality.

## Comparison with `array of T`

A FAM is not a dynamic array. They share no run-time machinery:

|                       | `array of T` (dynamic array) | `array[] of T` (FAM)         |
|-----------------------|------------------------------|------------------------------|
| Storage               | Heap block referenced by a managed pointer in the record. | Inline tail of the containing record, allocated as one block with the header. |
| Lifetime              | Reference-counted, freed automatically with the containing record. | Manual; freed with the containing block. |
| `SetLength`           | Resizes the underlying block. | Not applicable; size is fixed by the original `GetMem`. |
| `Length(arr)`         | Returns the current element count. | Returns 0 (the static length). The runtime length is whatever you allocated; the compiler does not track it. |
| Range checking        | Runtime check via `fpc_dynarray_rangecheck`. | None. |
| Overhead per record   | One pointer + reference count. | Zero. |

If you want a managed, resizable array that lives elsewhere in memory, use `array of T`. If you want a fixed-shape tail that sits inline behind the record header in one block, use a FAM.

## Compatibility with PPU streams

The FAM flag (`ado_IsFlexibleArray`) is part of `arrayoptions`, which is already streamed in PPU files. A FAM-record declared in one unit and used from another behaves identically to one declared in the same unit, including the `sizeof` value and the disabled range check.

## Limitations

- A FAM-record cannot be passed by value, returned by value, or live on the stack. The compiler does not auto-promote to pointer; you have to write `PFamRec`.
- `Length()` returns 0 for a FAM, not the run-time payload count. Track the count yourself in a fixed field of the record (the typical pattern).
- The compiler does not zero-initialize the FAM tail. Use `FillChar` if you need that.
- No `for elem in fam do ...` enumeration; without a known length the loop has no termination condition.
