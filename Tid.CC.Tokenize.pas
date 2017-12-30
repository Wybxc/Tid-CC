unit Tid.CC.Tokenize; //68��:�����õĴʷ�������(�����)

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
    function Next: TToken; // ������һ��Token
  end;
  {
    TTokenizer.RequestAction ����
    1) ת����״̬ N ��ǰ��һ���ַ�: N
    2) ����״̬ Normal: 0
  }

implementation

{ TTokenizer }

constructor TTokenizer.Create(const ASource: string; const AGetCharType: TGetCharType; const
  ARequestAction: TRequestAction);
begin
  inherited;
  FIndex := 1; // Copy�������ַ�����1��ʼ
end;

function TTokenizer.Next: TToken;
var
  l: Integer; // Token�ĳ���
  // ��ǰ�ַ�: FSource[FIndex + l - 1]
  State: Integer;
begin
  l := 1;
  State := RequestAction(0, GetCharType(FSource[FIndex + l - 1]));
  // ��һ��ִ�е�ʱ�� State һ����Ϊ0,���������߼���ѭ��
  repeat
    Inc(l);
    State := RequestAction(State, GetCharType(FSource[FIndex + l - 1]));
  until State = 0;
  Result.S := Copy(FSource, FIndex, l - 1); // ��Ҳ��֪��Ϊɶ��l-1,����l-1�ܵõ���ȷ�Ľ��
  Result.tType := GetCharType(FSource[FIndex]);
  FIndex := FIndex + l - 1;
end;

procedure TTokenizer.SetSource(const ASource: string);
begin
  inherited;
  FSource := ASource;
end;

end.

