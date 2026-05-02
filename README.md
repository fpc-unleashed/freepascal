# FPC Unleashed

**FPC Unleashed** is a community-driven fork of **Free Pascal**, focused on pushing the language forward with modern, expressive, and practical features that have not (yet) been accepted into the official compiler.

## Table of Contents

- [Features](#features)
  - [Unleashed Mode](#unleashed-mode)
  - [Statement Expressions](#statement-expressions)
  - [Inline Variables](#inline-variables)
  - [Anonymous Tuples](#anonymous-tuples)
  - [Match Statement](#match-statement)
  - [Multi-Variable Initialization](#multi-variable-initialization)
  - [Scoped Cleanup (defer, autofree, scoped with)](#scoped-cleanup)
  - [Tweaks](#tweaks)
  - [Multiline Strings](#multiline-strings)
  - [Array Equality](#array-equality)
  - [No RTTI](#no-rtti)
  - [Indexed Labels](#indexed-labels)
  - [Lazy Label Declarations](#lazy-label-declarations)
  - [Compound Assignment for Pascal Operators](#compound-assignment-for-pascal-operators)
  - [Extra Improvements](#extra-improvements)
  - [Detailed Documentation](#detailed-documentation)
- [Installation](#installation)
- [Contributing](#contributing)

---

## Features

### Unleashed Mode

**Activate:** `{$mode unleashed}` or `-Munleashed`

A modern Pascal mode based on `objfpc` with powerful enhancements enabled by default. Instead of toggling individual modeswitches, you get everything at once.

When using **[Lazarus Unleashed](https://github.com/fpc-unleashed/lazarus)**, this mode is enabled by default for all projects and full code completion is supported out of the box.

The following modeswitches are enabled automatically:

| Modeswitch                         | Description                                                   |
| ---------------------------------- | ------------------------------------------------------------- |
| `statementexpressions`             | Use `if`, `case`, and `try` as expressions                    |
| `inlinevars`                       | Declare variables inline anywhere inside a `begin..end` block |
| `tuples`                           | Anonymous tuple types, literals, and destructuring            |
| `match`                            | Pattern matching with first-match semantics                   |
| `multivarinit`                     | Initialize several variables of the same type with one value  |
| `anonymousfunctions`               | Anonymous procedures and functions                            |
| `functionreferences`               | Function pointers that capture context                        |
| `advancedrecords`                  | Records with methods, properties, and operators               |
| `arrayoperators` + `arrayequality` | Direct array comparisons with `=` and `<>`                    |
| `ansistrings`                      | Use `AnsiString` as the default string type                   |
| `underscoreisseparator`            | Allow underscores in numeric literals (`1_000_000`)           |
| `duplicatelocals`                  | Allow reusing identifiers in limited scopes                   |
| `multilinestrings`                 | Allow multi-line string literals without manual concatenation |
| `stringordcast`                    | Cast a string literal to an ordinal type (`dword('RIFF')`)    |
| `autofree`                         | `defer STATEMENT`, `autofree EXPR`, scoped `with var x := ...` |

> [!NOTE]
> For the best code-completion experience, we recommend using **[Lazarus Unleashed](https://github.com/fpc-unleashed/lazarus)** - a fork of Lazarus with full support for unleashed mode. If you are using stock Lazarus, enable the mode via `-Munleashed` in the project's Custom Options instead of placing `{$mode unleashed}` directly in the source file, to avoid autocomplete issues and incorrect Code Insight behavior.
---

### Statement Expressions

**Activate:** available in Unleashed mode.

Allows using `if`, `case`, and `try` as **expressions** that return a value, enabling a more functional and concise coding style. All branches must return values of the same type.

#### What it does

Traditionally, `if`, `case`, and `try` are statements - they perform actions but don't produce a value. With statement expressions, they can be used on the right side of an assignment, as function arguments, or anywhere an expression is expected.

#### If expression
```pascal
var
  s: string;
begin
  s := if 0 < 1 then 'Foo' else 'Bar';
  // s = 'Foo'
end.
```

Chained if-expressions work as expected:
```pascal
s := if x > 100 then 'large' else
     if x > 10  then 'medium' else
     'small';
```

Only one branch is evaluated - side effects in the other branch are never triggered:
```pascal
function loadFromDatabase: string;  
begin  
  result := 'data';  
end;

var useCache := false;
var s := if useCache then 'cached' else loadFromDatabase;
// expensive is only called when condition is false
```

#### Case expression
```pascal
type
  TMyEnum = (mefirst, mesecond, melast);
var
  s: string;
begin
  s := case mesecond of
    mefirst:  'Foo';
    mesecond: 'Bar';
    melast:   'FooBar';
  end;
  // s = 'Bar'
end.
```

#### Ranges

```pascal
s := case x of
  0:    'zero';
  1..9: 'single digit';
  else  'large';
```

> [!NOTE]
> When using enums, all values must be covered. Otherwise, the compiler will reject the expression. When using integer or ordinal ranges, provide an `else` clause.

#### Try expression

Evaluates a function call and returns a fallback value if an exception occurs:
```pascal
function conditionalthrow(doraise: boolean): string;
begin
  result := 'OK';
  if doraise then raise TObject.Create;
end;

var
  s: string;
begin
  s := try conditionalthrow(false) except 'Error';
  // s = 'OK'

  s := try conditionalthrow(true) except 'Error';
  // s = 'Error'

  // match specific exception types:
  s := try conditionalthrow(true) except on o: TObject do 'TObject' else 'Error';
  // s = 'TObject'
end.
```

> [!NOTE]
> The `try` expression must contain a function call - `try 'literal' except ...` is not valid.

---

### Inline Variables

**Activate:** available in Unleashed mode.

Declare variables at the point of use inside `begin..end` blocks instead of in a separate `var` section at the top. Supports explicit types and type inference.

#### What it does

In standard Pascal, all variables must be declared in a `var` section before the `begin` keyword. Inline variables let you declare them exactly where they are needed, reducing visual distance between declaration and use, and enabling type inference from the initializer.

#### Basic declarations
```pascal
begin
  // explicit type, no initializer
  var x: integer;
  x := 10;

  // explicit type with initializer
  var y: integer := 42;

  // type inference - compiler deduces integer from the literal
  var z := 100;

  // string inference
  var s := 'hello';

  // multiple variables of the same type
  var a, b: integer;
  a := 1;
  b := 2;
end.
```

#### For loops
```pascal
var
  sum: integer;
begin
  sum := 0;

  // explicit type
  for var i: integer := 1 to 5 do
    sum := sum + i;

  // type inference
  for var j := 1 to 5 do
    sum := sum + j;
end.
```

#### For-in loops
```pascal
var
  arr: array[0..2] of integer = (10, 20, 30);
  sum: integer;
begin
  sum := 0;
  for var item in arr do
    sum := sum + item;
  // sum = 60
end.
```

> [!NOTE]
> Inline variables have the same scope as regular local variables - they are visible from the point of declaration until the end of the enclosing routine. They are not block-scoped.

> [!NOTE]
> Untyped numeric inline variables default to a 32-bit signed integer (`integer`).

---

### Anonymous Tuples

**Activate:** available in Unleashed mode (modeswitch `tuples`).

Lightweight anonymous record types written in parentheses, with literals, destructuring, comparison, and full record semantics (managed types, copy by value, passing by `var`/`const`). Tuples are stored as ordinary internal records, so anything records can do, tuples can do.

#### Positional fields (auto-named `_1`, `_2`, ...)

```pascal
function GetPair: (integer, integer);
begin
  Result := (10, 20);     // positional literal
end;

var
  p: (integer, string) := (42, 'hello');
begin
  writeln(p._1, ' ', p._2);  // 42 hello
  writeln(p[0], ' ', p[1]);  // same, by constant index
end.
```

#### Named fields

```pascal
function Coords: (x, y: integer);
begin
  Exit(x: 10, y: 20);     // shorthand inside Exit
end;
```

#### Destructuring

```pascal
var
  a, b: integer;
begin
  (a, b) := GetPair;       // unpack tuple into existing vars
end.
```

See [unleashed/docs/tuples.md](unleashed/docs/tuples.md) for the full grammar (named/positional mixing, tuple arrays, comparison operators, IDE hints).

---

### Match Statement

**Activate:** available in Unleashed mode (modeswitch `match`).

Pattern matching with first-match semantics. Replaces `case..of` for non-ordinal subjects (tuples, strings, arbitrary expressions) and adds catch-all, fallthrough, condition-based branches, tuple wildcards, and an expression form.

#### Subject form

```pascal
match s of
  'hello': writeln('greeting');
  'bye':   writeln('farewell');
  _:       writeln('unknown');     // catch-all
end;
```

#### Condition form (no `of`)

```pascal
match
  x > 100: writeln('big');
  x > 10:  writeln('medium');
  x > 0:   writeln('small');
  _:       writeln('non-positive');
end;
```

#### Tuple patterns with wildcards

```pascal
var p: (integer, integer) := (0, 5);
match p of
  (0, 0): writeln('origin');
  (0, _): writeln('on Y axis');     // matches
  (_, 0): writeln('on X axis');
  _:      writeln('other');
end;
```

#### Expression form

```pascal
var label_: string := match x of
  1: 'one';
  2: 'two';
  _: 'many';
end;
```

See [unleashed/docs/match.md](unleashed/docs/match.md) for fallthrough mode (`match all`), `leave`, range patterns, and exhaustiveness rules.

---

### Multi-Variable Initialization

**Activate:** available in Unleashed mode (modeswitch `multivarinit`).

Initialize several variables of the same type with a single value in one declaration. Works in `var`, typed constants, and inline `var`. Each variable gets its own independent copy.

```pascal
var
  a, b, c: integer = 42;             // global var
  ok, done: boolean = false;

const
  MinX, MinY, MinZ: integer = 0;     // typed constants

procedure Bar;
begin
  var p, q: integer := 99;           // inline var
  var i, j   := 10;                  // inline var with inference
end;
```

The initializer is evaluated once and copied into each variable; `a := 100` does not affect `b` or `c`. See [unleashed/docs/multi-var-init.md](unleashed/docs/multi-var-init.md) for the full evaluation table.

---

### Scoped Cleanup

**Activate:** available in Unleashed mode (modeswitch `autofree`).

Three cooperating constructs for scope-based resource management without `try..finally` boilerplate.

#### `defer STATEMENT`

Register a statement to fire when the enclosing `begin..end` block exits (normal exit, `exit`, `break`, `continue`, exception). Multiple defers fire in LIFO order. Argument expressions are evaluated at exit, not at registration.

```pascal
procedure CopyFile(const src, dst: string);
begin
  var fin  := TFileStream.Create(src, fmOpenRead);
  defer fin.Free;
  var fout := TFileStream.Create(dst, fmCreate);
  defer fout.Free;

  fout.CopyFrom(fin, 0);
end;
// fout.Free runs first (LIFO), then fin.Free, even if CopyFrom raises
```

#### `autofree EXPR`

Sugar that registers a nil-guarded `Free` defer for a class instance. Works on inline-var declarations and on assignments to existing locals. The cleanup uses `if x<>nil then begin x.Free; x:=nil end`, so manual `x.Free; x := nil;` earlier in the scope does not double-free.

```pascal
procedure foo;
begin
  var list := autofree TStringList.Create;
  list.Add('hello');
  list.Add('world');
  WriteLn(list.Text);
end;
// list.Free called automatically here

// also works on existing variables
var
  a, b: TFoo;
begin
  a := autofree TFoo.Create(1);
  b := autofree TFoo.Create(2);
  // ... use a, b ...
end;
// b.Free, then a.Free (LIFO)
```

The right-hand side must be a class derived from `TObject`. The LHS must be a plain local or inline variable.

#### Scoped `with`

The `with` statement accepts inline-var bindings, with optional `autofree`. Three forms:

```pascal
// inline-var with autofree (cleanup at end of with-scope)
with var http := autofree TFPHTTPClient.Create(nil) do
  s := http.Get('http://httpbin.org/ip');

// bind to an existing local
var http: TFPHTTPClient;
with http := autofree TFPHTTPClient.Create(nil) do
  s := http.Get('http://httpbin.org/ip');

// hidden holder (no name; methods reachable through with-symtable)
with autofree TFPHTTPClient.Create(nil) do
  s := Get('http://httpbin.org/ip');
```

Multi-with works with any combination:

```pascal
with var a := autofree TFoo.Create,
     var b := autofree TBar.Create do
  Use(a, b);
// b.Free, then a.Free
```

`defer` written inside a scoped-with body is scoped to that `with` (fires before the autofree cleanup), even when the body is a single statement without `begin..end`.

The classic `with X do BODY` (no inline-var, no autofree) is unchanged.

See [unleashed/docs/autofree.md](unleashed/docs/autofree.md) for the full grammar, lowering details, error catalogue, and edge cases.

---

### Tweaks

**Activate:** unleashed-mode-only (no separate modeswitch).

Small semantic adjustments to make existing Pascal constructs behave the way most people expect them to.

#### Preserved for-loop counter

In standard Pascal the for-loop counter is *undefined* after the loop exits - the optimizer is free to leave any value behind, and Delphi/FPC docs explicitly warn not to rely on it. That bites every time you write `for i := 1 to N do if X then break;` and then try to use `i`.

In Unleashed mode the counter is guaranteed to keep its last assigned value:

```pascal
for i := 1 to 100 do
  if X[i] = target then
    break;
{ i now holds the index of the match (or 100 if nothing matched) }

for i := 1 to 10 do ;
{ i = 10 (the last in-range value), not 11 (overshoot) }
```

This matches the intuitive behavior of C, Python, JavaScript and Go. Cost is one extra assignment on the natural exit path; nothing on `break`/`continue`/`exit`.

See [unleashed/docs/tweaks.md](unleashed/docs/tweaks.md) for the catalogue and the exact rules each tweak applies.

---

### Multiline Strings

**Activate:** available in Unleashed mode (modeswitch `multilinestrings`).

Two delimiter forms let a string literal span multiple source lines without manual `+` or `LineEnding`.

#### Backtick form

```pascal
const
  banner =
`========================================
=         FCF Fibonacci Demo           =
========================================`;
```

A normal string literal extended to tolerate embedded newlines.

#### Triple-quote form

```pascal
const
  sql =
    '''
    select id, name
    from users
    where active = 1
    ''';
```

A Delphi-11-style textblock literal. The opener (`'''` followed by a newline) and the closer (`'''` on its own line) must each sit alone; the indentation of the closing delimiter defines the column that gets stripped from every content line.

The two forms differ in tokenization, indentation handling, and how they compose in expressions. See [unleashed/docs/multiline-strings.md](unleashed/docs/multiline-strings.md) for the details. (Stock FPC actually accepts these too but never documented them.)

---

### Array Equality

**Activate:** `{$modeswitch arrayequality}` (requires `arrayoperators` to also be active; both are enabled in `{$mode unleashed}`)

Adds support for `=` and `<>` comparison operators between arrays.

#### What it does

Standard Free Pascal with `arrayoperators` allows `+` (concatenation) on dynamic arrays, but does not allow direct equality comparison. This modeswitch fills that gap - you can compare two arrays element-by-element using `=` and `<>`.

#### Example
```pascal
{$mode unleashed}
var
  a, b: array of integer;
begin
  a := [1, 2, 3];
  b := [1, 2, 3];

  if a = b then
    writeln('Arrays are equal');    // this is printed

  b := [1, 2, 4];
  if a <> b then
    writeln('Arrays are different'); // this is printed
end.
```

---

### No RTTI

**Activate:** `{$modeswitch nortti}`

> [!IMPORTANT]
> This modeswitch is **not** enabled by default in unleashed mode. It must be opted into explicitly.

#### What it does

When enabled, all RTTI strings (type names of custom structures like records, classes, etc.) are stripped from the binary - they are replaced with empty strings. RTTI structures still exist and cannot be fully removed, but the most obvious fingerprint - plain-text type identifiers - is gone.

#### Why

Sometimes one may want to avoid exposing an application's internal structure, especially when a simple ASCII dump can reveal type names and identifiers, and with them, the true purpose of the program.

For instance, in the context of game cheats, embedding a name like `TGameWallhack` in the binary can immediately reveal the nature of the software.

<table><tr><td>
<details>
<summary>📄 $\color{Yellow}{FULL \ CODE \ EXAMPLE \ -\ click \ to\ expand}$</summary>

```pas
program MyCoolCheat;

{$modeswitch nortti}

type
  TMyAwesomeCheatBase = class
    process_id: dword;
  end;

  TEnemy = record
    playername: string;
  end;

  TTargetList = array of TEnemy;

  TGameAimbot = class(TMyAwesomeCheatBase)
  private
    ftargets: TTargetList;
  public
    property targets: TTargetList read ftargets;
    constructor create;
    procedure addtarget(playername: string);
    procedure start;
    procedure stop;
  end;

  TGameWallhack = class(TMyAwesomeCheatBase)
    enabled: boolean;
  end;

  TCheat = class
    aimbot: TGameAimbot;
    wallhack: TGameWallhack;
    constructor create;
    destructor destroy; override;
  end;

constructor TGameAimbot.create;
begin
  setlength(ftargets, 0);
end;

procedure TGameAimbot.addtarget(playername: string);
var
  newtarget: TEnemy;
  i: integer;
begin
  newtarget.playername := playername;
  i := length(ftargets);
  setlength(ftargets, i+1);
  ftargets[i] := newtarget;
end;

procedure TGameAimbot.start;
begin
end;

procedure TGameAimbot.stop;
begin
end;

constructor TCheat.create;
begin
  inherited;
  aimbot := TGameAimbot.create;
  wallhack := TGameWallhack.create;
end;

destructor TCheat.destroy;
begin
  aimbot.free;
  wallhack.free;
  inherited;
end;

procedure list_enemies(const cheat: TCheat);
var
  enemy: TEnemy;
begin
  for enemy in cheat.aimbot.targets do writeln(enemy.playername);
end;

var
  cheat: TCheat;

begin
  // initialize game cheat
  cheat := TCheat.create;
  // add enemies
  cheat.aimbot.addtarget('Enemy Player');
  cheat.aimbot.addtarget('Another Enemy');
  // enable wallhack and start aimbot
  cheat.wallhack.enabled := true;
  cheat.aimbot.start;
  // print enemies list
  list_enemies(cheat);
  // stop the cheat
  cheat.aimbot.stop;
  cheat.free;
end.
```
</details>
</td></tr></table>

#### ASCII dump comparison

<table>
<tr>
<th>Standard</th>
<th>With <code>{$modeswitch nortti}</code></th>
</tr>
<tr>
<td valign="top" style="font-size:smaller">
<pre>
Offset Size String
acf0   10   0123456789ABCDEF
af20   29   FPC 3.3.1 [2025/06/18] for x86_64 - Win64
b0d1   13   TMyAwesomeCheatBase
b1c1   0b   TGameAimbot
b2a9   0d   TGameWallhack
b3b8   0c   Enemy Player
b3d8   0d   Another Enemy
b3ea   13   TMyAwesomeCheatBase
b418   0b   MyCoolCheat
b47a   0b   TTargetList
b4aa   0b   MyCoolCheat
b4c2   0b   TGameAimbot
b512   0b   TGameAimbot
b538   0b   MyCoolCheat
b552   0d   TGameWallhack
b57a   0b   MyCoolCheat
b5bb   0b   MyCoolCheat
</pre>
</td>
<td valign="top" style="font-size:smaller">
<pre>
Offset Size String
acf0   10   0123456789ABCDEF
af20   29   FPC 3.3.1 [2025/06/18] for x86_64 - Win64
b398   0c   Enemy Player
b3b8   0d   Another Enemy
</pre>
</td>
</tr>
</table>

Type names like `TGameAimbot`, `TGameWallhack`, or `MyCoolCheat` are no longer present, making the binary significantly less identifiable at first glance. Only actual string data (like player names) remains.

#### Side effects

Compiling a typical LCL application with `nortti` enabled will likely result in a startup failure, because code such as:
```pascal
application.createform(TForm1, form1);
```

will search for `""` (empty string) in the resources instead of `TForm1`, and fail.

#### Workaround

Two ways are provided to selectively whitelist identifiers that should remain visible:

**1. `{$expose}` directive** - placed before declarations to preserve their names:
```pascal
{$expose} TForm1 = class(TForm)
  // ...
end;
```

**2. `{$rttiwhitelist ID1 ID2 ...}` with multiple identifiers** - used to retain specific identifiers:
```pascal
{$rttiexpose TForm1 TForm2}
```

Wildcards can be used:
```pascal
{$rttiwhitelist TForm* ...}
```

> [!NOTE]
> The `{$modeswitch nortti}` directive works on a per-unit basis. You can enable it only in the units where you want to hide type names, while leaving it disabled in others - for example, in units that contain forms or require RTTI to function correctly.

---

### Indexed Labels

Labels now support indexes.

#### Example

```pascal
label
  mylabel1,
  mylabel2[1, 2, 3],
  mylabel3[1..10],
  mylabel4['foo', 'bar'];

begin
  goto mylabel4['foo'];

  writeln('you should not see this');

  mylabel1:
  mylabel2[2]:
  mylabel3[10]:
  mylabel4['foo']:

  writeln('hello!');
end.
```

---

### Lazy Label Declarations

Labels no longer need to be declared before use.

#### Example

```pascal
begin
  goto mylabel;

  writeln('you should not see this');

  mylabel:

  writeln('hello!');
end.
```

---

### Compound Assignment for Pascal Operators

Compound assignment is now supported for Pascal operators such as `div`, `mod`, and `xor`, without requiring `{$COPERATORS ON}`.

#### Example

```pascal
var
  i: integer = 10;
begin
  i div= 2;   // equivalent to: i := i div 2
  writeln(i); // prints "5"
end.
```

Available: `div=`, `mod=`, `and=`, `or=`, `xor=`, `shl=` and `shr=` .

---

### Extra Improvements

Smaller, targeted improvements that unlock Pascal patterns standard FPC modes reject. Each is gated on its own modeswitch (some are on by default in `unleashed`, others must be opted into):

- **`stringordcast`** - cast a string literal to an ordinal type at compile time, e.g. `dword('RIFF')` or `word('MZ')`. Useful for signature checks. *On by default in unleashed.*
- **`typehelpers`** - `type helper for T` on any named type, not just classes and records.
- **`multihelpers`** - several helpers for the same type visible in one scope (instead of "last one wins").
- **`implicitgenerics`** - Delphi-style implicit `generic` / `specialize` syntax (`TList<T>` without keywords). Stock FPC locks this to `{$mode delphi}`; the modeswitch makes it usable in any mode.

Full descriptions and examples in [unleashed/docs/extra-improvements.md](unleashed/docs/extra-improvements.md).

---

### Detailed Documentation

Each feature has a dedicated reference page in [unleashed/docs/](unleashed/docs/) with the full grammar, semantics, edge cases, and IDE notes. Start at the index: [unleashed/docs/README.md](unleashed/docs/README.md).

## Installation

### Option 1: Fresh install (FPC + Lazarus via fpcupdeluxe)

1. Download [fpcupdeluxe](https://github.com/LongDirtyAnimAlf/fpcupdeluxe) and run it once to generate the `fpcup.ini` file.
2. Edit `fpcup.ini` and add the following under `[ALIASfpcURL]`:

```ini
[ALIASfpcURL]
unleashed.git=https://github.com/fpc-unleashed/freepascal.git
```

And, for Lazarus Unleashed (with **autocomplete support** for some of the new features), add the following under `[ALIASlazURL]`:  

```ini
[ALIASlazURL]
unleashed.git=https://github.com/fpc-unleashed/lazarus.git
```

3. Reopen **fpcupdeluxe**, uncheck **GitLab**, and select `fpc-unleashed.git` as your FPC version.
4. Choose any Lazarus version you like.

![fpcupdeluxe](unleashed/img/installation_fpcupdeluxe.png)

5. Click **Install/update FPC+Lazarus**.
6. Optionally install cross-compilers via the `Cross` tab.

### Option 2: Upgrade an existing fpcupdeluxe setup

1. Make sure your existing FPC + Lazarus installation was created with **fpcupdeluxe**.
2. In your installation directory, delete or rename the `fpcsrc` folder.
3. Clone the FPC Unleashed repo into the `fpcsrc` directory:

```bash
git clone https://github.com/fpc-unleashed/freepascal.git fpcsrc
```

4. In **fpcupdeluxe**, go to **Setup+**, check **FPC/Laz rebuild only**, and confirm.
5. Click **Only FPC** to rebuild the compiler and RTL.
6. Optionally install cross-compilers via the `Cross` tab.

## Contributing

We welcome bold ideas and experimental features that push Pascal forward.

**FPC Unleashed** is a home for innovation. If you have built a language feature that was considered _too experimental_ or _not standard enough_ for upstream, this is where it belongs.

### What we are looking for

* **New language ideas** - Propose modeswitches, syntax extensions, or compiler enhancements via GitHub Issues or Discussions. Even if you do not have an implementation yet, a well-described idea with clear use cases is valuable.
* **Complete, high-quality implementations** - We accept pull requests for new language constructs, compiler enhancements, and RTL improvements. We expect production-grade code: clean implementation, proper test coverage, and clear documentation of the feature.

### What we are not looking for

We do not accept minor convenience patches, trivial reformats, or small tweaks that only scratch a personal itch. Every change to a compiler carries weight - if you are contributing code, it should be a meaningful feature or fix that benefits the broader community.
