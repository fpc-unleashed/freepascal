# Tweaks

Small semantic adjustments that make standard Pascal constructs behave the way most people expect them to. None of them have a dedicated modeswitch - they are unleashed-mode-only and turn on with `{$mode unleashed}` (or `-Munleashed`).

If you need the standard semantics for a specific routine, switch the mode locally back to `objfpc`/`delphi`.

## Preserved for-loop counter

In standard Pascal, the value of the for-loop counter after the loop exits is *undefined*. Delphi documents it explicitly and FPC follows the same rule - the optimizer is allowed to leave any value behind, and the generated code typically overshoots the final boundary so the comparison that ends the loop is cheaper.

That bites every time you write something like:

```pascal
for i := 1 to N do
  if X[i] = target then
    break;
if i <= N then
  WriteLn('found at ', i);   // works only by accident on stock FPC
```

### What unleashed mode does

The for-loop counter keeps its last assigned value across the exit:

| Exit path                                        | Value of `i` after the loop |
|--------------------------------------------------|-----------------------------|
| Natural end (`for i := 1 to 10 do ;`)            | `10` (last in-range value)  |
| `break` somewhere in the body                    | the value at break time     |
| `continue` to the natural end                    | last in-range value         |
| Single-iteration range (`for i := 5 to 5 do ;`)  | `5`                         |
| Empty range (`for i := 10 to 1 do ;`)            | unchanged (body never runs, counter never assigned) |
| `downto` natural exit (`for i := 10 downto 1`)   | `1`                         |
| `downto` with break                              | the value at break time     |

The same applies to nested loops - each counter keeps its last value independently:

```pascal
for i := 1 to 3 do
  for j := 100 to 105 do ;
WriteLn(i, ' ', j);   // 3 105
```

### Why standard Pascal does not do this

Stock FPC sets the `lnf_dont_mind_loopvar_on_exit` flag on every for-loop in `mode objfpc` / `mode fpc` / `mode delphi`. The flag tells the code generator that the counter is dead after the loop, which lets it pick whichever exit-condition encoding is cheapest - typically meaning the counter ends up *one past* the last in-range value (`for i := 1 to 10` leaves `i = 11`, not `10`).

In `mac`/`tp` mode the flag is not set, because both languages historically defined the counter to be preserved.

### What unleashed actually changes

Just the parser hook: it stops setting `lnf_dont_mind_loopvar_on_exit` when `m_unleashed` is active. The regular code generator path then keeps the counter at its last assigned value.

Cost: one extra assignment on the natural exit path. Nothing on `break`, `continue`, or `exit`.

### Interaction with `step` (for-step)

The for-step rewrite undoes the last increment before exiting, so the counter holds the **last value the loop actually used**:

```pascal
for i := 1 to 10 step 4 do ;
{ i = 9 (the last value the body would have seen), not 13 }
```

See [forstep.md](forstep.md) for the full description of the `step` clause.

### Want the standard "undefined on exit" semantics back?

Use the mode for the affected routine:

```pascal
{$mode objfpc}
procedure HotLoop;
begin
  for i := 1 to N do { ... };
  // i is undefined here - standard FPC semantics
end;
```

Or split the routine out into a unit compiled in `objfpc`/`delphi`.

## `is not` and `not in` operators

Standard Pascal forces an extra pair of parentheses for negated runtime type checks and set membership tests:

```pascal
if not (Obj is TFoo) then ...
if not (x in [Apple, Orange]) then ...
```

Unleashed mode adds the Delphi-style shorthand forms:

```pascal
if Obj is not TFoo then ...
if x not in [Apple, Orange] then ...
```

Each compiles to exactly the same node tree as the parenthesised form, so semantics, error messages, and runtime cost are unchanged.

### What unleashed actually changes

Just the parser. When the comparison-level expression sees `is` followed by `not`, it consumes both and wraps the resulting `is`-node in a `not`-node. The `not in` form is allowed to appear at the comparison level (where `not` is normally a unary prefix only) and parses the right-hand side as the operand of `in`.

Outside unleashed mode the parser rejects both: `obj is not T` is read as `obj is (not T)` and triggers an operator error, and `x not in S` produces a syntax error at `not`.

## Default-on switches

Three module-level switches that are off by default in `objfpc`/`fpc` are turned on automatically by `{$mode unleashed}`, so the constructs they gate work out of the box:

| Switch              | Directive / flag           | What it enables                                  |
|---------------------|----------------------------|--------------------------------------------------|
| goto support        | `{$goto on}` / `-Sg`       | `label` declarations and `goto`                  |
| C-style operators   | `{$coperators on}` / `-Sc` | `+=`, `-=`, `*=`, `/=` (see [compound-assignment.md](compound-assignment.md)) |
| macros              | `{$macro on}` / `-Sm`      | text-substitution macros (`$define name := value`) |

(`inline` is on too, but that comes from the `objfpc` base mode, not an unleashed addition.)

You can still turn any of them back off locally with the `off` form of the directive, e.g. `{$goto off}`.

### What unleashed actually changes

The mode handler includes `cs_support_goto`, `cs_support_c_operators` and `cs_support_macro` in the module switches whenever `m_unleashed` is set, mirroring how `delphi`/`tp7`/`mac` already default `goto` on.

## Future tweaks

This page is the catalogue for small unleashed-only semantic adjustments. As more of them land, they get appended here with the same shape: what the standard does, what unleashed changes, and how to opt back into the standard when you really need it.
