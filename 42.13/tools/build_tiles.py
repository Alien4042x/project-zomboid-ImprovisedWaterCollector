#!/usr/bin/env python3
"""Generate PZ tile pack (.pack) + tile definitions (.tiles) for IWC bins.

Layout: single-row tilesheet with 5 sprites (128x256 each for 2x, 64x128 for 1x).
Tile names: IWC_bins_01_0 .. IWC_bins_01_4.
"""
import os, struct, io
from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(ROOT, 'extract_preview')
OUT_PACK = os.path.join(ROOT, 'media', 'texturepacks')
OUT_TILES = os.path.join(ROOT, 'media')
os.makedirs(OUT_PACK, exist_ok=True)
os.makedirs(OUT_TILES, exist_ok=True)

SHEET = 'IWC_bins_01'
SPRITES = [
    ('IWC_bins_01_0', 'trashcontainers_01_16_1.png'),  # Recycle
    ('IWC_bins_01_1', 'trashcontainers_01_18_1.png'),  # Gray
    ('IWC_bins_01_2', 'trashcontainers_01_20_1.png'),  # Round
    ('IWC_bins_01_3', 'trashcontainers_01_21_1.png'),  # Public
    ('IWC_bins_01_4', 'trashcontainers_01_17.png'),    # Green (same craft & world)
]

TILE_META = [
    ("Water Collecting Recycle Bin", "Base.Mov_IWC_RecycleBin"),
    ("Water Collecting Gray Bin", "Base.Mov_IWC_GrayGarbageBin"),
    ("Water Collecting Round Bin", "Base.Mov_IWC_BinRound"),
    ("Water Collecting Public Bin", "Base.Mov_IWC_PublicGarbageBin"),
    ("Water Collecting Green Bin", "Base.Mov_IWC_GreenGarbageBin"),
]
TILE_W_2X, TILE_H_2X = 128, 256
TILE_W_1X, TILE_H_1X = 64, 128

def build_pack(out_path, page_name, tile_w, tile_h, scale):
    cols = len(SPRITES)
    sheet = Image.new('RGBA', (tile_w*cols, tile_h), (0,0,0,0))
    for i,(_,fn) in enumerate(SPRITES):
        img = Image.open(os.path.join(SRC, fn)).convert('RGBA')
        if img.size != (TILE_W_2X, TILE_H_2X):
            img = img.resize((TILE_W_2X, TILE_H_2X), Image.LANCZOS)
        if scale != 1.0:
            img = img.resize((tile_w, tile_h), Image.LANCZOS)
        sheet.paste(img, (tile_w*i, 0), img)
    buf = io.BytesIO()
    sheet.save(buf, 'PNG')
    png = buf.getvalue()

    # single-page pack format (no PZPK magic)
    out = bytearray()
    out += struct.pack('<I', 1)                         # version
    out += struct.pack('<I', len(page_name)) + page_name.encode()
    out += struct.pack('<I', len(SPRITES))              # numSprites
    out += struct.pack('<I', 1)                         # hasMask flag
    for i,(name,_) in enumerate(SPRITES):
        out += struct.pack('<I', len(name)) + name.encode()
        x = tile_w*i; y = 0; w = tile_w; h = tile_h
        ox, oy = 0, 0
        ow, oh = tile_w, tile_h
        out += struct.pack('<8i', x, y, w, h, ox, oy, ow, oh)
    out += png                                          # raw PNG, no length prefix
    out += struct.pack('<I', 0xDEADBEEF)                # end marker
    with open(out_path, 'wb') as f:
        f.write(out)
    print('wrote', out_path, 'pngsize', sheet.size)

def build_tiles(out_path):
    props_per_tile = []
    for i in range(len(SPRITES)):
        custom_name, custom_item = TILE_META[i]
        props_per_tile.append([
            ('BlocksPlacement', ''),
            ('CustomName', custom_name),
            ('CustomItem', custom_item),
            ('IsMoveAble', ''),
            ('IsWaterCollector', ''),
            ('PickUpWeight', '100'),
            ('solidtrans', ''),
        ])
    out = bytearray()
    out += b'tdef'
    out += struct.pack('<I', 1)      # version
    out += struct.pack('<I', 1)      # numSheets
    out += (SHEET + '\n').encode()
    out += (SHEET + '.png\n').encode()
    cols = len(SPRITES); rows = 1
    out += struct.pack('<I', cols)
    out += struct.pack('<I', rows)
    out += struct.pack('<I', 1)      # unknown
    out += struct.pack('<I', cols*rows)  # totalTiles
    for props in props_per_tile:
        out += struct.pack('<I', len(props))
        for n,v in props:
            out += (n + '\n' + v + '\n').encode()
    with open(out_path, 'wb') as f:
        f.write(out)
    print('wrote', out_path)

build_pack(os.path.join(OUT_PACK, 'iwc_bins.pack'), 'iwc_bins0', TILE_W_2X, TILE_H_2X, 1.0)
build_tiles(os.path.join(OUT_TILES, 'tiledefinitions.tiles'))
