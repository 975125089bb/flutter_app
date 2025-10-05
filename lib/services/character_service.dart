import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
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
      // Skip local file operations on web platforms
      if (kIsWeb) {
        print('🌐 CharacterService: Web platform - saving to cache only (no local file)');
        _cachedCharacters = List<Character>.from(characters);
        
        final bookmarkedCount = characters.where((c) => c.isBookmarked).length;
        print('💾 CharacterService: Cache updated with $bookmarkedCount bookmarked characters');
        return;
      }

      print('💾 CharacterService: Saving ${characters.length} characters to local storage...');
      final file = await _getLocalFile();
      final jsonString = json.encode(
        characters.map((c) => c.toJson()).toList(),
      );
      await file.writeAsString(jsonString);
      print('💾 CharacterService: Characters saved successfully to ${file.path}');

      // Update the cache to match the saved data
      _cachedCharacters = List<Character>.from(characters);
      
      // Count bookmarks for verification
      final bookmarkedCount = characters.where((c) => c.isBookmarked).length;
      print('💾 CharacterService: Cache updated with $bookmarkedCount bookmarked characters');
    } catch (e) {
      print('❌ CharacterService: Error saving characters: $e');
    }
  }

  /// Load characters from the JSON asset file or local storage
  static Future<List<Character>> loadCharacters() async {
    print('🔄 CharacterService: Starting loadCharacters...');

    if (_cachedCharacters != null) {
      print(
        '✅ CharacterService: Returning cached characters (${_cachedCharacters!.length} items)',
      );
      return _cachedCharacters!;
    }

    try {
      // Skip local file operations on web platforms
      if (!kIsWeb) {
        // First, try to load from local storage (only on non-web platforms)
        final file = await _getLocalFile();
        print('📁 CharacterService: Checking local file: ${file.path}');

        if (await file.exists()) {
          print('✅ CharacterService: Local file exists, loading...');
          final jsonString = await file.readAsString();
          print('📄 CharacterService: Local file size: ${jsonString.length} characters');
          
          final List<dynamic> jsonList = json.decode(jsonString);
          _cachedCharacters = jsonList
              .map((json) => Character.fromJson(json))
              .toList();
              
          final bookmarkedCount = _cachedCharacters!.where((c) => c.isBookmarked).length;
          print(
            '✅ CharacterService: Loaded ${_cachedCharacters!.length} characters from local file with $bookmarkedCount bookmarks',
          );
          return _cachedCharacters!;
        }
      } else {
        print('🌐 CharacterService: Web platform detected, skipping local file operations');
      }

      print('📱 CharacterService: Loading from assets...');
      print(
        '🔍 CharacterService: Attempting to load: assets/data/flutter_characters.json',
      );

      // Load from assets (works on all platforms)
      final String jsonString = await rootBundle.loadString(
        'assets/data/flutter_characters.json',
      );

      print(
        '✅ CharacterService: Asset loaded successfully, JSON length: ${jsonString.length}',
      );

      final List<dynamic> jsonList = json.decode(jsonString);
      print(
        '✅ CharacterService: JSON parsed successfully, ${jsonList.length} items found',
      );

      // Convert JSON to Character objects
      _cachedCharacters = jsonList
          .map((json) => Character.fromJson(json))
          .toList();

      print(
        '✅ CharacterService: Successfully loaded ${_cachedCharacters!.length} characters from assets',
      );
      return _cachedCharacters!;
    } catch (e) {
      print('❌ CharacterService: Error loading characters: $e');
      print('❌ CharacterService: Error type: ${e.runtimeType}');
      if (e is FlutterError) {
        print('❌ CharacterService: FlutterError details: ${e.toString()}');
      }
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

      // Sex filter
      if (options.sexFilter != SexFilter.any) {
        final characterGender = character.gender?.toLowerCase();
        switch (options.sexFilter) {
          case SexFilter.male:
            if (characterGender != '男' &&
                characterGender != 'male' &&
                characterGender != 'm')
              return false;
            break;
          case SexFilter.female:
            if (characterGender != '女' &&
                characterGender != 'female' &&
                characterGender != 'f')
              return false;
            break;
          case SexFilter.any:
            break;
        }
      }

      return true;
    }).toList();

    // Sort the filtered list
    filteredList.sort((a, b) {
      switch (options.sortBy) {
        case SortBy.number:
          // Extract number from ID (profile_X format)
          int getNumber(String id) {
            return int.tryParse(id.split("_").last) ?? 0;
          }
          return getNumber(a.id).compareTo(getNumber(b.id));
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
        case SortBy.random:
          return 0; // Will be shuffled after sorting
      }
    });

    // Shuffle if random sort is selected
    if (options.sortBy == SortBy.random) {
      filteredList.shuffle(Random());
    }

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
    final bookmarked = characters.where((character) => character.isBookmarked).toList();
    print('📑 CharacterService: Found ${bookmarked.length} bookmarked characters out of ${characters.length} total');
    if (bookmarked.isNotEmpty) {
      print('📑 CharacterService: Bookmarked character IDs: ${bookmarked.map((c) => c.id).join(', ')}');
    }
    return bookmarked;
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
