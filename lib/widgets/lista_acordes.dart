import 'package:flutter/material.dart';

const List<String> _graus = ['I', 'ii', 'iii', 'IV', 'V', 'vi'];

class ListaAcordes extends StatelessWidget {
  final List<String> acordes;
  final Function(String) onSelecionar;
  final bool modoSubstituicao;

  const ListaAcordes({
    Key? key,
    required this.acordes,
    required this.onSelecionar,
    this.modoSubstituicao = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.0,
      ),
      itemCount: acordes.length,
      itemBuilder: (context, index) {
        final acorde = acordes[index];
        final grau = index < _graus.length ? _graus[index] : '';

        return Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: () => onSelecionar(acorde),
            borderRadius: BorderRadius.circular(16),
            splashColor: const Color(0xFF3B82F6).withValues(alpha: 0.1),
            highlightColor: const Color(0xFF3B82F6).withValues(alpha: 0.05),
            child: Ink(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0C1A2E).withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEBF2FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      grau,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF3B82F6),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    acorde,
                    style: const TextStyle(
                      fontSize: 24,
                      color: Color(0xFF0F1D2E),
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        modoSubstituicao ? Icons.swap_horiz_rounded : Icons.add_rounded,
                        size: 11,
                        color: modoSubstituicao
                            ? const Color(0xFFF97316)
                            : const Color(0xFFADB9C7),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        modoSubstituicao ? 'trocar' : 'add',
                        style: TextStyle(
                          fontSize: 10,
                          color: modoSubstituicao
                              ? const Color(0xFFF97316)
                              : const Color(0xFFADB9C7),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
