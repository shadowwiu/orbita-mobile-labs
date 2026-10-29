"""Generate the original Orbita launcher icon (requires Pillow)."""
from pathlib import Path
from PIL import Image, ImageDraw

root = Path(__file__).resolve().parents[1]
image = Image.new('RGB', (512, 512), '#10151D')
draw = ImageDraw.Draw(image)
draw.ellipse((160, 160, 352, 352), fill='#C4ECA0')
draw.arc((72, 184, 440, 328), 0, 360, fill='#90A0AF', width=14)
draw.ellipse((150, 150, 362, 270), fill='#10151D')
draw.ellipse((160, 160, 352, 352), fill='#C4ECA0')
draw.arc((72, 184, 440, 328), 0, 180, fill='#C4ECA0', width=14)
draw.ellipse((384, 178, 412, 206), fill='#C4ECA0')
for folder, size in [('mdpi', 48), ('hdpi', 72), ('xhdpi', 96), ('xxhdpi', 144), ('xxxhdpi', 192)]:
    target = root / 'android/app/src/main/res' / f'mipmap-{folder}' / 'ic_launcher.png'
    image.resize((size, size), Image.Resampling.LANCZOS).save(target)
for size in [192, 512]:
    for name in [f'Icon-{size}.png', f'Icon-maskable-{size}.png']:
        image.resize((size, size), Image.Resampling.LANCZOS).save(root / 'web/icons' / name)
image.resize((32, 32), Image.Resampling.LANCZOS).save(root / 'web/favicon.png')
