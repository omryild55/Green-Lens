import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TrefleService {
  static const String _baseUrl = 'https://trefle.io/api/v1';
  static const String _token = 'usr-FWIO39A9lam2XrhlG0TdliakbmCdsel4x87Dulr8_i0';

  // Bitki arama metodu - Aktif dil parametresi eklendi reis!
  static Future<List<TreflePlant>> searchPlants(String query, [Locale aktifDil = const Locale('tr')]) async {
    if (query.isEmpty) return [];
    
    try {
      final String dilKodu = aktifDil.languageCode;
      final response = await http.get(
        Uri.parse('$_baseUrl/plants/search?q=$query&token=$_token&locale=$dilKodu'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> items = data['data'];
        return items.map((item) => TreflePlant.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('Arama hatası: $e');
      return [];
    }
  }

  // Popüler/rastgele bitkileri getir metodu
  static Future<List<TreflePlant>> getPopularPlants({int limit = 20, Locale aktifDil = const Locale('tr')}) async {
    try {
      final String dilKodu = aktifDil.languageCode;
      final response = await http.get(
        Uri.parse('$_baseUrl/plants?token=$_token&limit=$limit&locale=$dilKodu'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> items = data['data'];
        return items.map((item) => TreflePlant.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('Popüler bitkiler hatası: $e');
      return [];
    }
  }

  // ID'ye göre bitki detayı getir metodu
  static Future<TreflePlant?> getPlantById(int id, [Locale aktifDil = const Locale('tr')]) async {
    try {
      final String dilKodu = aktifDil.languageCode;
      final response = await http.get(
        Uri.parse('$_baseUrl/plants/$id?token=$_token&locale=$dilKodu'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return TreflePlant.fromJson(data['data']);
      }
      return null;
    } catch (e) {
      print('Detay hatası: $e');
      return null;
    }
  }
}

class TreflePlant {
  final int id;
  final String scientificName;
  final String? commonName;
  final String? slug;
  final String? imageUrl;
  final Map<String, dynamic>? mainSpecies;
  final Map<String, dynamic>? family;
  final Map<String, dynamic>? genus;

  TreflePlant({
    required this.id,
    required this.scientificName,
    this.commonName,
    this.slug,
    this.imageUrl,
    this.mainSpecies,
    this.family,
    this.genus,
  });

  factory TreflePlant.fromJson(Map<String, dynamic> json) {
    return TreflePlant(
      id: json['id'] ?? 0,
      scientificName: json['scientific_name'] ?? 'Bilinmiyor',
      commonName: json['common_name'],
      slug: json['slug'],
      imageUrl: json['image_url'],
      mainSpecies: json['main_species'],
      family: json['main_species']?['family'],
      genus: json['main_species']?['genus'],
    );
  }

  String get displayName => commonName ?? scientificName.split(' ').last;
  String get familyName => family?['name'] ?? 'Bilinmiyor';
  String get genusName => genus?['name'] ?? 'Bilinmiyor';
}