import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ChatShimmer extends StatelessWidget {
  const ChatShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[600]! : Colors.grey[100]!,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _fakeAiBubble(colors, wide: true),
          const SizedBox(height: 12),
          _fakeUserBubble(colors),
          const SizedBox(height: 12),
          _fakeAiBubble(colors, wide: false),
          const SizedBox(height: 12),
          _fakeAiBubble(colors, wide: true),
          const SizedBox(height: 12),
          _fakeUserBubble(colors),
          const SizedBox(height: 12),
          _fakeAiBubble(colors, wide: false),
        ],
      ),
    );
  }

  // fake AI message on the left
  Widget _fakeAiBubble(ColorScheme colors, {required bool wide}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // avatar circle
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _bar(width: wide ? 220 : 140, height: 14),
            const SizedBox(height: 6),
            _bar(width: wide ? 160 : 100, height: 14),
          ],
        ),
      ],
    );
  }

  // fake user message on the right
  Widget _fakeUserBubble(ColorScheme colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _bar(width: 130, height: 14),
            const SizedBox(height: 6),
            _bar(width: 80, height: 14),
          ],
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _bar({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
