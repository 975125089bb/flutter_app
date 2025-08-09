enum SortBy {
  distance,
  age,
  recentActivity,
  name,
}

enum AgeRange {
  all(18, 100, 'All ages'),
  young(18, 25, '18-25'),
  mid(26, 35, '26-35'),
  mature(36, 50, '36-50'),
  senior(51, 100, '51+');

  const AgeRange(this.min, this.max, this.label);
  final int min;
  final int max;
  final String label;
}

enum DistanceRange {
  nearby(0, 10, 'Within 10km'),
  close(0, 25, 'Within 25km'),
  medium(0, 50, 'Within 50km'),
  far(0, 100, 'Within 100km'),
  anywhere(0, double.infinity, 'Anywhere');

  const DistanceRange(this.min, this.max, this.label);
  final double min;
  final double max;
  final String label;
}

class FilterOptions {
  final AgeRange ageRange;
  final DistanceRange distanceRange;
  final List<String> selectedInterests;
  final SortBy sortBy;
  final bool showOnlineOnly;
  final bool hideRejected;

  const FilterOptions({
    this.ageRange = AgeRange.all,
    this.distanceRange = DistanceRange.anywhere,
    this.selectedInterests = const [],
    this.sortBy = SortBy.distance,
    this.showOnlineOnly = false,
    this.hideRejected = true,
  });

  FilterOptions copyWith({
    AgeRange? ageRange,
    DistanceRange? distanceRange,
    List<String>? selectedInterests,
    SortBy? sortBy,
    bool? showOnlineOnly,
    bool? hideRejected,
  }) {
    return FilterOptions(
      ageRange: ageRange ?? this.ageRange,
      distanceRange: distanceRange ?? this.distanceRange,
      selectedInterests: selectedInterests ?? this.selectedInterests,
      sortBy: sortBy ?? this.sortBy,
      showOnlineOnly: showOnlineOnly ?? this.showOnlineOnly,
      hideRejected: hideRejected ?? this.hideRejected,
    );
  }
}
