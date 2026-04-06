// ignore_for_file: avoid_print
/// Generates all pixel art PNG assets for King of Chicago.
///
/// Run with: dart run tool/generate_assets.dart
///
/// Uses the `image` package to create noir pixel art programmatically.
library;

import 'dart:io';
import 'dart:math';

import 'package:image/image.dart' as img;

// ── Color palette ──────────────────────────────────────────────────────────

const int _black = 0xFF0D0B08;
const int _nearBlack = 0xFF1A1612;
const int _darkBrown = 0xFF2A2520;
const int _smoke = 0xFF3A3530;
const int _ash = 0xFF9C9488;
const int _parchment = 0xFFD4C5A9;
const int _gold = 0xFFC9A84C;
const int _goldHighlight = 0xFFE8D5A3;
const int _crimson = 0xFF8B1A1A;
const int _deepRed = 0xFF6B1010;
const int _steelBlue = 0xFF4A6B8A;
const int _coldBlue = 0xFF3A5570;
const int _warmAmber = 0xFFB8864A;
const int _amber = 0xFF9A7040;
const int _purple = 0xFF6A4A8A;
const int _green = 0xFF4A8A4A;
const int _orange = 0xFFB87A30;
const int _neonRed = 0xFFFF3030;
const int _neonBlue = 0xFF3060FF;
const int _neonPink = 0xFFFF4080;
const int _windowYellow = 0xFFE8C860;
const int _windowOrange = 0xFFD09840;
const int _lampGlow = 0xFFFFD080;
const int _skyDark = 0xFF0A0810;
const int _skyMid = 0xFF141020;

void main() {
  print('Generating King of Chicago pixel art assets...\n');

  _generatePortraits();
  _generateBackgrounds();
  _generateMotifs();
  _generateTitleScreen();

  print('\nAll assets generated successfully.');
}

// ── Helper functions ───────────────────────────────────────────────────────

img.Color _c(int argb) {
  final a = (argb >> 24) & 0xFF;
  final r = (argb >> 16) & 0xFF;
  final g = (argb >> 8) & 0xFF;
  final b = argb & 0xFF;
  return img.ColorRgba8(r, g, b, a);
}

void _setPixel(img.Image image, int x, int y, int color) {
  if (x >= 0 && x < image.width && y >= 0 && y < image.height) {
    image.setPixel(x, y, _c(color));
  }
}

int _blend(int c1, int c2, double t) {
  final a1 = (c1 >> 24) & 0xFF;
  final r1 = (c1 >> 16) & 0xFF;
  final g1 = (c1 >> 8) & 0xFF;
  final b1 = c1 & 0xFF;
  final a2 = (c2 >> 24) & 0xFF;
  final r2 = (c2 >> 16) & 0xFF;
  final g2 = (c2 >> 8) & 0xFF;
  final b2 = c2 & 0xFF;
  final a = (a1 + (a2 - a1) * t).round().clamp(0, 255);
  final r = (r1 + (r2 - r1) * t).round().clamp(0, 255);
  final g = (g1 + (g2 - g1) * t).round().clamp(0, 255);
  final b = (b1 + (b2 - b1) * t).round().clamp(0, 255);
  return (a << 24) | (r << 16) | (g << 8) | b;
}

void _fillRect(img.Image image, int x1, int y1, int x2, int y2, int color) {
  for (int y = y1; y <= y2; y++) {
    for (int x = x1; x <= x2; x++) {
      _setPixel(image, x, y, color);
    }
  }
}

void _fillCircle(img.Image image, int cx, int cy, int radius, int color) {
  for (int y = cy - radius; y <= cy + radius; y++) {
    for (int x = cx - radius; x <= cx + radius; x++) {
      if ((x - cx) * (x - cx) + (y - cy) * (y - cy) <= radius * radius) {
        _setPixel(image, x, y, color);
      }
    }
  }
}

void _drawLine(
    img.Image image, int x1, int y1, int x2, int y2, int color) {
  final dx = (x2 - x1).abs();
  final dy = (y2 - y1).abs();
  final sx = x1 < x2 ? 1 : -1;
  final sy = y1 < y2 ? 1 : -1;
  var err = dx - dy;
  var cx = x1;
  var cy = y1;
  while (true) {
    _setPixel(image, cx, cy, color);
    if (cx == x2 && cy == y2) break;
    final e2 = 2 * err;
    if (e2 > -dy) {
      err -= dy;
      cx += sx;
    }
    if (e2 < dx) {
      err += dx;
      cy += sy;
    }
  }
}

void _savePng(img.Image image, String path) {
  final file = File(path);
  file.createSync(recursive: true);
  file.writeAsBytesSync(img.encodePng(image));
  print('  Saved: $path');
}

// Dither helper: checkerboard dither between two colors
void _dither(
    img.Image image, int x1, int y1, int x2, int y2, int c1, int c2) {
  for (int y = y1; y <= y2; y++) {
    for (int x = x1; x <= x2; x++) {
      _setPixel(image, x, y, (x + y) % 2 == 0 ? c1 : c2);
    }
  }
}

// Vertical gradient fill
void _gradientV(
    img.Image image, int x1, int y1, int x2, int y2, int topColor,
    int bottomColor) {
  final h = y2 - y1;
  if (h <= 0) return;
  for (int y = y1; y <= y2; y++) {
    final t = (y - y1) / h;
    final c = _blend(topColor, bottomColor, t);
    for (int x = x1; x <= x2; x++) {
      _setPixel(image, x, y, c);
    }
  }
}

// ── Portrait generation ────────────────────────────────────────────────────

void _generatePortraits() {
  print('Generating portraits (64x64)...');

  _generateVince();
  _generateEnzo();
  _generateTommy();
  _generateRosa();
  _generateMickey();
  _generateNarrator();
}

void _generateVince() {
  final im = img.Image(width: 64, height: 64);
  // Dark background with slight warm tint
  _fillRect(im, 0, 0, 63, 63, _black);
  _dither(im, 0, 0, 63, 63, _black, _nearBlack);

  // Shoulders/body silhouette
  _fillRect(im, 14, 50, 50, 63, 0xFF151210);
  _fillRect(im, 10, 54, 54, 63, 0xFF151210);
  // Collar/lapels
  _fillRect(im, 22, 48, 26, 54, 0xFF1A1612);
  _fillRect(im, 38, 48, 42, 54, 0xFF1A1612);

  // Neck
  _fillRect(im, 28, 44, 36, 52, 0xFF2A2218);

  // Head - strong jaw
  _fillRect(im, 22, 22, 42, 44, 0xFF2A2218);
  _fillRect(im, 24, 18, 40, 44, 0xFF2A2218);
  // Jaw line emphasis
  _fillRect(im, 20, 36, 44, 40, 0xFF2A2218);

  // Fedora
  _fillRect(im, 16, 14, 48, 18, 0xFF151210);
  _fillRect(im, 20, 10, 44, 16, 0xFF151210);
  _fillRect(im, 22, 8, 42, 12, 0xFF151210);
  // Hat band
  _fillRect(im, 20, 14, 44, 15, _darkBrown);

  // Eyes - bright spots
  _setPixel(im, 28, 28, _gold);
  _setPixel(im, 29, 28, _gold);
  _setPixel(im, 36, 28, _gold);
  _setPixel(im, 37, 28, _gold);
  // Eye shadow
  _fillRect(im, 27, 26, 30, 27, 0xFF1A1410);
  _fillRect(im, 35, 26, 38, 27, 0xFF1A1410);

  // Nose shadow
  _setPixel(im, 32, 32, 0xFF1A1410);
  _setPixel(im, 33, 33, 0xFF1A1410);

  // Mouth line
  _fillRect(im, 29, 38, 35, 38, 0xFF1A1410);

  // Gold rim light on right side
  for (int y = 10; y < 48; y++) {
    _setPixel(im, 45, y, _blend(_gold, _black, 0.6));
    _setPixel(im, 44, y, _blend(_gold, _black, 0.8));
  }
  // Rim on hat
  for (int x = 40; x < 49; x++) {
    _setPixel(im, x, 14, _blend(_gold, _black, 0.5));
  }

  _savePng(im, 'assets/portraits/vince.png');
}

void _generateEnzo() {
  final im = img.Image(width: 64, height: 64);
  _fillRect(im, 0, 0, 63, 63, _black);
  _dither(im, 0, 0, 63, 63, _black, 0xFF0F0D0A);

  // Shoulders - distinguished suit
  _fillRect(im, 12, 50, 52, 63, 0xFF1A1612);
  _fillRect(im, 8, 56, 56, 63, 0xFF1A1612);

  // Neck
  _fillRect(im, 28, 44, 36, 52, 0xFF3A3028);

  // Head - rounder, older
  _fillRect(im, 22, 20, 42, 44, 0xFF3A3028);
  _fillRect(im, 24, 18, 40, 44, 0xFF3A3028);

  // Balding / grey hair on sides
  _fillRect(im, 20, 20, 23, 30, _ash);
  _fillRect(im, 41, 20, 44, 30, _ash);
  // Top of head slightly receded
  _fillRect(im, 26, 16, 38, 19, 0xFF3A3028);
  _fillRect(im, 30, 15, 34, 17, _ash);

  // Eyes - warm
  _setPixel(im, 28, 28, _warmAmber);
  _setPixel(im, 29, 28, _warmAmber);
  _setPixel(im, 36, 28, _warmAmber);
  _setPixel(im, 37, 28, _warmAmber);

  // Nose
  _setPixel(im, 32, 32, 0xFF2A2018);
  _setPixel(im, 33, 33, 0xFF2A2018);

  // Slight smile
  _fillRect(im, 28, 38, 36, 38, 0xFF2A2018);
  _setPixel(im, 27, 37, 0xFF2A2018);
  _setPixel(im, 37, 37, 0xFF2A2018);

  // Warm rim light
  for (int y = 16; y < 46; y++) {
    _setPixel(im, 43, y, _blend(_warmAmber, _black, 0.5));
    _setPixel(im, 42, y, _blend(_warmAmber, _black, 0.7));
  }

  _savePng(im, 'assets/portraits/enzo.png');
}

void _generateTommy() {
  final im = img.Image(width: 64, height: 64);
  _fillRect(im, 0, 0, 63, 63, _black);

  // Shoulders - slightly smaller/thinner
  _fillRect(im, 16, 52, 48, 63, 0xFF1A1815);
  _fillRect(im, 12, 56, 52, 63, 0xFF1A1815);

  // Neck
  _fillRect(im, 28, 44, 36, 54, 0xFF3A3530);

  // Head - younger, slightly narrower
  _fillRect(im, 24, 20, 40, 44, 0xFF3A3530);
  _fillRect(im, 26, 18, 38, 44, 0xFF3A3530);

  // Disheveled hair
  _fillRect(im, 22, 14, 42, 22, _darkBrown);
  _fillRect(im, 24, 12, 40, 16, _darkBrown);
  // Messy strands
  _setPixel(im, 22, 13, _darkBrown);
  _setPixel(im, 43, 16, _darkBrown);
  _setPixel(im, 21, 18, _darkBrown);
  _setPixel(im, 44, 20, _darkBrown);

  // Eyes - slightly wider, nervous
  _setPixel(im, 29, 27, _parchment);
  _setPixel(im, 30, 27, _parchment);
  _setPixel(im, 35, 27, _parchment);
  _setPixel(im, 36, 27, _parchment);
  // Brows raised
  _fillRect(im, 28, 25, 31, 25, 0xFF2A2520);
  _fillRect(im, 34, 25, 37, 25, 0xFF2A2520);

  // Nose
  _setPixel(im, 32, 32, 0xFF2A2520);

  // Slightly open mouth
  _fillRect(im, 30, 38, 34, 39, 0xFF1A1510);

  // Light tones rim
  for (int y = 14; y < 46; y++) {
    _setPixel(im, 41, y, _blend(_parchment, _black, 0.7));
  }

  _savePng(im, 'assets/portraits/tommy.png');
}

void _generateRosa() {
  final im = img.Image(width: 64, height: 64);
  _fillRect(im, 0, 0, 63, 63, _black);

  // Shoulders - elegant dress
  _fillRect(im, 16, 50, 48, 63, 0xFF1A1210);
  _fillRect(im, 12, 54, 52, 63, 0xFF1A1210);
  // Dress neckline
  _fillRect(im, 26, 48, 38, 52, _black);

  // Neck - slender
  _fillRect(im, 29, 42, 35, 50, 0xFF3A3028);

  // Head - sharp features
  _fillRect(im, 24, 20, 40, 42, 0xFF3A3028);
  _fillRect(im, 26, 18, 38, 42, 0xFF3A3028);
  // Chin - pointed
  _fillRect(im, 30, 42, 34, 44, 0xFF3A3028);

  // Dark hair - flowing
  _fillRect(im, 20, 12, 44, 22, 0xFF0A0808);
  _fillRect(im, 22, 10, 42, 14, 0xFF0A0808);
  // Hair on sides flowing down
  _fillRect(im, 20, 22, 24, 40, 0xFF0A0808);
  _fillRect(im, 40, 22, 44, 38, 0xFF0A0808);

  // Eyes - sharp, amber
  _setPixel(im, 28, 28, _warmAmber);
  _setPixel(im, 29, 28, _warmAmber);
  _setPixel(im, 35, 28, _warmAmber);
  _setPixel(im, 36, 28, _warmAmber);
  // Eyelashes/liner
  _setPixel(im, 27, 27, 0xFF0A0808);
  _setPixel(im, 30, 27, 0xFF0A0808);
  _setPixel(im, 34, 27, 0xFF0A0808);
  _setPixel(im, 37, 27, 0xFF0A0808);

  // Lips - slight color
  _fillRect(im, 29, 36, 35, 37, 0xFF5A2020);

  // Warm amber rim light
  for (int y = 12; y < 44; y++) {
    _setPixel(im, 45, y, _blend(_warmAmber, _black, 0.5));
    _setPixel(im, 44, y, _blend(_warmAmber, _black, 0.7));
  }

  _savePng(im, 'assets/portraits/rosa.png');
}

void _generateMickey() {
  final im = img.Image(width: 64, height: 64);
  _fillRect(im, 0, 0, 63, 63, _black);
  _dither(im, 0, 0, 63, 63, _black, 0xFF0A0A0E);

  // Shoulders - well-tailored
  _fillRect(im, 12, 50, 52, 63, 0xFF14161A);
  _fillRect(im, 8, 56, 56, 63, 0xFF14161A);

  // Neck
  _fillRect(im, 28, 44, 36, 52, 0xFF32343A);

  // Head
  _fillRect(im, 22, 20, 42, 44, 0xFF32343A);
  _fillRect(im, 24, 18, 40, 44, 0xFF32343A);

  // Well-groomed hair - slicked back
  _fillRect(im, 22, 12, 42, 22, 0xFF1A1A20);
  _fillRect(im, 24, 10, 40, 14, 0xFF1A1A20);
  // Hair shine line
  _fillRect(im, 30, 11, 36, 11, 0xFF2A2A30);

  // Eyes - cold, calculating
  _setPixel(im, 28, 28, _steelBlue);
  _setPixel(im, 29, 28, _steelBlue);
  _setPixel(im, 36, 28, _steelBlue);
  _setPixel(im, 37, 28, _steelBlue);
  // Slightly narrowed
  _fillRect(im, 27, 27, 30, 27, 0xFF1A1A20);
  _fillRect(im, 35, 27, 38, 27, 0xFF1A1A20);

  // Nose
  _setPixel(im, 32, 32, 0xFF2A2A30);

  // Cold smile
  _fillRect(im, 28, 38, 36, 38, 0xFF2A2A30);
  _setPixel(im, 27, 38, 0xFF2A2A30);
  _setPixel(im, 37, 38, 0xFF2A2A30);
  _setPixel(im, 27, 37, 0xFF2A2A30);
  _setPixel(im, 37, 37, 0xFF2A2A30);

  // Steel blue rim light
  for (int y = 12; y < 48; y++) {
    _setPixel(im, 43, y, _blend(_steelBlue, _black, 0.4));
    _setPixel(im, 42, y, _blend(_steelBlue, _black, 0.6));
  }

  _savePng(im, 'assets/portraits/mickey.png');
}

void _generateNarrator() {
  final im = img.Image(width: 64, height: 64);
  _fillRect(im, 0, 0, 63, 63, _black);

  // Typewriter icon
  // Body of typewriter
  _fillRect(im, 14, 30, 50, 48, _nearBlack);
  _fillRect(im, 12, 44, 52, 50, _darkBrown);

  // Paper coming out top
  _fillRect(im, 20, 10, 44, 32, 0xFF2A2822);
  // Text lines on paper
  for (int row = 0; row < 5; row++) {
    final y = 14 + row * 3;
    final width = 16 - (row == 4 ? 6 : 0);
    _fillRect(im, 24, y, 24 + width, y, _gold);
  }

  // Keys
  for (int row = 0; row < 2; row++) {
    for (int col = 0; col < 6; col++) {
      final x = 18 + col * 5;
      final y = 36 + row * 5;
      _fillRect(im, x, y, x + 3, y + 3, _smoke);
      _setPixel(im, x + 1, y + 1, _gold);
    }
  }

  // Gold border frame
  for (int x = 4; x < 60; x++) {
    _setPixel(im, x, 4, _gold);
    _setPixel(im, x, 58, _gold);
  }
  for (int y = 4; y < 58; y++) {
    _setPixel(im, 4, y, _gold);
    _setPixel(im, 59, y, _gold);
  }

  _savePng(im, 'assets/portraits/narrator.png');
}

// ── Background generation ──────────────────────────────────────────────────

void _generateBackgrounds() {
  print('\nGenerating backgrounds (320x180)...');

  _generateSouthSide();
  _generateLittleItaly();
  _generateTheLoop();
  _generateNorthSide();
  _generateWestSide();
  _generateStockyards();
  _generateGoldCoast();
  _generateLeveeDistrict();
}

final _rng = Random(42); // deterministic seed

void _scatterWindows(img.Image im, int bx1, int by1, int bx2, int by2,
    {double density = 0.15}) {
  for (int y = by1 + 2; y < by2 - 2; y += 4) {
    for (int x = bx1 + 2; x < bx2 - 2; x += 5) {
      if (_rng.nextDouble() < density) {
        final wc =
            _rng.nextBool() ? _windowYellow : _windowOrange;
        _fillRect(im, x, y, x + 1, y + 2, wc);
      }
    }
  }
}

void _drawRain(img.Image im, {int count = 80}) {
  for (int i = 0; i < count; i++) {
    final x = _rng.nextInt(im.width);
    final y = _rng.nextInt(im.height);
    final len = 2 + _rng.nextInt(3);
    for (int d = 0; d < len; d++) {
      _setPixel(im, x + d, y + d * 2, _blend(0xFF8090A0, _black, 0.6));
    }
  }
}

void _drawStreetlamp(img.Image im, int x, int groundY) {
  // Pole
  _fillRect(im, x, groundY - 40, x + 1, groundY, _smoke);
  // Lamp head
  _fillRect(im, x - 2, groundY - 42, x + 3, groundY - 40, _smoke);
  // Glow
  for (int r = 1; r <= 12; r++) {
    final alpha = (0.3 * (1.0 - r / 12.0));
    final gc = _blend(_lampGlow, _black, 1.0 - alpha);
    _fillCircle(im, x, groundY - 42, r, gc);
  }
}

void _generateSouthSide() {
  final im = img.Image(width: 320, height: 180);

  // Sky gradient - dark rainy
  _gradientV(im, 0, 0, 319, 80, 0xFF050510, 0xFF101020);

  // Rain clouds
  _dither(im, 0, 0, 319, 30, 0xFF080810, 0xFF101018);

  // Buildings - brownstone
  final heights = [60, 75, 55, 80, 65, 70, 50, 85, 60, 72];
  for (int i = 0; i < heights.length; i++) {
    final bx = i * 32;
    final by = 140 - heights[i];
    _fillRect(im, bx, by, bx + 28, 139, 0xFF141210);
    _scatterWindows(im, bx, by, bx + 28, 139);
  }

  // Street / ground
  _fillRect(im, 0, 140, 319, 179, 0xFF0A0A08);
  // Wet street reflections
  _dither(im, 0, 150, 319, 179, 0xFF0A0A08, 0xFF101010);

  // Streetlamps
  _drawStreetlamp(im, 80, 140);
  _drawStreetlamp(im, 240, 140);

  // Rain
  _drawRain(im, count: 120);

  _savePng(im, 'assets/backgrounds/south_side.png');
}

void _generateLittleItaly() {
  final im = img.Image(width: 320, height: 180);

  // Warm sky
  _gradientV(im, 0, 0, 319, 60, 0xFF0A0808, 0xFF181410);

  // Narrow buildings - warm tones
  final buildingColors = [0xFF1A1410, 0xFF201812, 0xFF181210, 0xFF1C1614];
  for (int i = 0; i < 8; i++) {
    final bx = i * 40;
    final h = 80 + _rng.nextInt(30);
    final by = 140 - h;
    _fillRect(im, bx, by, bx + 36, 139, buildingColors[i % 4]);
    _scatterWindows(im, bx, by, bx + 36, 139, density: 0.2);
  }

  // Laundry lines between buildings
  for (int line = 0; line < 3; line++) {
    final y = 60 + line * 18;
    final x1 = 30 + line * 20;
    final x2 = x1 + 80;
    _drawLine(im, x1, y, x2, y + 2, _ash);
    // Hanging clothes
    for (int c = 0; c < 4; c++) {
      final cx = x1 + 10 + c * 16;
      final cc = _rng.nextBool() ? _parchment : _ash;
      _fillRect(im, cx, y + 1, cx + 3, y + 6, cc);
    }
  }

  // Street
  _fillRect(im, 0, 140, 319, 179, 0xFF100E0A);

  // Warm window light spill on street
  for (int i = 0; i < 4; i++) {
    final x = 40 + i * 70;
    _fillRect(im, x, 142, x + 10, 150, _blend(_windowOrange, _black, 0.8));
  }

  _savePng(im, 'assets/backgrounds/little_italy.png');
}

void _generateTheLoop() {
  final im = img.Image(width: 320, height: 180);

  // Slightly brighter sky - downtown glow
  _gradientV(im, 0, 0, 319, 60, 0xFF080A14, 0xFF101520);

  // Tall buildings - downtown
  final heights = [100, 120, 90, 130, 110, 95, 125, 105];
  for (int i = 0; i < heights.length; i++) {
    final bx = i * 40;
    final by = 150 - heights[i];
    _fillRect(im, bx, by, bx + 36, 149, 0xFF141618);
    _scatterWindows(im, bx, by, bx + 36, 149, density: 0.25);
  }

  // Neon signs
  _fillRect(im, 60, 60, 90, 68, _neonRed);
  _fillRect(im, 180, 50, 210, 56, _neonBlue);
  _fillRect(im, 260, 70, 285, 76, _neonPink);
  // Neon glow
  for (int g = 1; g <= 4; g++) {
    _dither(im, 58 - g, 58 - g, 92 + g, 70 + g,
        _blend(_neonRed, _black, 0.8), _black);
  }

  // Wide avenue / street
  _fillRect(im, 0, 150, 319, 179, 0xFF0A0C10);
  // Street lights reflected
  for (int i = 0; i < 6; i++) {
    final x = 20 + i * 55;
    _fillRect(im, x, 155, x + 4, 170, _blend(_windowYellow, _black, 0.85));
  }

  _savePng(im, 'assets/backgrounds/the_loop.png');
}

void _generateNorthSide() {
  final im = img.Image(width: 320, height: 180);

  // Foggy sky
  _gradientV(im, 0, 0, 319, 80, 0xFF0A0E14, 0xFF1A2028);

  // Water
  _gradientV(im, 0, 120, 319, 179, 0xFF0A1018, 0xFF060A10);
  // Water reflections
  for (int i = 0; i < 40; i++) {
    final x = _rng.nextInt(320);
    final y = 130 + _rng.nextInt(45);
    _setPixel(im, x, y, _blend(0xFF2A3040, _black, 0.5));
  }

  // Dock pilings
  for (int i = 0; i < 8; i++) {
    final x = 20 + i * 40;
    _fillRect(im, x, 110, x + 2, 130, _darkBrown);
  }
  // Dock platform
  _fillRect(im, 0, 115, 319, 120, 0xFF1A1810);

  // Industrial buildings in background
  for (int i = 0; i < 5; i++) {
    final bx = i * 65;
    final h = 40 + _rng.nextInt(30);
    _fillRect(im, bx, 80 - h, bx + 55, 115, 0xFF12141A);
    _scatterWindows(im, bx, 80 - h, bx + 55, 115, density: 0.1);
  }

  // Fog layer
  _dither(im, 0, 60, 319, 100, _blend(0xFF3040, _black, 0.9), _black);

  _savePng(im, 'assets/backgrounds/north_side.png');
}

void _generateWestSide() {
  final im = img.Image(width: 320, height: 180);

  // Very dark sky
  _gradientV(im, 0, 0, 319, 60, 0xFF050508, 0xFF0A0A0E);

  // Empty lot ground
  _fillRect(im, 0, 130, 319, 179, 0xFF0E0C0A);
  _dither(im, 0, 140, 319, 179, 0xFF0E0C0A, 0xFF0A0808);

  // Burned/ruined buildings
  // Jagged tops to suggest ruin
  _fillRect(im, 20, 50, 70, 130, 0xFF101010);
  _fillRect(im, 30, 45, 50, 50, 0xFF101010);
  _fillRect(im, 55, 40, 70, 50, 0xFF101010);

  _fillRect(im, 120, 60, 180, 130, 0xFF101010);
  _fillRect(im, 130, 50, 150, 60, 0xFF101010);

  _fillRect(im, 230, 55, 300, 130, 0xFF101010);
  _fillRect(im, 240, 45, 260, 55, 0xFF101010);
  _fillRect(im, 275, 48, 295, 55, 0xFF101010);

  // Faint fire glow in one window
  _fillRect(im, 140, 80, 145, 85, _blend(_crimson, _black, 0.5));

  // Menacing atmosphere - dark wisps
  for (int i = 0; i < 20; i++) {
    final x = _rng.nextInt(320);
    final y = 100 + _rng.nextInt(30);
    _setPixel(im, x, y, 0xFF141414);
  }

  _savePng(im, 'assets/backgrounds/west_side.png');
}

void _generateStockyards() {
  final im = img.Image(width: 320, height: 180);

  // Brown hazy sky
  _gradientV(im, 0, 0, 319, 80, 0xFF0A0808, 0xFF1A1410);

  // Smokestacks
  for (int i = 0; i < 4; i++) {
    final x = 40 + i * 75;
    _fillRect(im, x, 20, x + 8, 120, 0xFF181614);
    // Smoke
    for (int s = 0; s < 8; s++) {
      final sx = x - 5 + _rng.nextInt(20);
      final sy = 10 + _rng.nextInt(15) - s * 2;
      _fillCircle(im, sx, sy, 3 + _rng.nextInt(4),
          _blend(0xFF2A2420, _black, 0.6));
    }
  }

  // Industrial buildings
  _fillRect(im, 0, 80, 319, 120, 0xFF141210);
  _fillRect(im, 0, 100, 319, 120, 0xFF181614);

  // Rail lines
  _fillRect(im, 0, 125, 319, 126, 0xFF2A2820);
  _fillRect(im, 0, 135, 319, 136, 0xFF2A2820);
  // Ties
  for (int x = 0; x < 320; x += 8) {
    _fillRect(im, x, 124, x + 2, 137, 0xFF1A1810);
  }

  // Ground
  _fillRect(im, 0, 140, 319, 179, 0xFF0E0C08);
  // Brown haze dither
  _dither(im, 0, 0, 319, 40, 0xFF0A0808, _blend(0xFF1A1410, _black, 0.8));

  _savePng(im, 'assets/backgrounds/stockyards.png');
}

void _generateGoldCoast() {
  final im = img.Image(width: 320, height: 180);

  // Slightly warmer sky - refined
  _gradientV(im, 0, 0, 319, 70, 0xFF080810, 0xFF101018);

  // Elegant mansions
  for (int i = 0; i < 4; i++) {
    final bx = i * 80;
    // Main building
    _fillRect(im, bx + 5, 60, bx + 70, 130, 0xFF181820);
    // Peaked roof
    for (int r = 0; r < 15; r++) {
      _fillRect(im, bx + 5 + r, 60 - r, bx + 70 - r, 60 - r, 0xFF181820);
    }
    // Many warm windows
    for (int wy = 0; wy < 4; wy++) {
      for (int wx = 0; wx < 4; wx++) {
        final px = bx + 12 + wx * 14;
        final py = 70 + wy * 14;
        _fillRect(im, px, py, px + 4, py + 6, _windowYellow);
      }
    }
    // Door
    _fillRect(im, bx + 32, 115, bx + 40, 130, _darkBrown);
  }

  // Gas lamps
  for (int i = 0; i < 6; i++) {
    _drawStreetlamp(im, 15 + i * 55, 135);
  }

  // Manicured trees
  for (int i = 0; i < 5; i++) {
    final tx = 30 + i * 65;
    // Trunk
    _fillRect(im, tx, 120, tx + 2, 135, _darkBrown);
    // Foliage - dark rounded
    _fillCircle(im, tx + 1, 115, 8, 0xFF0A1A0A);
    _fillCircle(im, tx + 1, 115, 6, 0xFF102010);
  }

  // Street
  _fillRect(im, 0, 135, 319, 179, 0xFF0E0E10);

  _savePng(im, 'assets/backgrounds/gold_coast.png');
}

void _generateLeveeDistrict() {
  final im = img.Image(width: 320, height: 180);

  // Dark sky with glow
  _gradientV(im, 0, 0, 319, 60, 0xFF0A0810, 0xFF141018);

  // Buildings
  for (int i = 0; i < 8; i++) {
    final bx = i * 40;
    final h = 70 + _rng.nextInt(30);
    _fillRect(im, bx, 140 - h, bx + 36, 139, 0xFF141214);
  }

  // Neon club signs
  _fillRect(im, 20, 75, 60, 82, _neonRed);
  _fillRect(im, 100, 80, 140, 86, _neonPink);
  _fillRect(im, 200, 70, 240, 77, _neonBlue);
  _fillRect(im, 270, 78, 305, 84, _neonRed);

  // Neon glow halos
  for (int r = 1; r <= 6; r++) {
    final t = r / 6.0;
    _dither(im, 18 - r, 73 - r, 62 + r, 84 + r,
        _blend(_neonRed, _black, 0.7 + 0.3 * t), _black);
    _dither(im, 98 - r, 78 - r, 142 + r, 88 + r,
        _blend(_neonPink, _black, 0.7 + 0.3 * t), _black);
  }

  // Figures in doorways (small silhouettes)
  for (int i = 0; i < 4; i++) {
    final fx = 30 + i * 75;
    // Doorway
    _fillRect(im, fx, 120, fx + 8, 139, 0xFF0A0808);
    // Figure silhouette
    _fillRect(im, fx + 2, 125, fx + 6, 139, 0xFF060606);
    // Head
    _fillCircle(im, fx + 4, 124, 2, 0xFF060606);
  }

  // Street
  _fillRect(im, 0, 140, 319, 179, 0xFF0C0A0E);
  // Neon reflections on wet street
  _dither(im, 18, 145, 62, 160,
      _blend(_neonRed, _black, 0.9), 0xFF0C0A0E);
  _dither(im, 98, 145, 142, 160,
      _blend(_neonPink, _black, 0.9), 0xFF0C0A0E);

  _savePng(im, 'assets/backgrounds/levee_district.png');
}

// ── Motif generation ───────────────────────────────────────────────────────

void _generateMotifs() {
  print('\nGenerating motifs (32x32)...');

  _generateDread();
  _generateRespect();
  _generateSway();
  _generateEmpire();
  _generateGuile();
  _generateLegend();
  _generateKinship();
}

void _generateDread() {
  final im = img.Image(width: 32, height: 32);
  _fillRect(im, 0, 0, 31, 31, 0x00000000); // transparent

  // Skull shape - red
  _fillCircle(im, 16, 12, 8, _crimson);
  // Jaw
  _fillRect(im, 10, 14, 22, 20, _crimson);
  // Eye sockets
  _fillRect(im, 11, 10, 14, 13, _black);
  _fillRect(im, 18, 10, 21, 13, _black);
  // Nose
  _setPixel(im, 15, 15, _black);
  _setPixel(im, 17, 15, _black);
  // Teeth
  for (int x = 11; x <= 21; x += 2) {
    _setPixel(im, x, 19, _black);
  }

  // Knife below
  _fillRect(im, 15, 22, 17, 30, _deepRed);
  _setPixel(im, 16, 21, _deepRed);

  _savePng(im, 'assets/motifs/dread.png');
}

void _generateRespect() {
  final im = img.Image(width: 32, height: 32);
  _fillRect(im, 0, 0, 31, 31, 0x00000000);

  // Handshake - two hands clasping
  // Left hand
  _fillRect(im, 4, 12, 14, 16, _gold);
  _fillRect(im, 4, 10, 8, 12, _gold);
  // Right hand
  _fillRect(im, 16, 12, 26, 16, _goldHighlight);
  _fillRect(im, 22, 10, 26, 12, _goldHighlight);
  // Clasp area
  _fillRect(im, 12, 11, 18, 17, _gold);
  // Fingers interlocked
  _setPixel(im, 13, 11, _goldHighlight);
  _setPixel(im, 15, 11, _gold);
  _setPixel(im, 17, 11, _goldHighlight);
  // Wrists
  _fillRect(im, 2, 14, 5, 18, _gold);
  _fillRect(im, 25, 14, 28, 18, _goldHighlight);

  _savePng(im, 'assets/motifs/respect.png');
}

void _generateSway() {
  final im = img.Image(width: 32, height: 32);
  _fillRect(im, 0, 0, 31, 31, 0x00000000);

  // Gavel
  // Head
  _fillRect(im, 8, 6, 22, 10, _steelBlue);
  // Handle
  _fillRect(im, 14, 10, 16, 24, _coldBlue);
  // Impact star
  _setPixel(im, 15, 26, _steelBlue);
  _setPixel(im, 13, 27, _coldBlue);
  _setPixel(im, 17, 27, _coldBlue);
  _setPixel(im, 11, 28, _coldBlue);
  _setPixel(im, 19, 28, _coldBlue);

  // Base
  _fillRect(im, 6, 28, 24, 30, _steelBlue);

  _savePng(im, 'assets/motifs/sway.png');
}

void _generateEmpire() {
  final im = img.Image(width: 32, height: 32);
  _fillRect(im, 0, 0, 31, 31, 0x00000000);

  // Stack of coins
  for (int i = 0; i < 4; i++) {
    final y = 22 - i * 5;
    final gc = i == 0 ? _green : _blend(_green, 0xFF6ABA6A, i / 4.0);
    // Coin top (ellipse approx)
    _fillRect(im, 10, y, 22, y + 2, gc);
    _fillRect(im, 8, y + 1, 24, y + 1, gc);
    // Coin side
    _fillRect(im, 10, y + 2, 22, y + 4, _blend(gc, _black, 0.3));
  }

  // Dollar sign on top coin
  _fillRect(im, 15, 6, 17, 12, 0xFF2A5A2A);

  _savePng(im, 'assets/motifs/empire.png');
}

void _generateGuile() {
  final im = img.Image(width: 32, height: 32);
  _fillRect(im, 0, 0, 31, 31, 0x00000000);

  // Chess knight piece
  // Base
  _fillRect(im, 8, 26, 24, 30, _purple);
  _fillRect(im, 10, 24, 22, 26, _purple);
  // Body
  _fillRect(im, 12, 14, 20, 24, _purple);
  // Head
  _fillRect(im, 10, 8, 20, 14, _purple);
  // Snout forward
  _fillRect(im, 8, 10, 12, 13, _purple);
  // Ear
  _fillRect(im, 18, 4, 20, 8, _purple);
  // Eye
  _setPixel(im, 14, 10, _black);

  // Highlight edge
  for (int y = 4; y < 30; y++) {
    if (y >= 4 && y <= 8) _setPixel(im, 20, y, _blend(_purple, _parchment, 0.3));
    if (y >= 8 && y <= 24) _setPixel(im, 20, y, _blend(_purple, _parchment, 0.3));
  }

  _savePng(im, 'assets/motifs/guile.png');
}

void _generateLegend() {
  final im = img.Image(width: 32, height: 32);
  _fillRect(im, 0, 0, 31, 31, 0x00000000);

  // Newspaper
  _fillRect(im, 4, 4, 28, 28, _blend(_orange, _parchment, 0.5));
  // Fold line
  _fillRect(im, 4, 15, 28, 16, _blend(_orange, _black, 0.3));

  // Headline
  _fillRect(im, 6, 6, 26, 8, _orange);

  // Text lines
  for (int row = 0; row < 3; row++) {
    final y = 10 + row * 3;
    _fillRect(im, 6, y, 20 + _rng.nextInt(6), y, _blend(_orange, _black, 0.4));
  }

  // Subheadline
  _fillRect(im, 6, 18, 22, 19, _orange);

  // More text
  for (int row = 0; row < 3; row++) {
    final y = 21 + row * 3;
    _fillRect(im, 6, y, 18 + _rng.nextInt(8), y, _blend(_orange, _black, 0.4));
  }

  _savePng(im, 'assets/motifs/legend.png');
}

void _generateKinship() {
  final im = img.Image(width: 32, height: 32);
  _fillRect(im, 0, 0, 31, 31, 0x00000000);

  final brown = 0xFF8A6A40;
  final darkBr = _blend(brown, _black, 0.3);

  // House shape
  // Walls
  _fillRect(im, 6, 16, 26, 28, brown);
  // Roof triangle
  for (int r = 0; r < 10; r++) {
    _fillRect(im, 6 + r, 16 - r, 26 - r, 16 - r, darkBr);
  }
  // Roof peak
  _setPixel(im, 16, 6, darkBr);

  // Door
  _fillRect(im, 14, 20, 18, 28, darkBr);
  // Door knob
  _setPixel(im, 17, 24, _gold);

  // Windows
  _fillRect(im, 8, 18, 12, 22, _windowYellow);
  _fillRect(im, 20, 18, 24, 22, _windowYellow);

  // Chimney
  _fillRect(im, 22, 8, 24, 14, darkBr);

  // Warm glow from windows
  _setPixel(im, 7, 23, _blend(_windowYellow, _black, 0.7));
  _setPixel(im, 25, 23, _blend(_windowYellow, _black, 0.7));

  _savePng(im, 'assets/motifs/kinship.png');
}

// ── Title screen ───────────────────────────────────────────────────────────

void _generateTitleScreen() {
  print('\nGenerating title screen (480x270)...');

  final im = img.Image(width: 480, height: 270);

  // Background gradient - deep noir
  _gradientV(im, 0, 0, 479, 269, _black, _nearBlack);

  // Art deco border - outer
  _drawDecoBorder(im, 8, 8, 471, 261, _gold);
  // Inner border
  _drawDecoBorder(im, 16, 16, 463, 253, _blend(_gold, _black, 0.5));

  // Art deco decorative corners
  _drawDecoCorner(im, 12, 12, 1, 1);
  _drawDecoCorner(im, 467, 12, -1, 1);
  _drawDecoCorner(im, 12, 257, 1, -1);
  _drawDecoCorner(im, 467, 257, -1, -1);

  // Top decoration - fan/sunburst
  for (int i = 0; i < 12; i++) {
    final angle = (i - 6) * 0.12;
    for (int r = 10; r < 40; r++) {
      final x = 240 + (sin(angle) * r).round();
      final y = 40 + (cos(angle) * r * -1).round();
      _setPixel(im, x, y, _blend(_gold, _black, 0.4 + r / 80.0));
    }
  }

  // "KING OF" text (pixel font, large)
  _drawPixelText(im, 'KING OF', 160, 80, _goldHighlight, scale: 3);

  // "CHICAGO" text (larger)
  _drawPixelText(im, 'CHICAGO', 130, 120, _gold, scale: 4);

  // Decorative line under title
  _fillRect(im, 100, 165, 380, 165, _gold);
  _fillRect(im, 120, 167, 360, 167, _blend(_gold, _black, 0.5));
  // Diamond center
  _setPixel(im, 239, 164, _goldHighlight);
  _setPixel(im, 240, 163, _goldHighlight);
  _setPixel(im, 241, 164, _goldHighlight);
  _setPixel(im, 240, 165, _goldHighlight);

  // Subtitle
  _drawPixelText(im, 'A PROHIBITION ERA SAGA', 138, 185, _ash, scale: 1);

  // Bottom decoration
  _fillRect(im, 160, 220, 320, 220, _gold);
  // Diamond accents
  for (int d = 0; d < 3; d++) {
    final dx = 200 + d * 40;
    _setPixel(im, dx, 218, _gold);
    _setPixel(im, dx - 1, 219, _gold);
    _setPixel(im, dx + 1, 219, _gold);
    _setPixel(im, dx, 220, _gold);
  }

  // City skyline silhouette at bottom
  final skyline = [30, 50, 35, 60, 40, 55, 45, 70, 35, 50, 40, 65, 30, 55, 45, 38];
  for (int i = 0; i < skyline.length; i++) {
    final bx = 30 + i * 26;
    _fillRect(im, bx, 269 - skyline[i], bx + 22, 269, 0xFF0A0808);
  }

  _savePng(im, 'assets/title_screen.png');
}

void _drawDecoBorder(img.Image im, int x1, int y1, int x2, int y2, int color) {
  // Top & bottom
  for (int x = x1; x <= x2; x++) {
    _setPixel(im, x, y1, color);
    _setPixel(im, x, y2, color);
  }
  // Left & right
  for (int y = y1; y <= y2; y++) {
    _setPixel(im, x1, y, color);
    _setPixel(im, x2, y, color);
  }
}

void _drawDecoCorner(img.Image im, int cx, int cy, int dx, int dy) {
  // Small art deco corner flourish
  for (int i = 0; i < 8; i++) {
    _setPixel(im, cx + i * dx, cy, _gold);
    _setPixel(im, cx, cy + i * dy, _gold);
    _setPixel(im, cx + i * dx, cy + i * dy, _blend(_gold, _black, 0.5));
  }
}

// Minimal pixel font - uppercase letters and space
const Map<String, List<int>> _font = {
  'A': [0x7C, 0x92, 0x92, 0x7C, 0x92],
  'B': [0xFE, 0x92, 0x92, 0x6C, 0x00],
  'C': [0x7C, 0x82, 0x82, 0x44, 0x00],
  'D': [0xFE, 0x82, 0x82, 0x7C, 0x00],
  'E': [0xFE, 0x92, 0x92, 0x82, 0x00],
  'F': [0xFE, 0x90, 0x90, 0x80, 0x00],
  'G': [0x7C, 0x82, 0x92, 0x5C, 0x00],
  'H': [0xFE, 0x10, 0x10, 0xFE, 0x00],
  'I': [0x82, 0xFE, 0x82, 0x00, 0x00],
  'J': [0x04, 0x02, 0x82, 0xFC, 0x00],
  'K': [0xFE, 0x10, 0x28, 0xC6, 0x00],
  'L': [0xFE, 0x02, 0x02, 0x02, 0x00],
  'M': [0xFE, 0x40, 0x20, 0x40, 0xFE],
  'N': [0xFE, 0x40, 0x20, 0xFE, 0x00],
  'O': [0x7C, 0x82, 0x82, 0x7C, 0x00],
  'P': [0xFE, 0x90, 0x90, 0x60, 0x00],
  'Q': [0x7C, 0x82, 0x8A, 0x7C, 0x02],
  'R': [0xFE, 0x90, 0x98, 0x66, 0x00],
  'S': [0x64, 0x92, 0x92, 0x4C, 0x00],
  'T': [0x80, 0xFE, 0x80, 0x00, 0x00],
  'U': [0xFC, 0x02, 0x02, 0xFC, 0x00],
  'V': [0xF0, 0x0C, 0x02, 0x0C, 0xF0],
  'W': [0xFE, 0x04, 0x08, 0x04, 0xFE],
  'X': [0xC6, 0x28, 0x10, 0x28, 0xC6],
  'Y': [0xC0, 0x20, 0x1E, 0x20, 0xC0],
  'Z': [0x86, 0x8A, 0x92, 0xA2, 0xC2],
  ' ': [0x00, 0x00, 0x00, 0x00, 0x00],
};

void _drawPixelText(
    img.Image im, String text, int startX, int startY, int color,
    {int scale = 1}) {
  var x = startX;
  for (final ch in text.split('')) {
    final glyph = _font[ch.toUpperCase()];
    if (glyph == null) {
      x += 4 * scale;
      continue;
    }
    for (int col = 0; col < glyph.length; col++) {
      final bits = glyph[col];
      for (int row = 0; row < 8; row++) {
        if ((bits >> (7 - row)) & 1 == 1) {
          for (int sy = 0; sy < scale; sy++) {
            for (int sx = 0; sx < scale; sx++) {
              _setPixel(im, x + col * scale + sx,
                  startY + row * scale + sy, color);
            }
          }
        }
      }
    }
    x += (glyph.length + 1) * scale;
  }
}
