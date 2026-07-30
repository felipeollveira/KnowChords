// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get navProgression => 'Progressão';

  @override
  String get navComposition => 'Composição';

  @override
  String get navFavorites => 'Favoritos';

  @override
  String get splashSubtitle => 'Sua guitarra, seus acordes';

  @override
  String get homeTitle1 => 'Monte sua progressão';

  @override
  String get homeTitle2 => 'de acordes';

  @override
  String get selectTone => 'Selecione o Tom';

  @override
  String get yourProgression => 'Sua Progressão';

  @override
  String chordsInTone(String tone) {
    return 'Acordes em $tone';
  }

  @override
  String get tapChordToReplace => 'Toque um acorde abaixo para substituir';

  @override
  String get cancel => 'Cancelar';

  @override
  String get tapChordsToStart => 'Toque nos acordes abaixo para começar';

  @override
  String numChords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count acordes',
      one: '1 acorde',
    );
    return '$_temp0';
  }

  @override
  String get share => 'Compartilhar';

  @override
  String get saveProgressionTooltip => 'Salvar progressão';

  @override
  String get clear => 'Limpar';

  @override
  String get progressionHint =>
      'Segure para remover  •  Toque para substituir  •  ●● para duração';

  @override
  String get chooseToneToStart => 'Escolha o tom para começar';

  @override
  String get availableChordsAppearHere =>
      'Os acordes disponíveis aparecerão aqui';

  @override
  String get tapToSeeDiagram => 'toque para\nver diagrama';

  @override
  String get saveProgressionTitle => 'Salvar Progressão';

  @override
  String get progressionNameHint => 'Nome da progressão...';

  @override
  String get save => 'Salvar';

  @override
  String get progressionSaved => 'Progressão salva!';

  @override
  String numBeats(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'batidas',
      one: 'batida',
    );
    return '$_temp0';
  }

  @override
  String get howManyBeats => 'Quantas batidas este acorde dura?';

  @override
  String progressionShareText(String tone, String chords, int bpm) {
    return '🎸 Progressão em $tone\n$chords\n$bpm BPM\n\nFeito com KnowChords';
  }

  @override
  String get compositionHeader => 'Composição';

  @override
  String get editLyricsTitle => 'Editar letra?';

  @override
  String get chordsWillBeLost =>
      'Os acordes atribuídos serão perdidos ao editar a letra.';

  @override
  String get editAnyway => 'Editar assim mesmo';

  @override
  String get editLyricsTooltip => 'Editar letra';

  @override
  String get saveCompositionTooltip => 'Salvar composição';

  @override
  String get lyricsHint => 'Cole ou escreva a letra da música aqui...';

  @override
  String get addChords => 'Adicionar Acordes';

  @override
  String get selectToneAbove => 'Selecione um tom acima';

  @override
  String get tapSyllableToAddChord =>
      'Toque em uma sílaba para adicionar acorde';

  @override
  String chordLabel(String chord) {
    return 'Acorde: $chord';
  }

  @override
  String get chooseChord => 'Escolha o acorde';

  @override
  String get duration => 'DURAÇÃO';

  @override
  String get beatAbbrev => 'bat.';

  @override
  String get stop => 'Parar';

  @override
  String get play => 'Tocar';

  @override
  String get selectToneFirst => 'Selecione um tom primeiro';

  @override
  String get saveCompositionTitle => 'Salvar Composição';

  @override
  String get compositionNameHint => 'Nome da composição...';

  @override
  String get compositionSaved => 'Composição salva!';

  @override
  String compositionShareText(
      String lyrics, String chords, String tone, int bpm) {
    return '🎵 $lyrics\n\nAcordes: $chords\nTom: $tone · $bpm BPM\n\nFeito com KnowChords';
  }

  @override
  String get favorites => 'Favoritos';

  @override
  String get deleteTitle => 'Excluir?';

  @override
  String get deleteContent => 'Este item será removido permanentemente.';

  @override
  String get delete => 'Excluir';

  @override
  String get nothingSaved => 'Nada salvo ainda';

  @override
  String get saveToAccess =>
      'Salve progressões e composições\npara acessar aqui.';

  @override
  String get progressionLabel => 'Progressão';

  @override
  String get compositionLabel => 'Composição';

  @override
  String get dateToday => 'Hoje';

  @override
  String get dateYesterday => 'Ontem';

  @override
  String dateNDaysAgo(int days) {
    return 'Há $days dias';
  }

  @override
  String get supportTitle => 'Apoiar o app';

  @override
  String get supportSubtitle =>
      'Se o KnowChords foi útil, considere apoiar o desenvolvimento ☕';
}
