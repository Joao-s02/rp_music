"""Deriva iconos de plataforma de la variante A aprobada. Requiere Pillow.

Ejecutar desde cualquier carpeta: python tools/generar_iconos.py
No regenera ni redibuja el diseño original.
"""
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / 'assets/branding/rp-music-variant-a.png'
source = Image.open(SOURCE).convert('RGB')
assert source.width == source.height
resample = Image.Resampling.LANCZOS

def save_icon(relative, size, safe=False):
    target = ROOT / relative
    target.parent.mkdir(parents=True, exist_ok=True)
    if safe:
        image = Image.new('RGB', (size, size), '#10131a')
        inner = round(size * 2 / 3)
        image.paste(source.resize((inner, inner), resample),
                    ((size - inner) // 2, (size - inner) // 2))
    else:
        image = source.resize((size, size), resample)
    image.save(target)
    with Image.open(target) as check:
        assert check.size == (size, size)
    return image

for density, size in [('mdpi', 48), ('hdpi', 72), ('xhdpi', 96),
                      ('xxhdpi', 144), ('xxxhdpi', 192)]:
    save_icon(f'android/app/src/main/res/mipmap-{density}/ic_launcher.png', size)

# Android adaptive layers: extra margin protects RP and bars against mask crops.
save_icon('android/app/src/main/res/drawable-nodpi/ic_launcher_foreground.png', 432, True)
ico = ROOT / 'windows/runner/resources/app_icon.ico'
source.resize((256, 256), resample).save(
    ico, sizes=[(n, n) for n in [16, 24, 32, 48, 64, 128, 256]])
with Image.open(ico) as check:
    assert check.ico.sizes() == {(n, n) for n in [16, 24, 32, 48, 64, 128, 256]}
for size in [192, 512]:
    save_icon(f'web/icons/Icon-{size}.png', size)
    save_icon(f'web/icons/Icon-maskable-{size}.png', size, True)
save_icon('web/favicon.png', 32)
print('Iconos Android, Windows (7 resoluciones) y web generados y verificados.')
