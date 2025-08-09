import '../data/character.dart';
import '../models/filter_options.dart';

class CharacterService {
  static List<Character> filterAndSort(
    List<Character> characters,
    FilterOptions options,
  ) {
    var filteredList = characters.where((character) {
      // Age filter
      if (character.age < options.ageRange.min ||
          character.age > options.ageRange.max) {
        return false;
      }

      // Distance filter
      if (character.distanceKm > options.distanceRange.max) {
        return false;
      }

      // Online filter
      if (options.showOnlineOnly) {
        final now = DateTime.now();
        final difference = now.difference(character.lastActive);
        if (difference.inMinutes > 15) return false;
      }

      // Hide rejected
      if (options.hideRejected && character.isRejected) {
        return false;
      }

      // Interest filter
      if (options.selectedInterests.isNotEmpty) {
        final hasCommonInterest = character.interests.any(
          (interest) => options.selectedInterests.contains(interest),
        );
        if (!hasCommonInterest) return false;
      }

      return true;
    }).toList();

    // Sort the filtered list
    filteredList.sort((a, b) {
      switch (options.sortBy) {
        case SortBy.distance:
          return a.distanceKm.compareTo(b.distanceKm);
        case SortBy.age:
          return a.age.compareTo(b.age);
        case SortBy.recentActivity:
          return b.lastActive.compareTo(a.lastActive); // Most recent first
        case SortBy.name:
          return a.name.compareTo(b.name);
      }
    });

    return filteredList;
  }

  static List<String> getAllInterests(List<Character> characters) {
    final allInterests = <String>{};
    for (final character in characters) {
      allInterests.addAll(character.interests);
    }
    return allInterests.toList()..sort();
  }

  static List<Character> getBookmarkedCharacters(List<Character> characters) {
    return characters.where((character) => character.isBookmarked).toList();
  }

  static List<Character> getMatchedCharacters(List<Character> characters) {
    return characters.where((character) => character.isMatched).toList();
  }

  static int getCompatibilityScore(
    Character character,
    List<String> userInterests,
  ) {
    if (userInterests.isEmpty) return 50; // Default score

    final commonInterests = character.interests
        .where((interest) => userInterests.contains(interest))
        .length;

    final maxInterests = character.interests.length > userInterests.length
        ? character.interests.length
        : userInterests.length;

    return ((commonInterests / maxInterests) * 100).round();
  }
}
