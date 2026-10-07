program IconFontsImageListTests;

{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}

uses
  System.SysUtils,
  DUnitX.Loggers.Console,
  DUnitX.TestFramework,
  IconFontsTestUtils in 'IconFontsTestUtils.pas',
  IconFontsRenderingTests in 'IconFontsRenderingTests.pas',
  IconFontsLayoutTests in 'IconFontsLayoutTests.pas',
  IconFontsDuotoneTests in 'IconFontsDuotoneTests.pas';

var
  LRunner: ITestRunner;
  LResults: IRunResults;
begin
  try
    TDUnitX.CheckCommandLine;
    LRunner := TDUnitX.CreateRunner;
    LRunner.UseRTTI := True;
    LRunner.FailsOnNoAsserts := True;
    LRunner.AddLogger(TDUnitXConsoleLogger.Create(True));
    LResults := LRunner.Execute;
    if not LResults.AllPassed then
      System.ExitCode := 1;
  except
    on E: Exception do
    begin
      Writeln(E.ClassName, ': ', E.Message);
      System.ExitCode := 1;
    end;
  end;
end.
