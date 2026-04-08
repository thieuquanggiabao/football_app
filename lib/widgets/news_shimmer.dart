import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class NewsShimmer extends StatelessWidget {
  const NewsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[900]!,
      highlightColor: Colors.grey[800]!,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Skeleton cho ảnh
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(height: 12),
                // Skeleton cho thời gian
                Container(
                  height: 12,
                  width: 80,
                  color: Colors.black,
                ),
                const SizedBox(height: 8),
                // Skeleton cho tiêu đề (dòng 1)
                Container(
                  height: 16,
                  width: double.infinity,
                  color: Colors.black,
                ),
                const SizedBox(height: 4),
                // Skeleton cho tiêu đề (dòng 2)
                Container(
                  height: 16,
                  width: 200,
                  color: Colors.black,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
