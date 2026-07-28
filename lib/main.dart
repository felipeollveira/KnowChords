import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/salvos_screen.dart';
import 'screens/composicao_screen.dart';
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

  late final List<Widget> _telas;

  @override
  void initState() {
    super.initState();
    _telas = [
      const HomeScreen(),
      const ComposicaoScreen(),
      SalvosScreen(onNavegar: (i) => setState(() => _selectedIndex = i)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KC',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF5F8FC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3B82F6),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: IndexedStack(index: _selectedIndex, children: _telas),
        bottomNavigationBar: NavigationBar(
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          indicatorColor: const Color(0xFF3B82F6).withValues(alpha: 0.12),
          selectedIndex: _selectedIndex,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          onDestinationSelected: (index) => setState(() => _selectedIndex = index),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.queue_music_outlined),
              selectedIcon: Icon(Icons.queue_music, color: Color(0xFF3B82F6)),
              label: 'Progressão',
            ),
            NavigationDestination(
              icon: Icon(Icons.lyrics_outlined),
              selectedIcon: Icon(Icons.lyrics, color: Color(0xFF3B82F6)),
              label: 'Composição',
            ),
            NavigationDestination(
              icon: Icon(Icons.favorite_outline),
              selectedIcon: Icon(Icons.favorite, color: Color(0xFF3B82F6)),
              label: 'Favoritos',
            ),
          ],
        ),
      ),
    );
  }
}
