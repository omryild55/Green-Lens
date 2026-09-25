class PlantIdentificationResult {
  final String id;
  final List<PlantSuggestion> suggestions;
  final List<String>? images;
  final DateTime? createdAt;
  final bool isPlant;

  PlantIdentificationResult({
    required this.id,
    required this.suggestions,
    this.images,
    this.createdAt,
    required this.isPlant,
  });

  factory PlantIdentificationResult.fromJson(Map<String, dynamic> json) {
    return PlantIdentificationResult(
      id: json['id']?.toString() ?? '',
      isPlant: json['is_plant'] ?? false,
      suggestions: (json['suggestions'] as List?)
          ?.map((s) => PlantSuggestion.fromJson(s))
          .toList() ?? [],
      images: (json['images'] as List?)?.map((i) => i['url'] as String).toList(),
      createdAt: json['created_datetime'] != null 
          ? DateTime.tryParse(json['created_datetime']) 
          : null,
    );
  }
}

class PlantSuggestion {
  final String scientificName;
  final double probability;
  final List<String> commonNames;
  final String? wikiDescription;
  final String? wikiUrl;
  final String? imageUrl;
  final Taxonomy? taxonomy;
  final bool? confirmed;

  PlantSuggestion({
    required this.scientificName,
    required this.probability,
    this.commonNames = const [],
    this.wikiDescription,
    this.wikiUrl,
    this.imageUrl,
    this.taxonomy,
    this.confirmed,
  });

  factory PlantSuggestion.fromJson(Map<String, dynamic> json) {
    final plantDetails = json['plant_details'] ?? {};
    final similarImages = json['similar_images'] as List?;
    final structuredName = plantDetails['structured_name'] ?? {};
    
    List<String> names = [];
    if (plantDetails['common_names'] != null && plantDetails['common_names'] is List) {
      names = (plantDetails['common_names'] as List).map((n) => n.toString()).toList();
    }
    
    // NOT: Burada eskiden olan "genus türü" uydurma kısmını sildik.
    // Artık sadece gerçek isimleri alacak.

    return PlantSuggestion(
      scientificName: json['plant_name'] ?? 'Bilinmiyor',
      probability: (json['probability'] ?? 0).toDouble(),
      commonNames: names,
      wikiDescription: plantDetails['wiki_description']?['value'],
      wikiUrl: plantDetails['url'],
      imageUrl: similarImages?.isNotEmpty == true ? similarImages!.first['url'] : null,
      taxonomy: structuredName.isNotEmpty 
          ? Taxonomy.fromJson(plantDetails['taxonomy'] ?? structuredName) 
          : null,
      confirmed: json['confirmed'],
    );
  }
}

class Taxonomy {
  final String? className;
  final String? family;
  final String? genus;
  final String? order;
  final String? phylum;
  final String? kingdom;

  Taxonomy({
    this.className,
    this.family,
    this.genus,
    this.order,
    this.phylum,
    this.kingdom,
  });

  // Metot ismini fromJson olarak sabitledik
  factory Taxonomy.fromJson(Map<String, dynamic> json) {
    return Taxonomy(
      className: json['class'],
      family: json['family'],
      genus: json['genus'] != null 
          ? json['genus'][0].toUpperCase() + json['genus'].substring(1) 
          : null,
      order: json['order'],
      phylum: json['phylum'],
      kingdom: json['kingdom'],
    );
  }

  bool get isEmpty => 
    className == null && 
    family == null && 
    genus == null && 
    order == null && 
    phylum == null && 
    kingdom == null;

  bool get hasAnyData => !isEmpty;
}