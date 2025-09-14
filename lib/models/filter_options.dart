enum SortBy { number, age, name, height, random }

enum SexFilter {
  any('Any'),
  male('Male'),
  female('Female');

  const SexFilter(this.label);
  final String label;
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

enum HeightRange {
  all(140, 220, 'Any height'),
  short(140, 165, 'Under 165cm'),
  average(165, 175, '165-175cm'),
  tall(175, 185, '175-185cm'),
  veryTall(185, 220, 'Over 185cm');

  const HeightRange(this.min, this.max, this.label);
  final int min;
  final int max;
  final String label;
}

enum BMIRange {
  all(15.0, 40.0, 'Any BMI'),
  underweight(15.0, 18.5, 'Underweight (<18.5)'),
  normal(18.5, 25.0, 'Normal (18.5-25)'),
  overweight(25.0, 30.0, 'Overweight (25-30)'),
  obese(30.0, 40.0, 'Obese (>30)');

  const BMIRange(this.min, this.max, this.label);
  final double min;
  final double max;
  final String label;
}

enum EducationFilter {
  any('Any'),
  college('College/University'),
  graduate('Graduate degree'),
  professional('Professional');

  const EducationFilter(this.label);
  final String label;
}

enum MaritalStatusFilter {
  any('Any'),
  single('Single'),
  divorced('Divorced'),
  widowed('Widowed');

  const MaritalStatusFilter(this.label);
  final String label;
}

class FilterOptions {
  final AgeRange ageRange;
  final HeightRange heightRange;
  final BMIRange bmiRange;
  final List<String> selectedInterests;
  final SortBy sortBy;
  final SexFilter sexFilter;
  final bool showOnlineOnly;
  final bool hideRejected;
  final bool requireHouse;
  final bool requireCar;
  final MaritalStatusFilter maritalStatus;
  final EducationFilter education;

  const FilterOptions({
    this.ageRange = AgeRange.all,
    this.heightRange = HeightRange.all,
    this.bmiRange = BMIRange.all,
    this.selectedInterests = const [],
    this.sortBy = SortBy.random,
    this.sexFilter = SexFilter.any,
    this.showOnlineOnly = false,
    this.hideRejected = true,
    this.requireHouse = false,
    this.requireCar = false,
    this.maritalStatus = MaritalStatusFilter.any,
    this.education = EducationFilter.any,
  });

  FilterOptions copyWith({
    AgeRange? ageRange,
    HeightRange? heightRange,
    BMIRange? bmiRange,
    List<String>? selectedInterests,
    SortBy? sortBy,
    SexFilter? sexFilter,
    bool? showOnlineOnly,
    bool? hideRejected,
    bool? requireHouse,
    bool? requireCar,
    MaritalStatusFilter? maritalStatus,
    EducationFilter? education,
  }) {
    return FilterOptions(
      ageRange: ageRange ?? this.ageRange,
      heightRange: heightRange ?? this.heightRange,
      bmiRange: bmiRange ?? this.bmiRange,
      selectedInterests: selectedInterests ?? this.selectedInterests,
      sortBy: sortBy ?? this.sortBy,
      sexFilter: sexFilter ?? this.sexFilter,
      showOnlineOnly: showOnlineOnly ?? this.showOnlineOnly,
      hideRejected: hideRejected ?? this.hideRejected,
      requireHouse: requireHouse ?? this.requireHouse,
      requireCar: requireCar ?? this.requireCar,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      education: education ?? this.education,
    );
  }
}
