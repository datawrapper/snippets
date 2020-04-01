#!/usr/bin/env python3

import argparse
import sys
from colorsys import rgb_to_hsv
from pathlib import Path
from typing import Tuple

import pandas as pd
from PIL import Image, ImageOps

from selenium import webdriver


def color_8bit_to_float(color_8bit: Tuple[int, ...]) -> Tuple[float, ...]:
    return tuple(x / 255 for x in color_8bit)


def rgb_to_hex(rgb: Tuple[float, float, float]) -> str:
    r, g, b = (round(x * 255) for x in rgb)
    return f'#{r:02x}{g:02x}{b:02x}'


def hex_to_rgb(h: str) -> Tuple[float, ...]:
    return tuple(int(h[i : i + 2], 16) / 255 for i in (1, 3, 5))


def hex_to_h(h: str) -> float:
    rgb = hex_to_rgb(h)
    hsv = rgb_to_hsv(*rgb)
    return hsv[0]


def take_screenshot(url: str, path: str):
    options = webdriver.FirefoxOptions()
    options.headless = True
    driver = webdriver.Firefox(options=options)
    driver.get(url)
    try:
        driver.save_screenshot(path)
    finally:
        driver.quit()


def analyze_image(
    path: str, posterize_bits: int = 4, min_frequency: float = 0.0001,
) -> pd.Series:
    im = Image.open(path).convert(mode='RGB')
    im = ImageOps.posterize(im, posterize_bits)
    pixels = pd.Series(list(im.getdata()), name='frequency')
    pixels = pixels.apply(color_8bit_to_float)
    pixels = pixels.apply(rgb_to_hex)
    counts = pixels.value_counts(normalize=True)
    counts = counts[counts > min_frequency]
    counts = counts / counts.sum()
    df = pd.DataFrame(
        {
            'frequency': counts.values,
            'h': counts.index.to_series().apply(hex_to_h),
        },
        index=counts.index,
    )
    df.sort_values(by='h', inplace=True)
    return df['frequency']


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('-u', '--url', required=True)
    parser.add_argument('-s', '--screenshot-path', required=True)
    args = parser.parse_args()
    if not Path(args.screenshot_path).exists():
        take_screenshot(args.url, args.screenshot_path)
    counts = analyze_image(args.screenshot_path)
    counts.to_csv(sys.stdout, index_label='color')


if __name__ == '__main__':
    main()
