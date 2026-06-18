# Out-Variables

Declare a variable inline at an `out`-argument position, or discard the result, instead of pre-declaring a throwaway variable for every output. Inline `var x` binds the output; `_` discards it.

```pas
function TryParse(s: string; out value: integer): boolean; ...

if TryParse('42', var n) then       // `n` is declared here, type inferred
  Writeln(n);                       // and stays in scope afterwards

GetCursorPos(_);                    // result not wanted: discard it
```

Feature gated by modeswitch `OUTVAR`, enabled by default in `{$mode unleashed}`.

## `var x` - inline out-variable

At an `out` argument, `var name` declares a fresh variable whose type is taken from the matched `out` parameter. The variable lands in the enclosing block (the same scope an ordinary inline `var` would get) and is live from the call onward:

```pas
procedure SplitName(full: string; out first, last: string); ...

SplitName('Ada Lovelace', var fn, var ln);
Writeln(fn);                        // Ada
Writeln(ln);                        // Lovelace
```

No type annotation is written or allowed - the type is always inferred from the parameter. The variable behaves like any local from then on: assignable, addressable, captured by closures, finalized at scope end.

`_` is a valid Pascal identifier, so `var _` is not special: it declares a variable literally named `_`, exactly as `var x` declares `x`.

## `_` - discard

A bare `_` at an `out` argument throws the value away. The call still runs; the compiler passes a hidden local that nobody can name:

```pas
// only the boolean result matters, not the position
if Pos2('x', s, _) then ...

// run the call for its side effects, drop the out value
GetState(_);
```

`_` is the same "don't care" marker unleashed already uses for tuple destructuring (`var (x, _, z) := t`) and match wildcards.

### A declared `_` always wins

`_` counts as a discard only when no identifier `_` is in scope. If one exists - a local, a field, a global from a used unit - `_` means that variable, everywhere, in every parameter position:

```pas
var _: integer;
...
GetValue(_);                        // writes into the variable `_`
Writeln(_);                         // prints it
```

This keeps the feature backward compatible: code that declares `_` compiles and behaves identically with the modeswitch on or off.

### No discard at intrinsics

`Write`, `WriteLn`, `Read`, `ReadLn`, `Str` and friends are compiler intrinsics without `out` parameters, so `_` is never a discard there. With no `_` declared it is simply an unknown identifier:

```pas
WriteLn(_);                         // Error: Identifier not found "_"
```

## Where it is allowed

`var x` / `_` are accepted only at an **`out`** parameter. At a `var`, `const`, or value parameter they are rejected:

```pas
procedure ByValue(x: integer);
procedure ByVar(var x: integer);

ByValue(var y);                     // error: not an out parameter
ByVar(var y);                       // error: not an out parameter
```

A `var` parameter is read on entry, so capturing it as a fresh (uninitialised) variable would hide a bug; value / const parameters are inputs, not outputs. The restriction is deliberate.

## Type inference happens after overload resolution

`var x` / `_` carry no type until a candidate is chosen, so they match an `out` parameter of *any* type. If several overloads differ only in that `out` parameter's type, the call is ambiguous:

```pas
procedure Take(out x: integer); overload;
procedure Take(out x: string);  overload;

Take(var y);                        // error: can't determine which overload
```

Pin it down by giving the variable a type through a different argument, or by not overloading on the out type.

## Name collision

`var name` declares a new variable, so reusing a name already visible in scope is a duplicate, exactly as a second ordinary declaration would be:

```pas
var offset: integer;
...
Find(s, sub, var offset);           // error: duplicate identifier "offset"
```

Drop the `var` to pass the existing variable (`Find(s, sub, offset)`), or pick a fresh name.

## Managed types

Captured and discarded out-variables of a managed type (string, dynamic array, interface, Variant) are ordinary locals, so they are initialised on entry and finalised at scope end through the normal mechanism - no leaks, including for `_` discards in a loop:

```pas
procedure Build(out s: string); ...

Build(var text);                    // text finalized at scope end
Writeln(text);

for i := 1 to N do
  Build(_);                         // hidden temp finalized each iteration
```

## Scope

The variable is added to the nearest enclosing block: a routine body, a nested `begin..end`, or the program / unit main block. It is not limited to the single statement - like an inline `var`, it lives to the end of that block:

```pas
procedure Run;
begin
  if Lookup(key, var found) then    // `found` declared in Run's body
    Use(found);
  Writeln(found);                   // still in scope here
end;
```

## How it works

The parser turns `var x` / `_` into a load of a placeholder local (created with an error type) and flags the call argument. Overload matching treats a flagged argument as an exact match for an `out` parameter of any type and a non-match for anything else. Once a candidate wins, binding sets the placeholder's type to the chosen `out` parameter's type and re-checks the load. The flag is cleared at that point, so it never reaches code generation or a `.ppu`.

## Want it off?

```pas
{$mode unleashed}
{$modeswitch outvar-}

GetCursorPos(var p);                // syntax error: `var` not valid here
```

Outside unleashed (or with the switch off) `var` / `_` at an argument are not recognized, so existing code is never affected - the feature is purely opt-in.
