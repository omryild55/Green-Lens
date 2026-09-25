import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:greenlens/main.dart';
import 'package:share_plus/share_plus.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;
  bool _saveHistoryEnabled = true;
  bool _isDarkMode = false;
  String _selectedLanguage = 'Türkçe';
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    final ayarlar = await SharedPreferences.getInstance();
    final dilKodu = ayarlar.getString('language') ?? 'tr';
    setState(() {
      _notificationsEnabled = ayarlar.getBool('notifications') ?? true;
      _saveHistoryEnabled = ayarlar.getBool('saveHistory') ?? true;
      _isDarkMode = ayarlar.getBool('isDarkMode') ?? false;
      _selectedLanguage = dilKodu == 'tr' ? 'Türkçe' : 'English';
    });
  }
  
  Future<void> _saveSettings() async {
    final ayarlar = await SharedPreferences.getInstance();
    await ayarlar.setBool('notifications', _notificationsEnabled);
    await ayarlar.setBool('saveHistory', _saveHistoryEnabled);
    await ayarlar.setString('language', _selectedLanguage == 'Türkçe' ? 'tr' : 'en');
  }

  String _t(String tr, String en) {
    return _selectedLanguage == 'Türkçe' ? tr : en;
  }

  void _toggleDarkMode(bool deger) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext onayContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(_t('Tema Değişikliği', 'Theme Change')),
          content: Text(_t('Uygulama temasını değiştirmek istediğinize emin misiniz?', 'Are you sure you want to change the theme?')),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(onayContext);
              },
              child: Text(_t('İptal', 'Cancel'), style: const TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                final ayarlar = await SharedPreferences.getInstance();
                await ayarlar.setBool('isDarkMode', deger);
                
                setState(() {
                  _isDarkMode = deger;
                });
                
                if (mounted) {
                  Navigator.pop(onayContext);
                }
                
                await Future.delayed(const Duration(milliseconds: 300));
                temaModuNotifier.value = deger ? ThemeMode.dark : ThemeMode.light;
                _showToast(deger ? _t('🌙 Koyu tema aktif edildi', '🌙 Dark theme activated') : _t('☀️ Açık tema aktif edildi', '☀️ Light theme activated'));
              },
              child: Text(_t('Tamam', 'OK'), style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _t('👤 Profilim', '👤 My Profile'),
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 24),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.green),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          _buildProfileHeader(isDark),
          const SizedBox(height: 24),
          _buildStatsCard(isDark),
          const SizedBox(height: 24),
          _buildSettingsSection(isDark),
          const SizedBox(height: 24),
          _buildInfoSection(isDark),
          const SizedBox(height: 24),
          _buildLogoutButton(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
  
  Widget _buildProfileHeader(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                child: Image.network(
                  'https://via.placeholder.com/600x220',
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 160,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.green, Color(0xFF2E7D32)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                bottom: -40,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: isDark ? const Color(0xFF1E1E1E) : Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 45,
                    backgroundColor: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF5F5F5),
                    child: const Icon(Icons.person, size: 50, color: Colors.green), 
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 52),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Center(
                  child: Text(
                    'Ömer Yıldırım',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    _t('Öğrenci No: 254410108', 'Student ID: 254410108'),
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _t('Bilgisayar Mühendisliği Bölümü', 'Computer Engineering Department'),
                      style: const TextStyle(color: Colors.green, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Divider(color: Colors.grey.withOpacity(0.2), height: 1),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.assignment_outlined, color: Colors.green, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      _t('AKADEMİK PROJE KÜNYESİ', 'ACADEMIC PROJECT INFO'),
                      style: TextStyle(
                        fontSize: 12, 
                        fontWeight: FontWeight.w900, 
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                        letterSpacing: 1.0
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildKunyeSatiri(_t('Üniversite', 'University'), 'Kastamonu Üniversitesi', isDark),
                _buildKunyeSatiri(_t('Aşama', 'Stage'), _t('Proje 1 / Bitirme Projesi', 'Project 1 / Graduation Project'), isDark),
                _buildKunyeSatiri(_t('Proje Konusu', 'Project Topic'), _t('GreenLens Pro - Yapay Zeka Tabanlı Bitki Tanıma', 'GreenLens Pro - AI Based Plant Recognition'), isDark),
                _buildKunyeSatiri(_t('Danışman', 'Advisor'), _t('Dr. Öğretim Üyesi Ali Burak Öncül', 'Assist. Prof. Dr. Ali Burak Oncul'), isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKunyeSatiri(String baslik, String deger, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 95,
            child: Text(
              baslik,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(' :   ', style: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              deger,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatsCard(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('🌿', _t('Bitki Keşfi', 'Plant Discovery'), '12+', isDark),
          Container(width: 1, height: 40, color: Colors.grey.shade300),
          _buildStatItem('📸', _t('Fotoğraf', 'Photos'), '8', isDark),
          Container(width: 1, height: 40, color: Colors.grey.shade300),
          _buildStatItem('⭐', _t('Başarı', 'Success'), '92%', isDark),
        ],
      ),
    );
  }
  
  Widget _buildStatItem(String emoji, String label, String value, bool isDark) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 12),
        ),
      ],
    );
  }
  
  Widget _buildSettingsSection(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(Icons.settings, color: Colors.green),
                const SizedBox(width: 12),
                Text(_t('Uygulama Ayarları', 'App Settings'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const Divider(height: 0),
          SwitchListTile(
            secondary: const Icon(Icons.notifications, color: Colors.purple),
            title: Text(_t('Bildirimler', 'Notifications')),
            subtitle: Text(_t('Yeni bitki keşifleri için bildirim al', 'Get notifications for new plant discoveries')),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() => _notificationsEnabled = value);
              _saveSettings();
              _showToast(value ? _t('Bildirimler açıldı', 'Notifications enabled') : _t('Bildirimler kapatıldı', 'Notifications disabled'));
            },
            activeColor: Colors.green,
          ),
          const Divider(height: 0),
          SwitchListTile(
            secondary: const Icon(Icons.history, color: Colors.orange),
            title: Text(_t('Geçmiş Kaydet', 'Save History')),
            subtitle: Text(_t('Bitki tanıma geçmişini sakla', 'Save plant recognition history')),
            value: _saveHistoryEnabled,
            onChanged: (value) {
              setState(() => _saveHistoryEnabled = value);
              _saveSettings();
              _showToast(value ? _t('Geçmiş kaydı açıldı', 'History saving enabled') : _t('Geçmiş kaydı kapatıldı', 'History saving disabled'));
            },
            activeColor: Colors.green,
          ),
          const Divider(height: 0),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode, color: Colors.amber),
            title: Text(_t('Koyu Tema', 'Dark Mode')),
            subtitle: Text(_t('Tüm uygulamada koyu tema kullan', 'Use dark theme throughout the app')),
            value: _isDarkMode,
            onChanged: (value) => _toggleDarkMode(value),
            activeColor: Colors.green,
          ),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.language, color: Colors.teal),
            title: Text(_t('Dil Seçeneği', 'Language')),
            subtitle: Text(_selectedLanguage),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showLanguageDialog(),
          ),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.delete_sweep, color: Colors.red),
            title: Text(_t('Önbelleği Temizle', 'Clear Cache')),
            subtitle: Text(_t('Geçici dosyaları sil', 'Delete temporary files')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _clearCache(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoSection(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.teal),
            title: Text(_t('Hakkında', 'About')),
            subtitle: Text(_t('Proje bilgileri ve geliştirici', 'Project info and developer')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showAboutDialog(),
          ),

          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.share, color: Colors.blue),
            title: Text(_t('Paylaş', 'Share')),
            subtitle: Text(_t('Arkadaşlarını davet et', 'Invite your friends')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _shareApp(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLogoutButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton.icon(
        onPressed: () => _showLogoutDialog(),
        icon: const Icon(Icons.exit_to_app),
        label: Text(_t('ÇIKIŞ YAP', 'LOGOUT'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }
  
  void _showAboutDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: isDark ? const Color(0xFF2D2D2D) : Colors.white,
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  'https://sporakademisi.com/wp-content/uploads/2016/06/kastamonu-universitesi-logo.jpg',
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 150,
                    width: double.infinity,
                    color: Colors.green.shade100,
                    child: const Icon(Icons.school, size: 60, color: Colors.green),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '🌿 GreenLens Pro',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
              ),
              const SizedBox(height: 8),
              Text(
                _t('Versiyon 1.0.0', 'Version 1.0.0'),
                style: TextStyle(color: isDark ? Colors.white60 : Colors.grey.shade600, fontSize: 14),
              ),
              const Divider(height: 30),
              const SizedBox(height: 10),
              _aboutInfoRow(_t('👨‍🎓 Öğrenci', '👨‍🎓 Student'), 'Ömer YILDIRIM'),
              const SizedBox(height: 12),
              _aboutInfoRow(_t('🎓 Okul No', '🎓 Student ID'), '254410108'),
              const SizedBox(height: 12),
              _aboutInfoRow(_t('🏫 Fakülte', '🏫 Faculty'), _t('Mühendislik ve Mimarlık Fakültesi', 'Faculty of Engineering and Architecture')),
              const SizedBox(height: 12),
              _aboutInfoRow(_t('📚 Bölüm', '📚 Department'), _t('Bilgisayar Mühendisliği', 'Computer Engineering')),
              const SizedBox(height: 12),
              _aboutInfoRow(_t('📖 Ders', '📖 Course'), _t('PROJE-I (Bitirme Projesi)', 'PROJECT-I (Graduation Project)')),
              const SizedBox(height: 12),
              _aboutInfoRow(_t('👨‍🏫 Danışman', '👨‍🏫 Advisor'), _t('Dr. Öğretim Üyesi Ali Burak ÖNCÜL', 'Assist. Prof. Dr. Ali Burak ONCUL')),
              const Divider(height: 30),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: Text(_t('KAPAT', 'CLOSE'), style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _aboutInfoRow(String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white60 : Colors.grey.shade700,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
  
  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(_t('Dil Seçeneği', 'Language Option')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile(
              title: const Text('Türkçe'),
              value: 'Türkçe',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() => _selectedLanguage = value.toString());
                _saveSettings();
                dilNotifier.value = const Locale('tr');
                Navigator.pop(context);
                _showToast(_t('Dil Türkçe olarak değiştirildi', 'Language changed to Turkish'));
              },
            ),
            RadioListTile(
              title: const Text('English'),
              value: 'English',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() => _selectedLanguage = value.toString());
                _saveSettings();
                dilNotifier.value = const Locale('en');
                Navigator.pop(context);
                _showToast(_t('Language changed to English', 'Dil İngilizce olarak değiştirildi'));
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRatingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(_t('Uygulamayı Değerlendir', 'Rate the App')),
        content: Text(_t('Beğendiyseniz 5 yıldız verin! ⭐⭐⭐⭐⭐', 'If you like it, give 5 stars! ⭐⭐⭐⭐⭐')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_t('Şimdi Değil', 'Not Now')),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showToast(_t('Teşekkürler! ⭐⭐⭐⭐⭐', 'Thank you! ⭐⭐⭐⭐⭐'));
            },
            child: Text(_t('Değerlendir', 'Rate')),
          ),
        ],
      ),
    );
  }

  void _shareApp() async {
    const String appLink = 'https://github.com/omeryldrm/GreenLens';
    const String playStoreLink = 'https://play.google.com/store/apps/details?id=com.greenlens.app';
    
    const String mesajTr = '''
🌿 GreenLens Pro ile doğayı keşfet!

Yapay zeka ile bitkileri anında tanıyın.

📸 Fotoğraf çek → 🔍 Anında tanıma → 📚 Detaylı bilgi

✨ Özellikler:
• 8000+ bitki türü tanıma
• Wikipedia entegrasyonu
• Keşif geçmişi
• Koyu tema desteği

🔗 Proje Linki: $appLink
📦 Play Store: $playStoreLink

Kastamonu Üniversitesi - Bilgisayar Mühendisliği
Bitirme Projesi | Dr. Öğr. Üyesi Ali Burak ÖNCÜL

Geliştirici: Ömer YILDIRIM
Okul No: 254410108''';

    const String mesajEn = '''
🌿 Discover nature with GreenLens Pro!

Recognize plants instantly with AI.

📸 Take photo → 🔍 Instant recognition → 📚 Detailed info

✨ Features:
• 8000+ plant species recognition
• Wikipedia integration
• Discovery history
• Dark theme support

🔗 Project Link: $appLink
📦 Play Store: $playStoreLink

Kastamonu University - Computer Engineering
Graduation Project | Dr. Ali Burak ONCUL

Developer: Omer YILDIRIM
Student ID: 254410108''';

    final String message = _t(mesajTr, mesajEn);
    
    try {
      await Share.share(message);
      _showToast(_t('📱 Paylaşım seçenekleri açıldı', '📱 Share options opened'));
    } catch (e) {
      _showToast(_t('Paylaşım yapılamadı', 'Could not share'));
    }
  }
  
  void _clearCache() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(_t('Önbelleği Temizle', 'Clear Cache')),
        content: Text(_t('Geçici dosyalar silinecek. Devam et?', 'Temporary files will be deleted. Continue?')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(_t('İptal', 'Cancel'))),
          TextButton(
            onPressed: () async {
              PaintingBinding.instance.imageCache.clear();
              PaintingBinding.instance.imageCache.clearLiveImages();
              Navigator.pop(context);
              _showToast(_t('✅ Önbellek temizlendi', '✅ Cache cleared'));
            },
            child: Text(_t('Temizle', 'Clear'), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(_t('Çıkış Yap', 'Logout')),
        content: Text(_t('Uygulamadan çıkış yapmak istediğinize emin misiniz?', 'Are you sure you want to logout?')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(_t('İptal', 'Cancel'), style: const TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () {
              SystemNavigator.pop();
            },
            child: Text(_t('Çıkış', 'Logout'), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
  
  void _showToast(String mesaj) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mesaj),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.green,
      ),
    );
  }
}