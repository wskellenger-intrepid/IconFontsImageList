unit IconFontsDuotoneTests;

interface

uses
  System.SysUtils,
  System.Types,
  System.Generics.Collections,
  DUnitX.TestFramework;

type
  TRGB = record
    R, G, B: Integer;
  end;

  [TestFixture]
  TIconFontsDuotoneTests = class
  private
    FFontData: TBytes;
    FSecondaryArea: TList<TPoint>;
    function SecondaryColor(const ADuotone: Boolean; const ACodepoint, AFontColor2, AFontIcon2Dec: Integer): TRGB;
  public
    [SetupFixture]
    procedure Setup;
    [TearDownFixture]
    procedure TearDown;
    [Test]
    procedure DuotoneListDrawsTheSecondaryLayerDimmed;
    [Test]
    procedure ListWithoutDuotoneDrawsOnlyThePrimaryLayer;
    [Test]
    procedure FontColor2DrawsTheSecondaryLayerInItsOwnColor;
    [Test]
    procedure FontIcon2DecDrawsAnExplicitSecondaryGlyph;
  end;

implementation

uses
  System.Classes,
  System.UITypes,
  Vcl.Graphics,
  IconFontsItems,
  IconFontsVirtualImageList,
  IconFontsTestUtils;

const
  // Fonts\duotone-test.ttf, built by Fonts\make_duotone_test_font.py: every glyph is a rectangle
  TEST_FONT = 'IconFonts Duotone Test';
  LEFT_HALF = $E000;             // its secondary, U+10E000, is the right half
  LEFT_HALF_NO_SECONDARY = $E001;
  RIGHT_HALF = $E002;
  NO_COLOR2 = Integer(clDefault);
  // DuotoneOpacity defaults to 102 of 255: a red secondary over white comes out near (255, 153, 153)
  DIMMED = 153;
  TOLERANCE = 40;

{ TIconFontsDuotoneTests }

procedure TIconFontsDuotoneTests.Setup;
var
  LLeft, LRight: TBitmap;
  X, Y: Integer;
begin
  FFontData := RegisterMemoryFont('Fonts\duotone-test.ttf');
  // the secondary layer's area: solid in the right-half glyph and blank in the left-half glyph
  FSecondaryArea := TList<TPoint>.Create;
  LLeft := Render(TEST_FONT, LEFT_HALF);
  LRight := Render(TEST_FONT, RIGHT_HALF);
  try
    for X := 0 to LLeft.Width - 1 do
      for Y := 0 to LLeft.Height - 1 do
        if (Grey(LRight, X, Y) < 64) and (Grey(LLeft, X, Y) > 250) then
          FSecondaryArea.Add(Point(X, Y));
  finally
    LRight.Free;
    LLeft.Free;
  end;
end;

procedure TIconFontsDuotoneTests.TearDown;
begin
  FSecondaryArea.Free;
end;

function TIconFontsDuotoneTests.SecondaryColor(const ADuotone: Boolean;
  const ACodepoint, AFontColor2, AFontIcon2Dec: Integer): TRGB;
var
  LOwner: TComponent;
  LList: TIconFontsVirtualImageList;
  LBitmap: TBitmap;
  P: TPoint;
  C: TColor;
  R, G, B: Integer;
begin
  Assert.IsTrue(FSecondaryArea.Count > 20, 'the test font did not draw where expected');
  LOwner := TComponent.Create(nil);
  try
    LList := CreateList(TEST_FONT, ACodepoint, 100, LOwner);
    LList.Duotone := ADuotone;
    with LList.ImageCollection.IconFontItems[0] do
    begin
      FontColor := clRed;
      FontColor2 := TColor(AFontColor2);
      FontIcon2Dec := AFontIcon2Dec;
    end;
    LBitmap := DrawToBitmap(LList);
    try
      R := 0;
      G := 0;
      B := 0;
      for P in FSecondaryArea do
      begin
        C := LBitmap.Canvas.Pixels[P.X, P.Y];
        Inc(R, TColorRec(C).R);
        Inc(G, TColorRec(C).G);
        Inc(B, TColorRec(C).B);
      end;
      Result.R := R div FSecondaryArea.Count;
      Result.G := G div FSecondaryArea.Count;
      Result.B := B div FSecondaryArea.Count;
    finally
      LBitmap.Free;
    end;
  finally
    LOwner.Free;
  end;
end;

procedure TIconFontsDuotoneTests.DuotoneListDrawsTheSecondaryLayerDimmed;
var
  C: TRGB;
begin
  C := SecondaryColor(True, LEFT_HALF, NO_COLOR2, 0);
  Assert.IsTrue((C.R > 255 - TOLERANCE) and (Abs(C.G - DIMMED) < TOLERANCE) and (Abs(C.B - DIMMED) < TOLERANCE),
    Format('secondary layer is (%d, %d, %d), expected dimmed red', [C.R, C.G, C.B]));
end;

procedure TIconFontsDuotoneTests.ListWithoutDuotoneDrawsOnlyThePrimaryLayer;
var
  C: TRGB;
begin
  C := SecondaryColor(False, LEFT_HALF, NO_COLOR2, 0);
  Assert.IsTrue((C.R > 245) and (C.G > 245) and (C.B > 245),
    Format('secondary area is (%d, %d, %d), expected blank', [C.R, C.G, C.B]));
end;

procedure TIconFontsDuotoneTests.FontColor2DrawsTheSecondaryLayerInItsOwnColor;
var
  C: TRGB;
begin
  // an explicit FontColor2 is drawn at full opacity
  C := SecondaryColor(True, LEFT_HALF, Integer(clBlue), 0);
  Assert.IsTrue((C.B > 255 - TOLERANCE) and (C.R < TOLERANCE) and (C.G < TOLERANCE),
    Format('secondary layer is (%d, %d, %d), expected blue', [C.R, C.G, C.B]));
end;

procedure TIconFontsDuotoneTests.FontIcon2DecDrawsAnExplicitSecondaryGlyph;
var
  C: TRGB;
begin
  // the glyph has no secondary at + DuotoneOffset; FontIcon2Dec names one, and applies without Duotone
  C := SecondaryColor(False, LEFT_HALF_NO_SECONDARY, NO_COLOR2, RIGHT_HALF);
  Assert.IsTrue((C.R > 255 - TOLERANCE) and (Abs(C.G - DIMMED) < TOLERANCE) and (Abs(C.B - DIMMED) < TOLERANCE),
    Format('secondary layer is (%d, %d, %d), expected dimmed red', [C.R, C.G, C.B]));
end;

initialization
  TDUnitX.RegisterTestFixture(TIconFontsDuotoneTests);

end.
