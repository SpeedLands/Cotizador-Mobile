import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({super.key, this.size = 100.0});
  final double size;

  @override
  Widget build(BuildContext context) => Center(
    child: SizedBox(
      width: size,
      height: size,
      child: const RiveAnimation.asset(
        'assets/rive/manzana.riv',
        fit: BoxFit.contain,
      ),
    ),
  );
}
