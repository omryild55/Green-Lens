class PlantResult {
  final String scientificName;
  final String? scientificNameAuthorship;
  final String genus;
  final String family;
  final List<String> commonNames;
  final double score;
  final String? gbifId;
  final String? powoId;

  PlantResult({
    required this.scientificName,
    this.scientificNameAuthorship,
    required this.genus,
    required this.family,
    required this.commonNames,
    required this.score,
    this.gbifId,
    this.powoId,
  });

  factory PlantResult.fromJson(Map<String, dynamic> json) {
    final species = json['species'];
    return PlantResult(
      scientificName: species['scientificNameWithoutAuthor'] ?? '',
      scientificNameAuthorship: species['scientificNameAuthorship'],
      genus: species['genus']?['scientificNameWithoutAuthor'] ?? '',
      family: species['family']?['scientificNameWithoutAuthor'] ?? '',
      commonNames: List<String>.from(species['commonNames'] ?? []),
      score: (json['score'] ?? 0.0).toDouble(),
      gbifId: json['gbif']?['id']?.toString(),
      powoId: json['powo']?['id']?.toString(),
    );
  }

  String get displayName => commonNames.isNotEmpty 
      ? commonNames.first 
      : scientificName;
}

class PlantIdentificationResponse {
  final String bestMatch;
  final List<PlantResult> results;
  final List<PredictedOrgan> predictedOrgans;
  final int remainingRequests;
  final String version;

  PlantIdentificationResponse({
    required this.bestMatch,
    required this.results,
    required this.predictedOrgans,
    required this.remainingRequests,
    required this.version,
  });

  factory PlantIdentificationResponse.fromJson(Map<String, dynamic> json) {
    return PlantIdentificationResponse(
      bestMatch: json['bestMatch'] ?? '',
      results: (json['results'] as List? ?? [])
          .map((e) => PlantResult.fromJson(e))
          .toList(),
      predictedOrgans: (json['predictedOrgans'] as List? ?? [])
          .map((e) => PredictedOrgan.fromJson(e))
          .toList(),
      remainingRequests: json['remainingIdentificationRequests'] ?? 0,
      version: json['version'] ?? '',
    );
  }
}

class PredictedOrgan {
  final String organ;
  final double score;
  final String filename;

  PredictedOrgan({
    required this.organ,
    required this.score,
    required this.filename,
  });

  factory PredictedOrgan.fromJson(Map<String, dynamic> json) {
    return PredictedOrgan(
      organ: json['organ'] ?? '',
      score: (json['score'] ?? 0.0).toDouble(),
      filename: json['filename'] ?? '',
    );
  }
}