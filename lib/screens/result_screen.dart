import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/plant_model.dart';
import 'package:greenlens/main.dart';

class ResultScreen extends StatefulWidget {
  final PlantIdentificationResult result;
  final File? imageFile;

  const ResultScreen({
    Key? key,
    required this.result,
    this.imageFile,
  }) : super(key: key);

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeOut);
    _slideAnimation = Tween<double>(begin: 50, end: 0).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _t(String tr, String en, Locale aktifDil) {
    return aktifDil.languageCode == 'tr' ? tr : en;
  }

  @override
  Widget build(BuildContext context) {
    final suggestion = widget.result.suggestions.first;
    final confidence = (suggestion.probability * 100).toStringAsFixed(1);
    final isHighConfidence = suggestion.probability > 0.7;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: ValueListenableBuilder<Locale>(
        valueListenable: dilNotifier,
        builder: (context, guncelDil, child) {
          return Scaffold(
            backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8FAFC),
            body: CustomScrollView(
              slivers: [
                _buildHeroAppBar(suggestion, isHighConfidence, confidence, guncelDil),
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Transform.translate(
                      offset: Offset(0, _slideAnimation.value),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            // REİS: İstediğin gibi Geri Dön butonunu resmin hemen altına konumlandırdık
                            _buildTopBackButton(isDark, guncelDil),
                            const SizedBox(height: 20),
                            _buildConfidenceCard(isHighConfidence, confidence, isDark, guncelDil),
                            const SizedBox(height: 24),
                            _buildScientificNameCard(suggestion, isDark, guncelDil),
                            const SizedBox(height: 24),
                            if (suggestion.commonNames.isNotEmpty) ...[
                              _buildCommonNamesCard(suggestion.commonNames, isDark, guncelDil),
                              const SizedBox(height: 24),
                            ],
                            _buildTaxonomyCard(suggestion.taxonomy, isDark, guncelDil),
                            const SizedBox(height: 24),
                            if (suggestion.wikiDescription != null) ...[
                              _buildDescriptionCard(suggestion.wikiDescription!, isDark, guncelDil),
                            ],
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }

  Widget _buildHeroAppBar(PlantSuggestion suggestion, bool isHighConfidence, String confidence, Locale guncelDil) {
    return SliverAppBar(
      expandedHeight: 480,
      pinned: true,
      stretch: true,
      backgroundColor: Colors.black,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: IconButton(
              icon: const Icon(Icons.share_rounded, color: Colors.white),
              onPressed: () => _sharePlantInfo(suggestion, guncelDil),
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (widget.imageFile != null)
              Image.file(
                widget.imageFile!,
                fit: BoxFit.cover,
              )
            else
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade800, Colors.green.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.2),
                    Colors.black.withOpacity(0.7),
                  ],
                  stops: const [0.4, 0.7, 1.0],
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.shade400,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified, size: 16, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(
                          _t('%$confidence Güvenilirlik', '%$confidence Confidence', guncelDil),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    suggestion.scientificName,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // REİS: Resmin hemen altına yerleştirdiğimiz modern Geri Dön butonu
  Widget _buildTopBackButton(bool isDark, Locale guncelDil) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
        label: Text(
          _t('GEÇMİŞE VE KEŞFE GERİ DÖN', 'RETURN TO DISCOVERY LOG', guncelDil),
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: isDark ? Colors.white70 : Colors.grey.shade800,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          side: BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300, width: 1.2),
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        ),
      ),
    );
  }

  Widget _buildConfidenceCard(bool isHighConfidence, String confidence, bool isDark, Locale guncelDil) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isHighConfidence
              ? [Colors.green.shade50, Colors.green.shade100]
              : [Colors.orange.shade50, Colors.orange.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (isHighConfidence ? Colors.green : Colors.orange).withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              isHighConfidence ? Icons.verified_rounded : Icons.science_rounded,
              color: isHighConfidence ? Colors.green : Colors.orange,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _t('Tanıma Güvenilirliği', 'Identification Confidence', guncelDil),
                  style: TextStyle(
                    color: isHighConfidence ? Colors.green.shade800 : Colors.orange.shade800,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '%$confidence',
                  style: TextStyle(
                    color: isHighConfidence ? Colors.green.shade900 : Colors.orange.shade900,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isHighConfidence ? _t('Yüksek', 'High', guncelDil) : _t('Orta', 'Medium', guncelDil),
              style: TextStyle(
                color: isHighConfidence ? Colors.green.shade800 : Colors.orange.shade800,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScientificNameCard(PlantSuggestion suggestion, bool isDark, Locale guncelDil) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.science, color: Colors.purple.shade400, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                _t('BİLİMSEL AD', 'SCIENTIFIC NAME', guncelDil),
                style: TextStyle(
                  color: Colors.purple.shade400,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            suggestion.scientificName,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              fontStyle: FontStyle.italic,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getScientificNameMeaning(suggestion.scientificName, guncelDil),
            style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildCommonNamesCard(List<String> commonNames, bool isDark, Locale guncelDil) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.language, color: Colors.blue.shade400, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                _t('TÜRKÇE KARŞILIĞI', 'COMMON NAMES', guncelDil),
                style: TextStyle(
                  color: Colors.blue.shade400,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: commonNames.take(4).map((name) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade50, Colors.blue.shade100],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue.shade200, width: 0.5),
                ),
                child: Text(
                  name,
                  style: TextStyle(
                    color: Colors.blue.shade800,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTaxonomyCard(Taxonomy? taxonomy, bool isDark, Locale guncelDil) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.account_tree, color: Colors.orange.shade400, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                _t('SINIFLANDIRMA', 'TAXONOMY', guncelDil),
                style: TextStyle(
                  color: Colors.orange.shade400,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildTaxonomyRow(_t('Aile', 'Family', guncelDil), taxonomy?.family, Icons.family_restroom, isDark, guncelDil),
          const SizedBox(height: 16),
          _buildTaxonomyRow(_t('Cins', 'Genus', guncelDil), taxonomy?.genus, Icons.category, isDark, guncelDil),
        ],
      ),
    );
  }

  Widget _buildTaxonomyRow(String label, String? value, IconData icon, bool isDark, Locale guncelDil) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 18, color: isDark ? Colors.grey.shade400 : Colors.grey.shade700),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: isDark ? Colors.grey.shade500 : Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
                value ?? _t('Bilinmiyor', 'Unknown', guncelDil),
                style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionCard(String description, bool isDark, Locale guncelDil) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.menu_book_rounded, color: Colors.teal.shade400, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                _t('HAKKINDA', 'ABOUT', guncelDil),
                style: TextStyle(
                  color: Colors.teal.shade400,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: TextStyle(
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
              fontSize: 15,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 20, color: Colors.teal.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _t('Kaynak: Wikipedia', 'Source: Wikipedia', guncelDil),
                    style: TextStyle(color: Colors.teal.shade600, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getScientificNameMeaning(String scientificName, Locale guncelDil) {
    final parts = scientificName.split(' ');
    if (parts.length >= 2) {
      return guncelDil.languageCode == 'tr'
          ? '${parts[0]} cinsine ait ${parts[1]} türü'
          : 'Species of ${parts[1]} belonging to the genus ${parts[0]}';
    }
    return _t('Bitki türü', 'Plant species', guncelDil);
  }

  void _sharePlantInfo(PlantSuggestion suggestion, Locale guncelDil) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_t('Paylaşma özelliği yakında gelecek', 'Sharing feature coming soon', guncelDil))),
    );
  }
}