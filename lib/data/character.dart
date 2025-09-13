class Character {
  final String id;
  final String? gender;
  final int age;
  final int? height;
  final String? zodiac;
  final String? mbti;
  final String rawText;
  final String? image;
  final double? bmi;
  final String? hometown;
  final String currentLocation;
  final String occupation;
  final List<String> interests;
  final bool? hasHouse;
  final bool? hasCar;
  final String? maritalStatus;

  // UI state properties
  bool isBookmarked;
  bool isLiked;
  bool isRejected;
  String note;

  Character({
    required this.id,
    this.gender,
    required this.age,
    this.height,
    this.zodiac,
    this.mbti,
    required this.rawText,
    this.image,
    this.bmi,
    this.hometown,
    required this.currentLocation,
    required this.occupation,
    required this.interests,
    this.hasHouse,
    this.hasCar,
    this.maritalStatus,
    this.isBookmarked = false,
    this.isLiked = false,
    this.isRejected = false,
    this.note = '',
  });

  // Factory constructor to create Character from JSON
  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'] ?? '',
      gender: json['gender'],
      age: json['age'] ?? 0,
      height: json['height'],
      zodiac: json['zodiac'],
      mbti: json['mbti'],
      rawText: json['raw_text'] ?? '',
      image: json['image'],
      bmi: json['bmi']?.toDouble(),
      hometown: json['hometown'],
      currentLocation: json['current_location'] ?? '',
      occupation: json['occupation'] ?? '',
      interests: List<String>.from(json['interests'] ?? []),
      hasHouse: json['has_house'],
      hasCar: json['has_car'],
      maritalStatus: json['marital_status'],
      isBookmarked: json['is_bookmarked'] ?? false,
      isLiked: json['is_liked'] ?? false,
      isRejected: json['is_rejected'] ?? false,
      note: json['note'] ?? '',
    );
  }

  // Convert Character to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gender': gender,
      'age': age,
      'height': height,
      'zodiac': zodiac,
      'mbti': mbti,
      'raw_text': rawText,
      'image': image,
      'bmi': bmi,
      'hometown': hometown,
      'current_location': currentLocation,
      'occupation': occupation,
      'interests': interests,
      'has_house': hasHouse,
      'has_car': hasCar,
      'marital_status': maritalStatus,
      'is_bookmarked': isBookmarked,
      'is_liked': isLiked,
      'is_rejected': isRejected,
      'note': note,
    };
  }

  // Helper getters for UI compatibility
  String get name => 'Profile ${id.replaceAll('profile_', '')}';
  String get description => _extractDescription();
  String? get imageUrl => image;
  String get location => currentLocation;
  List<String> get skillsOrInterests => interests;
  String get profession => occupation;
  double get distanceKm => 5.0; // Default distance

  String _extractDescription() {
    // Extract the self-introduction part from raw text
    final lines = rawText.split('\n');
    bool inDescription = false;
    List<String> descriptionLines = [];

    for (String line in lines) {
      if (line.trim() == '自我介绍' || line.trim().startsWith('自我介绍')) {
        inDescription = true;
        continue;
      }
      if (line.trim() == '择偶要求' || line.trim().startsWith('择偶要求')) {
        break;
      }
      if (inDescription && line.trim().isNotEmpty) {
        descriptionLines.add(line.trim());
      }
    }

    return descriptionLines
        .join(' ')
        .substring(
          0,
          descriptionLines.join(' ').length > 200
              ? 200
              : descriptionLines.join(' ').length,
        );
  }

  // Create a copy with updated properties
  Character copyWith({
    String? id,
    String? gender,
    int? age,
    int? height,
    String? zodiac,
    String? mbti,
    String? rawText,
    String? image,
    double? bmi,
    String? hometown,
    String? currentLocation,
    String? occupation,
    List<String>? interests,
    bool? hasHouse,
    bool? hasCar,
    String? maritalStatus,
    bool? isBookmarked,
    bool? isLiked,
    bool? isRejected,
    String? note,
  }) {
    return Character(
      id: id ?? this.id,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      height: height ?? this.height,
      zodiac: zodiac ?? this.zodiac,
      mbti: mbti ?? this.mbti,
      rawText: rawText ?? this.rawText,
      image: image ?? this.image,
      bmi: bmi ?? this.bmi,
      hometown: hometown ?? this.hometown,
      currentLocation: currentLocation ?? this.currentLocation,
      occupation: occupation ?? this.occupation,
      interests: interests ?? this.interests,
      hasHouse: hasHouse ?? this.hasHouse,
      hasCar: hasCar ?? this.hasCar,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      isLiked: isLiked ?? this.isLiked,
      isRejected: isRejected ?? this.isRejected,
      note: note ?? this.note,
    );
  }
}
