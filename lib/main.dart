import 'package:flutter/material.dart';
import 'package:po/beranda_screen.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'booking_history_screen.dart';
import 'account_screen.dart';

void main() {
  runApp(AirlineApp());
}

class AirlineApp extends StatefulWidget {
  @override
  _AirlineAppState createState() => _AirlineAppState();
}

class _AirlineAppState extends State<AirlineApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        dialogBackgroundColor: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        primaryColor: Colors.blue[800],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: Colors.blue[800],
          unselectedItemColor: Colors.grey,
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.blue[700],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[900],
          foregroundColor: Colors.white,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: Colors.blue[300],
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.grey[900],
        ),
        textTheme: ThemeData.dark().textTheme.apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
      ),
      themeMode: _themeMode,
      // Tampilkan HomeScreen dulu, lalu navigasi ke MainScreen setelah delay
      home: SplashScreen(
        onFinish: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => MainScreen(onChangeTheme: _toggleTheme),
            ),
          );
        },
      ),
    );
  }
}

// SplashScreen sementara pakai HomeScreen tampilan awal
class SplashScreen extends StatefulWidget {
  final VoidCallback onFinish;

  const SplashScreen({Key? key, required this.onFinish}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), widget.onFinish);
  }

  @override
  Widget build(BuildContext context) {
    return const HomeScreen(); // Tampilkan HomeScreen tanpa navigasi
  }
}

class MainScreen extends StatefulWidget {
  final VoidCallback onChangeTheme;

  const MainScreen({Key? key, required this.onChangeTheme}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      BerandaScreen(),
      SearchScreen(),
      BookingHistoryScreen(),
      AccountScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: theme.bottomNavigationBarTheme.selectedItemColor,
        unselectedItemColor: theme.bottomNavigationBarTheme.unselectedItemColor,
        items: const [
          // BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),    // Index 0
          // BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Cari'),      // Index 1
          // BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),  // Index 2
          // BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Akun'),      // Index 3
        ],
      ),
    );
  }
}
