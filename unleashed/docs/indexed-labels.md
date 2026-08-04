# Indexed Labels and Lazy Labels

Two extensions to `label` / `goto`. **Indexed labels** declare a whole family of labels under one name, keyed by ordinal values or strings, and jump to them by index - including a runtime index, which compiles to a case dispatch. **Lazy labels** drop the declaration requirement entirely: a `goto` to an undeclared name simply creates the label.

Availability:

- Indexed labels: every mode, whenever goto support is active (`{$goto on}` / `-Sg`; automatic in `{$mode unleashed}`). No modeswitch.
- Lazy labels: `{$mode unleashed}` only.

## Indexed labels

### Numeric ranges

```pascal
label state[0..4];

goto state[2];

state[0]: writeln('zero');
state[1]: writeln('one');
state[2]: writeln('two');
state[3]: writeln('three');
state[4]: writeln('four');
```

`label state[0..4]` declares five labels addressed as `state[0]` .. `state[4]`. As with plain labels, control falls through from one label to the next unless you jump away.

### Value lists, whole types, constant expressions

The index spec accepts more than a plain range - explicit value lists, a whole ordinal type, constant expressions, and mixes of all of them:

```pascal
label steps[1, 2, 3];     // explicit value list
label bits[byte];         // whole ordinal type: 0..255
label edge[0..3-1];       // constant expressions fold: 0..2
label mix[1..3, 7];       // ranges and values mix
```

The index spec is always a set of *values*, never a count. A single value in brackets is a one-element value list: `label mylabel[256]` declares exactly one label, `mylabel[256]` - not 256 labels. To declare 256 labels indexed from zero, write `label mylabel[0..255]` or `label mylabel[byte]`.

Declared labels that are never defined are fine - `label bits[byte]` declares 256 potential targets and you define only the ones you use. Constant indices in `goto` fold at compile time to a direct jump with zero overhead:

```pascal
const BASE = 3;
goto steps[BASE-1]; // resolves to a direct jump to steps[2]
```

### Ordinal index types

Any ordinal type works as the key space, enums included:

```pascal
type TMode = (mFast, mSlow, mIdle);

label handler[mFast..mIdle];

goto handler[mode]; // mode: TMode, runtime dispatch

handler[mFast]: ...
handler[mSlow]: ...
handler[mIdle]: ...
```

### String keys

```pascal
label action['start', 'stop', 'reset'];

goto action['start'];

action['start']: writeln('starting');
action['stop']:  writeln('stopping');
action['reset']: writeln('resetting');
```

String keys are case-insensitive: `goto action['START']` jumps to `action['start']`. Only constant strings work - a string key is resolved entirely at compile time.

### Variable index: runtime dispatch

When the index is a runtime value, the compiler generates a hidden case statement that jumps to the matching label:

```pascal
label state[0..4];
var n: integer;

n := 2;
goto state[n]; // lowered to: case n of 0: goto state[0]; ... end
```

A variable index requires an explicit `label` declaration with an ordinal range - the declaration is what tells the compiler the full target set. Without it the goto reports `Error: Label not found`. String-keyed labels never take a variable index (their resolution is compile-time only).

The dispatch covers exactly the declared index set. Labels defined outside the declared set (possible in `{$mode unleashed}` through lazy labels) are not reachable through a variable-index `goto` - make sure the declaration spans every index the dispatch may take.

## Lazy labels

In `{$mode unleashed}` a `goto` to an undeclared name creates the label on the spot - no `label` section needed:

```pascal
begin
  goto done;
  writeln('skipped');
done:
  writeln('done');
end;
```

Constant-index gotos are lazy too; each referenced target is auto-declared as it is encountered:

```pascal
goto step[1]; // auto-declares the indexed label family

step[0]: writeln('zero');
step[1]: writeln('one');
```

### Lazy limitations

- A variable-index `goto name[n]` still requires an explicit `label name[lo..hi]` declaration - laziness cannot recover the range needed to build the dispatch table.
- Lazily defined indices do not extend an existing declaration: with `label mylabel[256]` in scope, defining `mylabel[0]:` .. `mylabel[3]:` creates those labels lazily, but a variable-index dispatch is still built from the declared set only.
- String-keyed labels always require an explicit declaration with the key list.

Lazy labels follow the same scoping rules as declared ones: visible in the whole routine body.

## Demo

A bytecode interpreter for a small stack machine. The opcode dispatch is a single variable-index `goto` over an enum-keyed label family - the classic computed-goto interpreter loop, no `case` ladder around the whole body:

```pascal
program indexed_labels_demo;

{$mode unleashed}

type
  TOp = (opPush, opAdd, opMul, opPrint, opHalt);

// tiny stack machine: computed goto dispatches on the current opcode
procedure run(const code: array of integer);
label
  dispatch, op[opPush..opHalt];
var
  stack: array[0..15] of integer;
  sp, pc: integer;
begin
  sp := 0;
  pc := 0;

dispatch:
  var cur := TOp(code[pc]);
  inc(pc);
  goto op[cur]; // runtime dispatch, lowered to a case jump

op[opPush]:
  begin
    stack[sp] := code[pc];
    inc(sp); inc(pc);
    goto dispatch;
  end;
op[opAdd]:
  begin
    dec(sp); stack[sp-1] += stack[sp];
    goto dispatch;
  end;
op[opMul]:
  begin
    dec(sp); stack[sp-1] *= stack[sp];
    goto dispatch;
  end;
op[opPrint]:
  begin
    writeln('top = ', stack[sp-1]);
    goto dispatch;
  end;
op[opHalt]:
  writeln('halted');
end;

begin
  // (2 + 3) * 7 = 35
  run([ord(opPush), 2, ord(opPush), 3, ord(opAdd), ord(opPush), 7, ord(opMul), ord(opPrint), ord(opHalt)]);
  {$ifdef WINDOWS}readln;{$endif}
end.
```

Output:

```
top = 35
halted
```
