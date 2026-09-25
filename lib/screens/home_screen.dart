import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/history_model.dart';
import '../services/plant_id_service.dart';
import '../services/database_service.dart';
import '../models/plant_model.dart';
import 'category_detail_screen.dart'; // REİS: Eski sayfa yerine modern CategoryDetailScreen eklendi!
import 'result_screen.dart';
import 'package:greenlens/main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin {
  final ImagePicker _picker = ImagePicker();
  List<File> _selectedImages = [];
  bool _isLoading = false;
  String? _errorDisplay;

  @override
  bool get wantKeepAlive => true;

  String _t(String tr, String en, Locale aktifDil) {
    return aktifDil.languageCode == 'tr' ? tr : en;
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      if (source == ImageSource.camera) {
        var status = await Permission.camera.request();
        if (!status.isGranted) {
          final String izinHatasi = dilNotifier.value.languageCode == 'tr' ? "Kamera izni reddedildi." : "Camera permission denied.";
          setState(() => _errorDisplay = izinHatasi);
          return;
        }
      }
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1080,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          _errorDisplay = null;
          _selectedImages = [File(pickedFile.path)];
        });
      }
    } catch (e) {
      final String resimHatasi = dilNotifier.value.languageCode == 'tr' ? "Resim alma hatası: $e" : "Image picker error: $e";
      setState(() => _errorDisplay = resimHatasi);
    }
  }

  Future<void> _identifyPlant(Locale guncelDil) async {
    if (_selectedImages.isEmpty) {
      final String secimHatasi = guncelDil.languageCode == 'tr' ? "Lütfen bir resim çekin veya seçin." : "Please capture or select an image.";
      setState(() => _errorDisplay = secimHatasi);
      return;
    }
    setState(() {
      _isLoading = true;
      _errorDisplay = null;
    });
    try {
      final response = await PlantIdService.identifyPlant(images: _selectedImages, aktifDil: guncelDil);
      
      if (response.suggestions.isEmpty) {
        final String tanimHatasi = guncelDil.languageCode == 'tr' ? "Bitki türü tanımlanamadı." : "Could not identify plant species.";
        setState(() => _errorDisplay = tanimHatasi);
      } else {
        final bestResult = response.suggestions.first;
        final tarananDosya = _selectedImages.first;

        await DatabaseService.insertHistory(HistoryModel(
          imagePath: tarananDosya.path,
          scientificName: bestResult.scientificName,
          commonNames: bestResult.commonNames.join(', '),
          confidence: bestResult.probability,
          date: DateTime.now().toIso8601String(),
        ));
        
        setState(() {
          _selectedImages = [];
        });

        if (!mounted) return;
        
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              result: response,
              imageFile: tarananDosya,
            ),
          ),
        );
      }
    } catch (e) {
      final String apiHatasi = guncelDil.languageCode == 'tr' ? "API Hatası: $e" : "API Error: $e";
      setState(() => _errorDisplay = apiHatasi);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _goToCategory(String categoryName) {
    final allPlants = PlantIdService.turkishCommonNames.entries.toList();
    Map<String, List<String>> keywords = {
      'Şifalı Bitkiler': ['şifalı', 'tıbbi', 'lavanta', 'kekik', 'adaçayı', 'nane', 'papatya'],
      'Çiçekler': ['çiçek', 'lale', 'gül', 'orkide', 'sümbül', 'nergis', 'papatya', 'menekşe'],
      'Ağaçlar': ['ağaç', 'çam', 'meşe', 'akçaağaç', 'kavak', 'söğüt'],
    };
    final keys = keywords[categoryName] ?? [];
    final filtered = allPlants.where((plant) => keys.any((k) => plant.value.toLowerCase().contains(k))).toList();
    
    if (filtered.isNotEmpty) {
      IconData icon = Icons.spa;
      Color color = Colors.purple;
      if (categoryName == 'Çiçekler') {
        icon = Icons.local_florist;
        color = Colors.pink;
      } else if (categoryName == 'Ağaçlar') {
        icon = Icons.park;
        color = Colors.green;
      }
      
      final String aktifDil = dilNotifier.value.languageCode;
      final String gosterilecekAd = aktifDil == 'tr' 
          ? categoryName 
          : (categoryName == 'Çiçekler' ? 'Flowers' : (categoryName == 'Ağaçlar' ? 'Trees' : 'Medicinal Plants'));

      // REİS: İşte kilit nokta burası! Navigator artık sap sapan eski ekran yerine modern CategoryDetailScreen ekranına gidiyor!
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CategoryDetailScreen(
            kategoriAdi: gosterilecekAd,
            bitkiler: filtered,
            ikon: icon,
            renk: color,
          ),
        ),
      );
    } else {
      final String bulunamadiHatasi = dilNotifier.value.languageCode == 'tr' ? 'Bu kategoride bitki bulunamadı' : 'No plants found in this category';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(bulunamadiHatasi), backgroundColor: Colors.orange),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ValueListenableBuilder<Locale>(
      valueListenable: dilNotifier,
      builder: (context, guncelDil, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 60,
                backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
                elevation: 0,
                title: const Text('GreenLens Pro', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                centerTitle: true,
                pinned: true,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_t("Proje-1 Dersi! 🌿", "Project-1 Course! 🌿", guncelDil), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      Text(_t("Doğayı keşfetmek için bir resim ekle.", "Add an image to explore nature.", guncelDil), style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey)),
                      const SizedBox(height: 25),
                      _buildMainCard(isDark, guncelDil),
                      const SizedBox(height: 35),
                      Text(_t("Hızlı Kategoriler", "Quick Categories", guncelDil), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 15),
                      SizedBox(
                        height: 110,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _catCard(Icons.local_florist, 'Çiçekler', 'Flowers', isDark, guncelDil),
                            const SizedBox(width: 12),
                            _catCard(Icons.park, 'Ağaçlar', 'Trees', isDark, guncelDil),
                            const SizedBox(width: 12),
                            _catCard(Icons.spa, 'Şifalı Bitkiler', 'Medicinal Plants', isDark, guncelDil),
                          ],
                        ),
                      ),
                      const SizedBox(height: 35),
                      Text(_t("Tarama İpuçları", "Scanning Tips", guncelDil), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 15),
                      _buildTipCard(isDark, guncelDil),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildTipCard(bool isDark, Locale guncelDil) {
    final List<Map<String, String>> ipuclari = [
      {'icon': '🌿', 'title': _t('Yaprak Şekli', 'Leaf Shape', guncelDil), 'desc': _t('Yaprağın tamamını çerçeveye al', 'Frame the whole leaf', guncelDil)},
      {'icon': '🌸', 'title': _t('Çiçek Detayı', 'Flower Detail', guncelDil), 'desc': _t('Çiçeğin ortasına odaklan', 'Focus on center of flower', guncelDil)},
      {'icon': '📏', 'title': _t('Mesafe', 'Distance', guncelDil), 'desc': _t('15-30 cm uzaktan çek', 'Keep 15-30 cm distance', guncelDil)},
      {'icon': '☀️', 'title': _t('Işık', 'Lighting', guncelDil), 'desc': _t('Doğal ışıkta çekim yap', 'Shoot in natural light', guncelDil)},
    ];
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade400, Colors.green.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb, color: Colors.white, size: 24),
              const SizedBox(width: 10),
              Text(
                _t("Başarılı Tarama İpuçları", "Successful Scan Tips", guncelDil),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: ipuclari.map((tip) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(tip['icon']!, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(
                      tip['title']!,
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      tip['desc']!,
                      style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _catCard(IconData ikon, String trAd, String enAd, bool isDark, Locale guncelDil) {
    final String kategoriAdi = guncelDil.languageCode == 'tr' ? trAd : enAd;
    return GestureDetector(
      onTap: () => _goToCategory(trAd),
      child: Container(
        width: 120,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2D2D2D) : Colors.green.shade50,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: isDark ? Colors.green.shade900 : Colors.green.shade200, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(ikon, color: Colors.green, size: 36),
            const SizedBox(height: 10),
            Text(
              kategoriAdi, 
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : Colors.black87), 
              textAlign: TextAlign.center
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainCard(bool isDark, Locale guncelDil) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(color: isDark ? const Color(0xFF1E1E1E) : Colors.green.shade50, borderRadius: BorderRadius.circular(30)),
    child: Column(
      children: [
        Row(
          children: [
            Expanded(child: _actionBtn(Icons.camera_alt, _t("Kamera", "Camera", guncelDil), () => _pickImage(ImageSource.camera), isDark)),
            const SizedBox(width: 15),
            Expanded(child: _actionBtn(Icons.photo_library, _t("Galeri", "Gallery", guncelDil), () => _pickImage(ImageSource.gallery), isDark)),
          ],
        ),
        if (_selectedImages.isNotEmpty) ...[
          const SizedBox(height: 20),
          ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.file(_selectedImages.first, height: 120, width: 120, fit: BoxFit.cover))
        ],
        const SizedBox(height: 25),
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: _isLoading ? null : () => _identifyPlant(guncelDil),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
            child: _isLoading 
                ? const CircularProgressIndicator(color: Colors.white) 
                : Text(_t("🔍 Bitkiyi Tanı", "🔍 Identify Plant", guncelDil), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
        if (_errorDisplay != null) Padding(padding: const EdgeInsets.only(top: 10), child: Text(_errorDisplay!, style: const TextStyle(color: Colors.red, fontSize: 12))),
      ],
    ),
  );

  Widget _actionBtn(IconData icon, String label, VoidCallback onTap, bool isDark) => InkWell(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(color: isDark ? const Color(0xFF2D2D2D) : Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(children: [Icon(icon, color: Colors.green), const SizedBox(height: 8), Text(label, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))]),
    ),
  );
}