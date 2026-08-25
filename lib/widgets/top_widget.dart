import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TopWidget extends StatelessWidget {
  const TopWidget({super.key, required this.text, required this.path});

  final String text;
  final String path;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              const Icon(Icons.star_rounded, color: Colors.yellow, size: 30),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  text,
                  softWrap: true,
                  style: const TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        FilledButton(
          onPressed: () {
            context.go(path);
          },
          child: const Text('ดูทั้งหมด'),
        ),
      ],
    );
  }
}
