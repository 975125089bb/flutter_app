import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../data/character.dart';
import '../models/filter_options.dart';

class CharacterService {
  static List<Character>? _cachedCharacters;

  /// Get the local file for storing characters
  static Future<File> _getLocalFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/characters.json');
  }

  /// Save characters to local storage
  static Future<void> saveCharacters(List<Character> characters) async {
    try {
      final file = await _getLocalFile();
      final jsonString = json.encode(
        characters.map((c) => c.toJson()).toList(),
      );
      await file.writeAsString(jsonString);

      // Update the cache to match the saved data
      _cachedCharacters = List<Character>.from(characters);
    } catch (e) {
      print('Error saving characters: $e');
    }
  }

  /// Load characters from the JSON asset file or local storage
  static Future<List<Character>> loadCharacters() async {
    if (_cachedCharacters != null) {
      return _cachedCharacters!;
    }

    try {
      // First, try to load from local storage
      final file = await _getLocalFile();
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        final List<dynamic> jsonList = json.decode(jsonString);
        _cachedCharacters = jsonList
            .map((json) => Character.fromJson(json))
            .toList();
        return _cachedCharacters!;
      }

      // If no local file, load from assets
      final String jsonString = await rootBundle.loadString(
        'assets/test_characters.json',
      );
      final List<dynamic> jsonList = json.decode(jsonString);

      // Convert JSON to Character objects
      _cachedCharacters = jsonList
          .map((json) => Character.fromJson(json))
          .toList();

      return _cachedCharacters!;
    } catch (e) {
      print('Error loading characters: $e');
      // Return empty list if there's an error
      return [];
    }
  }

  /// Clear the cache to force reload on next call
  static void clearCache() {
    _cachedCharacters = null;
  }

  /// Force reload characters from JSON (bypasses cache)
  static Future<List<Character>> reloadCharacters() async {
    clearCache();
    return await loadCharacters();
  }

  /// Get a character by ID
  static Future<Character?> getCharacterById(String id) async {
    final characters = await loadCharacters();
    try {
      return characters.firstWhere((character) => character.id == id);
    } catch (e) {
      return null;
    }
  }

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

      // Height filter
      if (character.height != null) {
        if (character.height! < options.heightRange.min ||
            character.height! > options.heightRange.max) {
          return false;
        }
      } else if (options.heightRange != HeightRange.all) {
        // If height filter is applied but character has no height data, exclude
        return false;
      }

      // BMI filter
      if (character.bmi != null) {
        if (character.bmi! < options.bmiRange.min ||
            character.bmi! > options.bmiRange.max) {
          return false;
        }
      } else if (options.bmiRange != BMIRange.all) {
        // If BMI filter is applied but character has no BMI data, exclude
        return false;
      }

      // Distance filter
      if (character.distanceKm > options.distanceRange.max) {
        return false;
      }

      // House requirement filter
      if (options.requireHouse && (character.hasHouse != true)) {
        return false;
      }

      // Car requirement filter
      if (options.requireCar && (character.hasCar != true)) {
        return false;
      }

      // Marital status filter
      if (options.maritalStatus != MaritalStatusFilter.any) {
        final statusMatch = character.maritalStatus?.toLowerCase();
        switch (options.maritalStatus) {
          case MaritalStatusFilter.single:
            if (statusMatch != '单身' && statusMatch != 'single') return false;
            break;
          case MaritalStatusFilter.divorced:
            if (statusMatch != '离婚' && statusMatch != 'divorced') return false;
            break;
          case MaritalStatusFilter.widowed:
            if (statusMatch != '丧偶' && statusMatch != 'widowed') return false;
            break;
          case MaritalStatusFilter.any:
            break;
        }
      }

      // Education filter (basic implementation - could be enhanced with more data)
      if (options.education != EducationFilter.any) {
        final occupation = character.occupation.toLowerCase();
        final rawText = character.rawText.toLowerCase();
        switch (options.education) {
          case EducationFilter.college:
            if (!rawText.contains('大学') &&
                !rawText.contains('学院') &&
                !rawText.contains('college') &&
                !rawText.contains('university')) {
              return false;
            }
            break;
          case EducationFilter.graduate:
            if (!rawText.contains('硕士') &&
                !rawText.contains('博士') &&
                !rawText.contains('研究生') &&
                !rawText.contains('master') &&
                !rawText.contains('phd') &&
                !rawText.contains('graduate')) {
              return false;
            }
            break;
          case EducationFilter.professional:
            if (!occupation.contains('医生') &&
                !occupation.contains('律师') &&
                !occupation.contains('工程师') &&
                !occupation.contains('doctor') &&
                !occupation.contains('lawyer') &&
                !occupation.contains('engineer')) {
              return false;
            }
            break;
          case EducationFilter.any:
            break;
        }
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
        case SortBy.name:
          return a.name.compareTo(b.name);
        case SortBy.height:
          // Sort by height (nulls last)
          if (a.height == null && b.height == null) return 0;
          if (a.height == null) return 1;
          if (b.height == null) return -1;
          return b.height!.compareTo(
            a.height!,
          ); // Descending order (tall first)
      }
    });

    return filteredList;
  }

  static List<String> getAllInterests(List<Character> characters) {
    final allInterests = <String>{};
    for (final character in characters) {
      allInterests.addAll(character.interests);
    }
    return normalizeInterests(allInterests.toList())..sort();
  }

  static List<String> normalizeInterests(List<String> interests) {
    // Sort interests by length (shortest first)
    final sortedInterests = List<String>.from(interests)
      ..sort((a, b) => a.length.compareTo(b.length));

    final normalizedInterests = <String>{};

    for (final interest in sortedInterests) {
      // Check if this interest is a combination of already processed interests
      bool isComposite = normalizedInterests.any(
        (existing) => interest != existing && interest.contains(existing),
      );

      if (!isComposite) {
        normalizedInterests.add(interest);
      }
    }

    return normalizedInterests.toList()..sort();
  }

  static List<Character> getBookmarkedCharacters(List<Character> characters) {
    return characters.where((character) => character.isBookmarked).toList();
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
