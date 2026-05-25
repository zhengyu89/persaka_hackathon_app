import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

class HackathonCover extends StatelessWidget {
  const HackathonCover({
    super.key,
    required this.imageBase64,
    this.height = 160,
    this.width = double.infinity,
    this.borderRadius = 20,
    this.placeholderIcon = Icons.image_outlined,
    this.placeholderLabel = 'No poster added yet',
  });

  final String imageBase64;
  final double height;
  final double width;
  final double borderRadius;
  final IconData placeholderIcon;
  final String placeholderLabel;

  @override
  Widget build(BuildContext context) {
    final memoryImage = _decodeImage(imageBase64);

    if (memoryImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.memory(
          memoryImage,
          height: height,
          width: width,
          fit: BoxFit.cover,
        ),
      );
    }

    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFEAE7FF),
            Color(0xFFF6EFFF),
          ],
        ),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            placeholderIcon,
            color: const Color(0xFF6D55F8),
            size: 30,
          ),
          const SizedBox(height: 10),
          Text(
            placeholderLabel,
            style: const TextStyle(
              color: Color(0xFF5B5F72),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Uint8List? _decodeImage(String imageBase64) {
    if (imageBase64.trim().isEmpty) {
      return null;
    }

    try {
      return base64Decode(imageBase64);
    } catch (_) {
      return null;
    }
  }
}
