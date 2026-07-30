import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'screens/home_screen.dart';
import 'screens/salvos_screen.dart';
import 'screens/composicao_screen.dart';
import 'screens/splash_screen.dart';
import 'services/save_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SaveService.instance.init();
  runApp(const AcordesApp());
}

class AcordesApp extends StatefulWidget {
  const AcordesApp({Key? key}) : super(key: key);

  @override
  State<AcordesApp> createState() => _AcordesAppState();
}

class _AcordesAppState extends State<AcordesApp> {
  int _selectedIndex = 0;
  bool _showSplash = true;

  late final List<Widget> _telas;

  @override
  void initState() {
    super.initState();
    _telas = [
      const HomeScreen(),
      const ComposicaoScreen(),
      SalvosScreen(onNavegar: (i) => setState(() => _selectedIndex = i)),
    ];
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => _showSplash = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KnowChords',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('pt'),
      ],
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF5F8FC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3B82F6),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 450),
        child: _showSplash
            ? const SplashScreen()
            : Builder(
                builder: (ctx) {
                  final l10n = AppLocalizations.of(ctx)!;
                  return Scaffold(
                    key: const ValueKey('main'),
                    body: IndexedStack(index: _selectedIndex, children: _telas),
                    bottomNavigationBar: NavigationBar(
                      backgroundColor: Colors.white,
                      elevation: 0,
                      surfaceTintColor: Colors.transparent,
                      indicatorColor: const Color(0xFF3B82F6).withValues(alpha: 0.12),
                      selectedIndex: _selectedIndex,
                      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                      onDestinationSelected: (index) =>
                          setState(() => _selectedIndex = index),
                      destinations: [
                        NavigationDestination(
                          icon: const Icon(Icons.queue_music_outlined),
                          selectedIcon: const Icon(Icons.queue_music, color: Color(0xFF3B82F6)),
                          label: l10n.navProgression,
                        ),
                        NavigationDestination(
                          icon: const Icon(Icons.lyrics_outlined),
                          selectedIcon: const Icon(Icons.lyrics, color: Color(0xFF3B82F6)),
                          label: l10n.navComposition,
                        ),
                        NavigationDestination(
                          icon: const Icon(Icons.favorite_outline),
                          selectedIcon: const Icon(Icons.favorite, color: Color(0xFF3B82F6)),
                          label: l10n.navFavorites,
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
