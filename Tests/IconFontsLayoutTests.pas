unit IconFontsLayoutTests;

interface

uses
  System.SysUtils,
  DUnitX.TestFramework;

type
  [TestFixture]
  TIconFontsLayoutTests = class
  private
    FFontData: TBytes;
  public
    [SetupFixture]
    procedure RegisterTestFont;
    [Test]
    procedure GlyphWiderThanItsBoxIsScaledToFitIt;
    [Test]
    procedure GlyphNarrowerThanItsBoxIsCentered;
    [Test]
    procedure GlyphTallerThanItsBoxIsNotClipped;
  end;

implementation

uses
  System.Types,
  Vcl.Graphics,
  IconFontsTestUtils;

const
  // Fonts\icon-test.ttf, built by Fonts\make_test_font.py: every glyph is a rectangle
  TEST_FONT = 'IconFonts Test';
  WIDE = $E010;   // 1.25em
  NARROW = $E011; // 0.25em
  TALL = $E012;   // 1.5em tall

{ TIconFontsLayoutTests }

procedure TIconFontsLayoutTests.RegisterTestFont;
begin
  FFontData := RegisterMemoryFont('Fonts\icon-test.ttf');
end;

procedure TIconFontsLayoutTests.GlyphWiderThanItsBoxIsScaledToFitIt;
var
  LBitmap: TBitmap;
  LInk: TRect;
begin
  // a wide glyph must stay inside its box so it cannot run into the caption next to it
  LBitmap := Render(TEST_FONT, WIDE);
  try
    LInk := InkBounds(LBitmap);
    Assert.IsTrue(LInk.Right >= LInk.Left, 'the glyph was not drawn');
    Assert.IsTrue((LInk.Left >= BOX) and (LInk.Right < 2 * BOX),
      Format('ink spans x %d..%d, outside the box %d..%d', [LInk.Left, LInk.Right, BOX, 2 * BOX - 1]));
    // scaled to fit, not shrunk further: the 0.95em-wide rectangle nearly fills the box
    Assert.IsTrue(LInk.Right - LInk.Left + 1 >= BOX - 3,
      Format('ink is only %d px wide in a %d px box', [LInk.Right - LInk.Left + 1, BOX]));
  finally
    LBitmap.Free;
  end;
end;

procedure TIconFontsLayoutTests.GlyphNarrowerThanItsBoxIsCentered;
var
  LBitmap: TBitmap;
  LInk: TRect;
  LOffset: Double;
begin
  LBitmap := Render(TEST_FONT, NARROW);
  try
    LInk := InkBounds(LBitmap);
    Assert.IsTrue(LInk.Right >= LInk.Left, 'the glyph was not drawn');
    // centers in pixels: the ink's against the box's (x 16..31, center 23.5)
    LOffset := (LInk.Left + LInk.Right) / 2 - (BOX + (BOX - 1) / 2);
    Assert.IsTrue(Abs(LOffset) <= 1,
      Format('ink spans x %d..%d, %.1f px off the box center', [LInk.Left, LInk.Right, LOffset]));
  finally
    LBitmap.Free;
  end;
end;

procedure TIconFontsLayoutTests.GlyphTallerThanItsBoxIsNotClipped;
var
  LBitmap: TBitmap;
  LInk: TRect;
begin
  // the glyph reaches past the font's ascent and descent: it must overflow its box, not be cut off
  LBitmap := Render(TEST_FONT, TALL);
  try
    LInk := InkBounds(LBitmap);
    Assert.IsTrue(LInk.Right >= LInk.Left, 'the glyph was not drawn');
    Assert.IsTrue((LInk.Top < BOX) and (LInk.Bottom >= 2 * BOX),
      Format('ink spans y %d..%d, clipped to the box %d..%d', [LInk.Top, LInk.Bottom, BOX, 2 * BOX - 1]));
  finally
    LBitmap.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TIconFontsLayoutTests);

end.
