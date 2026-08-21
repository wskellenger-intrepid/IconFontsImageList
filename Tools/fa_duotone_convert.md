# fa_duotone_convert.py

Patches a Font Awesome Duotone `.otf`/`.ttf` font so every icon's secondary
layer gets a plain, directly-addressable Unicode codepoint
(`primary codepoint + 0x100000`) - the same convention Font Awesome itself
used for FA5 duotone icons, and the same convention `TIconFontsImageListBase`
and `TIconFontsImageCollection` already default to via their `DuotoneOffset`
property.

## Why this exists

Font Awesome 5 gave every duotone icon two Unicode codepoints: a primary
layer and a secondary layer at `primary + 0x100000`. Font Awesome 6/7 kept
that pairing for icons that already existed in FA5 (for backward
compatibility), but for every icon added since, the secondary layer has
**no Unicode codepoint at all** - it's only reachable by typing the icon's
name as a ligature (`iconname` + `##`). GDI+ text rendering (what this
library uses, `Winapi.GDIPOBJ`/`Winapi.GDIPAPI`) does not resolve OpenType
ligature substitutions, so `TIconFontItem.FontIcon2Hex` has nothing to point
at for those icons - there's no hex value you can type in.

The good news, confirmed by inspecting an actual
`Font Awesome 7 Duotone-Regular-400.otf`: the secondary artwork is still
sitting in the font. It's just an orphaned glyph, named `"<icon-slug>-secondary"`,
that no codepoint maps to. This script adds that missing `cmap` entry. It
does not invent, redraw, or modify any artwork - it only tells the font
"codepoint X now also points at the glyph that was already there."

## The "tofu box" hazard - why mismatched icons can't just be left alone

If you enable `Duotone := True` globally and an icon's computed secondary
codepoint (`primary + offset`) has **no glyph at all** in the font, GDI+
doesn't render nothing - it renders the font's `.notdef` glyph, which for
both FA7 Duotone fonts checked here is a visible bordered box (the classic
"tofu box" you see for unsupported characters). That means an *unpatched*
duotone font with `Duotone := True` turned on can look actively broken -
a box glyph stamped on top of every icon that isn't a legacy FA5 icon -
rather than just quietly missing its second color. This is what made a
naive "patch everything" pass necessary rather than optional.

## What it actually checks, per icon

For every glyph in the font named `"<slug>-secondary"`:

1. **Already has a real secondary codepoint?** (i.e. `primary + offset`
   already points at something) - skip, nothing to do. These are the
   legacy FA5-era icons.
2. **No base codepoint for `<slug>` at all?** - skip and report; this
   would be unusual and worth investigating if it happens.
3. **Base codepoint's glyph doesn't exactly match `"<slug>-primary"`?** -
   this means the codepoint you use today as `FontIconDec` is a
   pre-composited/flattened "combined" glyph, not a clean primary-only
   outline, for this specific icon. **By default** the script repoints the
   **existing** base codepoint at `"<slug>-primary"` (so any `FontIconDec`
   values you already use keep working, now rendering the clean
   primary-only outline instead of the flattened one), *then* patches the
   secondary. This overwrites an existing cmap entry rather than only
   adding new ones, and the old flattened "combined, non-recolorable"
   glyph becomes unreachable by codepoint for these icons - an acceptable
   trade for a library whose whole point is per-layer recoloring.
   - `--no-remap-mismatched-primary`: disable the remap and skip these
     icons entirely instead (safest fallback, but they get no secondary
     layer at all).
   - `--no-remap-mismatched-primary --include-mismatched-primary`: patch
     the secondary anyway, without remapping the base codepoint - not
     recommended, since the secondary layer ends up drawn on top of a
     glyph that may already contain that same shape (doubled/thickened
     edges). Mainly useful for comparing against the default.
4. **Otherwise** - patch `primary + offset -> "<slug>-secondary"`.

Measured against four real FA7 fonts (already OK / resolved cleanly /
mismatched-primary, out of each font's total icon count):

- `Duotone-Regular-400`: 1,628 / 2,032 / 116 (3%)
- `Duotone-Solid-900`: 1,628 / 81 / 2,067 (55%)
- `Sharp Duotone-Thin-100`: 1,628 / 2,047 / 101 (3%)
- `Jelly Duo-Regular-400` (a much smaller, 275-icon set): 159 / 76 / 40 (15%)

The Solid weight is the outlier - its base codepoints mostly point at the
flattened glyph, not the primary-only one - which is exactly why a
Solid-900 font patched *without* remapping showed visible box glyphs on
most icons once `Duotone` was turned on, while the other three fonts look
fine with only the secondary patched. The default remap behavior handles
all four correctly without needing to know this in advance.

## Usage

```
pip install fonttools

# See what would happen without writing anything
python fa_duotone_convert.py "Font Awesome 7 Duotone-Solid-900.otf" --dry-run -v

# Patch it (default behavior remaps mismatched-primary base codepoints onto
# their clean -primary glyph automatically; never overwrite your original -
# always give a new output filename)
python fa_duotone_convert.py "Font Awesome 7 Duotone-Solid-900.otf" "Font Awesome 7 Duotone-Solid-900-patched.otf"

# Disable the remap and fall back to skipping mismatched-primary icons
# entirely (safest, but incomplete coverage on fonts like Duotone-Solid-900)
python fa_duotone_convert.py IN.otf OUT.otf --no-remap-mismatched-primary -v

# Patch secondaries for mismatched icons WITHOUT remapping the base
# codepoint (not recommended - see the tofu-box/doubled-edge tradeoffs above)
python fa_duotone_convert.py IN.otf OUT.otf --no-remap-mismatched-primary --include-mismatched-primary

# Use a different offset convention if your font family uses one
python fa_duotone_convert.py IN.otf OUT.otf --offset 200000
```

After patching, use the **patched** font file in your project (point your
`TIconFontsImageCollection`/`TIconFontsImageList`'s `FontName` at it, or
install it as a system/embedded font same as you would the original). Leave
`Duotone := True` and `DuotoneOffset := $100000` (the library's defaults) -
no code changes are needed in the Delphi library itself, since the offset
convention already matches.

Note that even with the default remap behavior, some icons may still have
no secondary at all - anything reported as "no base codepoint" or any icon
that simply doesn't have a `-secondary` glyph. For those, either leave
`Duotone` effectively off for that specific icon (don't rely on the global
default; explicitly set `FontIcon2Dec` to something valid, or accept it
renders single-color) rather than assuming every icon in a "Duotone" family
font actually has two layers.

## Verifying before you trust it

1. Run `--dry-run -v` first and read the summary counts + the
   mismatched/no-base-codepoint slug lists.
2. Open the patched font in FontForge (or just in the
   `TIconFontsImageListEditor` / `TIconFontsCharMapForm` char-map picker in
   this library) and spot-check a handful of newly-patched icons at their
   new `primary + 0x100000` codepoint against Font Awesome's official
   duotone render.
3. Only then roll it out broadly.

## Licensing note

Font Awesome's Duotone font files are commercial/Pro assets. This script
only edits a `cmap` table you already have a license for - it doesn't add
Font Awesome's IP to this repository (the font itself is never checked in
here). If you plan to ship a patched font file to end users, check your
Font Awesome license terms first; redistributing a modified copy of their
font may be restricted depending on your license tier.
