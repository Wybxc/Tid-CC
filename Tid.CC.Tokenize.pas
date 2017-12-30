unit Tid.CC.Tokenize; //68行:可配置的词法分析器(快夸我)

interface

uses
  Tid.CC.Types;

type
  TTokenizer = class;

  TToken = record
    S: string;
    tType: Integer;
  end;

  TTokenizer = class(TMealy)
  private
    FSource: string;
    FIndex: Integer;
  protected
    procedure SetSource(const ASource: string); override;
  public
    constructor Create(const ASource: string; const AGetCharType: TGetCharType; const ARequestAction:
      TRequestAction); // override;
    function Next: TToken; // 返回下一个Token
  end;
  {
    TTokenizer.RequestAction 规则
    1) 转换到状态 N 并前进一个字符: N
    2) 返回状态 Normal: 0
  }

implementation

{ TTokenizer }

constructor TTokenizer.Create(const ASource: string; const AGetCharType: TGetCharType; const
  ARequestAction: TRequestAction);
begin
  inherited;
  FIndex := 1; // Copy函数中字符串从1起始
end;

function TTokenizer.Next: TToken;
var
  l: Integer; // Token的长度
  // 当前字符: FSource[FIndex + l - 1]
  State: Integer;
begin
  l := 1;
  State := RequestAction(0, GetCharType(FSource[FIndex + l - 1]));
  // 第一次执行的时候 State 一定不为0,否则会出现逻辑死循环
  repeat
    Inc(l);
    State := RequestAction(State, GetCharType(FSource[FIndex + l - 1]));
  until State = 0;
  Result.S := Copy(FSource, FIndex, l - 1); // 我也不知道为啥是l-1,但是l-1能得到正确的结果
  Result.tType := GetCharType(FSource[FIndex]);
  FIndex := FIndex + l - 1;
end;

procedure TTokenizer.SetSource(const ASource: string);
begin
  inherited;
  FSource := ASource;
end;

end.

