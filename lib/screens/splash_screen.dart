import 'dart:async';
import 'package:flutter/material.dart';
import 'home_screen.dart'; // Reis senin ana sayfanın yolu neyse ona göre import et
import 'package:greenlens/main.dart';

class CustomSplashScreen extends StatefulWidget {
  const CustomSplashScreen({Key? key}) : super(key: key);

  @override
  State<CustomSplashScreen> createState() => _CustomSplashScreenState();
}

class _CustomSplashScreenState extends State<CustomSplashScreen> {
  @override
  void initState() {
    super.initState();
    // 2 saniye boyunca okul binası ekranda kalır, sonra tık diye ana sayfaya uçar
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainNavigation()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Arka plana o cillop gibi fakülte binasını tam ekran çakıyoruz
          Image.asset(
            'assets/splash_bg.bmp', // Reis burayı png yaptıysan png, jpg bıraktıysan jpg yaz
            fit: BoxFit.cover,
          ),
          // Karartma katmanı (Okul yazısı ve logo daha net gözüksün diye)
          Container(color: Colors.black.withOpacity(0.3)),
          // Ortadaki o şanlı logomuz
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/logo.png',
                    width: 120,
                    height: 120,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'KASTAMONU ÜNİVERSİTESİ\nMühendislik ve Mimarlık Fakültesi',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    shadows: [Shadow(blurRadius: 10, color: Colors.black, offset: Offset(0, 2))],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}