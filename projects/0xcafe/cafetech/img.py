import io
from PIL import Image
import random
import hashlib

def generate_8bit_pattern(seed_string: str, width: int = 1024, height: int = 512, pattern_size: int = 16, color_palette = None) -> bytes:
    if not color_palette:
        color_palette = [
            (120, 100, 102),  # muted red
            (78, 105, 120),   # muted blue
            (105, 120, 78),   # muted green
            (120, 115, 75),   # muted yellow
            (88, 88, 88),     # muted grey
        ]
    # Set the seed for random number generator
    seed_hash = hashlib.sha256(seed_string.encode()).hexdigest()
    random.seed(int(seed_hash, 16) % (2**32))

    # Create a new image with the given width and height
    image = Image.new("RGB", (width, height))

    # Generate a random 8-bit pattern
    for x in range(0, width, pattern_size):
        for y in range(0, height, pattern_size):
            # Choose a random color from the palette
            color = random.choice(color_palette)
            for i in range(pattern_size):
                for j in range(pattern_size):
                    # Set the color of the pixel
                    image.putpixel((x+i, y+j), color)

    img_byte_array = io.BytesIO()
    image.save(img_byte_array, format='PNG')
    return img_byte_array.getvalue()
