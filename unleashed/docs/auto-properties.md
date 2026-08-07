# Auto-Properties

A property declared with a type but no `read` / `write` clause makes the compiler synthesize a hidden backing field and bind the property straight to it (`read FName write FName`). No getter / setter method is generated - the property reads and writes the field directly, so the result is identical to a hand-written field-backed property with zero runtime overhead.

Modeswitch: `autoproperties`, enabled by default in `{$mode unleashed}`.

## Basic use

```pascal
type
  TPerson = class
    property name: string;       // -> strict private Fname; read Fname write Fname
    property id: integer;        // -> strict private Fid;   read Fid  write Fid
  end;
```

Each accessor-less property gets a backing field named `F` + the property name. The field is a real `strict private` member, so methods of the declaring type use it by name:

```pascal
constructor TPerson.Create(anId: integer);
begin
  Fid := anId; // backing field reachable from methods
end;
```

## Backing-field name prefix

The default prefix is `F`. With camelCase property names that can read awkwardly (`Fenabled`), so the prefix is configurable:

- `{$autopropprefix _}` - directive; sets the prefix for properties declared after it (the field for `enabled` becomes `_enabled`).
- `--autopropprefix=_` - command-line option (also usable in `fpc.cfg`) setting the default for the whole compilation.

The prefix may be several characters (`{$autopropprefix fld_}` makes `fld_enabled`) and its case is kept as written; it must combine with the property name into a valid identifier. The field stays `strict private` regardless of the prefix.

## `readonly` / `writeonly`

Narrow the access with a directive after the property's terminating semicolon - the same shape as a procedure directive (`function foo: integer; stdcall;`):

```pascal
property id: integer; readonly;    // -> read Fid only  (no write)
property tag: string; writeonly;   // -> write Ftag only (no read)
```

- no directive - both `read` and `write`
- `readonly` - only `read`
- `writeonly` - only `write`

The semicolon before the directive is mandatory. The backing field is created regardless - a `readonly` property is still writable through its field from inside the class; from outside, only the chosen direction exists. Assigning to a `readonly` property reports `Cannot assign to read-only property "X"`, reading a `writeonly` one reports the standard no-read-accessor error.

`readonly` and `writeonly` are **soft keywords**: recognized only right after an accessor-less property's semicolon, ordinary identifiers everywhere else - existing code using the names keeps compiling.

## Field initializers

A `= constexpr` after the type seeds the backing field at construction:

```pascal
type
  TConfig = class
    property host: string = 'localhost';
    property port: integer = 8080;
    property tag: string = 'x'; readonly; // combines with the directive
  end;
```

The value must be a compile-time constant. It is assigned right after the instance is allocated and **before** the constructor body runs, so a constructor can override it:

```pascal
constructor TConfig.Create(aPort: integer);
begin
  Fport := aPort; // wins over the = 8080 default
end;
```

A class with initializers but no constructor of its own gets a synthesized parameterless constructor (calling the inherited one), so `TConfig.Create` applies the defaults. This assumes the parent has a parameterless constructor - the usual `TObject` / `TPersistent` case. Initializers on a base class and a descendant are both applied when the descendant is constructed.

Initializers apply to instance properties of classes and objects only - not to records, class properties, indexed properties, or properties with an explicit `read` / `write`.

## Class properties

A `class property` synthesizes a `class var` backing field, shared by all instances:

```pascal
type
  TRegistry = class
    class property count: integer; // -> class var Fcount; read/write Fcount
  end;

TRegistry.count += 1;
```

## Records

Advanced records support auto-properties too; the backing field is an ordinary record field:

```pascal
type
  TWidget = record
    property tag: string;
    property size: integer;
  end;
```

## Published properties and RTTI

The property binds directly to a field, so a `published` auto-property is RTTI-complete - `TypInfo` routines behave exactly as for a hand-written field-backed published property:

```pascal
type
  TCfg = class(TPersistent)
  published
    property host: string;
    property port: integer;
  end;

SetStrProp(c, 'host', 'abc');
SetOrdProp(c, 'port', 42);
// GetStrProp / GetOrdProp read them back
```

## Trigger condition

Synthesis fires only when a property has a type **and** neither `read` nor `write`. Anything else keeps its classic behavior:

- `property x: T read getX;` - explicit accessor, no synthesis.
- `property x;` (no type) - the visibility-reintroduction form, no synthesis.

Without the modeswitch a bare typed property is rejected the classic way (a `read` or `write` specifier is expected).

## Errors

| Situation | Message |
|---|---|
| `readonly` and `writeonly` together | `Property cannot be both "readonly" and "writeonly"` |
| Bare indexed property (`property items[i: integer]: T;`) | `Indexed property requires an explicit "read" or "write" accessor` |
| The backing-field name already exists in the type | `Cannot synthesize backing field "Fname": a member with that name already exists` |
| Assignment to a `readonly` property | `Cannot assign to read-only property "X"` |
| Non-constant initializer | `Property initializer must be a constant expression` |
| Initializer where no field is synthesized (explicit accessor, indexed, record) | `Property initializer requires an accessor-less property in a class or object` |

## Limitations

- Indexed properties cannot be auto-backed - they need explicit accessors.
- Initializers: instance properties of classes and objects only.
- The synthesized parameterless constructor calls a parameterless inherited one - a base type whose only constructor takes parameters is not supported for initializer synthesis.

## Demo

```pascal
program auto_prop_demo;

{$mode unleashed}

type
  TConfig = class
    property host: string = 'localhost';
    property port: integer = 8080;
    property hits: integer; readonly;
    procedure bump;
  end;

  TCounter = class
    class property total: integer; // class var backing field, shared
  end;

procedure TConfig.bump;
begin
  inc(Fhits); // the strict private backing field is reachable from methods
end;

begin
  var cfg := TConfig.Create; // synthesized constructor applies the defaults
  writeln($'{cfg.host}:{cfg.port}');
  cfg.port := 9090;
  cfg.bump;
  cfg.bump;
  writeln($'{cfg.host}:{cfg.port} hits={cfg.hits}');
  cfg.Free;

  TCounter.total := 3;
  TCounter.total += 2;
  writeln($'class-level total: {TCounter.total}');
  {$ifdef WINDOWS}readln;{$endif}
end.
```

Output:

```
localhost:8080
localhost:9090 hits=2
class-level total: 5
```
