# FPC Unleashed

**FPC Unleashed** is a community-driven fork of **Free Pascal**, focused on pushing the language forward with modern, expressive, and practical features that have not (yet) been accepted into the official compiler.

## Table of Contents

- [Features](#features)
  - [Unleashed Mode](#unleashed-mode)
  - [Statement Expressions](#statement-expressions)
  - [Inline Variables](#inline-variables)
  - [Array Equality](#array-equality)
  - [No RTTI](#no-rtti)
- [Installation](#installation)
- [Contributing](#contributing)

---

## Features

### Unleashed Mode

**Activate:** `{$mode unleashed}` or `-Munleashed`

A modern Pascal mode based on `objfpc` with powerful enhancements enabled by default. Instead of toggling individual modeswitches, you get everything at once.

When using **[Lazarus Unleashed](https://github.com/fpc-unleashed/lazarus)**, this mode is enabled by default for all projects and full code completion is supported out of the box.

The following modeswitches are enabled automatically:

| Modeswitch | Description |
|---|---|
| `statementexpressions` | Use `if`, `case`, and `try` as expressions |
| `inlinevars` | Declare variables inline, anywhere inside a `begin..end` block |
| `anonymousfunctions` | Anonymous procedures and functions |
| `functionreferences` | Function pointers that capture context |
| `advancedrecords` | Records with methods, properties, and operators |
| `arrayoperators` + `arrayequality` | Direct array comparisons with `=` and `<>` |
| `ansistrings` | Uses `AnsiString` as the default string type |
| `underscoreisseparator` | Allows underscores in numeric literals (`1_000_000`) |
| `duplicatenames` | Allows reusing identifiers in limited scopes |

> [!NOTE]
> For the best experience with code completion, we recommend using **[Lazarus Unleashed](https://github.com/fpc-unleashed/lazarus)** - a fork of Lazarus with full support for unleashed mode. If you are using stock Lazarus, enable the mode via `-Munleashed` in the project's Custom Options rather than placing `{$mode unleashed}` directly in the source file, to avoid autocomplete issues and incorrect code insight behavior.

---

### Statement Expressions

**Activate:** `{$modeswitch statementexpressions}` (or use `{$mode unleashed}`)

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
function expensive: string;
begin
  inc(counter);
  result := 'computed';
end;

// ...
s := if condition then 'fast' else expensive;
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

Ranges work too:
```pascal
s := case x of
  0:    'zero';
  1..9: 'single digit';
  else  'large';
```

> [!NOTE]
> When using enums, all values must be covered - otherwise the compiler will reject it. When using integer/ordinal ranges, provide an `else` clause.

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

**Activate:** `{$modeswitch inlinevars}` (or use `{$mode unleashed}`)

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

## Installation

> [!NOTE]
> This section covers installing **FPC Unleashed** (the compiler) paired with stock Lazarus. A dedicated installation guide for **[Lazarus Unleashed](https://github.com/fpc-unleashed/lazarus)** - which includes full code completion support for unleashed mode - is currently being written. In the meantime, feel free to explore the Lazarus Unleashed repository and try it out yourself.

### Option 1: Fresh install (FPC + Lazarus via fpcupdeluxe)

1. Download [fpcupdeluxe](https://github.com/LongDirtyAnimAlf/fpcupdeluxe) and run it once to generate the `fpcup.ini` file.
2. Edit `fpcup.ini` and add the following under `[ALIASfpcURL]`:
```ini
[ALIASfpcURL]
fpc-unleashed.git=https://github.com/fpc-unleashed/freepascal.git
```
3. Reopen **fpcupdeluxe**, uncheck **GitLab**, and select `fpc-unleashed.git` as your FPC version.
4. Choose any Lazarus version you like.

![fpcupdeluxe](unleashed/img/installation_fpcupdeluxe.png)

5. Click **Install/update FPC+Lazarus**.
6. Optionally install cross-compilers via the `Cross` tab.

### Option 2: Upgrade existing fpcupdeluxe setup

1. Make sure your existing FPC+Lazarus was installed with **fpcupdeluxe**.
2. In your installation directory, delete or rename the `fpcsrc` folder.
3. Clone the FPC Unleashed repo into the `fpcsrc` directory:
```bash
git clone https://github.com/fpc-unleashed/freepascal.git fpcsrc
```
4. In **fpcupdeluxe**, go to **Setup+**, check **FPC/Laz rebuild only**, and confirm.
5. Click **Only FPC** to rebuild the compiler and RTL.
6. Optionally install cross-compilers via the `Cross` tab.

---

## Contributing

We welcome bold ideas and experimental features that push Pascal forward.

**FPC Unleashed** is a home for innovation - if you have built a language feature that was "too experimental" or "not standard enough" for upstream, this is where it belongs.

### What we are looking for

- **New language ideas** - propose modeswitches, syntax extensions, or compiler enhancements via GitHub Issues or Discussions. Even if you don't have an implementation yet, a well-described idea with use cases is valuable.
- **Complete, high-quality implementations** - we accept pull requests for new language constructs, compiler enhancements, and RTL improvements. We expect production-grade code: clean implementation, proper test coverage, and documentation of the feature.

### What we are not looking for

We do not accept minor convenience patches, trivial reformats, or small tweaks that only scratch a personal itch. Every change to a compiler carries weight - if you are contributing code, it should be a meaningful feature or fix that benefits the broader community.
