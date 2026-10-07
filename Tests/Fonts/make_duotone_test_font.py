#!/usr/bin/env python3
"""
Builds duotone-test.ttf, the font the duotone tests draw with. Each glyph is a plain rectangle, so a
test can tell the two layers apart by where their ink lands:

  U+E000    left half of the em box   primary layer
  U+10E000  right half                its duotone secondary (U+E000 + $100000, the default offset)
  U+E001    left half                 a primary with no secondary at + $100000
  U+E002    right half                an explicit secondary, for FontIcon2Dec

Requires: pip install fonttools
Usage:    python make_duotone_test_font.py
"""
import os

from fontTools.fontBuilder import FontBuilder
from fontTools.pens.ttGlyphPen import TTGlyphPen

FAMILY = 'IconFonts Duotone Test'
UPEM, ASCENT, DESCENT = 512, 448, -64
LEFT, RIGHT = (32, 240), (272, 480)


def rect(x0, x1):
    pen = TTGlyphPen(None)
    pen.moveTo((x0, DESCENT + 32))
    pen.lineTo((x0, ASCENT - 32))
    pen.lineTo((x1, ASCENT - 32))
    pen.lineTo((x1, DESCENT + 32))
    pen.closePath()
    return pen.glyph()


def main():
    glyphs = {'.notdef': TTGlyphPen(None).glyph(), 'left': rect(*LEFT), 'right': rect(*RIGHT)}
    fb = FontBuilder(UPEM, isTTF=True)
    fb.font.recalcTimestamp = False  # keeps rebuilds byte-identical
    fb.setupGlyphOrder(list(glyphs))
    fb.setupCharacterMap({0xE000: 'left', 0x10E000: 'right', 0xE001: 'left', 0xE002: 'right'})
    fb.setupGlyf(glyphs)
    # the left side bearing must equal each glyph's xMin, or Windows draws every rectangle at the left
    glyf = fb.font['glyf']
    fb.setupHorizontalMetrics({name: (UPEM, getattr(glyf[name], 'xMin', 0)) for name in glyphs})
    fb.setupHorizontalHeader(ascent=ASCENT, descent=DESCENT)
    fb.setupNameTable({'familyName': FAMILY, 'styleName': 'Regular', 'uniqueFontIdentifier': FAMILY,
                       'fullName': FAMILY + ' Regular', 'psName': 'IconFontsDuotoneTest-Regular'})
    fb.setupOS2(sTypoAscender=ASCENT, sTypoDescender=DESCENT, sTypoLineGap=0, usWinAscent=ASCENT,
                usWinDescent=-DESCENT, fsSelection=0x40, ulCodePageRange1=1)
    fb.setupPost()
    fb.font['head'].created = fb.font['head'].modified = 0
    out = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'duotone-test.ttf')
    fb.save(out)
    print('wrote', out)


if __name__ == '__main__':
    main()
