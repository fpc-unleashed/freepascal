# Anonymous Tuples

Tuples are lightweight, anonymous record types written in parentheses. A tuple is stored as an ordinary internal record, so everything the record infrastructure already knows how to do (Result.field access, per-field assignment, copy semantics, managed type init/fini, passing by value/var/const) works unchanged.

Feature gated by modeswitch `TUPLES`, enabled by default in `{$mode unleashed}`.

## Declaring tuple types

### Positional (auto-named fields _1, _2, ...)

```pas
function GetPair: (Integer, Integer);

var
  p: (Integer, String);
```

Fields are generated with canonical names `_1`, `_2`, `_3`, ... and accessed via those names or by constant integer index (0-based):

```pas
Result._1 := 10;             { by name }
Result._2 := 'hello';
WriteLn(p[0], ' ', p[1]);   { by index - same as _1, _2 }
```

The index must be a compile-time constant. Variable indices are not supported because field types can differ (`(Integer, String)` - the compiler cannot determine the result type of `t[i]` when `i` is a variable).

### Named (user-chosen field names)

Names on the left, `:` then the type. Multiple names share a type via comma. Different type groups are separated by `;`, as in record field declarations.

```pas
function Coords: (a, b: Integer);
function Row: (x: Integer; y: String);
function Mixed: (a, b: Integer; s: String; f: Double);
```

Access is by the declared names:

```pas
Result.a := 10;
Result.b := 20;
```

## Tuple literals

### Positional literal

```pas
Result := (10, 20);
p := (42, 'hello');
arr[i] := (1, 2);
```

Applies to any assignment whose left-hand side has a tuple type, and requires the element count to match.

### Named literal (comma delimited)

```pas
Result := (a: 10, b: 20);
Result := (b: 20, a: 10);  { fields may be written in any order }
```

Names must match the fields of the target tuple, and every field must be set exactly once.

## Return syntax sugar: tuple Exit

Inside a function with a tuple return type, `Exit` accepts a literal directly without extra parentheses:

```pas
function Foo: (Integer, Integer);
begin
  if cond then Exit(10, 20);  { positional }
  Result := (100, 200);
end;

function Bar: (a, b: Integer);
begin
  Exit(a: 1, b: 2);          { named }
end;
```

`Exit(single_expr)` still works for a plain tuple-compatible value.

## Tuples as array elements

```pas
var
  pairs: array of (Integer, Integer);
  rows: array of (a, b: Integer);

pairs := [(1, 2), (3, 4), (5, 6)];
rows[0] := (a: 10, b: 20);
```

Tuple literals inside array literals build the declared element type automatically, and sub-32-bit integer literals plus constant strings are promoted to Int32 / the mode's default string type to match typical declarations.

## Inline var destructuring

```pas
var (x, y) := GetPair;
var (a, b) := GetCoords;
var (num, text) := GetMix;
```

Destructuring always happens by POSITION, so the introduced variables may use names different from the source tuple's fields. Each new variable gets the type of the corresponding field.

## Multi-assignment to existing variables

```pas
var x, y: Integer;
...
(x, y) := GetPair;
```

Same positional binding, but the variables must already exist. Used together with a tuple literal this gives a swap idiom:

```pas
(x, y) := (y, x);
```

## Tuples as function parameters

Tuples can be used directly as parameter types:

```pas
procedure Show(p: (Integer, Integer));
begin
  WriteLn(p._1, ' ', p._2);
end;

Show((10, 20));
```

### Parameter destructuring

Destructured parameters let you name the fields directly:

```pas
procedure Process((x, y): (Integer, Integer));
begin
  WriteLn(x, ' ', y);  { x, y available directly }
end;
```

### Inline named tuple parameters

As a shorthand, the type can be declared inline together with the field names. These two declarations are equivalent:

```pas
procedure Foo((a, b): (a, b: Integer));  { explicit }
procedure Foo((a, b: Integer));          { shorthand }
```

Multiple type groups with `;` are supported:

```pas
procedure Bar((x, y: Integer; name: String));
begin
  WriteLn(x, ' ', y, ' ', name);
end;
```

### Wildcard `_`

Ignore tuple fields in destructuring:

```pas
var (first, _, _, last) := GetQuad;
for var (key, _) in pairs do ...
```

## Comparison operators

Tuples support `=`, `<>`, `<`, `<=`, `>`, `>=`:

```pas
if (1, 2) = (1, 2) then ...;  { true - field-by-field equality }
if (1, 2) < (1, 5) then ...;  { true - lexicographic ordering }
```

Tuples of different shapes compare as not equal without error:

```pas
(1, 2, 3) = (1, 2, 3, 4)  { false, not an error }
(1, 2) <> (1, 2, 3)       { true, not an error }
```

Ordering operators (`<`, `>`, `<=`, `>=`) between tuples of different shapes emit a compile-time error: "Tuples have different shapes and cannot be compared".

## WriteLn

Tuples can be passed directly to `Write`/`WriteLn`:

```pas
var t: (Integer, String);
t := (42, 'hello');
WriteLn(t);  { outputs: 42, hello }
```

## Constant-index access

Tuple fields can be accessed by constant integer index (0-based):

```pas
var t: (Integer, String);
WriteLn(t[0]);  { same as t._1 }
WriteLn(t[1]);  { same as t._2 }
```

Variable indices are not supported (heterogeneous field types).

## for-in destructuring

```pas
for var (key, value) in dict do
  WriteLn(key, '=', value);
```

Each element of the collection is destructured into the declared names exactly like a single `var (k, v) := element`.

## Nested tuples

Tuples may contain tuples as fields, positionally or named:

```pas
function Node: (id: Integer; pos: (x, y: Integer));
var
  n: (Integer, (String, Integer));
begin
  n := (5, ('label', 42));
end;
```

## Tuples as record fields

```pas
type
  TItem = record
    id: Integer;
    pt: (x, y: Integer);
  end;

it.pt := (1, 2);           { positional tuple literal }
it.pt := (x: 10, y: 20);  { named tuple literal }
```

## Structural compatibility

Two tuple records with matching shape (same field count, same types in order, and matching field names) are treated as equal, so a function returning `(Integer, Integer)` can be assigned to a variable declared as `(Integer, Integer)` in another place.

If either side is a positional tuple (auto `_1, _2, ...` names), the field-name check is skipped and only the types are compared. This lets a positional literal like `(10, 20)` be assigned to a named tuple `(a, b: Integer)` of the same shape. Two named tuples with different user-chosen names remain distinct.

Tuples are also structurally compatible with regular records of the same shape when either side has the tuple flag.

## Generics

Generic type parameters are accepted as tuple field types:

```pas
generic function MakePair<A, B>(x: A; y: B): (A, B);
generic function MakeNamed<T>(val: T): (key: String; value: T);
```

`array of X` as a generic function return type is an existing FPC limitation and requires a typed alias:

```pas
type
  TArrOfPair = array of (Integer, String);

generic function Zip<A, B>(xs: array of A; ys: array of B): TArrOfPair;
```

## Typed constants

Typed constants support positional tuple literals:

```pas
const
  origin: (Integer, Integer) = (0, 0);
  greet:  (Integer, String) = (42, 'hello');
  point:  (x, y: Integer) = (10, 20);
```

The classic record-style syntax with field names still works:

```pas
const
  origin: (Integer, Integer) = (_1: 0; _2: 0);
  point:  (x, y: Integer) = (x: 10, y: 20);
```

## Not supported (MVP)

- One-element tuples. `(42)` is an arithmetic expression.
- Full RTTI / TypeInfo for tuple types.
