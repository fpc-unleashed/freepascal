program autofree_owns_autofree_01;

{$mode unleashed}

uses Classes;

type
  TParent = class
    Child: TStringList;
    constructor Create;
    destructor Destroy; override;
  end;

var
  parent_destroyed: Boolean = false;

constructor TParent.Create;
begin
  Child := TStringList.Create;
end;

destructor TParent.Destroy;
begin
  Child.Free;
  parent_destroyed := true;
  inherited;
end;

procedure DoWork;
begin
  var p := autofree TParent.Create;
  p.Child.Add('hello');
  if p.Child.Count <> 1 then halt(99);
end;

begin
  DoWork;
  if not parent_destroyed then halt(1);
end.
