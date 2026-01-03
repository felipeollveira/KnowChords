import 'package:flutter/material.dart';
import '../../data/acordes.dart';
import '../widgets/seletor_tom.dart';
import '../widgets/lista_acordes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? tomSelecionado;

  // Lista de índices que permite repetição (ex: [0, 4, 5, 4])
  List<int> indicesSelecionados = [];

  // Adiciona o acorde à lista (permitindo duplicatas)
  void _adicionarAcorde(int index) {
    setState(() {
      indicesSelecionados.add(index);
    });
  }

  // Remove um acorde específico pela sua posição na sequência
  void _removerAcordeDaSequencia(int posicao) {
    setState(() {
      indicesSelecionados.removeAt(posicao);
    });
  }

  @override
  Widget build(BuildContext context) {
    final acordesDoTom = tomSelecionado != null
        ? List<String>.from(obterAcordesDoTom(tomSelecionado!))
        : <String>[];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Bem-vindo ao Know Chords 👋", style: TextStyle(fontSize: 16, color: Colors.black54)),
              const SizedBox(height: 8),
              const Text(
                "Monte sua progressão",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF154666)),
              ),
              const SizedBox(height: 24),

              _buildDestaqueCard(),

              const SizedBox(height: 28),
              const Text(
                "1. Selecione o Tom base",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF154666)),
              ),
              const SizedBox(height: 16),

              SeletorTom(
                tomSelecionado: tomSelecionado,
                onSelecionar: (novoTom) {
                  setState(() {
                    tomSelecionado = tomSelecionado == novoTom ? null : novoTom;
                  });
                },
              ),

              // Exibição da sequência que está sendo montada
              _buildSequenciaPreview(acordesDoTom),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: tomSelecionado != null
                    ? Column(
                  key: ValueKey(tomSelecionado),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 32),
                    Text(
                      "3. Escolha os acordes para a lista ($tomSelecionado)",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF154666)),
                    ),
                    const SizedBox(height: 12),
                    ListaAcordes(
                      acordes: acordesDoTom,
                      onSelecionar: (acorde) {
                        int idx = acordesDoTom.indexOf(acorde);
                        _adicionarAcorde(idx);
                      },
                    ),
                  ],
                )
                    : _buildAvisoSelecao(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSequenciaPreview(List<String> acordesDoTom) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: indicesSelecionados.isNotEmpty && tomSelecionado != null
          ? Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "2. Sequência selecionada",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF154666)),
              ),
              TextButton(
                onPressed: () => setState(() => indicesSelecionados.clear()),
                child: const Text("Limpar lista", style: TextStyle(color: Colors.redAccent)),
              )
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 50,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: indicesSelecionados.length,
              separatorBuilder: (context, index) => const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
              itemBuilder: (context, index) {
                final int idxSalvo = indicesSelecionados[index];
                // Transposição automática: pega o nome do acorde no tom atual pelo índice
                final String nomeTraduzido = acordesDoTom[idxSalvo];

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: InputChip(
                    label: Text(nomeTraduzido, style: const TextStyle(fontWeight: FontWeight.bold)),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Color(0xFF154666)),
                    ),
                    onDeleted: () => _removerAcordeDaSequencia(index),
                    deleteIcon: const Icon(Icons.cancel, size: 18, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
        ],
      )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildDestaqueCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF154666), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Colors.white, size: 24),
          SizedBox(width: 12),
          Flexible(
            child: Text(
              "Monte sua progressão de acordes. Ao trocar o tom, a sequência será transposta automaticamente.",
              style: TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvisoSelecao() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 40),
      padding: const EdgeInsets.all(20),
      child: const Column(
        children: [
          Icon(Icons.library_music_outlined, size: 48, color: Colors.black12),
          SizedBox(height: 12),
          Text(
            "Selecione um tom acima para visualizar os acordes disponíveis.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black45),
          ),
        ],
      ),
    );
  }
}