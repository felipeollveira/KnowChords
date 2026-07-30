import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt')
  ];

  /// No description provided for @navProgression.
  ///
  /// In pt, this message translates to:
  /// **'Progressão'**
  String get navProgression;

  /// No description provided for @navComposition.
  ///
  /// In pt, this message translates to:
  /// **'Composição'**
  String get navComposition;

  /// No description provided for @navFavorites.
  ///
  /// In pt, this message translates to:
  /// **'Favoritos'**
  String get navFavorites;

  /// No description provided for @splashSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Sua guitarra, seus acordes'**
  String get splashSubtitle;

  /// No description provided for @homeTitle1.
  ///
  /// In pt, this message translates to:
  /// **'Monte sua progressão'**
  String get homeTitle1;

  /// No description provided for @homeTitle2.
  ///
  /// In pt, this message translates to:
  /// **'de acordes'**
  String get homeTitle2;

  /// No description provided for @selectTone.
  ///
  /// In pt, this message translates to:
  /// **'Selecione o Tom'**
  String get selectTone;

  /// No description provided for @yourProgression.
  ///
  /// In pt, this message translates to:
  /// **'Sua Progressão'**
  String get yourProgression;

  /// No description provided for @chordsInTone.
  ///
  /// In pt, this message translates to:
  /// **'Acordes em {tone}'**
  String chordsInTone(String tone);

  /// No description provided for @tapChordToReplace.
  ///
  /// In pt, this message translates to:
  /// **'Toque um acorde abaixo para substituir'**
  String get tapChordToReplace;

  /// No description provided for @cancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @tapChordsToStart.
  ///
  /// In pt, this message translates to:
  /// **'Toque nos acordes abaixo para começar'**
  String get tapChordsToStart;

  /// No description provided for @numChords.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 acorde} other{{count} acordes}}'**
  String numChords(int count);

  /// No description provided for @share.
  ///
  /// In pt, this message translates to:
  /// **'Compartilhar'**
  String get share;

  /// No description provided for @saveProgressionTooltip.
  ///
  /// In pt, this message translates to:
  /// **'Salvar progressão'**
  String get saveProgressionTooltip;

  /// No description provided for @clear.
  ///
  /// In pt, this message translates to:
  /// **'Limpar'**
  String get clear;

  /// No description provided for @progressionHint.
  ///
  /// In pt, this message translates to:
  /// **'Segure para remover  •  Toque para substituir  •  ●● para duração'**
  String get progressionHint;

  /// No description provided for @chooseToneToStart.
  ///
  /// In pt, this message translates to:
  /// **'Escolha o tom para começar'**
  String get chooseToneToStart;

  /// No description provided for @availableChordsAppearHere.
  ///
  /// In pt, this message translates to:
  /// **'Os acordes disponíveis aparecerão aqui'**
  String get availableChordsAppearHere;

  /// No description provided for @tapToSeeDiagram.
  ///
  /// In pt, this message translates to:
  /// **'toque para\nver diagrama'**
  String get tapToSeeDiagram;

  /// No description provided for @saveProgressionTitle.
  ///
  /// In pt, this message translates to:
  /// **'Salvar Progressão'**
  String get saveProgressionTitle;

  /// No description provided for @progressionNameHint.
  ///
  /// In pt, this message translates to:
  /// **'Nome da progressão...'**
  String get progressionNameHint;

  /// No description provided for @save.
  ///
  /// In pt, this message translates to:
  /// **'Salvar'**
  String get save;

  /// No description provided for @progressionSaved.
  ///
  /// In pt, this message translates to:
  /// **'Progressão salva!'**
  String get progressionSaved;

  /// No description provided for @numBeats.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{batida} other{batidas}}'**
  String numBeats(int count);

  /// No description provided for @howManyBeats.
  ///
  /// In pt, this message translates to:
  /// **'Quantas batidas este acorde dura?'**
  String get howManyBeats;

  /// No description provided for @progressionShareText.
  ///
  /// In pt, this message translates to:
  /// **'🎸 Progressão em {tone}\n{chords}\n{bpm} BPM\n\nFeito com KnowChords'**
  String progressionShareText(String tone, String chords, int bpm);

  /// No description provided for @compositionHeader.
  ///
  /// In pt, this message translates to:
  /// **'Composição'**
  String get compositionHeader;

  /// No description provided for @editLyricsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Editar letra?'**
  String get editLyricsTitle;

  /// No description provided for @chordsWillBeLost.
  ///
  /// In pt, this message translates to:
  /// **'Os acordes atribuídos serão perdidos ao editar a letra.'**
  String get chordsWillBeLost;

  /// No description provided for @editAnyway.
  ///
  /// In pt, this message translates to:
  /// **'Editar assim mesmo'**
  String get editAnyway;

  /// No description provided for @editLyricsTooltip.
  ///
  /// In pt, this message translates to:
  /// **'Editar letra'**
  String get editLyricsTooltip;

  /// No description provided for @saveCompositionTooltip.
  ///
  /// In pt, this message translates to:
  /// **'Salvar composição'**
  String get saveCompositionTooltip;

  /// No description provided for @lyricsHint.
  ///
  /// In pt, this message translates to:
  /// **'Cole ou escreva a letra da música aqui...'**
  String get lyricsHint;

  /// No description provided for @addChords.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar Acordes'**
  String get addChords;

  /// No description provided for @selectToneAbove.
  ///
  /// In pt, this message translates to:
  /// **'Selecione um tom acima'**
  String get selectToneAbove;

  /// No description provided for @tapSyllableToAddChord.
  ///
  /// In pt, this message translates to:
  /// **'Toque em uma sílaba para adicionar acorde'**
  String get tapSyllableToAddChord;

  /// No description provided for @chordLabel.
  ///
  /// In pt, this message translates to:
  /// **'Acorde: {chord}'**
  String chordLabel(String chord);

  /// No description provided for @chooseChord.
  ///
  /// In pt, this message translates to:
  /// **'Escolha o acorde'**
  String get chooseChord;

  /// No description provided for @duration.
  ///
  /// In pt, this message translates to:
  /// **'DURAÇÃO'**
  String get duration;

  /// No description provided for @beatAbbrev.
  ///
  /// In pt, this message translates to:
  /// **'bat.'**
  String get beatAbbrev;

  /// No description provided for @stop.
  ///
  /// In pt, this message translates to:
  /// **'Parar'**
  String get stop;

  /// No description provided for @play.
  ///
  /// In pt, this message translates to:
  /// **'Tocar'**
  String get play;

  /// No description provided for @selectToneFirst.
  ///
  /// In pt, this message translates to:
  /// **'Selecione um tom primeiro'**
  String get selectToneFirst;

  /// No description provided for @saveCompositionTitle.
  ///
  /// In pt, this message translates to:
  /// **'Salvar Composição'**
  String get saveCompositionTitle;

  /// No description provided for @compositionNameHint.
  ///
  /// In pt, this message translates to:
  /// **'Nome da composição...'**
  String get compositionNameHint;

  /// No description provided for @compositionSaved.
  ///
  /// In pt, this message translates to:
  /// **'Composição salva!'**
  String get compositionSaved;

  /// No description provided for @compositionShareText.
  ///
  /// In pt, this message translates to:
  /// **'🎵 {lyrics}\n\nAcordes: {chords}\nTom: {tone} · {bpm} BPM\n\nFeito com KnowChords'**
  String compositionShareText(
      String lyrics, String chords, String tone, int bpm);

  /// No description provided for @favorites.
  ///
  /// In pt, this message translates to:
  /// **'Favoritos'**
  String get favorites;

  /// No description provided for @deleteTitle.
  ///
  /// In pt, this message translates to:
  /// **'Excluir?'**
  String get deleteTitle;

  /// No description provided for @deleteContent.
  ///
  /// In pt, this message translates to:
  /// **'Este item será removido permanentemente.'**
  String get deleteContent;

  /// No description provided for @delete.
  ///
  /// In pt, this message translates to:
  /// **'Excluir'**
  String get delete;

  /// No description provided for @nothingSaved.
  ///
  /// In pt, this message translates to:
  /// **'Nada salvo ainda'**
  String get nothingSaved;

  /// No description provided for @saveToAccess.
  ///
  /// In pt, this message translates to:
  /// **'Salve progressões e composições\npara acessar aqui.'**
  String get saveToAccess;

  /// No description provided for @progressionLabel.
  ///
  /// In pt, this message translates to:
  /// **'Progressão'**
  String get progressionLabel;

  /// No description provided for @compositionLabel.
  ///
  /// In pt, this message translates to:
  /// **'Composição'**
  String get compositionLabel;

  /// No description provided for @dateToday.
  ///
  /// In pt, this message translates to:
  /// **'Hoje'**
  String get dateToday;

  /// No description provided for @dateYesterday.
  ///
  /// In pt, this message translates to:
  /// **'Ontem'**
  String get dateYesterday;

  /// No description provided for @dateNDaysAgo.
  ///
  /// In pt, this message translates to:
  /// **'Há {days} dias'**
  String dateNDaysAgo(int days);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
