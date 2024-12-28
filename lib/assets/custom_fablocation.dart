import 'package:flutter/material.dart';

class CustomFloatingActionButtonLocation extends FloatingActionButtonLocation {
  final FloatingActionButtonLocation baseLocation;
  final double offsetX;
  final double offsetY;

  CustomFloatingActionButtonLocation(this.baseLocation, this.offsetX, this.offsetY);

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final baseOffset = baseLocation.getOffset(scaffoldGeometry);
    return Offset(baseOffset.dx + offsetX, baseOffset.dy + offsetY);
  }
}