import 'package:flutter/material.dart';

enum HomeCardSkeletonType { spending, barChart, category }

class HomeCardSkeleton extends StatefulWidget {
  const HomeCardSkeleton({super.key, required this.type});

  final HomeCardSkeletonType type;

  @override
  State<HomeCardSkeleton> createState() => _HomeCardSkeletonState();
}

class _HomeCardSkeletonState extends State<HomeCardSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final value = _controller.value;
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment(-1.5 + value * 3, 0),
            end: Alignment(-0.5 + value * 3, 0),
            colors: const [
              Color(0xFFE5E7EB),
              Color(0xFFF8FAFC),
              Color(0xFFE5E7EB),
            ],
            stops: const [0, 0.5, 1],
          ).createShader(bounds),
          child: child,
        );
      },
      child: switch (widget.type) {
        HomeCardSkeletonType.spending => const _SpendingSkeleton(),
        HomeCardSkeletonType.barChart => const _BarChartSkeleton(),
        HomeCardSkeletonType.category => const _CategorySkeleton(),
      },
    );
  }
}

class _SpendingSkeleton extends StatelessWidget {
  const _SpendingSkeleton();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 92,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Bone(width: 100, height: 13),
              _Bone(width: 82, height: 25),
            ],
          ),
          SizedBox(height: 8),
          _Bone(width: 190, height: 24),
          SizedBox(height: 14),
          _Bone(height: 6),
        ],
      ),
    );
  }
}

class _BarChartSkeleton extends StatelessWidget {
  const _BarChartSkeleton();

  @override
  Widget build(BuildContext context) {
    const heights = [100.0, 180.0, 135.0, 240.0, 165.0, 210.0];
    return SizedBox(
      height: 344,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Bone(width: 190, height: 18),
          const SizedBox(height: 20),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                for (final height in heights)
                  _Bone(width: 30, height: height, radius: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategorySkeleton extends StatelessWidget {
  const _CategorySkeleton();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 400,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Bone(width: 155, height: 18),
              _Bone(width: 110, height: 30),
            ],
          ),
          SizedBox(height: 24),
          Center(child: _Bone(width: 190, height: 190, radius: 95)),
          SizedBox(height: 22),
          _Bone(height: 42, radius: 10),
          SizedBox(height: 10),
          _Bone(height: 42, radius: 10),
          SizedBox(height: 10),
          _Bone(height: 42, radius: 10),
        ],
      ),
    );
  }
}

class _Bone extends StatelessWidget {
  const _Bone({
    this.width = double.infinity,
    required this.height,
    this.radius = 4,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: const Color(0xFFE5E7EB),
      borderRadius: BorderRadius.circular(radius),
    ),
  );
}
