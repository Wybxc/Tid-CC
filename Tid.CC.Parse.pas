unit Tid.CC.Parse;

interface

uses
  Tid.CC.Types, Tid.CC.Tokenize, Tid.CC.Parse.AST, Generics.Collections;

type
  TParser = class;

  TParser = class(TMealy)
  private
    FTokenizer: TTokenizer;
    FSymbolStack: TStack<TAST>;
    FStateStack: TStack<Integer>;
    type
      TReduce = function(                // →_→
        const SymbolStack: TStack<TAST>; // 符号栈
        const Action: Integer;           // RequestAction 返回的 (-Action-1) (正数)
        out Count: Integer;              // 返回弹出的符号数
        out sType: Integer               // 返回规约结构的类型
      ): TAST;                           // ←_←

      TGo = type TRequestAction; // 规约完成之后的跳转
  private
    TokenRequestAction: TRequestAction;
    Reduce: TReduce;
    Go: TGo;
  protected
    procedure SetSource(const ASource: string); override;
    function LRStep(const Token: TToken): Boolean; // 执行一次移入/规约,返回是否完成
  public
    constructor Create(const ASource: string; const AGetCharType: TGetCharType; const
      ATokenRequestAction: TRequestAction; const AParseRequestAction: TRequestAction; const AReduce:
      TReduce; const AGo: TGo); // override;
    function Parse: TAST; // 重点在这里 (´⊙ω⊙`)！(颜文字要用UTF-8保存)
  end;
  {
    TParser.RequestAction 规则
    1) 移入并跳转到状态N:N
    2) 使用规则N规约:-(N+1)
    3) 完成:0 (当 Input 为 EOF ,且 State 为最终结果时返回0) (RequestAction(1 , EOF)一定不能为0)
    4) 出错:-1
    Tips:状态从1开始编号(1为初始状态)
  }

implementation

uses
  SysUtils;

{ TParser }

constructor TParser.Create(const ASource: string; const AGetCharType: TGetCharType; const
  ATokenRequestAction: TRequestAction; const AParseRequestAction: TRequestAction; const AReduce:
  TReduce; const AGo: TGo);
begin
  inherited Create(ASource, @AGetCharType, @AParseRequestAction);
  TokenRequestAction := @ATokenRequestAction;
  Reduce := @AReduce;
  Go := @AGo;
  SetSource(ASource);
end;

function TParser.LRStep(const Token: TToken): Boolean; // 其实重点应该在这里ㄟ(⊙ω⊙ㄟ)
var
  Action: Integer;
  NewStruct: TAST;
  Count: Integer;
  sType: Integer;
begin
  Result := True;
  while True do
  begin
    Action := RequestAction(FStateStack.Peek, Token.tType);
    if Action = 0 then // 分析完成
      Exit
    else if Action > 0 then // 移入
    begin
      FSymbolStack.Push(TASTSymbol.Create(Token));
      FStateStack.Push(Action);
    end
    else // 规约
    begin
      if Action = -1 then
        raise Exception.Create('输入不正确!');
      NewStruct := Reduce(FSymbolStack, -Action - 1, { out } Count, { out } sType);
      FSymbolStack.Push(NewStruct);
      while Count > 0 do
      begin
        FStateStack.Pop;
        Dec(Count);
      end;
      FStateStack.Push(Go(FStateStack.Peek, sType));
      Continue;
    end;
    Break;
  end;
  Result := False;
end;

function TParser.Parse: TAST;
var
  t: TAST;
begin
  // Init
  FSymbolStack := TStack<TAST>.Create;
  FStateStack := TStack<Integer>.Create;
  FStateStack.Push(1);
  // Go!
  while not LRStep(FTokenizer.Next) do
  begin // 这里似乎没有什么可写的了
    if FStateStack.Count <= 0 then
      raise Exception.Create('语法分析错误!');
  end;
  Result := FSymbolStack.Pop;
  for t in FSymbolStack do
    t.Free;
  FTokenizer.Free;
  FSymbolStack.Free;
  FStateStack.Free;
end;

procedure TParser.SetSource(const ASource: string);
begin
  inherited;
  if Assigned(FTokenizer) then
    FTokenizer.Free;
  FTokenizer := TTokenizer.Create(ASource, @GetCharType, @TokenRequestAction);
end;

end.

