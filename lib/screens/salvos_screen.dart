import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import '../services/save_service.dart';
import '../models/saved_item.dart';
import '../data/acordes.dart';
import '../widgets/support_card.dart';

class SalvosScreen extends StatefulWidget {
  final void Function(int) onNavegar;
  const SalvosScreen({super.key, required this.onNavegar});

  @override
  State<SalvosScreen> createState() => _SalvosScreenState();
}

class _SalvosScreenState extends State<SalvosScreen> {
  AppLocalizations get _l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    SaveService.instance.addListener(_onChanged);
  }

  @override
  void dispose() {
    SaveService.instance.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() => setState(() {});

  void _carregar(SavedItem item) {
    if (item is ProgressaoSalva) {
      SaveService.instance.requestLoadProgressao(item);
      widget.onNavegar(0);
    } else if (item is ComposicaoSalva) {
      SaveService.instance.requestLoadComposicao(item);
      widget.onNavegar(1);
    }
  }

  Future<bool> _confirmarDelete(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(l10n.deleteTitle,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            content: Text(l10n.deleteContent),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(l10n.cancel)),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: FilledButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
                child: Text(l10n.delete),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final items = SaveService.instance.items;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FC),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: items.isEmpty
                  ? _buildEmpty()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                      itemCount: items.length + 1,
                      itemBuilder: (_, i) {
                        if (i < items.length) return _buildCard(items[i]);
                        return const SupportCard();
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      color: const Color(0xFF0C1A2E),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.bookmark_rounded, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 10),
          Text(
            _l10n.favorites,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w200,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    final l10n = _l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.bookmark_border_rounded, size: 48, color: Color(0xFF3B82F6)),
            ),
            const SizedBox(height: 20),
            Text(l10n.nothingSaved,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F1D2E))),
            const SizedBox(height: 8),
            Text(
              l10n.saveToAccess,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(SavedItem item) {
    final l10n = _l10n;
    final isProgressao = item is ProgressaoSalva;
    final color = isProgressao ? const Color(0xFF3B82F6) : const Color(0xFF2563EB);
    final icon = isProgressao ? Icons.queue_music_rounded : Icons.lyrics_outlined;
    final label = isProgressao ? l10n.progressionLabel : l10n.compositionLabel;

    String info;
    if (item is ProgressaoSalva) {
      final acordes = obterAcordesDoTom(item.tom);
      final preview = item.indices.take(4).map((i) => acordes[i]).join(' · ');
      final mais = item.indices.length > 4 ? ' +${item.indices.length - 4}' : '';
      info = '$preview$mais  ·  ${item.bpm} BPM';
    } else {
      final c = item as ComposicaoSalva;
      final primeirasLinhas = c.letra.split('\n').first;
      final trecho = primeirasLinhas.length > 40
          ? '${primeirasLinhas.substring(0, 40)}…'
          : primeirasLinhas;
      info = '"$trecho"  ·  ${c.acordesPorSilaba.length} acordes';
    }

    final date = _formatDate(item.criadoEm);

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmarDelete(context),
      onDismissed: (_) => SaveService.instance.deletar(item.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 22),
      ),
      child: GestureDetector(
        onTap: () => _carregar(item),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0C1A2E).withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.nome,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F1D2E),
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      info,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: color,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          date,
                          style: const TextStyle(fontSize: 11, color: Color(0xFFADB9C7)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFFCBD5E0)),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final l10n = _l10n;
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return l10n.dateToday;
    if (diff.inDays == 1) return l10n.dateYesterday;
    if (diff.inDays < 7) return l10n.dateNDaysAgo(diff.inDays);
    final locale = Localizations.localeOf(context).languageCode;
    return DateFormat.MMMd(locale).format(dt);
  }
}
