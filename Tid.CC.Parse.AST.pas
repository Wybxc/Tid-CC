unit Tid.CC.Parse.AST;

interface

uses
  Tid.CC.Tokenize;

type
  TAST = class; // 抽象语法树基类

  TAST = class
  public
    Name: TToken;
    constructor Create(const AName: TToken);
    destructor Destroy; override;
    class function IsSymbol: Boolean; virtual; abstract;
  end;

  TASTSymbol = class(TAST) // 抽象语法树中的符号, 无子节点
  //毫无存在意义的一个类
    class function IsSymbol: Boolean; override;
  end;

  TASTStruct = class(TAST) // 抽象语法树的语法结构, 有子节点
  public
    sType: Integer; //语法结构类型(与 Name.tType 不同)
    Children: array of TAST; // 阔爱的复数
    constructor Create(const AName: TToken; const AChildCount: Integer = 1);
    destructor Destroy; override;
    class function IsSymbol: Boolean; override;
  end;

{$IFDEF DEBUG}
function AST2Str(const AST: TAST; const TabCount: Integer = 0; const AutoFree: Boolean = True): string;
{$ENDIF}

implementation

uses
  Tid.CC.Types;

{ TASTStruct }

constructor TASTStruct.Create(const AName: TToken; const AChildCount: Integer = 1);
begin
  inherited Create(AName);
  SetLength(Children, AChildCount);
  {$IFDEF DEBUG}
  Writeln('    Struct  ' + Name.S + '    ', AChildCount);
  {$ENDIF}
end;

destructor TASTStruct.Destroy;
var
  c: TAST;
begin
  inherited;
  for c in Children do
    c.Free;
end;

class function TASTStruct.IsSymbol: Boolean;
begin
  Result := False;
end;

{ TASTSymbol }

class function TASTSymbol.IsSymbol: Boolean;
begin
  Result := True;
end;

{$IFDEF DEBUG}
function AST2Str(const AST: TAST; const TabCount: Integer = 0; const AutoFree: Boolean = True): string;
var
  c: TAST;
begin
  Result := StringOfChar(#9, TabCount) + AST.Name.S + #10#13;
  if not AST.IsSymbol then
    for c in TASTStruct(AST).Children do
      Result := Result + AST2Str(c, TabCount + 1, AutoFree);
  if AutoFree then
    AST.Free;
end;
// 11.24: 这种实现我当初是怎么想出来的...
{$ENDIF}

{ TAST }

constructor TAST.Create(const AName: TToken);
begin
  Name := AName;
  {$IFDEF DEBUG}
  Writeln('Create AST  ' + Name.S);
  {$ENDIF}
end;

destructor TAST.Destroy;
begin
  {$IFDEF DEBUG}
  Writeln('Destroy AST  ' + Name.S);
  Readln;
  {$ENDIF}
end;

end.

