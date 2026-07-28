import 'dart:async';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../data/acordes.dart';
import '../services/chord_player.dart';
import '../services/save_service.dart';
import '../models/saved_item.dart';
import '../widgets/seletor_tom.dart';
import '../widgets/chord_diagram.dart';

// ── Silabificação ─────────────────────────────────────────────────────────────

const _vogais = 'aeiouáéíóúâêôãõàäëïöAEIOUÁÉÍÓÚÂÊÔÃÕÀÄËÏÖ';

bool _isVogal(String c) => _vogais.contains(c);
bool _isLetra(String c) => RegExp(r'[a-zA-ZÀ-ÿ]').hasMatch(c);

List<String> _silabificar(String palavra) {
  if (palavra.length <= 1) return [palavra];
  final silabas = <String>[];
  int start = 0, i = 0;
  final n = palavra.length;
  while (i < n) {
    while (i < n && _isLetra(palavra[i]) && !_isVogal(palavra[i])) i++;
    while (i < n && _isVogal(palavra[i])) i++;
    while (i < n && _isLetra(palavra[i]) && !_isVogal(palavra[i])) {
      if (i + 1 < n && _isVogal(palavra[i + 1])) break;
      i++;
    }
    if (i > start) {
      silabas.add(palavra.substring(start, i));
      start = i;
    } else {
      i++;
      if (i > start) { silabas.add(palavra.substring(start, i)); start = i; }
    }
  }
  if (start < n) silabas.add(palavra.substring(start));
  return silabas.isEmpty ? [palavra] : silabas;
}

// ── Tokens ────────────────────────────────────────────────────────────────────

class _Palavra {
  final List<(String texto, int indice)> silabas;
  const _Palavra(this.silabas);
}

// Espaços e pontuação também recebem índice → podem ter acordes atribuídos
class _Sep {
  final String texto;
  final int indice;
  const _Sep(this.texto, this.indice);
}

// ── Screen ────────────────────────────────────────────────────────────────────

class ComposicaoScreen extends StatefulWidget {
  const ComposicaoScreen({super.key});

  @override
  State<ComposicaoScreen> createState() => _ComposicaoScreenState();
}

class _ComposicaoScreenState extends State<ComposicaoScreen> {
  final _controller = TextEditingController();
  bool _modoEdicao = true;
  String? _tomSelecionado;
  int? _silabaAtiva;

  // índice da sílaba → índice do acorde na escala (0–5)
  // Trocar o tom transpõe automaticamente pois os índices são preservados
  final Map<int, int> _acordesPorSilaba = {};
  final Map<int, int> _batidasPorSilaba = {};
  List<List<Object>> _linhas = [];
  String? _currentSaveId;

  // Playback
  final ChordPlayer _chordPlayer = ChordPlayer();
  Timer? _playbackTimer;
  int _bpm = 80;
  bool _tocando = false;
  int _acordeAtualIdx = -1;
  int? _silabaToando;           // índice global da sílaba em reprodução
  List<int> _chavesDaSequencia = []; // keys ordenadas da sequência atual

  // Scroll + keys por linha para auto-scroll
  final _scrollController = ScrollController();
  final Map<int, GlobalKey> _linhaKeys = {};

  @override
  void initState() {
    super.initState();
    SaveService.instance.loadComposicao.addListener(_onLoad);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onLoad());
  }

  @override
  void dispose() {
    SaveService.instance.loadComposicao.removeListener(_onLoad);
    _controller.dispose();
    _playbackTimer?.cancel();
    _chordPlayer.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onLoad() {
    final item = SaveService.instance.loadComposicao.value;
    if (item == null) return;
    _pararAcordes();
    setState(() {
      _controller.text = item.letra;
      _tomSelecionado = item.tom;
      _acordesPorSilaba
        ..clear()
        ..addAll(item.acordesPorSilaba);
      _batidasPorSilaba
        ..clear()
        ..addAll(item.batidasPorSilaba);
      _bpm = item.bpm;
      _linhas = _tokenizar(item.letra);
      _modoEdicao = false;
      _silabaAtiva = null;
    });
    _currentSaveId = item.id;
    SaveService.instance.loadComposicao.value = null;
  }

  Future<void> _salvar() async {
    if (_tomSelecionado == null || _acordesPorSilaba.isEmpty) return;
    final controller = TextEditingController();
    final nome = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(ctx).viewInsets.bottom + 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 36, height: 4,
              decoration: BoxDecoration(color: const Color(0xFFCBD5E0), borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            const Text('Salvar Composição',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F1D2E))),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
              decoration: InputDecoration(
                hintText: 'Nome da composição...',
                filled: true,
                fillColor: const Color(0xFFF5F8FC),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(ctx, controller.text.trim()),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Salvar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
    if (nome == null || nome.isEmpty) return;
    await SaveService.instance.salvar(ComposicaoSalva(
      id: _currentSaveId ?? SaveService.newId(),
      nome: nome,
      criadoEm: DateTime.now(),
      letra: _controller.text,
      tom: _tomSelecionado!,
      acordesPorSilaba: Map.from(_acordesPorSilaba),
      batidasPorSilaba: Map.from(_batidasPorSilaba),
      bpm: _bpm,
    ));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Composição salva!'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  // ── Ações ────────────────────────────────────────────────────────────────

  void _entrarModoAcorde() {
    final texto = _controller.text;
    if (texto.trim().isEmpty) return;
    setState(() {
      _linhas = _tokenizar(texto);
      _acordesPorSilaba.clear();
      _batidasPorSilaba.clear();
      _silabaAtiva = null;
      _modoEdicao = false;
    });
  }

  List<List<Object>> _tokenizar(String texto) {
    int idx = 0;
    return texto.split('\n').map((linha) {
      final items = <Object>[];
      for (final m in RegExp(r'[a-zA-ZÀ-ÿ]+|[^a-zA-ZÀ-ÿ]+').allMatches(linha)) {
        final parte = m.group(0)!;
        if (RegExp(r'[a-zA-ZÀ-ÿ]').hasMatch(parte)) {
          items.add(_Palavra(_silabificar(parte).map((s) => (s, idx++)).toList()));
        } else {
          items.add(_Sep(parte, idx++));
        }
      }
      return items;
    }).toList();
  }

  void _selecionarSilaba(int idx) {
    if (_tomSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione um tom primeiro'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() => _silabaAtiva = _silabaAtiva == idx ? null : idx);
  }

  void _atribuirAcorde(int chordIdx) {
    if (_silabaAtiva == null) return;
    setState(() {
      _acordesPorSilaba[_silabaAtiva!] = chordIdx;
      _batidasPorSilaba.putIfAbsent(_silabaAtiva!, () => 2);
    });
  }

  void _removerAcorde() {
    if (_silabaAtiva == null) return;
    setState(() {
      _acordesPorSilaba.remove(_silabaAtiva);
      _batidasPorSilaba.remove(_silabaAtiva);
    });
  }

  // ── Playback ──────────────────────────────────────────────────────────────

  List<String> _sequenciaParaTocar(List<String> acordesDoTom) {
    if (_acordesPorSilaba.isEmpty || acordesDoTom.isEmpty) return [];
    _chavesDaSequencia = _acordesPorSilaba.keys.toList()..sort();
    return _chavesDaSequencia.map((k) => acordesDoTom[_acordesPorSilaba[k]!]).toList();
  }

  void _tocarAcordes(List<String> acordesDoTom) {
    final seq = _sequenciaParaTocar(acordesDoTom);
    if (seq.isEmpty) return;
    _playbackTimer?.cancel();
    setState(() {
      _tocando = true;
      _acordeAtualIdx = 0;
      _silabaAtiva = null;
      _silabaToando = _chavesDaSequencia[0];
    });
    _chordPlayer.playChord(seq[0]);
    _scrollParaSilaba(_chavesDaSequencia[0]);
    _agendarProximo(seq, 0);
  }

  void _agendarProximo(List<String> seq, int atual) {
    final beatMs = (60000 / _bpm).round();
    final batidas = _batidasPorSilaba[_chavesDaSequencia[atual]] ?? 2;
    _playbackTimer = Timer(Duration(milliseconds: beatMs * batidas), () {
      if (!mounted || !_tocando) return;
      final proximo = (atual + 1) % seq.length;
      final silabaProxima = _chavesDaSequencia[proximo];
      setState(() { _acordeAtualIdx = proximo; _silabaToando = silabaProxima; });
      _chordPlayer.playChord(seq[proximo]);
      _scrollParaSilaba(silabaProxima);
      _agendarProximo(seq, proximo);
    });
  }

  void _pararAcordes() {
    _playbackTimer?.cancel();
    _chordPlayer.stop();
    setState(() { _tocando = false; _acordeAtualIdx = -1; _silabaToando = null; });
  }

  void _ajustarBpm(int delta) {
    setState(() => _bpm = (_bpm + delta).clamp(40, 200));
    if (_tocando) {
      _playbackTimer?.cancel();
      final acordesDoTom = _tomSelecionado != null ? obterAcordesDoTom(_tomSelecionado!) : <String>[];
      _agendarProximo(_sequenciaParaTocar(acordesDoTom), _acordeAtualIdx);
    }
  }

  // Rola para manter a sílaba tocando visível
  void _scrollParaSilaba(int silabaIdx) {
    for (int l = 0; l < _linhas.length; l++) {
      for (final item in _linhas[l]) {
        if (item is _Palavra && item.silabas.any((s) => s.$2 == silabaIdx)) {
          final key = _linhaKeys[l];
          if (key?.currentContext != null) {
            Scrollable.ensureVisible(
              key!.currentContext!,
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOut,
              alignment: 0.35,
            );
          }
          return;
        }
      }
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FC),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _modoEdicao ? _buildEditor() : _buildLetra()),
          ],
        ),
      ),
    );
  }

  
  Widget _buildHeader() {
    final podeSalvar = !_modoEdicao && _tomSelecionado != null && _acordesPorSilaba.isNotEmpty;
    final landscape = MediaQuery.of(context).orientation == Orientation.landscape;
    return Container(
      padding: EdgeInsets.fromLTRB(24, landscape ? 10 : 28, 16, landscape ? 10 : 32),
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
                "Composição",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w200,
                  letterSpacing: -0.2,
                ),
              ),
              const Spacer(),
              if (!_modoEdicao) ...[
                IconButton(
                  onPressed: () async {
                    if (_acordesPorSilaba.isNotEmpty) {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          title: const Text('Editar letra?',
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                          content: const Text('Os acordes atribuídos serão perdidos ao editar a letra.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancelar'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              style: FilledButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
                              child: const Text('Editar assim mesmo'),
                            ),
                          ],
                        ),
                      );
                      if (ok != true) return;
                    }
                    _pararAcordes();
                    setState(() { _modoEdicao = true; _silabaAtiva = null; });
                    _currentSaveId = null;
                  },
                  icon: const Icon(Icons.edit_outlined),
                  color: Colors.white60,
                  iconSize: 20,
                  tooltip: 'Editar letra',
                ),
                IconButton(
                  onPressed: _acordesPorSilaba.isNotEmpty ? () {
                    final acordesDoTom = _tomSelecionado != null ? obterAcordesDoTom(_tomSelecionado!) : <String>[];
                    final nomes = (_acordesPorSilaba.keys.toList()..sort())
                        .map((k) => acordesDoTom[_acordesPorSilaba[k]!])
                        .toSet()
                        .join(', ');
                    final linhas = _controller.text.split('\n').take(2).join(' / ');
                    Share.share('🎵 $linhas\n\nAcordes: $nomes\nTom: $_tomSelecionado · $_bpm BPM\n\nFeito com KnowChords');
                  } : null,
                  icon: const Icon(Icons.ios_share_rounded),
                  color: _acordesPorSilaba.isNotEmpty ? Colors.white60 : Colors.white24,
                  iconSize: 18,
                  tooltip: 'Compartilhar',
                ),
                IconButton(
                  onPressed: podeSalvar ? _salvar : null,
                  icon: const Icon(Icons.bookmark_add_outlined),
                  color: podeSalvar ? const Color(0xFF3B82F6) : Colors.white24,
                  iconSize: 22,
                  tooltip: 'Salvar composição',
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditor() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              style: const TextStyle(fontSize: 16, height: 1.7),
              decoration: InputDecoration(
                hintText: 'Cole ou escreva a letra da música aqui...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _entrarModoAcorde,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Adicionar Acordes',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLetra() {
    final acordesDoTom = _tomSelecionado != null
        ? obterAcordesDoTom(_tomSelecionado!)
        : <String>[];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: SeletorTom(
            tomSelecionado: _tomSelecionado,
            onSelecionar: (tom) => setState(() { _tomSelecionado = tom; _silabaAtiva = null; }),
          ),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _silabaAtiva = null),
            behavior: HitTestBehavior.translucent,
            child: Container(
              color: Colors.white,
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(_linhas.length, (i) => _buildLinha(_linhas[i], acordesDoTom, i)),
                ),
              ),
            ),
          ),
        ),
        _buildBarraAcordes(acordesDoTom),
      ],
    );
  }

  // ── Linha ────────────────────────────────────────────────────────────────

  Widget _buildLinha(List<Object> items, List<String> acordesDoTom, int linhaIdx) {
    final key = _linhaKeys.putIfAbsent(linhaIdx, () => GlobalKey());
    if (items.isEmpty) return SizedBox(key: key, height: 44);
    return Padding(
      key: key,
      padding: const EdgeInsets.only(bottom: 10),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.end,
        runSpacing: 14,
        children: items.map((item) {
          if (item is _Sep) {
            final acorde = _acordesPorSilaba.containsKey(item.indice) && acordesDoTom.isNotEmpty
                ? acordesDoTom[_acordesPorSilaba[item.indice]!]
                : null;
            return _buildSilaba(item.texto, item.indice, acorde);
          }
          return _buildPalavra(item as _Palavra, acordesDoTom);
        }).toList(),
      ),
    );
  }

  // Palavra: sílabas em Row — nunca quebra no meio
  Widget _buildPalavra(_Palavra palavra, List<String> acordesDoTom) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: palavra.silabas.map((sil) {
        final (texto, indice) = sil;
        final idxAcorde = _acordesPorSilaba[indice];
        final acorde = (idxAcorde != null && acordesDoTom.isNotEmpty)
            ? acordesDoTom[idxAcorde]
            : null;
        return _buildSilaba(texto, indice, acorde);
      }).toList(),
    );
  }

  // ── Sílaba ────────────────────────────────────────────────────────────────

  Widget _buildSilaba(String texto, int indice, String? acorde) {
    final tocando   = _silabaToando == indice;
    final ativa     = !tocando && _silabaAtiva == indice;
    final temAcorde = acorde != null;
    final tomAtivo  = _tomSelecionado != null;
    final batidas   = _batidasPorSilaba[indice] ?? 2;

    final Color badgeColor = tocando
        ? const Color(0xFF16A34A)
        : ativa
            ? const Color(0xFFF59E0B)
            : const Color(0xFF2563EB);

    BoxDecoration deco;
    if (tocando) {
      deco = BoxDecoration(
        color: const Color(0xFFDCFCE7),
        borderRadius: BorderRadius.circular(5),
      );
    } else if (ativa) {
      deco = BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: const Color(0xFFFBBF24).withValues(alpha: 0.6), width: 1.5),
      );
    } else if (temAcorde) {
      deco = BoxDecoration(
        border: Border(bottom: BorderSide(color: badgeColor.withValues(alpha: 0.35), width: 2)),
      );
    } else if (tomAtivo) {
      deco = const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
      );
    } else {
      deco = const BoxDecoration();
    }

    return GestureDetector(
      onTap: _tocando ? null : () => _selecionarSilaba(indice),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        decoration: deco,
        padding: EdgeInsets.symmetric(horizontal: ativa || tocando ? 3 : 0, vertical: ativa || tocando ? 1 : 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge do acorde — largura 0 para não alargar a sílaba; badge flutua via OverflowBox
            SizedBox(
              height: 32,
              width: 0,
              child: OverflowBox(
                maxWidth: 120,
                alignment: Alignment.bottomLeft,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  transitionBuilder: (child, anim) =>
                      FadeTransition(opacity: anim, child: child),
                  child: temAcorde
                      ? Container(
                          key: ValueKey('$acorde-$tocando-$ativa'),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: badgeColor,
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: tocando
                                ? [BoxShadow(
                                    color: badgeColor.withValues(alpha: 0.45),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  )]
                                : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                acorde,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 0.3,
                                  height: 1.0,
                                ),
                              ),
                              if (batidas != 2) ...[
                                const SizedBox(width: 3),
                                Text(
                                  '×$batidas',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white.withValues(alpha: 0.8),
                                    height: 1.0,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        )
                      : const SizedBox.shrink(key: ValueKey('_empty')),
                ),
              ),
            ),
            // Texto da sílaba
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 140),
              style: TextStyle(
                fontSize: tocando ? 24 : 22,
                height: 1.0,
                fontWeight: tocando
                    ? FontWeight.w700
                    : ativa
                        ? FontWeight.w600
                        : temAcorde
                            ? FontWeight.w500
                            : FontWeight.w400,
                color: tocando
                    ? const Color(0xFF166534)
                    : ativa
                        ? const Color(0xFF92400E)
                        : temAcorde
                            ? const Color(0xFF0F172A)
                            : const Color(0xFF475569),
              ),
              child: Text(texto),
            ),
          ],
        ),
      ),
    );
  }

  // ── Barra de acordes ─────────────────────────────────────────────────────

  Widget _buildBarraAcordes(List<String> acordes) {
    final semTom = _tomSelecionado == null;
    final semSilaba = _silabaAtiva == null;
    final idxAtivo = _silabaAtiva != null ? _acordesPorSilaba[_silabaAtiva!] : null;
    final landscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(20, landscape ? 8 : 14, 20, landscape ? 8 : 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label dinâmico — oculto em landscape para economizar espaço
          if (!landscape) AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              semTom
                  ? 'Selecione um tom acima'
                  : semSilaba
                      ? 'Toque em uma sílaba para adicionar acorde'
                      : idxAtivo != null
                          ? 'Acorde: ${acordes[idxAtivo]}'
                          : 'Escolha o acorde',
              key: ValueKey('$semTom/$semSilaba/$idxAtivo'),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: (!semSilaba && !semTom)
                    ? const Color(0xFF2563EB)
                    : const Color(0xFF94A3B8),
                letterSpacing: 0.3,
              ),
            ),
          ),
          if (!landscape) const SizedBox(height: 12),
          // Linha de botões + remover
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(acordes.isEmpty ? 6 : acordes.length, (i) {
                      final label = acordes.isEmpty ? '—' : acordes[i];
                      final selecionado = i == idxAtivo;
                      final habilitado = !semSilaba && !semTom && acordes.isNotEmpty;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: habilitado ? () => _atribuirAcorde(i) : null,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
                            decoration: BoxDecoration(
                              color: selecionado
                                  ? const Color(0xFF2563EB)
                                  : habilitado
                                      ? Colors.white
                                      : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: selecionado
                                    ? const Color(0xFF2563EB)
                                    : habilitado
                                        ? const Color(0xFFCBD5E1)
                                        : const Color(0xFFE2E8F0),
                                width: selecionado ? 1.5 : 1,
                              ),
                              boxShadow: selecionado
                                  ? [BoxShadow(
                                      color: const Color(0xFF2563EB).withValues(alpha: 0.28),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    )]
                                  : habilitado
                                      ? [BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.05),
                                          blurRadius: 4,
                                          offset: const Offset(0, 1),
                                        )]
                                      : null,
                            ),
                            child: Text(
                              label,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: selecionado
                                    ? Colors.white
                                    : habilitado
                                        ? const Color(0xFF1E293B)
                                        : const Color(0xFFCBD5E1),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              // Botão diagrama + remover
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 160),
                child: idxAtivo != null
                    ? Row(
                        key: const ValueKey('actions'),
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () => showChordDiagram(context, acordes[idxAtivo]),
                            child: Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.piano_outlined, color: Color(0xFF2563EB), size: 20),
                            ),
                          ),
                          GestureDetector(
                            onTap: _removerAcorde,
                            child: Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEE2E2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.delete_outline, color: Color(0xFFDC2626), size: 20),
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(key: ValueKey('none')),
              ),
            ],
          ),

          // ── Duração por sílaba ─────────────────────────────────
          if (_silabaAtiva != null && idxAtivo != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Text(
                  'DURAÇÃO',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF94A3B8),
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(width: 14),
                ...List.generate(4, (i) {
                  final beats = i + 1;
                  final atual = _batidasPorSilaba[_silabaAtiva!] ?? 2;
                  final selecionado = atual == beats;
                  return Padding(
                    padding: EdgeInsets.only(right: i < 3 ? 8 : 0),
                    child: GestureDetector(
                      onTap: () => setState(() => _batidasPorSilaba[_silabaAtiva!] = beats),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 48,
                        height: 40,
                        decoration: BoxDecoration(
                          color: selecionado ? const Color(0xFF2563EB) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$beats',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: selecionado ? Colors.white : const Color(0xFF1E293B),
                              ),
                            ),
                            Text(
                              beats == 1 ? 'bat.' : 'bat.',
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w600,
                                color: selecionado ? Colors.white60 : const Color(0xFFADB9C7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ],

          // ── Playback ───────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(vertical: landscape ? 6 : 12),
            child: const Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),
          Row(
            children: [
              // Controles BPM
              _BpmButton(Icons.remove, () => _ajustarBpm(-5)),
              const SizedBox(width: 8),
              SizedBox(
                width: 72,
                child: Text(
                  '$_bpm BPM',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _BpmButton(Icons.add, () => _ajustarBpm(5)),
              const Spacer(),
              // Botão play/stop
              GestureDetector(
                onTap: acordes.isEmpty
                    ? null
                    : _tocando
                        ? _pararAcordes
                        : () => _tocarAcordes(acordes),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: acordes.isEmpty
                        ? const Color(0xFFF1F5F9)
                        : _tocando
                            ? const Color(0xFFDC2626)
                            : const Color(0xFF2563EB),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: acordes.isNotEmpty
                        ? [BoxShadow(
                            color: (_tocando
                                ? const Color(0xFFDC2626)
                                : const Color(0xFF2563EB)).withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          )]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _tocando ? Icons.stop_rounded : Icons.play_arrow_rounded,
                        color: acordes.isEmpty ? const Color(0xFFCBD5E1) : Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _tocando ? 'Parar' : 'Tocar',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: acordes.isEmpty ? const Color(0xFFCBD5E1) : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── BPM button ────────────────────────────────────────────────────────────────

class _BpmButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _BpmButton(this.icon, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: const Color(0xFF475569)),
      ),
    );
  }
}
