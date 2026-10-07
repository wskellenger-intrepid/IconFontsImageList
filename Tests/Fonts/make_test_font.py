#!/usr/bin/env python3
"""
Builds icon-test.ttf, the font the layout and duotone tests draw with. Each glyph is a plain
rectangle, so a test can tell where its ink lands:

  U+E000    left half of the em box   primary layer
  U+10E000  right half                its duotone secondary (U+E000 + $100000, the default offset)
  U+E001    left half                 a primary with no secondary at + $100000
  U+E002    right half                an explicit secondary, for FontIcon2Dec
  U+E010    1.25em wide               wider than its box, like Font Awesome's widest icons
  U+E011    0.25em wide               narrower than its box
  U+E012    0.25em wide, 1.5em tall   taller than its box (reaches 0.25em past ascent and descent)

Requires: pip install fonttools
Usage:    python make_test_font.py
"""
import os

from fontTools.fontBuilder import FontBuilder
from fontTools.pens.ttGlyphPen import TTGlyphPen

FAMILY = 'IconFonts Test'
UPEM, ASCENT, DESCENT = 512, 448, -64

# name: (left, right, bottom, top, advance width)
LINE = (DESCENT + 32, ASCENT - 32)
GLYPHS = {
    'left': (32, 240) + LINE + (UPEM,),
    'right': (272, 480) + LINE + (UPEM,),
    'wide': (16, 624) + LINE + (640,),
    'narrow': (16, 112) + LINE + (128,),
    'tall': (16, 112, DESCENT - 128, ASCENT + 128, 128),
}
CMAP = {0xE000: 'left', 0x10E000: 'right', 0xE001: 'left', 0xE002: 'right', 0xE010: 'wide', 0xE011: 'narrow',
        0xE012: 'tall'}


def rect(x0, x1, y0, y1):
    pen = TTGlyphPen(None)
    pen.moveTo((x0, y0))
    pen.lineTo((x0, y1))
    pen.lineTo((x1, y1))
    pen.lineTo((x1, y0))
    pen.closePath()
    return pen.glyph()


def main():
    glyphs = {'.notdef': TTGlyphPen(None).glyph()}
    glyphs.update({name: rect(x0, x1, y0, y1) for name, (x0, x1, y0, y1, _) in GLYPHS.items()})
    fb = FontBuilder(UPEM, isTTF=True)
    fb.font.recalcTimestamp = False  # keeps rebuilds byte-identical
    fb.setupGlyphOrder(list(glyphs))
    fb.setupCharacterMap(CMAP)
    fb.setupGlyf(glyphs)
    # the left side bearing must equal each glyph's xMin, or Windows draws every rectangle at the left
    metrics = {'.notdef': (UPEM, 0)}
    metrics.update({name: (g[4], g[0]) for name, g in GLYPHS.items()})
    fb.setupHorizontalMetrics(metrics)
    fb.setupHorizontalHeader(ascent=ASCENT, descent=DESCENT)
    fb.setupNameTable({'familyName': FAMILY, 'styleName': 'Regular', 'uniqueFontIdentifier': FAMILY,
                       'fullName': FAMILY + ' Regular', 'psName': 'IconFontsTest-Regular'})
    fb.setupOS2(sTypoAscender=ASCENT, sTypoDescender=DESCENT, sTypoLineGap=0, usWinAscent=ASCENT,
                usWinDescent=-DESCENT, fsSelection=0x40, ulCodePageRange1=1)
    fb.setupPost()
    fb.font['head'].created = fb.font['head'].modified = 0
    out = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'icon-test.ttf')
    fb.save(out)
    print('wrote', out)


if __name__ == '__main__':
    main()
