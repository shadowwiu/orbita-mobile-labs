"""Original procedural illustrations. Run: python -m pip install pillow numpy.

No downloaded artwork; exported PNG assets are already included in the project.
"""
from pathlib import Path
import math
import random
import numpy as np
from PIL import Image, ImageDraw, ImageFilter

OUT = Path(__file__).resolve().parents[1] / 'assets' / 'images'
OUT.mkdir(parents=True, exist_ok=True)
W, H = 1000, 600
rng = random.Random(33)
palettes = {
    'earth': ((48, 103, 139), (17, 32, 49)),
    'mars': ((214, 124, 88), (48, 29, 32)),
    'saturn': ((209, 181, 130), (36, 34, 39)),
    'moon': ((175, 185, 190), (28, 35, 47)),
    'jupiter': ((206, 168, 132), (40, 31, 36)),
    'neptune': ((72, 122, 222), (20, 30, 57)),
}

for name, (base, bg) in palettes.items():
    yy, xx = np.mgrid[0:H, 0:W]
    glow = np.exp(-(((xx - 560) / 420) ** 2 + ((yy - 280) / 300) ** 2))
    canvas = np.zeros((H, W, 3), dtype=np.uint8)
    for c in range(3):
        canvas[:, :, c] = np.clip(bg[c] * .42 + glow * bg[c] * .5, 0, 255)
    image = Image.fromarray(canvas).convert('RGBA')
    stars = ImageDraw.Draw(image)
    for _ in range(90):
        sx, sy = rng.randrange(W), rng.randrange(H)
        v = rng.randrange(70, 160)
        stars.ellipse((sx, sy, sx + rng.choice([1, 1, 2]), sy + 1), fill=(v, v, v, 190))

    radius = 175 if name == 'saturn' else 207
    cx, cy = 550, 300
    x = (xx - cx) / radius
    y = (yy - cy) / radius
    mask = x*x + y*y <= 1
    z = np.sqrt(np.maximum(0, 1 - x*x - y*y))
    light = np.clip(-.48*x - .35*y + .8*z, .04, 1)
    noise = (np.sin(xx*.059 + np.sin(yy*.034)*5) + np.sin(yy*.091 + xx*.012)) / 2
    bands = np.sin(y*28 + np.sin(x*5)*.5) * .07
    colors = np.zeros((H, W, 4), dtype=np.uint8)
    for c in range(3):
        colors[:, :, c] = np.clip(base[c] * (light*.95+.13) * (1 + noise*.12 + bands), 0, 255)
    if name == 'earth':
        land = (np.sin(x*9+y*5) + np.cos(y*14-x*4) + np.sin(x*17-y*7)) > .65
        for c, value in enumerate((101, 137, 103)):
            colors[:, :, c] = np.where(land, value * (light+.1), colors[:, :, c]).clip(0, 255)
        clouds = np.sin(y*24 + np.sin(x*9)*2) > .88
        for c in range(3):
            colors[:, :, c] = np.where(clouds, 205 * (light+.1), colors[:, :, c]).clip(0, 255)
    if name == 'moon':
        craters = np.zeros((H, W))
        for _ in range(55):
            qx, qy = rng.uniform(-.85, .85), rng.uniform(-.85, .85)
            qr = rng.uniform(.018, .12)
            d = np.sqrt((x-qx)**2 + (y-qy)**2)
            craters += np.where(d < qr, -.20, np.where(d < qr*1.15, .13, 0))
        for c in range(3):
            colors[:, :, c] = np.clip(colors[:, :, c].astype(float)*(1+craters), 0, 255)
    colors[:, :, 3] = mask.astype(np.uint8)*255
    planet = Image.fromarray(colors)
    if name == 'saturn':
        rings = Image.new('RGBA', (W, H))
        draw = ImageDraw.Draw(rings)
        for rad in range(245, 330):
            alpha = 100 if rad % 9 < 3 else 180
            draw.ellipse((cx-rad, cy-rad*.29, cx+rad, cy+rad*.29), outline=(187, 167, 135, alpha), width=2)
        rings = rings.rotate(-22, resample=Image.Resampling.BICUBIC, center=(cx, cy))
        image.alpha_composite(rings)
        image.alpha_composite(planet)
        front = rings.copy()
        alpha = np.array(front.getchannel('A'))
        alpha[yy < cy - (xx-cx)*.4] = 0
        front.putalpha(Image.fromarray(alpha))
        image.alpha_composite(front)
    else:
        image.alpha_composite(planet)
    image.convert('RGB').save(OUT / f'{name}.png', optimize=True)
    print(name)
