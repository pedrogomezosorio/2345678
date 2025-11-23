// lib/responsive_helper.dart

import 'package:flutter/material.dart';

class ResponsiveHelper extends StatelessWidget {
  final Widget phoneLayout;
  final Widget tabletLayout;

  const ResponsiveHelper({
    super.key,
    required this.phoneLayout,
    required this.tabletLayout,
  });

  // Usamos 600 puntos como el límite entre teléfono y tablet.
  // Esto es un estándar común en Material Design.
  static const double _tabletBreakpoint = 600.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < _tabletBreakpoint) {
          // Si la pantalla es estrecha, usa el layout de teléfono
          return phoneLayout;
        } else {
          // Si la pantalla es ancha, usa el layout de tablet
          return tabletLayout;
        }
      },
    );
  }
}