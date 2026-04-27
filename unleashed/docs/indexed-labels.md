# Indexed Labels

Declare arrays of labels and jump to them by index or string key. Useful for dispatch tables and state machines.

Always available when `{$goto on}` is active. No modeswitch required.

## Numeric range syntax

```pas
label state[0..4];
```

Declares labels `state$0` through `state$4` internally. Use them with constant or variable indices:

```pas
goto state[0]; // jump to state$0

state[0]: writeln('state 0');
state[1]: writeln('state 1');
state[2]: writeln('state 2');
state[3]: writeln('state 3');
state[4]: writeln('state 4');
```

## String key syntax

```pas
label action['start', 'stop', 'reset'];
```

Declares labels keyed by string. Jump with a string constant:

```pas
goto action['start'];

action['start']: writeln('starting');
action['stop']:  writeln('stopping');
action['reset']: writeln('resetting');
```

## Variable index

When the index is a variable (not a compile-time constant), the compiler generates a case dispatch that jumps to the correct label. Requires an explicit `label` declaration with a range:

```pas
label state[0..4];
var n: integer;

n := 2;
goto state[n]; // dispatches via case statement
```

Variable indices only work with numeric ranges, not string keys.

## Ordinal index types

The index range can use any ordinal type:

```pas
type TMode = (mFast, mSlow, mIdle);

label handler[mFast..mIdle];

goto handler[mode];

handler[mFast]: writeln('fast');
handler[mSlow]: writeln('slow');
handler[mIdle]: writeln('idle');
```

## Constant expressions

Compile-time constant expressions in the index resolve to a direct jump with zero overhead:

```pas
label state[0..9];

const base = 3;
goto state[base + 1]; // resolves to goto state$4 at compile time
```

# Lazy Label Declarations

Standard Pascal requires all labels to be declared in a `label` section before use. Unleashed mode relaxes this: if a `goto` references a label name that has not been declared, the compiler creates the label automatically.

```pas
{$goto on}
procedure Foo;
begin
  goto done;       // no prior "label done;" needed
  writeln('skip');
done:
  writeln('end');
end;
```

## Lazy labels with constant index

Lazy labels also work with constant-index gotos. The compiler auto-declares the individual label targets as they are encountered:

```pas
{$goto on}
procedure Bar;
begin
  goto step[1]; // auto-declares label "step$1"

step[0]: writeln('zero');
step[1]: writeln('one');
step[2]: writeln('two');
end;
```

## Limitations

- Variable-index goto (`goto name[variable]`) requires an explicit `label name[lo..hi]` declaration. Lazy labels do not create the range information needed for variable dispatch.
- String-key labels always require an explicit `label` declaration with the key list.

## Scope

Lazy labels follow the same scoping rules as explicitly declared labels. They are visible within the entire procedure body.
