import 'dart:math';

import 'package:fast_noise/fast_noise.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

/// Inspired by this coding challenge from The Coding Train:
/// https://thecodingtrain.com/challenges/103-fire-effect
///
/// Based on this article :
/// https://web.archive.org/web/20160418004150/http://freespace.virgin.net/hugo.elias/models/m_fire.htm
class FireSim extends Game with SingleGameInstance {
  FireSim() {
    buffer1 = List.filled(width * height, 0);
    buffer2 = List.filled(width * height, 0);
    coolmap = List.filled(width * height, 0);
  }

  final viewport = FixedResolutionViewport(Vector2(160, 100));
  final white = Paint()..color = const Color(0xFFFFFFFF);
  final noise = PerlinNoise();

  List<int> buffer1 = [];
  List<int> buffer2 = [];
  List<double> coolmap = [];

  int get width => viewport.effectiveSize.x.toInt();
  int get height => viewport.effectiveSize.y.toInt();
  int ix(int x, int y) => x + y * width;

  static const convection = 2;

  double startY = 0;

  void cool() {
    for (var j = 0; j < height; j++) {
      for (var i = 0; i < width; i++) {
        final n = noise.getPerlin2(i.toDouble(), j + startY);
        coolmap[ix(i, j)] = 16 * (n + sqrt1_2) / (2 * sqrt1_2);
      }
    }
    startY += 1.5;
  }

  @override
  void update(double dt) {
    cool();
    for (var j = convection; j < height - 1; j++) {
      for (var i = 1; i < width - 1; i++) {
        final x = i;
        final y = j;
        final n = buffer1[ix(x, y - 1)] - coolmap[ix(x, y - 1)];
        final e = buffer1[ix(x + 1, y)] - coolmap[ix(x + 1, y)];
        final s = buffer1[ix(x, y + 1)] - coolmap[ix(x, y + 1)];
        final w = buffer1[ix(x - 1, y)] - coolmap[ix(x - 1, y)];
        var r = (n + e + s + w) ~/ 4;

        if (r < 0) r = 0;
        buffer2[ix(x, y - convection)] = r;
      }
    }

    for (var j = height - 1 - convection; j < height - 1; j++) {
      for (var i = 0; i < width; i++) {
        buffer2[ix(i, j)] = buffer2[ix(i, j - 1)];
      }
    }
    for (var i = 0; i < width; i++) {
      buffer2[ix(i, height - 1)] = 255;
    }
  }

  @override
  void render(Canvas canvas) {
    viewport
      ..resize(size)
      ..render(
        canvas,
        (c) {
          for (var j = 0; j < height; j++) {
            for (var i = 0; i < width; i++) {
              final brightness = buffer2[ix(i, j)];
              final red =
                  map(brightness.toDouble(), 0, 255, 0xff, 0x87).toInt();
              final green =
                  map(brightness.toDouble(), 0, 255, 0x13, 0xa5).toInt();
              final blue =
                  map(brightness.toDouble(), 0, 255, 0x5b, 0x56).toInt();
              white.color = Color.fromARGB(
                buffer2[ix(i, j)],
                red,
                green,
                blue,
              );
              c.drawRect(
                Rect.fromLTWH(i.toDouble(), j.toDouble(), 1, 1),
                white,
              );
            }
          }
        },
      );
    buffer1 = buffer2;
  }

  double map(double brightness, double i, double j, double k, double l) {
    final m = k + (brightness - i) * (l - k) / (j - i);
    return m;
  }
}
