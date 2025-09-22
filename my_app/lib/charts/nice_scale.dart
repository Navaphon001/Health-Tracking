import 'dart:math' as math;

double _niceNum(double range, {bool round = false}) {
  final exp = (math.log(range) / math.ln10).floor();
  final f = range / math.pow(10.0, exp);
  double nf;
  if (round) {
    if (f < 1.5) nf = 1;
    else if (f < 3) nf = 2;
    else if (f < 7) nf = 5;
    else nf = 10;
  } else {
    if (f <= 1) nf = 1;
    else if (f <= 2) nf = 2;
    else if (f <= 5) nf = 5;
    else nf = 10;
  }
  return nf * math.pow(10.0, exp);
}

({double maxY, double interval}) niceScale(List<double> values, {int targetTicks = 5}) {
  if (values.isEmpty) return (maxY: 1, interval: 1);
  final maxVal = values.reduce(math.max).toDouble();
  final range = maxVal == 0 ? 1.0 : maxVal;
  final niceRange = _niceNum(range, round: false);
  final tick = _niceNum(niceRange / targetTicks, round: true);
  final maxY = ((maxVal / tick).ceil() * tick).toDouble();
  return (maxY: maxY, interval: tick);
}
