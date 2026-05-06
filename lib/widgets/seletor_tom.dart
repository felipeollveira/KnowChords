import 'package:flutter/material.dart';
import '../data/acordes.dart';

class SeletorTom extends StatelessWidget {
  final String? tomSelecionado;
  final Function(String?) onSelecionar;

  const SeletorTom({Key? key, required this.tomSelecionado, required this.onSelecionar}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tons.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final tom = tons[index];
          final isSelected = tomSelecionado == tom;

          return GestureDetector(
            onTap: () => onSelecionar(isSelected ? null : tom),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeInOut,
              width: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: isSelected ? const Color(0xFF3B82F6) : Colors.white,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF3B82F6).withValues(alpha: 0.32),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: const Color(0xFF0C1A2E).withValues(alpha: 0.06),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Center(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 180),
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF4B5563),
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 15,
                    letterSpacing: -0.2,
                  ),
                  child: Text(tom),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
