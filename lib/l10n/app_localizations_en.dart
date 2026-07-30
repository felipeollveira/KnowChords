// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navProgression => 'Progression';

  @override
  String get navComposition => 'Composition';

  @override
  String get navFavorites => 'Favorites';

  @override
  String get splashSubtitle => 'Your guitar, your chords';

  @override
  String get homeTitle1 => 'Build your chord';

  @override
  String get homeTitle2 => 'progression';

  @override
  String get selectTone => 'Select Key';

  @override
  String get yourProgression => 'Your Progression';

  @override
  String chordsInTone(String tone) {
    return 'Chords in $tone';
  }

  @override
  String get tapChordToReplace => 'Tap a chord below to replace';

  @override
  String get cancel => 'Cancel';

  @override
  String get tapChordsToStart => 'Tap chords below to start';

  @override
  String numChords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count chords',
      one: '1 chord',
    );
    return '$_temp0';
  }

  @override
  String get share => 'Share';

  @override
  String get saveProgressionTooltip => 'Save progression';

  @override
  String get clear => 'Clear';

  @override
  String get progressionHint =>
      'Hold to remove  •  Tap to replace  •  ●● for duration';

  @override
  String get chooseToneToStart => 'Choose a key to start';

  @override
  String get availableChordsAppearHere => 'Available chords will appear here';

  @override
  String get tapToSeeDiagram => 'tap to\nsee diagram';

  @override
  String get saveProgressionTitle => 'Save Progression';

  @override
  String get progressionNameHint => 'Progression name...';

  @override
  String get save => 'Save';

  @override
  String get progressionSaved => 'Progression saved!';

  @override
  String numBeats(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'beats',
      one: 'beat',
    );
    return '$_temp0';
  }

  @override
  String get howManyBeats => 'How many beats does this chord last?';

  @override
  String progressionShareText(String tone, String chords, int bpm) {
    return '🎸 Progression in $tone\n$chords\n$bpm BPM\n\nMade with KnowChords';
  }

  @override
  String get compositionHeader => 'Composition';

  @override
  String get editLyricsTitle => 'Edit lyrics?';

  @override
  String get chordsWillBeLost =>
      'Assigned chords will be lost when you edit the lyrics.';

  @override
  String get editAnyway => 'Edit anyway';

  @override
  String get editLyricsTooltip => 'Edit lyrics';

  @override
  String get saveCompositionTooltip => 'Save composition';

  @override
  String get lyricsHint => 'Paste or type the song lyrics here...';

  @override
  String get addChords => 'Add Chords';

  @override
  String get selectToneAbove => 'Select a key above';

  @override
  String get tapSyllableToAddChord => 'Tap a syllable to add a chord';

  @override
  String chordLabel(String chord) {
    return 'Chord: $chord';
  }

  @override
  String get chooseChord => 'Choose chord';

  @override
  String get duration => 'DURATION';

  @override
  String get beatAbbrev => 'beat';

  @override
  String get stop => 'Stop';

  @override
  String get play => 'Play';

  @override
  String get selectToneFirst => 'Select a key first';

  @override
  String get saveCompositionTitle => 'Save Composition';

  @override
  String get compositionNameHint => 'Composition name...';

  @override
  String get compositionSaved => 'Composition saved!';

  @override
  String compositionShareText(
      String lyrics, String chords, String tone, int bpm) {
    return '🎵 $lyrics\n\nChords: $chords\nKey: $tone · $bpm BPM\n\nMade with KnowChords';
  }

  @override
  String get favorites => 'Favorites';

  @override
  String get deleteTitle => 'Delete?';

  @override
  String get deleteContent => 'This item will be permanently removed.';

  @override
  String get delete => 'Delete';

  @override
  String get nothingSaved => 'Nothing saved yet';

  @override
  String get saveToAccess =>
      'Save progressions and compositions\nto access them here.';

  @override
  String get progressionLabel => 'Progression';

  @override
  String get compositionLabel => 'Composition';

  @override
  String get dateToday => 'Today';

  @override
  String get dateYesterday => 'Yesterday';

  @override
  String dateNDaysAgo(int days) {
    return '$days days ago';
  }
}
