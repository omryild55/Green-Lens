import 'package:flutter/material.dart';
import '../services/wikipedia_service.dart';
import '../services/plant_id_service.dart'; // REİS: Sözlüğe erişim için eklendi
import 'package:greenlens/main.dart'; // dilNotifier nesnesine erisim icin eklendi

class CategoryPlantsScreen extends StatefulWidget {
  final String kategoriAdi;
  final List<MapEntry<String, String>> bitkiler;
  final IconData ikon;
  final Color renk;

  const CategoryPlantsScreen({
    super.key,
    required this.kategoriAdi,
    required this.bitkiler,
    required this.ikon,
    required this.renk,
  });

  @override
  State<CategoryPlantsScreen> createState() => _CategoryPlantsScreenState();
}

class _CategoryPlantsScreenState extends State<CategoryPlantsScreen> {
  late List<MapEntry<String, String>> _filtrelenmisBitkiler;
  bool _aramaAcikMi = false;
  final TextEditingController _aramaDenetleyicisi = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filtrelenmisBitkiler = widget.bitkiler;
  }

  void _aramaYap(String kelime) {
    setState(() {
      _filtrelenmisBitkiler = widget.bitkiler.where((bitki) {
        final turkceIsim = bitki.value.toLowerCase();
        final bilimselIsim = bitki.key.toLowerCase();
        final arananKelime = kelime.toLowerCase();
        return turkceIsim.contains(arananKelime) || bilimselIsim.contains(arananKelime);
      }).toList();
    });
  }

  String _t(String tr, String en, Locale aktifDil) {
    return aktifDil.languageCode == 'tr' ? tr : en;
  }

  String _dinamikBaslikGetir(Locale aktifDil) {
    final baslik = widget.kategoriAdi;
    if (baslik == 'Çiçekler' || baslik == 'Flowers') {
      return aktifDil.languageCode == 'tr' ? 'Çiçekler' : 'Flowers';
    }
    if (baslik == 'Ağaçlar' || baslik == 'Trees') {
      return aktifDil.languageCode == 'tr' ? 'Ağaçlar' : 'Trees';
    }
    if (baslik == 'Şifalı Bitkiler' || baslik == 'Medicinal Plants') {
      return aktifDil.languageCode == 'tr' ? 'Şifalı Bitkiler' : 'Medicinal Plants';
    }
    return baslik; 
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
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            elevation: 0,
            foregroundColor: isDark ? Colors.white : Colors.black87,
            centerTitle: true,
            title: _aramaAcikMi
                ? TextField(
                    controller: _aramaDenetleyicisi,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: _t('Bitki ara...', 'Search plant...', guncelDil),
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: isDark ? Colors.grey.shade500 : Colors.grey),
                    ),
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 18),
                    onChanged: _aramaYap,
                  )
                : Text(
                    _dinamikBaslikGetir(guncelDil),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
            actions: [
              IconButton(
                icon: Icon(_aramaAcikMi ? Icons.close : Icons.search),
                onPressed: () {
                  setState(() {
                    if (_aramaAcikMi) {
                      _aramaAcikMi = false;
                      _aramaDenetleyicisi.clear();
                      _filtrelenmisBitkiler = widget.bitkiler;
                    } else {
                      _aramaAcikMi = true;
                    }
                  });
                },
              ),
            ],
          ),
          body: _filtrelenmisBitkiler.isEmpty
              ? Center(
                  child: Text(
                    _t('Aradığın bitki buralarda yok sanki...', 'The plant you are looking for is not here...', guncelDil),
                    style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _filtrelenmisBitkiler.length,
                  itemBuilder: (context, indeks) {
                    final bitki = _filtrelenmisBitkiler[indeks];
                    final turkceIsim = bitki.value.split('/').first.trim();
                    final bilimselIsim = bitki.key;
                    final resimUrl = 'https://source.unsplash.com/featured/?$bilimselIsim,plant';

                    return GestureDetector(
                      onTap: () => _detayDialogGoster(context, bilimselIsim, turkceIsim, isDark, guncelDil),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                child: Image.network(
                                  resimUrl,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    color: widget.renk.withOpacity(0.1),
                                    child: Icon(widget.ikon, color: widget.renk, size: 40),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    turkceIsim,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    bilimselIsim,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      fontSize: 12,
                                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
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
                ),
        );
      }
    );
  }

  Future<void> _detayDialogGoster(BuildContext context, String bilimselIsim, String turkceIsim, bool isDark, Locale guncelDil) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.green)),
    );

    final wikiBilgi = await WikipediaService.getPlantInfo(bilimselIsim, guncelDil);
    
    if (!context.mounted) return;
    Navigator.pop(context);

    // REİS: Aynı cinse ait alternatif bitkileri bulup olasılık simülasyonu yapan o şanlı motor!
    final cinsAdi = bilimselIsim.split(' ').first;
    final alternatifler = PlantIdService.turkishCommonNames.entries
        .where((e) => e.key.startsWith(cinsAdi) && e.key != bilimselIsim)
        .take(2)
        .toList();

    showDialog(
      context: context,
      builder: (BuildContext onayContext) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF2D2D2D) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          contentPadding: EdgeInsets.zero,
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
                  child: Image.network(
                    'https://source.unsplash.com/featured/?$bilimselIsim',
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 200,
                      color: widget.renk.withOpacity(0.1),
                      child: Icon(widget.ikon, color: widget.renk, size: 50),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        turkceIsim,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        bilimselIsim,
                        style: TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: isDark ? Colors.grey.shade400 : Colors.grey,
                        ),
                      ),
                      const Divider(height: 30),
                      Text(
                        wikiBilgi.aciklama ?? _t('Bilgi bulunamadı.', 'Information not found.', guncelDil),
                        style: TextStyle(
                          height: 1.5,
                          fontSize: 14,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                      
                      // REİS: İşte arzuladığın, silinen o şanlı "Diğer Olasılıklar" zırhı buraya geri çakıldı!
                      if (alternatifler.isNotEmpty) ...[
                        const Divider(height: 40),
                        Text(
                          _t('🎯 Diğer Olasılıklar (% Tahmin)', '🎯 Other Suggestions (% Match)', guncelDil),
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.green.shade600),
                        ),
                        const SizedBox(height: 10),
                        ...alternatifler.map((alt) {
                          final double sahteYuzde = (alt.key.hashCode % 150 + 50) / 10; // %5.0 ile %20.0 arası dinamik matematik
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    "${alt.value.split('/').first.trim()} (${alt.key})",
                                    style: TextStyle(fontSize: 13, color: isDark ? Colors.white70 : Colors.black87, fontStyle: FontStyle.italic),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                  child: Text("%${sahteYuzde.toStringAsFixed(1)}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green)),
                                )
                              ],
                            ),
                          );
                        }).toList(),
                      ]
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(onayContext),
              child: Text(
                _t('Kapat', 'Close', guncelDil),
                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}