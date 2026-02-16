import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoading extends StatelessWidget {
  final Widget child;
  final bool isLoading;

  const ShimmerLoading({
    super.key,
    required this.child,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading) {
      return child;
    }

    final theme = Theme.of(context);

    // Using a base color that adapts to light/dark mode
    // Surfaces are usually a bit darker/lighter than the background
    final baseColor = theme.brightness == Brightness.light
        ? Colors.grey[300]!
        : Colors.grey[700]!;

    final highlightColor = theme.brightness == Brightness.light
        ? Colors.grey[100]!
        : Colors.grey[500]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: child,
    );
  }
}

class ShimmerPlaceholder extends StatelessWidget {
  final double width;
  final double height;
  final ShapeBorder shape;

  const ShimmerPlaceholder({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.shape = const RoundedRectangleBorder(),
  });

  ShimmerPlaceholder.rectangular({
    super.key,
    this.width = double.infinity,
    required this.height,
    double borderRadius = 8,
  }) : shape = RoundedRectangleBorder(
         borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
       );

  const ShimmerPlaceholder.circular({super.key, required double size})
    : width = size,
      height = size,
      shape = const CircleBorder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: ShapeDecoration(
        color: Colors
            .black, // Color doesn't matter, it's determined by Shimmer.fromColors
        shape: shape,
      ),
    );
  }
}

class MenuGridShimmer extends StatelessWidget {
  final int itemCount;

  const MenuGridShimmer({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      isLoading: true,
      child: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount:
              2, // Assuming 2 columns for mobile, adaptive logic might be needed if generalized
          childAspectRatio: 0.8,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: ShimmerPlaceholder.rectangular(
                    height: double.infinity,
                    borderRadius:
                        12, // Top corners should ideally match, but simple rect is fine
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerPlaceholder.rectangular(height: 16, width: 120),
                        SizedBox(height: 8),
                        ShimmerPlaceholder.rectangular(height: 14, width: 60),
                        Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ShimmerPlaceholder.rectangular(
                              height: 20,
                              width: 40,
                            ),
                            ShimmerPlaceholder.circular(size: 24),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class OrderListShimmer extends StatelessWidget {
  final int itemCount;

  const OrderListShimmer({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      isLoading: true,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(bottom: 16.0),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ShimmerPlaceholder.rectangular(height: 20, width: 100),
                        ShimmerPlaceholder.rectangular(height: 20, width: 60),
                      ],
                    ),
                    SizedBox(height: 16),
                    ShimmerPlaceholder.rectangular(
                      height: 14,
                      width: double.infinity,
                    ),
                    SizedBox(height: 8),
                    ShimmerPlaceholder.rectangular(height: 14, width: 200),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ShimmerPlaceholder.rectangular(height: 16, width: 80),
                        ShimmerPlaceholder.circular(size: 32),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
