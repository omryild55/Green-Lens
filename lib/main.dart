import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'screens/species_screen.dart';
import 'screens/history_screen.dart';
import 'screens/chatbot_screen.dart'; // : Şanlı chatbot ekranımız burada
import 'screens/profile_screen.dart';
import 'l10n/app_localizations.dart';
import 'screens/splash_screen.dart';

final ValueNotifier<ThemeMode> temaModuNotifier = ValueNotifier(ThemeMode.light);
final ValueNotifier<Locale> dilNotifier = ValueNotifier(const Locale('tr'));
final ValueNotifier<int> veritabaniTazelemeNotifier = ValueNotifier<int>(0);
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await [
    Permission.camera,
    Permission.photos,
    Permission.storage,
  ].request();

  final ayarlar = await SharedPreferences.getInstance();
  final koyuTemaAktifMi = ayarlar.getBool('isDarkMode') ?? false;
  final dilKodu = ayarlar.getString('language') ?? 'tr';

  temaModuNotifier.value = koyuTemaAktifMi ? ThemeMode.dark : ThemeMode.light;
  dilNotifier.value = Locale(dilKodu);

  runApp(const GreenLensApp());
}

class GreenLensApp extends StatelessWidget {
  const GreenLensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: temaModuNotifier,
      builder: (context, guncelTemaModu, child) {
        return ValueListenableBuilder<Locale>(
          valueListenable: dilNotifier,
          builder: (context, guncelDil, child) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'GreenLens Pro',
              locale: guncelDil,
              supportedLocales: const [
                Locale('tr', 'TR'),
                Locale('en', 'US'),
                Locale('de', 'DE'),
              ],
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              theme: ThemeData.light().copyWith(
                primaryColor: Colors.green,
                scaffoldBackgroundColor: const Color(0xFFF5F5F5),
                appBarTheme: const AppBarTheme(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  centerTitle: false,
                  iconTheme: IconThemeData(color: Colors.green),
                ),
                cardColor: Colors.white,
              ),
              darkTheme: ThemeData.dark().copyWith(
                primaryColor: Colors.green,
                scaffoldBackgroundColor: const Color(0xFF121212),
                appBarTheme: const AppBarTheme(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  centerTitle: false,
                  iconTheme: IconThemeData(color: Colors.green),
                ),
                cardColor: const Color(0xFF1E1E1E),
              ),
              themeMode: guncelTemaModu,
              home: CustomSplashScreen(),
            );
          },
        );
      },
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}
class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  String _t(String tr, String en, Locale aktifDil) {
    return aktifDil.languageCode == 'tr' ? tr : en;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // REİS: Klavyenin açık olup olmadığını milimetrik hesaplayan o kutsal radar!
    final klavyeAcikMi = MediaQuery.of(context).viewInsets.bottom > 0;

    return ValueListenableBuilder<Locale>(
      valueListenable: dilNotifier,
      builder: (context, guncelDil, child) {
        final List<Widget> sayfalar = [
          const HomeScreen(),
          const SpeciesScreen(),
          const ChatbotScreen(),
          const HistoryScreen(),
          const ProfileScreen(),
        ];

        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: sayfalar,
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          // REİS: İşte o butonun yukarı fırlamasını engelleyen akıllı filtre! Klavye açıkken null dönüp butonu tamamen yok ediyor!
          floatingActionButton: klavyeAcikMi
              ? null
              : Container(
            width: 68,
            height: 68,
            margin: const EdgeInsets.only(top: 20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  _currentIndex = 2;
                });
              },
              backgroundColor: _currentIndex == 2 ? Colors.green.shade700 : Colors.green,
              shape: const CircleBorder(),
              elevation: 0,
              child: Icon(
                _currentIndex == 2 ? Icons.chat_bubble_rounded : Icons.chat_bubble_outline_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
          bottomNavigationBar: NavigationBarTheme(
            data: NavigationBarThemeData(
              indicatorColor: Colors.transparent,
              labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
                if (states.contains(WidgetState.selected)) {
                  return const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green);
                }
                return const TextStyle(fontSize: 11, fontWeight: FontWeight.w500);
              }),
              iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((states) {
                if (states.contains(WidgetState.selected)) {
                  return const IconThemeData(color: Colors.green, size: 24);
                }
                return const IconThemeData(color: Colors.grey, size: 24);
              }),
            ),
            child: NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: (int indeks) {
                setState(() {
                  if (indeks == 2) return;
                  _currentIndex = indeks;
                });
              },
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.camera_alt_outlined),
                  selectedIcon: const Icon(Icons.camera_alt),
                  label: _t('Tara', 'Scan', guncelDil),
                ),
                NavigationDestination(
                  icon: const Icon(Icons.search_outlined),
                  selectedIcon: const Icon(Icons.search),
                  label: _t('Türler', 'Species', guncelDil),
                ),
                NavigationDestination(
                  icon: const SizedBox(height: 10),
                  label: _t('Asistana Sor', 'Ask AI', guncelDil),
                ),
                NavigationDestination(
                  icon: const Icon(Icons.history_outlined),
                  selectedIcon: const Icon(Icons.history),
                  label: _t('Geçmiş', 'History', guncelDil),
                ),
                NavigationDestination(
                  icon: const Icon(Icons.person_outline),
                  selectedIcon: const Icon(Icons.person),
                  label: _t('Profil', 'Profile', guncelDil),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}