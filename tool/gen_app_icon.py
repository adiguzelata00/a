"""Placeholder app icon: a cream okey tile with a golden sun on a night-sky
disc ringed by tamga-like ticks. Writes the master PNG and every Android /
iOS size. Run from the project root (needs Pillow):

    python3 tool/gen_app_icon.py

Replace assets/icon/app_icon.png with final art and rerun this script's
resize part (or use flutter_launcher_icons) later.
"""
import json
import math
import os

from PIL import Image, ImageDraw, ImageFilter

S = 1024
NIGHT = (14, 20, 40)
NIGHT_LIGHT = (38, 49, 90)
GOLD = (212, 168, 75)
GOLD_DARK = (142, 108, 37)
CREAM = (243, 233, 210)
CREAM_EDGE = (185, 169, 131)
RED = (192, 57, 43)


def master():
    img = Image.new('RGB', (S, S), NIGHT)
    d = ImageDraw.Draw(img)
    # Radial glow.
    for r in range(S // 2, 0, -4):
        t = r / (S / 2)
        c = tuple(int(NIGHT_LIGHT[i] * (1 - t) + NIGHT[i] * t) for i in range(3))
        d.ellipse([S / 2 - r, S / 2 - r, S / 2 + r, S / 2 + r], fill=c)
    # Stars.
    import random
    rnd = random.Random(3)
    for _ in range(60):
        x, y = rnd.uniform(0, S), rnd.uniform(0, S)
        rr = rnd.uniform(2, 5)
        d.ellipse([x - rr, y - rr, x + rr, y + rr], fill=(243, 233, 210))
    # Motif ring with ticks.
    c = S / 2
    for rad, w in ((430, 10), (392, 6)):
        d.ellipse([c - rad, c - rad, c + rad, c + rad], outline=GOLD, width=w)
    for i in range(24):
        a = i * math.pi / 12
        x1, y1 = c + math.cos(a) * 398, c + math.sin(a) * 398
        x2, y2 = c + math.cos(a) * 424, c + math.sin(a) * 424
        d.line([x1, y1, x2, y2], fill=GOLD, width=8)
    # Tile with shadow and edge.
    tw, th = 420, 560
    x0, y0 = c - tw / 2, c - th / 2 - 10
    shadow = Image.new('L', (S, S), 0)
    ImageDraw.Draw(shadow).rounded_rectangle(
        [x0 + 14, y0 + 40, x0 + tw + 14, y0 + th + 40], 60, fill=150)
    img.paste((0, 0, 0), mask=shadow.filter(ImageFilter.GaussianBlur(20)))
    d = ImageDraw.Draw(img)
    d.rounded_rectangle([x0, y0 + 30, x0 + tw, y0 + th + 30], 60, fill=CREAM_EDGE)
    d.rounded_rectangle([x0, y0, x0 + tw, y0 + th], 60, fill=CREAM)
    d.rounded_rectangle([x0 + 18, y0 + 18, x0 + tw - 18, y0 + th - 18], 46,
                        outline=GOLD, width=12)
    # Sun symbol (red tiles' symbol) in the middle.
    sc = (c, y0 + th / 2)
    d.ellipse([sc[0] - 95, sc[1] - 95, sc[0] + 95, sc[1] + 95], fill=RED)
    for i in range(8):
        a = i * math.pi / 4
        d.line([sc[0] + math.cos(a) * 130, sc[1] + math.sin(a) * 130,
                sc[0] + math.cos(a) * 185, sc[1] + math.sin(a) * 185],
               fill=RED, width=30)
    return img


def main():
    img = master()
    os.makedirs('assets/icon', exist_ok=True)
    img.save('assets/icon/app_icon.png')

    android = {'mdpi': 48, 'hdpi': 72, 'xhdpi': 96, 'xxhdpi': 144, 'xxxhdpi': 192}
    for name, size in android.items():
        path = f'android/app/src/main/res/mipmap-{name}/ic_launcher.png'
        img.resize((size, size), Image.LANCZOS).save(path)

    ios_dir = 'ios/Runner/Assets.xcassets/AppIcon.appiconset'
    with open(f'{ios_dir}/Contents.json') as f:
        contents = json.load(f)
    for entry in contents['images']:
        base = float(entry['size'].split('x')[0])
        scale = int(entry['scale'].rstrip('x'))
        px = int(round(base * scale))
        img.resize((px, px), Image.LANCZOS).save(f"{ios_dir}/{entry['filename']}")


if __name__ == '__main__':
    main()
