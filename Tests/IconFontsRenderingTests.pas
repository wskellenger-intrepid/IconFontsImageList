unit IconFontsRenderingTests;

interface

uses
  System.SysUtils,
  DUnitX.TestFramework;

type
  [TestFixture]
  TIconFontsRenderingTests = class
  private
    FFontData: TBytes;
    FInstalledBefore: Boolean;
  public
    [SetupFixture]
    procedure RegisterTestFont;
    [Test]
    procedure RegisteredMemoryFontIsAvailable;
    [Test]
    procedure RegisteredMemoryFontDrawsItsOwnGlyphs;
    [Test]
    procedure IconDrawnOnAWindowIsAntiAliased;
  end;

implementation

uses
  System.Generics.Collections,
  Winapi.Windows,
  Vcl.Graphics,
  Vcl.Forms,
  IconFontsItems,
  IconFontsVirtualImageList,
  IconFontsTestUtils;

const
  // Weather Icons ships with the demos and is normally not installed, so it is only reachable
  // through IconFontsAddMemoryFont
  TEST_FONT = 'Weather Icons';
  WI_DAY_SUNNY = $F00D;

type
  TPaintForm = class(TForm)
  public
    List: TIconFontsVirtualImageList;
    procedure DoPaint(Sender: TObject);
  end;

procedure TPaintForm.DoPaint(Sender: TObject);
begin
  List.Draw(Canvas, 8, 8, 0);
end;

{ TIconFontsRenderingTests }

procedure TIconFontsRenderingTests.RegisterTestFont;
begin
  FInstalledBefore := Screen.Fonts.IndexOf(TEST_FONT) <> -1;
  FFontData := RegisterMemoryFont('..\Demo\Fonts\weathericons-regular-webfont.ttf');
end;

procedure TIconFontsRenderingTests.RegisteredMemoryFontIsAvailable;
begin
  if FInstalledBefore then
    Assert.Pass(TEST_FONT + ' is installed on this machine, so registration cannot be told apart');
  Assert.IsTrue(IconFontsFontAvailable(TEST_FONT));
end;

procedure TIconFontsRenderingTests.RegisteredMemoryFontDrawsItsOwnGlyphs;
var
  LMemoryFont, LOtherFont: TBitmap;
  X, Y, LDiffering: Integer;
begin
  if FInstalledBefore then
    Assert.Pass(TEST_FONT + ' is installed on this machine, so registration cannot be told apart');
  LMemoryFont := Render(TEST_FONT, WI_DAY_SUNNY);
  // a font without this glyph: what GDI+ draws when the family name does not resolve
  LOtherFont := Render('Segoe UI', WI_DAY_SUNNY);
  try
    LDiffering := 0;
    for X := 0 to LMemoryFont.Width - 1 do
      for Y := 0 to LMemoryFont.Height - 1 do
        if Abs(Grey(LMemoryFont, X, Y) - Grey(LOtherFont, X, Y)) > 64 then
          Inc(LDiffering);
    Assert.IsTrue(InkCount(LMemoryFont) > 15, 'the sun glyph was not drawn');
    Assert.IsTrue(LDiffering > 15, 'drew the fallback font, not ' + TEST_FONT);
  finally
    LOtherFont.Free;
    LMemoryFont.Free;
  end;
end;

procedure TIconFontsRenderingTests.IconDrawnOnAWindowIsAntiAliased;
var
  LForm: TPaintForm;
  LCapture: TBitmap;
  LDC: HDC;
  LLevels: TDictionary<Integer, Boolean>;
  X, Y: Integer;
begin
  // GDI+ draws text aliased straight onto a window DC in some sessions (seen over Remote Desktop);
  // this only fails where that happens, so run it in such a session to cover the regression
  LForm := TPaintForm.CreateNew(nil);
  LCapture := TBitmap.Create;
  LLevels := TDictionary<Integer, Boolean>.Create;
  try
    LForm.BorderStyle := bsNone;
    LForm.Color := clWhite;
    LForm.Position := poDesigned;
    LForm.SetBounds(40, 40, 2 * BOX, 2 * BOX);
    LForm.List := CreateList(TEST_FONT, WI_DAY_SUNNY, 100, LForm);
    LForm.OnPaint := LForm.DoPaint;
    LForm.Show;
    LForm.Repaint;
    Application.ProcessMessages;
    LCapture.PixelFormat := pf24bit;
    LCapture.SetSize(2 * BOX, 2 * BOX);
    LDC := GetDC(LForm.Handle);
    try
      BitBlt(LCapture.Canvas.Handle, 0, 0, 2 * BOX, 2 * BOX, LDC, 0, 0, SRCCOPY);
    finally
      ReleaseDC(LForm.Handle, LDC);
    end;
    for X := 0 to LCapture.Width - 1 do
      for Y := 0 to LCapture.Height - 1 do
        LLevels.AddOrSetValue(Grey(LCapture, X, Y), True);
    Assert.IsTrue(InkCount(LCapture) > 15, 'the icon was not drawn on the window');
    // black on white with no anti-aliasing has 2 grey levels
    Assert.IsTrue(LLevels.Count > 4, Format('only %d grey levels: edges are not anti-aliased', [LLevels.Count]));
  finally
    LLevels.Free;
    LCapture.Free;
    LForm.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TIconFontsRenderingTests);

end.
