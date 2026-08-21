#!/usr/bin/env python3
"""
fa_duotone_convert.py

Patch a Font Awesome Duotone OTF/TTF font so every icon's secondary layer
is reachable by a plain Unicode codepoint (primary codepoint + 0x100000),
the same convention Font Awesome used for FA5 duotone icons.

HOW THIS WAS VERIFIED (not theoretical)
----------------------------------------
Inspecting an actual "Font Awesome 7 Duotone-Regular-400.otf":
  - The font's glyph table already names each duotone icon's parts plainly:
    "<slug>", "<slug>-primary", "<slug>-secondary" (e.g. "crow",
    "crow-primary", "crow-secondary"). No OpenType ligature/GSUB parsing is
    needed to find the secondary artwork - it's just a glyph with a
    predictable name, sitting in the font unused by any cmap entry.
  - ~1,856 icons in that font already have a real "primary + 0x100000"
    cmap entry (legacy FA5 icons, kept for back-compat) - nothing to do
    for those, this script skips them automatically.
  - ~2,148 icons have a "<slug>-secondary" glyph but no codepoint pointing
    at it - this script adds one, at "<the icon's existing codepoint> +
    offset", pointing at that already-existing glyph. No new artwork is
    invented, only a cmap entry is added.
  - For some icons, the glyph at the icon's existing plain codepoint is NOT
    byte-identical to its "<slug>-primary" glyph (i.e. the codepoint you
    already use for FontIconDec may be a pre-composited/flattened glyph
    rather than a clean primary-only outline for that icon) - this varies
    a lot by font: ~3% of icons in "Duotone-Regular-400", but ~55% in
    "Duotone-Solid-900". By default this script repoints that base
    codepoint at the real "-primary" glyph (so existing FontIconDec values
    keep working, now rendering the clean outline) before patching the
    secondary - pass --no-remap-mismatched-primary to fall back to
    skipping these icons instead.

WHAT THIS SCRIPT DOES NOT NEED
-------------------------------
No external metadata file (icons.json, slug lists, etc.) - everything is
discovered directly from the font's own glyph order and cmap table.

USAGE
-----
    pip install fonttools
    python fa_duotone_convert.py INPUT.otf --dry-run -v
    python fa_duotone_convert.py INPUT.otf OUTPUT.otf
    python fa_duotone_convert.py INPUT.otf OUTPUT.otf --no-remap-mismatched-primary -v

See fa_duotone_convert.md alongside this file for the full walkthrough.
"""

import argparse
import sys
from fontTools.ttLib import TTFont

DEFAULT_OFFSET = 0x100000
SECONDARY_SUFFIX = "-secondary"
PRIMARY_SUFFIX = "-primary"


def get_cff_charstring_program(font, glyph_name):
    """Return the decompiled T2 charstring program for a glyph, or None if
    the font has no CFF table / the glyph doesn't exist there (e.g. TTF
    outline fonts use glyf instead - see get_glyf_signature)."""
    if "CFF " not in font:
        return None
    cff = font["CFF "].cff
    top_dict = cff[cff.keys()[0]]
    charstrings = top_dict.CharStrings
    if glyph_name not in charstrings:
        return None
    cs = charstrings[glyph_name]
    cs.decompile()
    return cs.program


def get_glyf_signature(font, glyph_name):
    """Fallback outline signature for TTF (glyf-based) fonts."""
    if "glyf" not in font:
        return None
    glyf = font["glyf"]
    if glyph_name not in glyf:
        return None
    glyph = glyf[glyph_name]
    return glyph.compile(glyf)


def outlines_match(font, glyph_a, glyph_b):
    prog_a = get_cff_charstring_program(font, glyph_a)
    if prog_a is not None:
        prog_b = get_cff_charstring_program(font, glyph_b)
        return prog_a == prog_b
    sig_a = get_glyf_signature(font, glyph_a)
    sig_b = get_glyf_signature(font, glyph_b)
    return sig_a == sig_b


def build_reverse_cmap(cmap):
    """glyph name -> first codepoint that maps to it."""
    rev = {}
    for codepoint, glyph_name in cmap.items():
        rev.setdefault(glyph_name, codepoint)
    return rev


def patch_cmap(font, new_mappings, overwrite_codepoints=frozenset()):
    """Add {codepoint: glyph_name} into every cmap subtable capable of
    representing that codepoint (format 12/13 for anything above 0xFFFF).
    Codepoints in `overwrite_codepoints` are allowed to replace an existing
    mapping (used to remap a base codepoint from a "combined" glyph onto its
    "-primary" glyph); anything else refuses to overwrite a differing entry."""
    cmap_table = font["cmap"]
    touched = 0
    patched_any_subtable = False
    for subtable in cmap_table.tables:
        if subtable.format not in (4, 12, 13):
            continue
        patched_any_subtable = True
        for codepoint, glyph_name in new_mappings.items():
            if subtable.format == 4 and codepoint > 0xFFFF:
                continue  # format 4 can't represent codepoints past the BMP
            existing = subtable.cmap.get(codepoint)
            if existing is not None and existing != glyph_name:
                if codepoint not in overwrite_codepoints:
                    print(
                        f"warning: codepoint U+{codepoint:06X} already mapped to "
                        f"{existing!r} in a format-{subtable.format} subtable - "
                        f"leaving it alone, NOT overwriting with {glyph_name!r}",
                        file=sys.stderr,
                    )
                    continue
            subtable.cmap[codepoint] = glyph_name
            touched += 1
    if not patched_any_subtable:
        print(
            "warning: no format 4/12/13 cmap subtable found - could not patch anything.",
            file=sys.stderr,
        )
    return touched


def main():
    parser = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter
    )
    parser.add_argument("input_font")
    parser.add_argument("output_font", nargs="?", help="omit with --dry-run to just see the report")
    parser.add_argument(
        "--offset", type=lambda s: int(s, 16), default=DEFAULT_OFFSET,
        help="hex offset added to the primary codepoint for the new secondary codepoint (default 100000)",
    )
    parser.add_argument("--dry-run", action="store_true", help="report what would happen, don't write output_font")
    parser.add_argument(
        "--no-remap-mismatched-primary", action="store_true",
        help="for icons whose base codepoint glyph isn't identical to their -primary glyph: by default "
             "(without this flag) the base codepoint is repointed at the -primary glyph, so FontIconDec "
             "values you already use keep working and start rendering the clean primary-only outline "
             "instead of the flattened combined glyph - this overwrites an existing cmap entry rather than "
             "only adding new ones, and the old 'combined, single flattened color' glyph becomes "
             "unreachable by codepoint for these icons. Pass this flag to disable that remap and fall back "
             "to skipping these icons entirely (see also --include-mismatched-primary).",
    )
    parser.add_argument(
        "--include-mismatched-primary", action="store_true",
        help="only meaningful together with --no-remap-mismatched-primary: patch the secondary codepoint "
             "for mismatched-primary icons anyway, WITHOUT remapping the base codepoint. Not recommended - "
             "the secondary layer ends up drawn on top of a base glyph that may already contain that same "
             "shape, which can look like doubled/thickened edges. Mainly useful for comparing against the "
             "default remap behavior.",
    )
    parser.add_argument("-v", "--verbose", action="store_true", help="list every skipped/mismatched icon slug")
    args = parser.parse_args()

    if not args.dry_run and not args.output_font:
        parser.error("output_font is required unless --dry-run is given")

    do_remap = not args.no_remap_mismatched_primary
    include_mismatched = do_remap or args.include_mismatched_primary

    font = TTFont(args.input_font)
    cmap = font.getBestCmap()
    rev_cmap = build_reverse_cmap(cmap)
    glyph_order = font.getGlyphOrder()

    secondary_glyphs = [g for g in glyph_order if g.endswith(SECONDARY_SUFFIX)]
    print(f"found {len(secondary_glyphs)} '*{SECONDARY_SUFFIX}' glyph(s) in the font", file=sys.stderr)

    already_had_secondary = []
    no_base_codepoint = []
    mismatched_primary = []
    resolved = {}
    remapped = {}

    for secondary_glyph in secondary_glyphs:
        slug = secondary_glyph[: -len(SECONDARY_SUFFIX)]
        base_codepoint = rev_cmap.get(slug)
        if base_codepoint is None:
            no_base_codepoint.append(slug)
            continue

        target_codepoint = base_codepoint + args.offset
        if target_codepoint in cmap:
            already_had_secondary.append(slug)
            continue

        primary_glyph = slug + PRIMARY_SUFFIX
        is_mismatched = primary_glyph in glyph_order and not outlines_match(font, slug, primary_glyph)
        if is_mismatched:
            mismatched_primary.append(slug)
            if not include_mismatched:
                continue
            if do_remap:
                remapped[base_codepoint] = primary_glyph

        resolved[target_codepoint] = secondary_glyph

    print(f"already had a real secondary codepoint (nothing to do):   {len(already_had_secondary)}")
    print(f"'-secondary' glyph but slug has no base codepoint (odd):   {len(no_base_codepoint)}")
    print(f"base codepoint glyph differs from '-primary' variant:     {len(mismatched_primary)}"
          + ("" if include_mismatched else " (skipped - see --no-remap-mismatched-primary/--include-mismatched-primary)"))
    print(f"resolved secondary codepoints -> will patch:               {len(resolved)}")
    print(f"base codepoints remapped to their -primary glyph:          {len(remapped)}")

    if args.verbose:
        if no_base_codepoint:
            print("  no-base-codepoint:", ", ".join(no_base_codepoint))
        if mismatched_primary:
            print("  mismatched-primary:", ", ".join(mismatched_primary))

    if args.dry_run:
        print("dry run - not writing output font")
        return

    if not resolved and not remapped:
        print("nothing to patch - exiting without writing output font", file=sys.stderr)
        return

    all_mappings = dict(resolved)
    all_mappings.update(remapped)
    touched = patch_cmap(font, all_mappings, overwrite_codepoints=set(remapped))
    print(f"patched {touched} cmap entries")
    font.save(args.output_font)
    print(f"wrote {args.output_font}")


if __name__ == "__main__":
    main()
