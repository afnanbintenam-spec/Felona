"""
Generate onboarding SVG illustrations for FeloNa app.
Style: Organic blob background + floating eco objects
Colors: App palette (#2B7A6B primary, #DFF3EA mint, #F7F8F5 bg)
"""
import svgwrite
import math
import random

random.seed(42)  # Reproducible

# App colors
PRIMARY = "#2B7A6B"
MINT = "#DFF3EA"
MINT_DARK = "#B8E4D4"
BG = "#F7F8F5"
BEIGE = "#EFE4D2"
LAVENDER = "#E8E3F7"
BLUE_SOFT = "#DCEEF8"
TEXT_PRIMARY = "#1B1B1B"
TEXT_SEC = "#6B7280"
STROKE = "#2B7A6B"
STROKE_LIGHT = "#4DA89A"
ACCENT_ORANGE = "#E8A838"
ACCENT_BLUE = "#5B9BD5"


def blob_path(cx, cy, rx, ry, points=8, variance=0.15):
    """Generate organic blob shape as SVG path."""
    path_data = []
    angles = [i * (2 * math.pi / points) for i in range(points)]
    coords = []
    for a in angles:
        r_x = rx * (1 + random.uniform(-variance, variance))
        r_y = ry * (1 + random.uniform(-variance, variance))
        x = cx + r_x * math.cos(a)
        y = cy + r_y * math.sin(a)
        coords.append((x, y))
    
    # Build smooth cubic bezier path
    path_data.append(f"M {coords[0][0]:.1f},{coords[0][1]:.1f}")
    n = len(coords)
    for i in range(n):
        p0 = coords[i]
        p1 = coords[(i + 1) % n]
        p2 = coords[(i + 2) % n]
        # Control points
        cp1x = p0[0] + (p1[0] - coords[(i - 1) % n][0]) * 0.3
        cp1y = p0[1] + (p1[1] - coords[(i - 1) % n][1]) * 0.3
        cp2x = p1[0] - (p2[0] - p0[0]) * 0.3
        cp2y = p1[1] - (p2[1] - p0[1]) * 0.3
        path_data.append(f"C {cp1x:.1f},{cp1y:.1f} {cp2x:.1f},{cp2y:.1f} {p1[0]:.1f},{p1[1]:.1f}")
    path_data.append("Z")
    return " ".join(path_data)


def add_small_dots(dwg, count=12, area=(0, 0, 375, 400)):
    """Add small floating dots/particles."""
    for _ in range(count):
        x = random.uniform(area[0] + 20, area[2] - 20)
        y = random.uniform(area[1] + 20, area[3] - 20)
        r = random.uniform(2, 5)
        opacity = random.uniform(0.3, 0.6)
        dwg.add(dwg.circle(center=(x, y), r=r, fill=MINT_DARK, opacity=opacity))


def draw_recycle_symbol(dwg, cx, cy, size=30):
    """Draw a simple recycle symbol."""
    g = dwg.g(transform=f"translate({cx},{cy})")
    s = size / 2
    # Three arrows in triangle
    for angle in [0, 120, 240]:
        rad = math.radians(angle - 90)
        x1 = s * 0.6 * math.cos(rad)
        y1 = s * 0.6 * math.sin(rad)
        rad2 = math.radians(angle + 30 - 90)
        x2 = s * 0.6 * math.cos(rad2)
        y2 = s * 0.6 * math.sin(rad2)
        g.add(dwg.line(start=(x1, y1), end=(x2, y2),
                       stroke=PRIMARY, stroke_width=2.5, stroke_linecap="round"))
        # Arrow head
        rad3 = math.radians(angle + 40 - 90)
        ax = s * 0.45 * math.cos(rad3)
        ay = s * 0.45 * math.sin(rad3)
        g.add(dwg.circle(center=(x2, y2), r=3, fill=PRIMARY))
    dwg.add(g)


def draw_bottle(dwg, x, y, scale=1.0):
    """Draw a simple bottle outline."""
    g = dwg.g(transform=f"translate({x},{y}) scale({scale})")
    # Body
    g.add(dwg.rect(insert=(-8, 0), size=(16, 35), rx=4, ry=4,
                   fill="none", stroke=STROKE_LIGHT, stroke_width=2))
    # Neck
    g.add(dwg.rect(insert=(-4, -12), size=(8, 14), rx=3, ry=3,
                   fill="none", stroke=STROKE_LIGHT, stroke_width=2))
    # Cap
    g.add(dwg.rect(insert=(-5, -16), size=(10, 5), rx=2, ry=2,
                   fill=PRIMARY, stroke="none", opacity=0.7))
    dwg.add(g)


def draw_cup(dwg, x, y, scale=1.0):
    """Draw a disposable cup."""
    g = dwg.g(transform=f"translate({x},{y}) scale({scale})")
    # Cup body (trapezoid-ish)
    points = [(-10, 0), (10, 0), (8, 30), (-8, 30)]
    g.add(dwg.polygon(points=points, fill="none", stroke=STROKE_LIGHT, stroke_width=2))
    # Straw
    g.add(dwg.line(start=(3, -10), end=(5, 5), stroke=ACCENT_ORANGE, stroke_width=2, stroke_linecap="round"))
    # Lid
    g.add(dwg.line(start=(-11, 0), end=(11, 0), stroke=STROKE_LIGHT, stroke_width=2.5, stroke_linecap="round"))
    dwg.add(g)


def draw_detergent(dwg, x, y, scale=1.0):
    """Draw a detergent bottle."""
    g = dwg.g(transform=f"translate({x},{y}) scale({scale})")
    # Body
    g.add(dwg.rect(insert=(-12, 0), size=(24, 40), rx=5, ry=5,
                   fill="none", stroke=STROKE_LIGHT, stroke_width=2))
    # Handle
    g.add(dwg.rect(insert=(-5, -10), size=(10, 12), rx=3, ry=3,
                   fill="none", stroke=STROKE_LIGHT, stroke_width=2))
    # Label
    g.add(dwg.rect(insert=(-8, 12), size=(16, 12), rx=2, ry=2,
                   fill=MINT, stroke="none"))
    dwg.add(g)


def draw_glass_bottle(dwg, x, y, scale=1.0):
    """Draw a wine/glass bottle."""
    g = dwg.g(transform=f"translate({x},{y}) scale({scale})")
    # Body
    g.add(dwg.ellipse(center=(0, 25), r=(10, 15), fill="none", stroke=STROKE_LIGHT, stroke_width=2))
    # Neck
    g.add(dwg.rect(insert=(-4, -5), size=(8, 20), rx=3, ry=3,
                   fill="none", stroke=STROKE_LIGHT, stroke_width=2))
    dwg.add(g)


def draw_can(dwg, x, y, scale=1.0):
    """Draw a can."""
    g = dwg.g(transform=f"translate({x},{y}) scale({scale})")
    g.add(dwg.rect(insert=(-9, 0), size=(18, 28), rx=4, ry=4,
                   fill="none", stroke=STROKE_LIGHT, stroke_width=2))
    # Top
    g.add(dwg.ellipse(center=(0, 0), r=(9, 3), fill="none", stroke=STROKE_LIGHT, stroke_width=2))
    # Tab
    g.add(dwg.circle(center=(3, -1), r=2.5, fill=ACCENT_ORANGE, stroke="none"))
    dwg.add(g)


def draw_phone(dwg, x, y, scale=1.0):
    """Draw a phone/tablet (e-waste)."""
    g = dwg.g(transform=f"translate({x},{y}) scale({scale})")
    g.add(dwg.rect(insert=(-12, -18), size=(24, 36), rx=4, ry=4,
                   fill="none", stroke=STROKE_LIGHT, stroke_width=2))
    # Screen
    g.add(dwg.rect(insert=(-9, -14), size=(18, 26), rx=2, ry=2,
                   fill=BLUE_SOFT, stroke="none", opacity=0.5))
    # Button
    g.add(dwg.circle(center=(0, 14), r=2.5, fill="none", stroke=STROKE_LIGHT, stroke_width=1.5))
    dwg.add(g)


def draw_battery(dwg, x, y, scale=1.0):
    """Draw a battery."""
    g = dwg.g(transform=f"translate({x},{y}) scale({scale})")
    g.add(dwg.rect(insert=(-8, -12), size=(16, 24), rx=3, ry=3,
                   fill="none", stroke=STROKE_LIGHT, stroke_width=2))
    # Terminal
    g.add(dwg.rect(insert=(-4, -15), size=(8, 4), rx=1, ry=1,
                   fill=STROKE_LIGHT, stroke="none"))
    # Lightning
    g.add(dwg.text("⚡", insert=(- 4, 4), font_size="12px", fill=ACCENT_ORANGE))
    dwg.add(g)


def draw_leaf(dwg, x, y, scale=1.0):
    """Draw a small leaf."""
    g = dwg.g(transform=f"translate({x},{y}) scale({scale})")
    # Leaf shape
    path = f"M 0,-12 C 8,-8 10,0 6,8 C 3,12 0,12 0,12 C 0,12 -3,12 -6,8 C -10,0 -8,-8 0,-12 Z"
    g.add(dwg.path(d=path, fill=MINT, stroke=PRIMARY, stroke_width=1.5))
    # Vein
    g.add(dwg.line(start=(0, -8), end=(0, 10), stroke=PRIMARY, stroke_width=1, opacity=0.5))
    dwg.add(g)


def draw_jar(dwg, x, y, scale=1.0):
    """Draw a glass jar."""
    g = dwg.g(transform=f"translate({x},{y}) scale({scale})")
    g.add(dwg.rect(insert=(-10, 0), size=(20, 30), rx=4, ry=4,
                   fill="none", stroke=STROKE_LIGHT, stroke_width=2))
    # Lid
    g.add(dwg.rect(insert=(-11, -5), size=(22, 6), rx=2, ry=2,
                   fill=BEIGE, stroke=STROKE_LIGHT, stroke_width=1.5))
    dwg.add(g)


def generate_onboarding_1(output_path):
    """Reuse — plastic bottles, cups, detergent, recycle symbol."""
    dwg = svgwrite.Drawing(output_path, size=("375px", "400px"), viewBox="0 0 375 400")
    
    # Background blob
    blob = blob_path(187, 180, 160, 140, points=8, variance=0.18)
    dwg.add(dwg.path(d=blob, fill=MINT, stroke="none", opacity=0.6))
    
    # Smaller accent blob
    blob2 = blob_path(280, 100, 50, 40, points=6, variance=0.2)
    dwg.add(dwg.path(d=blob2, fill=MINT_DARK, stroke="none", opacity=0.3))
    
    # Floating dots
    add_small_dots(dwg, count=15)
    
    # Eco objects
    draw_cup(dwg, 80, 120, 1.0)
    draw_bottle(dwg, 160, 90, 1.1)
    draw_detergent(dwg, 270, 130, 0.9)
    draw_bottle(dwg, 120, 220, 0.8)
    draw_cup(dwg, 250, 230, 0.7)
    draw_recycle_symbol(dwg, 200, 170, 35)
    draw_leaf(dwg, 310, 80, 1.0)
    draw_leaf(dwg, 60, 260, 0.8)
    
    dwg.save()
    print(f"Generated: {output_path}")


def generate_onboarding_2(output_path):
    """Reduce — glass bottles, jars, cans, leaves."""
    dwg = svgwrite.Drawing(output_path, size=("375px", "400px"), viewBox="0 0 375 400")
    
    # Background blob
    blob = blob_path(190, 190, 155, 145, points=7, variance=0.2)
    dwg.add(dwg.path(d=blob, fill=MINT, stroke="none", opacity=0.6))
    
    # Accent blob
    blob2 = blob_path(90, 280, 45, 35, points=6, variance=0.2)
    dwg.add(dwg.path(d=blob2, fill=MINT_DARK, stroke="none", opacity=0.3))
    
    add_small_dots(dwg, count=12)
    
    # Objects
    draw_glass_bottle(dwg, 100, 110, 1.0)
    draw_jar(dwg, 200, 100, 1.0)
    draw_can(dwg, 280, 120, 1.0)
    draw_glass_bottle(dwg, 150, 220, 0.8)
    draw_recycle_symbol(dwg, 250, 200, 30)
    draw_leaf(dwg, 180, 80, 1.2)
    draw_leaf(dwg, 300, 250, 0.9)
    draw_leaf(dwg, 70, 180, 0.7)
    draw_can(dwg, 90, 260, 0.7)
    
    dwg.save()
    print(f"Generated: {output_path}")


def generate_onboarding_3(output_path):
    """Recycle — electronics, batteries, mixed items."""
    dwg = svgwrite.Drawing(output_path, size=("375px", "400px"), viewBox="0 0 375 400")
    
    # Background blob
    blob = blob_path(185, 185, 150, 140, points=8, variance=0.17)
    dwg.add(dwg.path(d=blob, fill=MINT, stroke="none", opacity=0.6))
    
    # Accent blob
    blob2 = blob_path(300, 280, 40, 35, points=6, variance=0.2)
    dwg.add(dwg.path(d=blob2, fill=LAVENDER, stroke="none", opacity=0.4))
    
    add_small_dots(dwg, count=14)
    
    # Objects
    draw_phone(dwg, 120, 130, 1.1)
    draw_battery(dwg, 220, 110, 1.0)
    draw_bottle(dwg, 290, 150, 0.9)
    draw_recycle_symbol(dwg, 170, 200, 35)
    draw_can(dwg, 80, 230, 0.8)
    draw_detergent(dwg, 270, 240, 0.7)
    draw_leaf(dwg, 320, 90, 1.0)
    draw_leaf(dwg, 50, 150, 0.8)
    draw_phone(dwg, 200, 270, 0.7)
    
    dwg.save()
    print(f"Generated: {output_path}")


if __name__ == "__main__":
    output_dir = r"d:\Felona\felo_na\Assets\illustrations"
    import os
    os.makedirs(output_dir, exist_ok=True)
    
    generate_onboarding_1(os.path.join(output_dir, "onboarding_reuse.svg"))
    generate_onboarding_2(os.path.join(output_dir, "onboarding_reduce.svg"))
    generate_onboarding_3(os.path.join(output_dir, "onboarding_recycle.svg"))
    print("\nAll 3 onboarding illustrations generated!")
