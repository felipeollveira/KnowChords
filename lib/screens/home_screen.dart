import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../data/acordes.dart';
import '../widgets/seletor_tom.dart';
import '../widgets/lista_acordes.dart';
import '../services/chord_player.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? tomSelecionado;
  List<int> indicesSelecionados = [];
  int? _posicaoParaSubstituir;

  // Playback
  final ChordPlayer _chordPlayer = ChordPlayer();
  Timer? _playbackTimer;
  int _acordeAtual = -1;
  int _bpm = 80;
  bool _tocando = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _playbackTimer?.cancel();
    _chordPlayer.dispose();
    super.dispose();
  }

  // ── Progressão ──────────────────────────────────────────────

  void _adicionarAcorde(int index) {
    setState(() {
      indicesSelecionados.add(index);
    });
  }

  void _removerAcordeDaSequencia(int posicao) {
    if (_tocando) return;
    setState(() {
      if (_posicaoParaSubstituir == posicao) {
        _posicaoParaSubstituir = null;
      } else if (_posicaoParaSubstituir != null && _posicaoParaSubstituir! > posicao) {
        _posicaoParaSubstituir = _posicaoParaSubstituir! - 1;
      }
      indicesSelecionados.removeAt(posicao);
    });
  }

  void _toggleSubstituicao(int posicao) {
    if (_tocando) return;
    setState(() {
      _posicaoParaSubstituir = _posicaoParaSubstituir == posicao ? null : posicao;
    });
  }

  void _substituirAcorde(int novoIndice) {
    if (_posicaoParaSubstituir == null) return;
    setState(() {
      indicesSelecionados[_posicaoParaSubstituir!] = novoIndice;
      _posicaoParaSubstituir = null;
    });
  }

  // ── Playback ─────────────────────────────────────────────────

  void _tocarProgressao(List<String> acordesDoTom) {
    if (indicesSelecionados.isEmpty) return;
    _playbackTimer?.cancel();
    _posicaoParaSubstituir = null;

    int currentIndex = 0;
    final duracaoMs = (60000 * 2 / _bpm).round(); // 2 beats por acorde

    setState(() {
      _tocando = true;
      _acordeAtual = 0;
    });

    _chordPlayer.playChord(acordesDoTom[indicesSelecionados[0]]);

    _playbackTimer = Timer.periodic(Duration(milliseconds: duracaoMs), (_) {
      if (!mounted) return;
      if (indicesSelecionados.isEmpty) {
        _pararProgressao();
        return;
      }
      currentIndex = (currentIndex + 1) % indicesSelecionados.length;
      setState(() => _acordeAtual = currentIndex);
      _chordPlayer.playChord(acordesDoTom[indicesSelecionados[currentIndex]]);
    });
  }

  void _pararProgressao() {
    _playbackTimer?.cancel();
    _playbackTimer = null;
    _chordPlayer.stop();
    if (mounted) {
      setState(() {
        _tocando = false;
        _acordeAtual = -1;
      });
    }
  }

  // ── Build ────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final acordesDoTom = tomSelecionado != null
        ? List<String>.from(obterAcordesDoTom(tomSelecionado!))
        : <String>[];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FC),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 28),
                  _buildSectionLabel("Selecione o Tom"),
                  const SizedBox(height: 14),
                  SeletorTom(
                    tomSelecionado: tomSelecionado,
                    onSelecionar: (novoTom) {
                      _pararProgressao();
                      setState(() {
                        tomSelecionado = tomSelecionado == novoTom ? null : novoTom;
                        _posicaoParaSubstituir = null;
                      });
                    },
                  ),
                  const SizedBox(height: 28),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child: tomSelecionado != null
                        ? Column(
                            key: ValueKey(tomSelecionado),
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionLabel("Sua Progressão"),
                              const SizedBox(height: 14),
                              _buildSequenciaPreview(acordesDoTom),
                              const SizedBox(height: 28),
                              _buildSectionLabel("Acordes em $tomSelecionado"),
                              const SizedBox(height: 14),
                              if (_posicaoParaSubstituir != null)
                                _buildSubstituteBanner(),
                              ListaAcordes(
                                acordes: acordesDoTom,
                                modoSubstituicao: _posicaoParaSubstituir != null,
                                onSelecionar: (acorde) {
                                  int idx = acordesDoTom.indexOf(acorde);
                                  if (_posicaoParaSubstituir != null) {
                                    _substituirAcorde(idx);
                                  } else {
                                    _adicionarAcorde(idx);
                                  }
                                },
                              ),
                              const SizedBox(height: 40),
                            ],
                          )
                        : _buildAvisoSelecao(),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Widgets ───────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
      color: const Color(0xFF0C1A2E),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.queue_music_rounded, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 10),
              const Text(
                "KnowChords",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                letterSpacing: -1.2,
                height: 1.15,
              ),
              children: [
                const TextSpan(
                  text: 'Monte sua progressão',
                  style: TextStyle(color: Colors.white),
                ),
                TextSpan(
                  text: '\nde acordes',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.35)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: const Color(0xFF3B82F6),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F1D2E),
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildSubstituteBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4EC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFFF97316),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Toque um acorde abaixo para substituir',
              style: TextStyle(fontSize: 13, color: Color(0xFFF97316), fontWeight: FontWeight.w500),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _posicaoParaSubstituir = null),
            child: const Text(
              'Cancelar',
              style: TextStyle(fontSize: 12, color: Color(0xFFF97316), fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSequenciaPreview(List<String> acordesDoTom) {
    if (indicesSelecionados.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFEBF2FF),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF3B82F6), size: 18),
            const SizedBox(width: 10),
            Text(
              "Toque nos acordes abaixo para começar",
              style: TextStyle(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.8),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0C1A2E).withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${indicesSelecionados.length} ${indicesSelecionados.length == 1 ? 'acorde' : 'acordes'}",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFADB9C7),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _pararProgressao();
                    setState(() {
                      indicesSelecionados.clear();
                      _posicaoParaSubstituir = null;
                    });
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFEF4444),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  child: const Text("Limpar"),
                ),
              ],
            ),
          ),
          // Chips
          SizedBox(
            height: 60,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
              scrollDirection: Axis.horizontal,
              itemCount: indicesSelecionados.length,
              separatorBuilder: (_, __) => const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Center(
                  child: Text(
                    '›',
                    style: TextStyle(
                      color: Color(0xFFCBD5E0),
                      fontSize: 20,
                      fontWeight: FontWeight.w300,
                      height: 1,
                    ),
                  ),
                ),
              ),
              itemBuilder: (context, index) {
                final String nomeTraduzido = acordesDoTom[indicesSelecionados[index]];
                final bool eSelecionado = _posicaoParaSubstituir == index;
                final bool eTocando = _acordeAtual == index;

                Color chipColor;
                if (eTocando) {
                  chipColor = const Color(0xFF22C55E);
                } else if (eSelecionado) {
                  chipColor = const Color(0xFFF97316);
                } else {
                  chipColor = const Color(0xFF0F1D2E);
                }

                Color? glowColor;
                if (eTocando) glowColor = const Color(0xFF22C55E);
                if (eSelecionado) glowColor = const Color(0xFFF97316);

                return GestureDetector(
                  onTap: () => _toggleSubstituicao(index),
                  onLongPress: () => _removerAcordeDaSequencia(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: chipColor,
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: glowColor != null
                          ? [BoxShadow(color: glowColor.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4))]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          nomeTraduzido,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            letterSpacing: -0.2,
                          ),
                        ),
                        if (eTocando) ...[
                          const SizedBox(width: 5),
                          const Icon(Icons.volume_up_rounded, size: 12, color: Colors.white70),
                        ] else if (eSelecionado) ...[
                          const SizedBox(width: 5),
                          const Icon(Icons.swap_horiz_rounded, size: 13, color: Colors.white70),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Hint
          if (!_tocando)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(
                'Segure para remover  •  Toque para substituir',
                style: TextStyle(
                  fontSize: 11,
                  color: const Color(0xFF0C1A2E).withValues(alpha: 0.25),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          // Divider
          Divider(
            height: 1,
            color: const Color(0xFF0C1A2E).withValues(alpha: 0.06),
          ),
          // Play controls
          _buildPlaybackControls(acordesDoTom),
        ],
      ),
    );
  }

  Widget _buildPlaybackControls(List<String> acordesDoTom) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      child: Row(
        children: [
          // BPM control
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F8FC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _bpmButton(Icons.remove_rounded, () {
                  if (_bpm > 40) setState(() => _bpm = max(40, _bpm - 5));
                }),
                const SizedBox(width: 10),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$_bpm',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F1D2E),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const Text(
                      'BPM',
                      style: TextStyle(
                        fontSize: 9,
                        color: Color(0xFFADB9C7),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                _bpmButton(Icons.add_rounded, () {
                  if (_bpm < 200) setState(() => _bpm = min(200, _bpm + 5));
                }),
              ],
            ),
          ),
          const Spacer(),
          // Play/Stop
          GestureDetector(
            onTap: _tocando ? _pararProgressao : () => _tocarProgressao(acordesDoTom),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _tocando ? const Color(0xFFEF4444) : const Color(0xFF3B82F6),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (_tocando ? const Color(0xFFEF4444) : const Color(0xFF3B82F6))
                        .withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                _tocando ? Icons.stop_rounded : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bpmButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0C1A2E).withValues(alpha: 0.06),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Icon(icon, size: 15, color: const Color(0xFF4B5563)),
      ),
    );
  }

  Widget _buildAvisoSelecao() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFFEBF2FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.music_note_rounded, size: 36, color: Color(0xFF3B82F6)),
          ),
          const SizedBox(height: 16),
          const Text(
            "Escolha o tom para começar",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F1D2E),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Os acordes disponíveis aparecerão aqui",
            style: TextStyle(color: Color(0xFFADB9C7), fontSize: 13),
          ),
        ],
      ),
    );
  }
}
