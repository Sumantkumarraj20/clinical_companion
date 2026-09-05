import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoading extends StatelessWidget {
  const ShimmerLoading({this.rows = 5, super.key});

  final int rows;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;
    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: Theme.of(context).colorScheme.surface,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: rows,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, __) => const SizedBox(
          height: 72,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
        ),
      ),
    );
  }
}