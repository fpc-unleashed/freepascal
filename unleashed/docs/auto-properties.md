# Auto-Properties

A property declared with a type but no `read` / `write` clause makes the compiler synthesize a hidden backing field and bind the property straight to it (`read FName write FName`). No getter / setter method is generated - the property reads and writes the field directly, so the code is identical to a hand-written field-backed property with zero runtime overhead.

Feature gated by modeswitch `AUTOPROPERTIES`, enabled by default in `{$mode unleashed}`.

## Basic use

```pas
type
  TPerson = class
    property Name: String;       // -> strict private FName; read FName write FName
    property Id: Integer;        // -> strict private FId;   read FId  write FId
  end;
```

Each accessor-less property gets its own backing field named `F` followed by the property name (`FName`, `FId`). The field is a real `strict private` member, so methods of the declaring type can use it by name:

```pas
constructor TPerson.Create(aId: Integer);
begin
  FId := aId;                    // backing field is reachable from methods
end;
```

## Backing-field name prefix

By default the synthesized field is the property name prefixed with `F`
(`FName`). With camelCase property names this can read awkwardly
(`FenabledThing`), so the prefix is configurable:

- `{$autopropprefix _}` - a directive that sets the prefix for properties
  declared after it; the field for `enabled` becomes `_enabled`.
- `--autopropprefix=_` - a command-line option (also usable in `fpc.cfg`)
  setting the default for the whole compilation.

The prefix may be several characters (`{$autopropprefix fld_}` makes
`fld_enabled`) and its case is kept as written. It must combine with the
property name to form a valid identifier. The field stays `strict private`
regardless of the prefix, so the choice never leaves the declaring unit.

## `readonly` / `writeonly`

The access can be narrowed with a directive that follows the property's
terminating semicolon, the same shape as a procedure directive
(`function Foo: Integer; stdcall;`):

```pas
property Id: Integer; readonly;   // -> read FId only  (no write)
property Tag: String; writeonly;  // -> write FTag only (no read)
```

- no directive - both `read FField` and `write FField`
- `readonly` - only `read FField`
- `writeonly` - only `write FField`

The semicolon before the directive is required; `property Id: Integer readonly;`
(no semicolon) is a syntax error. The backing field is always created, even for
`readonly` / `writeonly` - the directive only controls which property accessor is
kept. A `readonly` property is still writeable by name through its field from
inside the class (see the constructor above); from outside, only the chosen
direction is available. Assigning to a `readonly` property reports `Cannot assign
to read-only property`, reading a `writeonly` one reports `Cannot read write-only
property`.

`readonly` and `writeonly` are **soft keywords**: they are only recognized as a
directive right after an accessor-less property's semicolon. Everywhere else they
stay ordinary identifiers, so existing code using `readonly` / `writeonly` as
variable, function, or field names keeps compiling.

## Field initializers

A `= constexpr` after the type seeds the backing field with a default value at
construction:

```pas
type
  TConfig = class
    property Host: String = 'localhost';
    property Port: Integer = 8080;
    property Tag: String = 'x'; readonly;   // combines with the directive
  end;
```

The value must be a compile-time constant. It is assigned to the field right
after the instance is allocated and **before** the constructor body runs, so a
constructor can override it:

```pas
constructor TConfig.Create(aPort: Integer);
begin
  FPort := aPort;   // wins over the `= 8080` default
end;
```

A class with initializers but no constructor of its own gets a synthesized
parameterless constructor (calling the inherited one), so `TConfig.Create`
applies the defaults. This assumes the parent has a parameterless constructor
(the usual `TObject` / `TPersistent` case). Initializers on a base class and a
descendant are both applied when the descendant is constructed.

Initializers apply to instance properties of classes and objects. They are not
supported on records, class properties, indexed properties, or a property with an
explicit `read` / `write`.

## Class properties

A `class property` synthesizes a `class var` (static) backing field, shared by all instances:

```pas
type
  TRegistry = class
    class property Count: Integer;   // -> class var FCount; read/write FCount
  end;

begin
  TRegistry.Count := TRegistry.Count + 1;
end.
```

## Records

Advanced records support auto-properties too; the backing field is an ordinary record field:

```pas
type
  TWidget = record
    property Tag: String;
    property Size: Integer;
  end;
```

## Published properties and RTTI

Because the property binds directly to a field, a `published` auto-property is RTTI-complete - `TypInfo` routines work as for any field-backed published property:

```pas
type
  TConfig = class(TPersistent)
  published
    property Host: String;
    property Port: Integer;
  end;

// GetStrProp / SetStrProp / GetOrdProp / SetOrdProp all work on Host and Port
```

## Trigger condition

The feature kicks in only when a property has a type **and** has neither `read` nor `write`. Anything else keeps its classic behavior untouched:

- `property X: T read GetX;` - explicit accessor, no synthesis.
- `property X;` (no type) - the visibility-reintroduction form, no synthesis.

## Errors

| Situation | Message |
| --- | --- |
| `readonly` and `writeonly` on the same property | Property cannot be both "readonly" and "writeonly" |
| Bare property that is indexed (`property Items[i: Integer]: T;`) | Indexed property requires an explicit "read" or "write" accessor |
| `F<Name>` already exists in the type | Cannot synthesize backing field "F<Name>": a member with that name already exists |
| Non-constant initializer | Property initializer must be a constant expression |
| Initializer where no field is synthesized (explicit accessor, indexed, record) | Property initializer requires an accessor-less property in a class or object |

`readonly` / `writeonly` only attach to an accessor-less property; placed after a property that already has an explicit `read` / `write` they are not a directive and the compiler reports the misplaced member the usual way. Without the modeswitch a bare typed property is rejected the classic way (a `read` or `write` specifier is expected).

## Limitations

- An indexed property cannot be auto-backed; it needs an explicit `read` / `write` accessor.
- Initializers apply only to instance properties of classes and objects, not to records, class properties, or indexed properties.
- A class that has initializers but declares no constructor of its own gets a parameterless synthesized constructor that calls a parameterless inherited one, so a base type whose only constructor takes parameters is not supported.
