import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/saved_item.dart';

class SaveService extends ChangeNotifier {
  SaveService._();
  static final SaveService instance = SaveService._();

  static const _key = 'knowchords_saves_v1';

  final loadProgressao = ValueNotifier<ProgressaoSalva?>(null);
  final loadComposicao = ValueNotifier<ComposicaoSalva?>(null);

  List<SavedItem> _items = [];
  SharedPreferences? _prefs;

  List<SavedItem> get items => List.unmodifiable(_items);

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs!.getString(_key);
    if (raw != null && raw.isNotEmpty) {
      try {
        _items = SavedItem.decodeList(raw);
      } catch (_) {
        _items = [];
      }
    }
  }

  Future<void> salvar(SavedItem item) async {
    final idx = _items.indexWhere((e) => e.id == item.id);
    if (idx >= 0) {
      _items[idx] = item;
    } else {
      _items.insert(0, item);
    }
    await _persist();
    notifyListeners();
  }

  Future<void> deletar(String id) async {
    _items.removeWhere((e) => e.id == id);
    await _persist();
    notifyListeners();
  }

  void requestLoadProgressao(ProgressaoSalva item) {
    loadProgressao.value = item;
  }

  void requestLoadComposicao(ComposicaoSalva item) {
    loadComposicao.value = item;
  }

  Future<void> _persist() async {
    await _prefs!.setString(_key, SavedItem.encodeList(_items));
  }

  static String newId() => DateTime.now().millisecondsSinceEpoch.toString();
}
