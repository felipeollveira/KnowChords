import 'package:flutter/material.dart';

class SalvosScreen extends StatelessWidget {
  const SalvosScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<String> acordesSalvos = [];

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: SafeArea(
        child: acordesSalvos.isEmpty
            ? _buildEmptyState()
            : _buildSavedList(acordesSalvos),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF154666).withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_border_rounded,
                size: 52,
                color: Color(0xFF154666),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Nenhuma progressão salva",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A2E44),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Monte sua progressão e salve para acessar aqui.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedList(List<String> acordesSalvos) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: acordesSalvos.map((a) => Chip(label: Text(a))).toList(),
      ),
    );
  }
}
