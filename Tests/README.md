# Tests

DUnitX console tests for drawing icons through `TIconFontsImageCollection` and
`TIconFontsVirtualImageList` (VCL, GDI+).

- `IconFontsRenderingTests`: fonts registered from memory with `IconFontsAddMemoryFont`, glyphs that
  overflow their box, and anti-aliasing on a window. They use the Weather Icons font from
  `Demo\Fonts`, which is normally not installed: that is what lets them tell a registered memory font
  from an installed one.
- `IconFontsDuotoneTests`: the duotone secondary layer (`Duotone`, `FontColor2`, `FontIcon2Dec`). They
  use `Fonts\duotone-test.ttf`, whose glyphs are plain rectangles (a primary layer on the left half of
  the box, its secondary on the right), so a test can find each layer by position. Rebuild it with
  `python Fonts\make_duotone_test_font.py` (needs `pip install fonttools`).

Open `IconFontsImageListTests.dpr` in RAD Studio and run it, or build from a RAD Studio
command prompt (`rsvars.bat`):

```
dcc64 -B -U..\Source -I..\Source -NSSystem;Vcl;Winapi;Vcl.Imaging;System.Win IconFontsImageListTests.dpr
IconFontsImageListTests.exe
```

The exit code is 0 when every test passes.

`IconDrawnOnAWindowIsAntiAliased` opens a small window, so it needs an interactive desktop.
The bug it covers (GDI+ drawing aliased text straight onto a window DC) only shows in some
sessions, such as Remote Desktop, so run it there to cover that regression.
