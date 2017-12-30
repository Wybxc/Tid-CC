unit _Test;

interface

function Test: string;

implementation

uses
  SysUtils, Generics.Collections, Tid.CC.Types, Tid.CC.Tokenize, Tid.CC.Parse, Tid.CC.Parse.AST;

var
  TestStr: string = '';

function TokenizeTest: string; forward;

function ParseTest: string; forward;

function Test: string;
begin
  Readln(TestStr);
  if TestStr = '' then
    Exit;
  Result := TokenizeTest + #10#13 + ParseTest;
end;

function GetCharType(const Ch: Char): Integer;
begin
  case Ch of
    '0'..'9':
      Result := 1;
    '+':
      Result := 2;
    '(':
      Result := 3;
    ')':
      Result := 4;
  else
    Result := 0;
  end;
end;

function RequestAction(const State, Input: Integer): Integer;
begin
  case State of
    0:
      Result := Input;
    1:
      if Input = 1 then
        Result := 1
      else
        Result := 0;
  else
    Result := 0;
  end;
end;

function TokenizeTest: string;
var
  I: TTokenizer;
  Count: Integer;
  Temp: string;
begin
  Result := 'Tokenizer Test:'#10#13;
  Count := 0;
  I := TTokenizer.Create(TestStr, @GetCharType, @RequestAction);
  Temp := I.Next.S;
  while Temp <> '' do
  begin
    Inc(Count);
    Result := Result + IntToStr(Count) + ':'#9 + Temp + #10#13;
    Temp := I.Next.S;
  end;
  I.Free;
end;

function RequestAP(const State, Input: Integer): Integer;
begin
  // 手打 LR 分析表 →_→

  // 错误处理
  Result := -1;

  // 移入
  // 发现转置一下更简(nan)洁(dong)
  case Input of
    0: // EOF
      if State = 2 then
        Result := 0;
    1: // 数字
      case State of
        1, 3, 6:
          Result := 9;
      end;
    2: // '+'
      case State of
        2, 7:
          Result := 3;
      end;
    3: // '('
      case State of
        1, 3, 6:
          Result := 6;
      end;
    4: // ')'
      if State = 7 then
        Result := 8;
  end;

  //规约
  // 1) E -> E + F
  // 2) E -> F
  // 3) F -> ( E )
  // 4) F -> num
  case State of
    4, 5: // 规约 E
      case Input of
        0, 2, 4:
          Result := -(State - 3 + 1);
      end;
    8, 9: // 规约 F
      case Input of
        0, 2, 4:
          Result := -(State - 5 + 1);
      end;
  end;
end;

function Reduce(const SymbolStack: TStack<TAST>; const Action: Integer; out Count: Integer; out sType: Integer): TAST;
var
  t: TAST;
begin
  Result := nil;
  // 1) E -> E + F
  // 2) E -> F
  // 3) F -> ( E )
  // 4) F -> num
  case Action of
    1: // E -> E + F
      begin
        t := SymbolStack.Pop;
        Result := TASTStruct.Create(SymbolStack.Peek.Name, 2);
        SymbolStack.Pop.Free; // 内存泄露出自这里, 找了一早上
        with (Result as TASTStruct) do
        begin
          Children[1] := t;
          sType := 1;
          Children[0] := SymbolStack.Pop;
        end;
        Count := 3;
        sType := 1;
      end;
    2: // E -> F
      begin
        Result := SymbolStack.Pop;
        Count := 1;
        sType := 1;
      end;
    3: // F -> ( E )
      begin
        SymbolStack.Pop.Free; // 顺手把这里的内存泄露一起修复了
        Result := SymbolStack.Pop;
        SymbolStack.Pop.Free;
        Count := 3;
        sType := 2;
      end;
    4: // F -> num
      begin
        Result := SymbolStack.Pop;
        Count := 1;
        sType := 2;
      end;
  end;
end;

function Go(const State, Input: Integer): Integer;
begin
  Result := -1;
  case State of
    1:
      case Input of
        1:
          Result := 2;
        2:
          Result := 5;
      end;
    3:
      case Input of
        2:
          Result := 4;
      end;
    6:
      case Input of
        1:
          Result := 7;
        2:
          Result := 5;
      end;
  end;
end;

function Eval(t: TAST): Integer;
begin
  if t.IsSymbol then
    Result := StrToInt(t.Name.S)
  else
    with t as TASTStruct do
      Result := Eval(Children[0]) + Eval(Children[1]);
end;

function ParseTest: string;
var
  Parser: TParser;
  t: TAST;
begin
  Parser := TParser.Create(TestStr, GetCharType, RequestAction, RequestAP, Reduce, Go);
  t := Parser.Parse;
  Result := AST2Str(t, 0, False) + #10#13#10#13 + 'Result = ' + IntToStr(Eval(t));
  t.Free;
  Parser.Free;
end;

end.

