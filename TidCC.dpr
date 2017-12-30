program TidCC;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  _Test in '_Test.pas',
  Tid.CC.About in 'Tid.CC.About.pas',
  Tid.CC.Debugger in 'Tid.CC.Debugger.pas',
  Tid.CC.Parse.AST in 'Tid.CC.Parse.AST.pas',
  Tid.CC.Parse in 'Tid.CC.Parse.pas',
  Tid.CC.Tokenize in 'Tid.CC.Tokenize.pas',
  Tid.CC.Types in 'Tid.CC.Types.pas';

begin
  try
    {$IFDEF DEBUG}
    ReportMemoryLeaksOnShutdown := True;
    PrintDebugInfo('TidCC' + Version, ['']);
    PrintDebugInfo('Software' + SoftwareVersion, ['']);
    PrintDebugInfo('Test', [Test]);
    Readln;
    {$ENDIF}
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.

