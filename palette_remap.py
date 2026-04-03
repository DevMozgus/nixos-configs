#!/usr/bin/env python3
"""
palette_remap.py — Remap an image's colors to the Material Theme (Ocean) colorscheme.

Usage:
    python palette_remap.py input.png output.png [--no-dither]

Dependencies:
    pip install Pillow

The script maps every pixel in the input image to the nearest color in the
palette using perceptual (LAB) distance, with optional Floyd-Steinberg dithering.
"""

import sys
import argparse
from PIL import Image

# ── Material Theme (Ocean) palette ──────────────────────────────────────────
PALETTE = {
    "base00": (0x0F, 0x11, 0x1A),  # Background
    "base01": (0x18, 0x1A, 0x29),  # Alt bg
    "base02": (0x1F, 0x22, 0x33),  # Selection
    "base03": (0x46, 0x4B, 0x5D),  # Comments
    "base04": (0x67, 0x6E, 0x95),  # Dark fg
    "base05": (0x8F, 0x93, 0xA2),  # Foreground
    "base06": (0xEE, 0xFF, 0xFF),  # Light fg
    "base07": (0xFF, 0xFF, 0xFF),  # White
    "base08": (0xFF, 0x53, 0x70),  # Red
    "base09": (0xF7, 0x8C, 0x6C),  # Orange
    "base0A": (0xFF, 0xCB, 0x6B),  # Yellow
    "base0B": (0xC3, 0xE8, 0x8D),  # Green
    "base0C": (0x89, 0xDD, 0xFF),  # Cyan
    "base0D": (0x82, 0xAA, 0xFF),  # Blue
    "base0E": (0xC7, 0x92, 0xEA),  # Purple
    "base0F": (0xF0, 0x71, 0x78),  # Coral
}

PALETTE_COLORS = list(PALETTE.values())  # 16 RGB tuples


def rgb_to_lab(r, g, b):
    """Convert sRGB (0–255) to CIELAB for perceptual distance."""
    # Linearise
    def linearise(c):
        c /= 255.0
        return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4

    r, g, b = linearise(r), linearise(g), linearise(b)

    # To XYZ (D65)
    x = r * 0.4124 + g * 0.3576 + b * 0.1805
    y = r * 0.2126 + g * 0.7152 + b * 0.0722
    z = r * 0.0193 + g * 0.1192 + b * 0.9505

    # Normalise by D65 white point
    x /= 0.95047
    y /= 1.00000
    z /= 1.08883

    def f(t):
        return t ** (1 / 3) if t > 0.008856 else 7.787 * t + 16 / 116

    fx, fy, fz = f(x), f(y), f(z)
    L = 116 * fy - 16
    a = 500 * (fx - fy)
    b_val = 200 * (fy - fz)
    return L, a, b_val


# Pre-compute LAB values for all palette colors
PALETTE_LAB = [rgb_to_lab(*c) for c in PALETTE_COLORS]


def nearest_palette_color(r, g, b):
    """Return the palette RGB tuple closest to (r, g, b) in LAB space."""
    L, a, b_val = rgb_to_lab(r, g, b)
    best_idx, best_dist = 0, float("inf")
    for i, (pl, pa, pb) in enumerate(PALETTE_LAB):
        d = (L - pl) ** 2 + (a - pa) ** 2 + (b_val - pb) ** 2
        if d < best_dist:
            best_dist = d
            best_idx = i
    return PALETTE_COLORS[best_idx]


def build_pillow_palette():
    """Build a 768-byte palette blob for use with Image.quantize()."""
    flat = []
    for rgb in PALETTE_COLORS:
        flat.extend(rgb)
    flat += [0] * (768 - len(flat))
    return flat


def remap_image(input_path, output_path, dither=True):
    img = Image.open(input_path).convert("RGB")
    print(f"Loaded: {input_path}  ({img.width}×{img.height})")

    # Build a palette image that Pillow's quantize() accepts
    palette_img = Image.new("P", (1, 1))
    palette_img.putpalette(build_pillow_palette())

    dither_flag = Image.Dither.FLOYDSTEINBERG if dither else Image.Dither.NONE
    quantized = img.quantize(
        colors=len(PALETTE_COLORS),
        palette=palette_img,
        dither=dither_flag,
    )

    result = quantized.convert("RGB")
    result.save(output_path)
    print(f"Saved:  {output_path}  (dither={'on' if dither else 'off'})")


def main():
    parser = argparse.ArgumentParser(
        description="Remap image colors to the Material Theme (Ocean) palette."
    )
    parser.add_argument("input", help="Path to input image")
    parser.add_argument("output", help="Path for output image (PNG recommended)")
    parser.add_argument(
        "--no-dither",
        action="store_true",
        help="Disable Floyd-Steinberg dithering (hard nearest-color mapping)",
    )
    args = parser.parse_args()

    remap_image(args.input, args.output, dither=not args.no_dither)


if __name__ == "__main__":
    main()