unit Tid.CC.Types;

interface

uses
  Generics.Collections;

{$REGION '编译'}

type
  TGetCharType = function(const Ch: Char): Integer; // 查询字符类型，约定GetCharType(Char(0))为结束符

  TRequestAction = function(const State, Input: Integer): Integer; // 根据状态与输入进行操作，返回值规则由调用者决定

  TMealy = class//状态机
  protected
    GetCharType: TGetCharType;
    RequestAction: TRequestAction;
    procedure SetSource(const ASource: string); dynamic; abstract;// 使用 dynamic 方法是因为这个方法只被调用一次
  public
    constructor Create(const ASource: string; const AGetCharType: TGetCharType;
      const ARequestAction: TRequestAction);
    function EOF: Integer; //结束符
  end;

{$ENDREGION}

implementation

{ TMealy }

constructor TMealy.Create(const ASource: string; const AGetCharType:
  TGetCharType; const ARequestAction: TRequestAction);
begin
  GetCharType := @AGetCharType;
  RequestAction := @ARequestAction;
  SetSource(ASource);
end;

function TMealy.EOF: Integer;
begin
  Result := GetCharType(Char(0));
end;

end.

