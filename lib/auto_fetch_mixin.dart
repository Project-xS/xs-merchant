import 'dart:async';
import 'package:flutter/material.dart';

mixin AutoFetchMixin<T extends StatefulWidget> on State<T> {
  Timer? timer;

  @override
  void initState() {
    super.initState();
    fetchData();
    _startAutoFetch();
  }

  void _startAutoFetch() {
    timer = Timer.periodic(Duration(minutes: 2), (timer) {
      if (mounted) {
        fetchData();
      }
    });
  }

  void fetchData();

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
}
