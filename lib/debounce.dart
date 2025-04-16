import 'dart:async';

import 'package:flutter/material.dart';

class Debounce {
  final Duration duration;
  VoidCallback? _action;
  Timer? _timer;

  Debounce({required this.duration});

  void call(VoidCallback action) {
    _action = action;
    _timer?.cancel();
    _timer = Timer(duration, () => _action?.call());
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
  }
}
