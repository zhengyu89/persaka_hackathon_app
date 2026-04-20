import 'package:flutter/material.dart';

class FeatureCard extends StatelessWidget {
  final String title;
  final String description;

  const FeatureCard({
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(color: Colors.white, fontSize: 16)),
          Text(description,
              style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}