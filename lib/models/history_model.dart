class HistoryModel {
  final int? id;
  final String imagePath;
  final String scientificName;
  final String commonNames;
  final double confidence;
  final String date;
  final int isFavorite;

  HistoryModel({
    this.id,
    required this.imagePath,
    required this.scientificName,
    required this.commonNames,
    required this.confidence,
    required this.date,
    this.isFavorite = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imagePath': imagePath,
      'scientificName': scientificName,
      'commonNames': commonNames,
      'confidence': confidence,
      'date': date,
      'isFavorite': isFavorite,
    };
  }

  factory HistoryModel.fromMap(Map<String, dynamic> map) {
    return HistoryModel(
      id: map['id'] as int?,
      imagePath: map['imagePath'] as String,
      scientificName: map['scientificName'] as String,
      commonNames: map['commonNames'] as String,
      confidence: map['confidence'] as double,
      date: map['date'] as String,
      isFavorite: map['isFavorite'] as int? ?? 0,
    );
  }

  bool get isFavorited => isFavorite == 1;
}