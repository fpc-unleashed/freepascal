# 🚀 FPC Unleashed

**FPC Unleashed** is a community-driven fork of **Free Pascal**, focused on pushing the language forward with modern, expressive, and practical features that have not (yet) been accepted into the official compiler.

## 🌟 Key Features

### ✨ Statement Expressions - `{$modeswitch StatementExpressions}` - [#1037](https://gitlab.com/freepascal.org/fpc/source/-/merge_requests/1037)

Allows using control flow statements like `if`, `case`, and `try` as **expressions**, enabling a more functional and concise coding style.

#### Code examples:

```pas
s := if n > 0 then 'foo' else 'bar';
```
```pas
s := case x of
  1..3: 'in 1-3 range';
  6..9: 'in 6-9 range';
else 'out of range';
 ```
```pas
function canfail: string;
begin
  if random(2) = 1 then raise Exception.Create('exception');
  result := 'hello world';
end;
// ...
s := try canfail() except 'failed';
 ```
 
### ✨ Array Equality - `{$modeswitch ArrayEquality}` - [#829](https://gitlab.com/freepascal.org/fpc/source/-/merge_requests/829)

Adds support for `=` and `<>` comparisons between arrays when `ArrayOperators` is enabled.

### ✨ Unleashed Mode - `{$mode unleashed}` or `-Munleashed`

A modern Pascal mode based on `ObjFPC` but with powerful enhancements enabled by default.

The following `modeswitches` are enabled automatically in this mode:

-   `StatementExpressions` - Use `if`, `case`, and `try` as expressions.
-   `AnonymousFunctions` - Anonymous procedures and functions.
-   `FunctionReferences` - Function pointers that capture context.
-   `AdvancedRecords` - Records with methods, properties, and operators.
-   `ArrayOperators` and `ArrayEquality` - Direct array comparisons.
-   `AnsiStrings` - Uses `AnsiString` by default.
-   `UnderscoreIsSeparator` - Allows underscores in numbers (`1_000_000`).
-   `DuplicateNames` - Allows reusing identifiers in limited scopes.

> [!NOTE]
> Placing `{$mode unleashed}` directly in your source file may interfere with IDE autocompletion. It's recommended to enable the mode via `-Munleashed` in the Project's Custom Options instead.

## 📦 Installation

### Option 1: Fresh install (FPC + Lazarus via fpcupdeluxe)

1. Download [fpcupdeluxe](https://github.com/LongDirtyAnimAlf/fpcupdeluxe) and run it once to generate the `fpcup.ini` file.
2. Edit `fpcup.ini` and add the following under `[ALIASfpcURL]`:
```ini
[ALIASfpcURL]
fpc-unleashed.git=https://github.com/fpc-unleashed/freepascal.git
```
3. Reopen **fpcupdeluxe**, uncheck **GitLab**, and select `fpc-unleashed.git` as your FPC version.
4. Choose any Lazarus version you like.

![guhMdITgQs](https://github.com/user-attachments/assets/c9d71a23-bd7d-42da-819e-f60bca0838e3)

5. Click **Install/update FPC+Lazarus**.
6. Optionally install cross-compilers via the `Cross` tab.

### Option 2: Upgrade existing fpcupdeluxe setup

1. Make sure your existing FPC+Lazarus was installed with **fpcupdeluxe**.
2. In your installation directory, delete or rename the `fpcsrc` folder.
3. Clone the FPC Unleashed repo into the `fpcsrc` directory.
```bash
git clone https://github.com/fpc-unleashed/freepascal.git fpcsrc
```
4. In **fpcupdeluxe**, go to **Setup+**, check **FPC/Laz rebuild only**, and confirm.
5. Click **Only FPC** to rebuild the compiler and RTL.
6. Optionally install cross-compilers via the `Cross` tab.

## 🤝 Contributing

We welcome bold ideas, experimental features, and contributions that challenge the status quo of the Pascal language.

**FPC Unleashed** is a playground for innovation. If you've ever built a language feature that was "too weird" or "not standard enough" for upstream - this is where it belongs.

#### 🛠 What you can contribute

- 🧪 New language constructs and modeswitches  
- 🔧 Compiler enhancements or RTL improvements  
- 🧹 Cleanup and refactoring of legacy code  
- 🐞 Bugfixes related to unleashed features

