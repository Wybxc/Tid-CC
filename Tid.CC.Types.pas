unit Tid.CC.Types;

interface

uses
  Generics.Collections;

{$REGION '����'}

type
  TGetCharType = function(const Ch: Char): Integer; // ��ѯ�ַ����ͣ�Լ��GetCharType(Char(0))Ϊ������

  TRequestAction = function(const State, Input: Integer): Integer; // ����״̬��������в���������ֵ�����ɵ����߾���

  TMealy = class//״̬��
  protected
    GetCharType: TGetCharType;
    RequestAction: TRequestAction;
    procedure SetSource(const ASource: string); dynamic; abstract;// ʹ�� dynamic ��������Ϊ�������ֻ������һ��
  public
    constructor Create(const ASource: string; const AGetCharType: TGetCharType;
      const ARequestAction: TRequestAction);
    function EOF: Integer; //������
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

