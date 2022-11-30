import 'dart:math';

class PerlinNoise {
  PerlinNoise({int octaves = 1, double persistence = 1.0})
      : _octaves = octaves,
        _persistence = persistence;
  final int _octaves;
  final double _persistence;
  final Map<int, Map<int, Map<int, double>>> _noises = {};
  final _rand = Random();

  double _noise(int i, int x, int y) => _noises
      .putIfAbsent(i, () => {})
      .putIfAbsent(x, () => {})
      .putIfAbsent(y, () => 2 * _rand.nextDouble() - 1);

  double _smoothNoise(int i, int x, int y) {
    final corners = (_noise(i, x - 1, y - 1) +
            _noise(i, x + 1, y - 1) +
            _noise(i, x - 1, y + 1) +
            _noise(i, x + 1, y + 1)) /
        16;
    final sides = (_noise(i, x - 1, y) +
            _noise(i, x + 1, y) +
            _noise(i, x, y - 1) +
            _noise(i, x, y + 1)) /
        8;
    final center = _noise(i, x, y) / 4;
    return corners + sides + center;
  }

  double _interpolate(double a, double b, double x) {
    final ft = x * pi;
    final f = (1 - cos(ft)) * 0.5;
    return a * (1 - f) + b * f;
  }

  double _interpolatedNoise(int i, num x, num y) {
    final intX = x.floor();
    final intY = y.floor();

    final fracX = (x - intX).toDouble();
    final fracY = (y - intY).toDouble();

    final v1 = _smoothNoise(i, intX, intY);
    final v2 = _smoothNoise(i, intX + 1, intY);
    final v3 = _smoothNoise(i, intX, intY + 1);
    final v4 = _smoothNoise(i, intX + 1, intY + 1);

    final i1 = _interpolate(v1, v2, fracX);
    final i2 = _interpolate(v3, v4, fracX);

    return _interpolate(i1, i2, fracY);
  }

  double perlinNoise(num x, num y) {
    var total = 0.0;

    for (var i = 0; i < _octaves; i++) {
      final frequency = pow(2, i).toInt();
      final amplitude = pow(_persistence, i).toDouble();

      total += _interpolatedNoise(i, x * frequency, y * frequency) * amplitude;
    }
    return total;
  }
}
