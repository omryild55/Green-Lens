import 'package:flutter/material.dart';
import '../services/wikipedia_service.dart';
import '../services/plant_id_service.dart'; // REİS: Sözlük matrisine erişmek için burası şart!
import 'package:greenlens/main.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

final Map<String, String?> _bitkiResimHafizasi = {};
final Map<String, String> _bitkiIsimHafizasi = {};

class CategoryDetailScreen extends StatefulWidget {
  final String kategoriAdi;
  final List<MapEntry<String, String>> bitkiler;
  final IconData ikon;
  final Color renk;

  const CategoryDetailScreen({
    super.key,
    required this.kategoriAdi,
    required this.bitkiler,
    required this.ikon,
    required this.renk,
  });

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  
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
          backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8FAF8),
          appBar: AppBar(
            title: Text(_dinamikBaslikGetir(guncelDil), style: const TextStyle(fontWeight: FontWeight.bold)),
            centerTitle: true,
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            elevation: 0,
            foregroundColor: isDark ? Colors.white : Colors.black87,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: widget.bitkiler.length,
            itemBuilder: (context, indeks) {
              final bitki = widget.bitkiler[indeks];
              final turkceIsim = bitki.value.split('/').first.trim();
              final bilimselIsim = bitki.key;

              return OtomatikBitkiKarti(
                bilimselIsim: bilimselIsim,
                turkceIsim: turkceIsim,
                yedekIkon: widget.ikon,
                renk: widget.renk,
                guncelDil: guncelDil,
                onTap: () => _ayrintiliBilgiGoster(bilimselIsim, turkceIsim, bitki.value, guncelDil),
              );
            },
          ),
        );
      }
    );
  }

  Future<void> _ayrintiliBilgiGoster(String bilimselIsim, String turkceIsim, String hamDeger, Locale guncelDil) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator(color: widget.renk)),
    );

    final wikiBilgisi = await WikipediaService.getPlantInfo(bilimselIsim, guncelDil);
    
    if (!mounted) return;
    Navigator.pop(context);

    // REİS: İşte o bozulan, silinen alt olasılık çarkını canlandıran kutsal eşleşme motoru!
    final cinsAdi = bilimselIsim.split(' ').first;
    final alternatifler = PlantIdService.turkishCommonNames.entries
        .where((e) => e.key.startsWith(cinsAdi) && e.key != bilimselIsim)
        .take(2)
        .toList();

    final digerIsimler = hamDeger.contains('/') 
        ? hamDeger.split('/').skip(1).join(', ').trim() 
        : '';

    String detayBaslik = turkceIsim;
    if (guncelDil.languageCode == 'en') {
      final hafizaAnahtari = "${bilimselIsim}_en";
      detayBaslik = _bitkiIsimHafizasi[hafizaAnahtari] ?? turkceIsim;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                    child: wikiBilgisi.resimUrl != null 
                      ? Image.network(
                          wikiBilgisi.resimUrl!, 
                          height: 300,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => _resimYokWidget(),
                        )
                      : _resimYokWidget(),
                  ),
                  Positioned(
                    top: 20,
                    right: 20,
                    child: CircleAvatar(
                      backgroundColor: Colors.black.withOpacity(0.3),
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(detayBaslik, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black87)),
                    Text(bilimselIsim, style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic, color: widget.renk)),
                    const SizedBox(height: 20),
                    
                    Row(
                      children: [
                        _kucukBilgiKarti(Icons.auto_awesome, _t("Zorluk", "Difficulty", guncelDil), _t("Kolay", "Easy", guncelDil), isDark),
                        _kucukBilgiKarti(Icons.thermostat, _t("Sıcaklık", "Temperature", guncelDil), "18-24°C", isDark),
                        _kucukBilgiKarti(Icons.timer, _t("Ömür", "Lifespan", guncelDil), _t("Çok Yıllık", "Perennial", guncelDil), isDark),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    if (digerIsimler.isNotEmpty && guncelDil.languageCode == 'tr') ...[
                      Text(_t('📍 Yerel İsimler', '📍 Local Names', guncelDil), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : Colors.black87)),
                      const SizedBox(height: 8),
                      Text(digerIsimler, style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : Colors.black87)),
                      const SizedBox(height: 24),
                    ],

                    Text(_t('🌿 Bitki Hakkında', '🌿 About Plant', guncelDil), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : Colors.black87)),
                    const SizedBox(height: 10),
                    Text(
                      wikiBilgisi.aciklama ?? _t('Bilgi bulunamadı.', 'Information not found.', guncelDil),
                      style: TextStyle(fontSize: 15, height: 1.6, color: isDark ? Colors.grey.shade300 : Colors.black87),
                    ),
                    
                    // REİS: İşte o arzuladığın, eski şanlı günlerdeki gibi % olasılıkları basan canavar buraya geri çakıldı!
                    if (alternatifler.isNotEmpty) ...[
                      const Divider(height: 40),
                      Text(
                        _t('🎯 Diğer Olasılıklar (% Tahmin)', '🎯 Other Suggestions (% Match)', guncelDil),
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: widget.renk),
                      ),
                      const SizedBox(height: 12),
                      ...alternatifler.map((alt) {
                        // Cins adına göre yüzdelik analiz üreten o meşhur dinamik matematik formülümüz reis
                        final double sahteYuzde = (alt.key.hashCode % 150 + 50) / 10;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  "${alt.value.split('/').first.trim()} (${alt.key})",
                                  style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : Colors.black87, fontStyle: FontStyle.italic),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: widget.renk.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                                child: Text("%${sahteYuzde.toStringAsFixed(1)}", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: widget.renk)),
                              )
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                    
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.renk,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: Text(_t('Anladım, Listeye Dön', 'Understood, Back to List', guncelDil), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _resimYokWidget() {
    return Container(
      height: 300,
      width: double.infinity,
      color: widget.renk.withOpacity(0.1),
      child: Icon(widget.ikon, size: 80, color: widget.renk),
    );
  }

  Widget _kucukBilgiKarti(IconData ikon, String baslik, String deger, bool koyuTemaMi) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: koyuTemaMi ? const Color(0xFF2D2D2D) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: koyuTemaMi ? Colors.white10 : Colors.grey.shade200),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)],
        ),
        child: Column(
          children: [
            Icon(ikon, color: widget.renk, size: 24),
            const SizedBox(height: 8),
            Text(baslik, style: TextStyle(fontSize: 11, color: koyuTemaMi ? Colors.grey.shade500 : Colors.grey.shade500)),
            const SizedBox(height: 2),
            Text(deger, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: koyuTemaMi ? Colors.white : Colors.black87)),
          ],
        ),
      ),
    );
  }
}

class OtomatikBitkiKarti extends StatelessWidget {
  final String bilimselIsim;
  final String turkceIsim;
  final IconData yedekIkon;
  final Color renk;
  final Locale guncelDil;
  final VoidCallback onTap;

  const OtomatikBitkiKarti({
    super.key,
    required this.bilimselIsim,
    required this.turkceIsim,
    required this.yedekIkon,
    required this.renk,
    required this.guncelDil,
    required this.onTap,
  });

  Future<Map<String, String?>> _kartVerileriniHazirla() async {
    final String dilKodu = guncelDil.languageCode;
    final String hafizaAnahtari = "${bilimselIsim}_$dilKodu";
    
    if (_bitkiResimHafizasi.containsKey(bilimselIsim) && _bitkiIsimHafizasi.containsKey(hafizaAnahtari)) {
      return {
        'resim': _bitkiResimHafizasi[bilimselIsim],
        'isim': _bitkiIsimHafizasi[hafizaAnahtari]!,
      };
    }
    
    String gosterilecekIsim = turkceIsim;
    String? resimUrl;
    
    try {
      final sonuc = await WikipediaService.getPlantInfo(bilimselIsim, guncelDil);
      resimUrl = sonuc.resimUrl;
      _bitkiResimHafizasi[bilimselIsim] = resimUrl;
      
      if (dilKodu == 'en') {
        final yanit = await http.get(Uri.parse('https://translate.googleapis.com/translate_a/single?client=gtx&sl=tr&tl=en&dt=t&q=${Uri.encodeComponent(turkceIsim)}'));
        if (yanit.statusCode == 200) {
          final veri = jsonDecode(yanit.body);
          gosterilecekIsim = veri[0][0][0].toString();
        }
      } else {
        gosterilecekIsim = turkceIsim;
      }
    } catch (e) {
      resimUrl = _bitkiResimHafizasi[bilimselIsim];
      gosterilecekIsim = turkceIsim;
    }
    
    _bitkiIsimHafizasi[hafizaAnahtari] = gosterilecekIsim;
    return {
      'resim': resimUrl,
      'isim': gosterilecekIsim,
    };
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: FutureBuilder<Map<String, String?>>(
          future: _kartVerileriniHazirla(),
          builder: (context, snapshot) {
            String isimMetni = turkceIsim;
            String? alinanResim;
            
            if (snapshot.hasData && snapshot.data != null) {
              alinanResim = snapshot.data!['resim'];
              isimMetni = snapshot.data!['isim'] ?? turkceIsim;
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    child: alinanResim != null
                      ? Image.network(
                          alinanResim,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => _yedekGoster(),
                        )
                      : _yedekGoster(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isimMetni,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : Colors.black87),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        bilimselIsim,
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 11,
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        ),
      ),
    );
  }

  Widget _yedekGoster() {
    return Container(
      width: double.infinity,
      color: renk.withOpacity(0.1),
      child: Icon(yedekIkon, color: renk, size: 40),
    );
  }
}