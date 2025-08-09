class Character {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final int age;
  final String location;
  final List<String> interests;
  final double distanceKm;
  final DateTime lastActive;
  final String profession;
  bool isBookmarked;
  bool isLiked;
  bool isRejected;
  String note;

  Character({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.age,
    required this.location,
    required this.interests,
    required this.distanceKm,
    required this.lastActive,
    required this.profession,
    this.isBookmarked = false,
    this.isLiked = false,
    this.isRejected = false,
    this.note = '',
  });

  // Helper method to get activity status
  String get activityStatus {
    final now = DateTime.now();
    final difference = now.difference(lastActive);

    if (difference.inMinutes < 15) return 'Online';
    if (difference.inHours < 24) return 'Active ${difference.inHours}h ago';
    if (difference.inDays < 7) return 'Active ${difference.inDays}d ago';
    return 'Active 1w+ ago';
  }

  // Create a copy with updated properties
  Character copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    int? age,
    String? location,
    List<String>? interests,
    double? distanceKm,
    DateTime? lastActive,
    String? profession,
    bool? isBookmarked,
    bool? isLiked,
    bool? isRejected,
    String? note,
  }) {
    return Character(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      age: age ?? this.age,
      location: location ?? this.location,
      interests: interests ?? this.interests,
      distanceKm: distanceKm ?? this.distanceKm,
      lastActive: lastActive ?? this.lastActive,
      profession: profession ?? this.profession,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      isLiked: isLiked ?? this.isLiked,
      isRejected: isRejected ?? this.isRejected,
      note: note ?? this.note,
    );
  }
}
