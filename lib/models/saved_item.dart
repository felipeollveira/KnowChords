import 'dart:convert';

sealed class SavedItem {
  final String id;
  final String nome;
  final DateTime criadoEm;

  const SavedItem({required this.id, required this.nome, required this.criadoEm});

  Map<String, dynamic> toJson();

  static SavedItem fromJson(Map<String, dynamic> json) {
    return json['tipo'] == 'composicao'
        ? ComposicaoSalva.fromJson(json)
        : ProgressaoSalva.fromJson(json);
  }

  static String encodeList(List<SavedItem> items) =>
      jsonEncode(items.map((e) => e.toJson()).toList());

  static List<SavedItem> decodeList(String raw) {
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => SavedItem.fromJson(e as Map<String, dynamic>)).toList();
  }
}

class ProgressaoSalva extends SavedItem {
  final String tom;
  final List<int> indices;
  final List<int> batidas;
  final int bpm;

  const ProgressaoSalva({
    required super.id,
    required super.nome,
    required super.criadoEm,
    required this.tom,
    required this.indices,
    required this.batidas,
    required this.bpm,
  });

  @override
  Map<String, dynamic> toJson() => {
    'tipo': 'progressao',
    'id': id,
    'nome': nome,
    'criadoEm': criadoEm.toIso8601String(),
    'tom': tom,
    'indices': indices,
    'batidas': batidas,
    'bpm': bpm,
  };

  factory ProgressaoSalva.fromJson(Map<String, dynamic> json) => ProgressaoSalva(
    id: json['id'] as String,
    nome: json['nome'] as String,
    criadoEm: DateTime.parse(json['criadoEm'] as String),
    tom: json['tom'] as String,
    indices: List<int>.from(json['indices']),
    batidas: List<int>.from(json['batidas']),
    bpm: json['bpm'] as int,
  );
}

class ComposicaoSalva extends SavedItem {
  final String letra;
  final String tom;
  final Map<int, int> acordesPorSilaba;
  final Map<int, int> batidasPorSilaba;
  final int bpm;

  const ComposicaoSalva({
    required super.id,
    required super.nome,
    required super.criadoEm,
    required this.letra,
    required this.tom,
    required this.acordesPorSilaba,
    required this.batidasPorSilaba,
    required this.bpm,
  });

  @override
  Map<String, dynamic> toJson() => {
    'tipo': 'composicao',
    'id': id,
    'nome': nome,
    'criadoEm': criadoEm.toIso8601String(),
    'letra': letra,
    'tom': tom,
    'acordesPorSilaba': acordesPorSilaba.map((k, v) => MapEntry(k.toString(), v)),
    'batidasPorSilaba': batidasPorSilaba.map((k, v) => MapEntry(k.toString(), v)),
    'bpm': bpm,
  };

  factory ComposicaoSalva.fromJson(Map<String, dynamic> json) => ComposicaoSalva(
    id: json['id'] as String,
    nome: json['nome'] as String,
    criadoEm: DateTime.parse(json['criadoEm'] as String),
    letra: json['letra'] as String,
    tom: json['tom'] as String,
    acordesPorSilaba: (json['acordesPorSilaba'] as Map<String, dynamic>)
        .map((k, v) => MapEntry(int.parse(k), v as int)),
    batidasPorSilaba: (json['batidasPorSilaba'] as Map<String, dynamic>)
        .map((k, v) => MapEntry(int.parse(k), v as int)),
    bpm: json['bpm'] as int,
  );
}
