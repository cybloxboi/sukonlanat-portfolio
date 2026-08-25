import 'package:flutter/material.dart';

class EmptySection extends StatelessWidget {
  const EmptySection({
    super.key,
    required this.description,
    this.selectedCertificate,
  });

  final String description;
  final String? selectedCertificate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        selectedCertificate == null
            ? description
            : 'ข้อมูล Certificate ที่ส่งมา: $selectedCertificate',
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 24),
      ),
    );
  }
}
