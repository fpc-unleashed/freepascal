# Out-Variables

Declare a variable inline at an `out`-argument position, or discard the output, instead of pre-declaring a throwaway local for every output. `var x` at the argument binds the output to a fresh variable; `_` throws it away.

```pascal
function TryParse(s: string; out value: integer): boolean; ...

if TryParse('42', var n) then       // n declared here, type inferred
  writeln(n);                       // and stays in scope afterwards

GetCursorPos(_); // value not wanted: discard it
```

Modeswitch: `outvar`, enabled by default in `{$mode unleashed}`.

## `var x` - inline out-variable

At an `out` argument, `var name` declares a fresh variable whose type is taken from the matched `out` parameter. The variable lands in the nearest enclosing block (the same scope an ordinary inline `var` would get) and is live from the call onward:

```pascal
procedure SplitName(full: string; out first, last: string); ...

SplitName('Ada Lovelace', var fn, var ln);
writeln(fn);                        // Ada
writeln(ln);                        // Lovelace
```

No type annotation is written or allowed - the type is always inferred from the parameter. The variable behaves like any local from then on: assignable, addressable, captured by closures, finalized at scope end.

`_` is a valid Pascal identifier, so `var _` is not special: it declares a variable literally named `_`, exactly as `var x` declares `x`.

## `_` - discard

A bare `_` at an `out` argument throws the value away. The call still runs; the compiler passes a hidden local that nobody can name:

```pascal
// only the boolean result matters, not the position
if Pos2('x', s, _) then ...

// run the call for its side effects, drop the out value
GetState(_);
```

`_` is the same "don't care" marker unleashed already uses in tuple destructuring (`var (x, _, z) := t`) and match wildcards.

### A declared `_` always wins

`_` counts as a discard only when no identifier `_` is in scope. If one exists - a local, a field, a global from a used unit - `_` means that variable, everywhere, in every parameter position:

```pascal
var _: integer;
...
Fill(_);                            // writes into the variable _
writeln(_);                         // prints it
```

This keeps the feature backward compatible: code that declares `_` compiles and behaves identically with the modeswitch on or off. Note the flip side: with an `integer` variable `_` in scope, `_` at a `string` out parameter is now a type error, not a discard.

### No discard at intrinsics

`Write`, `Read`, `Str()`, `Val()` and the other compiler intrinsics have no true `out` parameters, so `_` is never a discard there. With no `_` declared it is simply an unknown identifier:

```pascal
writeln(_);                         // Error: Identifier not found "_"
Val(s, _, code);                    // Error: Identifier not found "_"
```

## Where it is allowed

`var x` / `_` are accepted only at an **`out`** parameter. At `var`, `const`, and value parameters the placeholder does not match, so the call fails overload matching (for a `var` parameter: `Call by var for arg no. N has to match exactly: Got "<erroneous type>" expected "T"`):

```pascal
procedure byVar(var x: integer);

byVar(var y); // rejected - not an out parameter
```

The restriction is deliberate: a `var` parameter is read on entry, so capturing it as a fresh uninitialized variable would hide a bug; value / `const` parameters are inputs, not outputs.

## Type inference happens after overload resolution

`var x` / `_` carry no type until a candidate is chosen, so they match an `out` parameter of *any* type. If overloads differ only in that `out` parameter's type, the call is ambiguous:

```pascal
procedure Take(out x: integer); overload;
procedure Take(out x: string); overload;

Take(var y); // Error: Can't determine which overloaded function to call
```

Pin it down through another argument, or do not overload on the out type alone.

## Name collision

`var name` is a real declaration, so a name already visible in scope is a duplicate:

```pascal
var offset: integer;
...
Find(s, sub, var offset); // Error: Duplicate identifier "offset"
```

Drop the `var` to pass the existing variable (`Find(s, sub, offset)`), or pick a fresh name.

## Managed types

Captured and discarded out-variables of a managed type (string, dynamic array, interface, `Variant`) are ordinary locals: initialized on entry, finalized at scope end through the normal mechanism. Discards in a loop finalize per iteration - no leaks:

```pascal
procedure Build(out s: string); ...

Build(var text);                    // text finalized at scope end
for i := 1 to n do
  Build(_);                         // hidden temp finalized each pass
```

## Scope

The variable is added to the nearest enclosing block: a routine body, a nested `begin..end`, or the program main block. Like an inline `var`, it lives to the end of that block, not just the one statement:

```pascal
procedure run;
begin
  if lookup(key, var found) then use(found);
  writeln(found); // still in scope here
end;
```

## How it works

The parser turns `var x` / `_` into a load of a placeholder local (created with an error type) and flags the call argument. Overload matching treats a flagged argument as an exact match for an `out` parameter of any type and a non-match for anything else. Once a candidate wins, binding sets the placeholder's type to the chosen `out` parameter's type and re-checks the load. The flag is cleared at that point, so it never reaches code generation or a PPU.

## Want it off?

```pascal
{$mode unleashed}
{$modeswitch outvar-}

GetCursorPos(var p); // no longer recognized - syntax error
```

Outside unleashed (or with the switch off) `var` / `_` at an argument are not recognized, so existing code is never affected - the feature is purely opt-in.

## Demo

```pascal
program out_var_demo;

{$mode unleashed}

uses SysUtils;

procedure splitAt(const s: string; sep: char; out head, tail: string);
begin
  var p := Pos(sep, s);
  if p = 0 then begin
    head := s;
    tail := '';
  end else begin
    head := Copy(s, 1, p-1);
    tail := Copy(s, p+1, Length(s));
  end;
end;

begin
  // declare receivers right at the call
  splitAt('width=1920', '=', var key, var value);
  if TryStrToInt(value, var w) then writeln($'{key} -> {w} (as integer)');

  // only care whether it parses - discard the value
  if TryStrToInt('oops', _) then writeln('parsed') else writeln('not a number');

  // the variables are ordinary locals from here on
  w += 80;
  writeln($'padded: {w}');
  {$ifdef WINDOWS}readln;{$endif}
end.
```

Output:

```
width -> 1920 (as integer)
not a number
padded: 2000
```
