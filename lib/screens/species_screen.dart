import 'package:flutter/material.dart';
import '../services/plant_id_service.dart';
import 'category_detail_screen.dart';
import 'package:greenlens/main.dart'; // dilNotifier nesnesine erisim icin import eklendi

class SpeciesScreen extends StatefulWidget {
  const SpeciesScreen({super.key});

  @override
  State<SpeciesScreen> createState() => _SpeciesScreenState();
}

class _SpeciesScreenState extends State<SpeciesScreen> {
  final TextEditingController _aramaDenetleyicisi = TextEditingController();
  List<MapEntry<String, String>> _aramaSonuclari = [];
  bool _aramaYapiliyorMu = false;

  // Yeni l10n mimarisine gore guncellenmis dil secim fonksiyonu
  String _t(String tr, String en, Locale aktifDil) {
    return aktifDil.languageCode == 'tr' ? tr : en;
  }

  final List<Kategori> _kategoriler = [
    Kategori(ad: 'Çiçekler', enAd: 'Flowers', renk: Colors.pink, resimUrl: 'https://images.unsplash.com/photo-1490750967868-88aa4486c946?w=500&q=80', ikon: Icons.local_florist),
    Kategori(ad: 'Ağaçlar', enAd: 'Trees', renk: Colors.green, resimUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS6oH4tylbwCG1QsJJUYYM-NZtrwKxqDf3y4w&s', ikon: Icons.park),
    Kategori(ad: 'Otlar', enAd: 'Grasses', renk: Colors.lightGreen, resimUrl: 'https://www.sukulentler.com/wp-content/uploads/2021/07/135249-eski-cicekler-gecmisten-gelen-cicekler-hakkinda-bilgi-edinin.jpg', ikon: Icons.grass),
    Kategori(ad: 'Sukulentler', enAd: 'Succulents', renk: Colors.teal, resimUrl: 'https://www.cimsas.com.tr/wp-content/uploads/2024/09/yabani-ot2.jpg', ikon: Icons.water_drop),
    Kategori(ad: 'Şifalı Bitkiler', enAd: 'Medicinal Plants', renk: Colors.purple, resimUrl: 'https://i.lezzet.com.tr/images-xxlarge-secondary/evinizden-eksik-etmemeniz-gereken-birbirinden-faydali-11-sifali-bitki-d0fbb183-6267-4ee6-9075-e68811c0f2bf.jpg', ikon: Icons.spa),
    Kategori(ad: 'Baharatlar', enAd: 'Spices', renk: Colors.orange, resimUrl: 'https://images.unsplash.com/photo-1596040033229-a9821ebd058d?w=500&q=80', ikon: Icons.kitchen),
    Kategori(ad: 'Meyveler', enAd: 'Fruits', renk: Colors.red, resimUrl: 'https://images.unsplash.com/photo-1619566636858-adf3ef46400b?w=500&q=80', ikon: Icons.yard),
    Kategori(ad: 'Çalılar', enAd: 'Shrubs', renk: Colors.brown, resimUrl: 'https://tropikbitkiler.wordpress.com/wp-content/uploads/2021/01/ekran-alintisi.jpg?w=1024', ikon: Icons.forest),
  ];

  void _bitkiAra(String kelime) {
    final tumBitkiler = PlantIdService.turkishCommonNames.entries.toList();
    setState(() {
      if (kelime.isEmpty) {
        _aramaYapiliyorMu = false;
        _aramaSonuclari = [];
      } else {
        _aramaYapiliyorMu = true;
        final aranan = kelime.toLowerCase().trim();
        _aramaSonuclari = tumBitkiler.where((oge) {
          final anaAd = oge.value.split('/').first.toLowerCase().trim();
          final latinAd = oge.key.toLowerCase();
          return anaAd.contains(aranan) || latinAd.contains(aranan);
        }).toList();
      }
    });
  }

  List<MapEntry<String, String>> _kategoriyeGoreGetir(String kategoriAdi) {
    final tumBitkiler = PlantIdService.turkishCommonNames.entries.toList();
    Map<String, List<String>> anahtarlar = {
      'Çiçekler': ['çiçek', 'lale', 'gül', 'orkide', 'sümbül', 'nergis', 'papatya', 'menekşe'],
      'Ağaçlar': ['ağaç', 'çam', 'meşe', 'akçaağaç', 'kavak', 'söğüt'],
      'Otlar': ['otu', 'çimen', 'saz', 'kamış'],
      'Sukulentler': ['sukulent', 'sedum', 'yeşim', 'aloe'],
      'Şifalı Bitkiler': ['şifalı', 'tıbbi', 'lavanta', 'kekik', 'adaçayı'],
      'Baharatlar': ['fesleğen', 'nane', 'biberiye', 'maydanoz'],
      'Meyveler': ['elma', 'armut', 'kiraz', 'üzüm', 'çilek'],
      'Çalılar': ['çalı', 'funda', 'orman gülü'],
    };
    final liste = anahtarlar[kategoriAdi] ?? [];
    return tumBitkiler.where((oge) => liste.any((k) => oge.value.toLowerCase().contains(k))).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ValueListenableBuilder<Locale>(
      valueListenable: dilNotifier,
      builder: (context, guncelDil, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.green, size: 20),
              onPressed: () async {
                bool donebilirMi = await Navigator.maybePop(context);
                if (!donebilirMi && mounted) {
                  Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                }
              },
            ),
            title: Text(
              _t('🌿 Bitki Türleri', '🌿 Plant Species', guncelDil),
              style: TextStyle(
                color: isDark ? Colors.white : Colors.green, 
                fontWeight: FontWeight.bold, 
                fontSize: 22
              ),
            ),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06), 
                        blurRadius: 15, 
                        offset: const Offset(0, 8)
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _aramaDenetleyicisi,
                    onChanged: _bitkiAra,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      hintText: _t('Bitki ansiklopedisinde ara...', 'Search plant encyclopedia...', guncelDil),
                      hintStyle: TextStyle(color: isDark ? Colors.grey.shade500 : Colors.grey.shade400, fontSize: 15),
                      prefixIcon: const Icon(Icons.search, color: Colors.green),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _aramaYapiliyorMu 
                  ? _aramaSonuclariListesi(isDark, guncelDil) 
                  : _resimliGrid(isDark, guncelDil),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _resimliGrid(bool isDark, Locale guncelDil) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 0.85,
      ),
      itemCount: _kategoriler.length,
      itemBuilder: (context, indeks) {
        final kat = _kategoriler[indeks];
        final bitkiler = _kategoriyeGoreGetir(kat.ad);
        
        return GestureDetector(
          onTap: () {
            if (bitkiler.isNotEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CategoryDetailScreen(
                    kategoriAdi: guncelDil.languageCode == 'tr' ? kat.ad : kat.enAd,
                    bitkiler: bitkiler,
                    ikon: kat.ikon,
                    renk: kat.renk,
                  ),
                ),
              );
            }
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: kat.renk.withOpacity(0.1),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.network(
                    kat.resimUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: kat.renk.withOpacity(0.2),
                      child: Icon(kat.ikon, color: kat.renk, size: 50),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        guncelDil.languageCode == 'tr' ? kat.ad : kat.enAd,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _t('${bitkiler.length} bitki', '${bitkiler.length} plants', guncelDil),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _aramaSonuclariListesi(bool isDark, Locale guncelDil) {
    if (_aramaSonuclari.isEmpty) {
      return Center(
        child: Text(
          _t('Bulunamadı.', 'Not found.', guncelDil),
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _aramaSonuclari.length,
      itemBuilder: (context, indeks) {
        final bitki = _aramaSonuclari[indeks];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
          child: ListTile(
            leading: const Icon(Icons.eco, color: Colors.green),
            title: Text(
              bitki.value.split('/').first.trim(),
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            ),
            subtitle: Text(
              bitki.key,
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 12,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CategoryDetailScreen(
                    kategoriAdi: _t('Arama Sonucu', 'Search Result', guncelDil),
                    bitkiler: [bitki],
                    ikon: Icons.search,
                    renk: Colors.green,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class Kategori {
  final String ad;
  final String enAd;
  final Color renk;
  final String resimUrl;
  final IconData ikon;
  Kategori({required this.ad, required this.enAd, required this.renk, required this.resimUrl, required this.ikon});
}