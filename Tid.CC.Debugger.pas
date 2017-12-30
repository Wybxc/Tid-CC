unit Tid.CC.Debugger;

interface

procedure PrintDebugInfo(const Title: string; const Info: array of const);

implementation

uses
  SysUtils;

function FormatTitle(const S: string): string;
const
  TitleLen = 28;
var
  Left, Right: Integer;
begin
  Left := (TitleLen - Length(S)) div 2;
  Right := TitleLen - Length(S) - Left;
  Result := StringOfChar('-', Left) + S + StringOfChar('-', Right);
end;

function VarRec2Variant(const V: TVarRec): Variant;
begin
  case V.VType of
    vtInteger:
      Result := V.VInteger;
    vtBoolean:
      Result := V.VBoolean;
    vtChar:
      Result := V.VChar;
    vtExtended:
      Result := V.VExtended^;
    vtString:
      Result := V.VString^;
    vtPointer:
      Result := Integer(V.VPointer);
    vtPChar:
      Result := string(V.VPChar);
    vtObject:
      Result := Integer(V.VObject);
    vtClass:
      Result := Integer(V.VClass);
    vtWideChar:
      Result := V.VWideChar;
    vtPWideChar:
      Result := string(V.VPWideChar);
    vtAnsiString:
      Result := Ansistring(V.VAnsiString);
    vtCurrency:
      Result := V.VCurrency^;
    vtVariant:
      Result := V.VVariant^;
    vtInterface:
      Result := IInterface(V.VInterface);
    vtWideString:
      Result := WideString(V.VWideString);
    vtInt64:
      Result := V.VInt64^;
    vtUnicodeString:
      Result := Unicodestring(V.VUnicodeString);
  end;
end;

procedure PrintDebugInfo(const Title: string; const Info: array of const);
var
  v: TVarRec;
begin
  Writeln(FormatTitle(Title));
  for v in Info do
    Writeln(VarRec2Variant(v));
end;

end.

