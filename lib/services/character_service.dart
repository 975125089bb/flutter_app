import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
      // Web platform: Save to cache and browser's local storage
      if (kIsWeb) {
        print(
          '🌐 CharacterService: Web platform - saving to cache and local storage',
        );
        _cachedCharacters = List<Character>.from(characters);

        // Save bookmark state to browser's local storage
        final prefs = await SharedPreferences.getInstance();

        // Save bookmarked character IDs
        final bookmarkedIds = characters
            .where((c) => c.isBookmarked)
            .map((c) => c.id)
            .toList();
        await prefs.setStringList('bookmarked_characters', bookmarkedIds);

        // Save notes as JSON
        final notesMap = <String, String>{};
        for (var character in characters) {
          if (character.note.isNotEmpty) {
            notesMap[character.id] = character.note;
          }
        }
        await prefs.setString('character_notes', json.encode(notesMap));

        final bookmarkedCount = bookmarkedIds.length;
        print(
          '💾 CharacterService: Local storage updated - $bookmarkedCount bookmarks, ${notesMap.length} notes',
        );
        return;
      } else {
        // save on Android/iOS/Windows/macOS using local storage
        print(
          '💾 CharacterService: Saving ${characters.length} characters to local storage...',
        );
        final file = await _getLocalFile();
        final jsonString = json.encode(
          characters.map((c) => c.toJson()).toList(),
        );
        await file.writeAsString(jsonString);
        print(
          '💾 CharacterService: Characters saved successfully to ${file.path}',
        );

        // Update the cache to match the saved data
        _cachedCharacters = List<Character>.from(characters);

        // Count bookmarks for verification
        final bookmarkedCount = characters.where((c) => c.isBookmarked).length;
        print(
          '💾 CharacterService: Cache updated with $bookmarkedCount bookmarked characters',
        );
      }
    } catch (e) {
      print('❌ CharacterService: Error saving characters: $e');
    }
  }

  /// Load characters from the JSON asset file or local storage
  static Future<List<Character>> loadCharacters() async {
    print('🔄 CharacterService: Starting loadCharacters...');

    // Return cached data if available
    if (_cachedCharacters != null) {
      print(
        '✅ CharacterService: Returning cached characters (${_cachedCharacters!.length} items)',
      );
      return _cachedCharacters!;
    }

    try {
      // Try loading from local file (desktop/mobile only)
      if (!kIsWeb) {
        final localData = await _loadFromLocalFile();
        if (localData != null) {
          _cachedCharacters = localData;
          return _cachedCharacters!;
        }
        // If no local file exists, fall back to loading from assets
        _cachedCharacters = await _loadFromAssets();
        print(
          '✅ CharacterService: Successfully loaded ${_cachedCharacters!.length} characters from assets',
        );
        return _cachedCharacters!;
      } else {
        // Load from assets and restore web state if needed
        _cachedCharacters = await _loadFromAssets();

        await _restoreWebState();

        print(
          '✅ CharacterService: Successfully loaded ${_cachedCharacters!.length} characters',
        );
        return _cachedCharacters!;
      }
    } catch (e) {
      print(
        '❌ CharacterService: Error loading characters: $e (${e.runtimeType})',
      );
      return [];
    }
  }

  /// Load characters from local file (desktop/mobile only)
  static Future<List<Character>?> _loadFromLocalFile() async {
    try {
      final file = await _getLocalFile();
      print('� CharacterService: Checking local file: ${file.path}');

      if (!await file.exists()) {
        return null;
      }

      final jsonString = await file.readAsString();
      final List<dynamic> jsonList = json.decode(jsonString);
      final characters = jsonList
          .map((json) => Character.fromJson(json))
          .toList();

      final bookmarkedCount = characters.where((c) => c.isBookmarked).length;
      print(
        '✅ CharacterService: Loaded ${characters.length} characters from local file ($bookmarkedCount bookmarks)',
      );

      return characters;
    } catch (e) {
      print('⚠️ CharacterService: Failed to load from local file: $e');
      return null;
    }
  }

  /// Load characters from assets
  static Future<List<Character>> _loadFromAssets() async {
    print('CharacterService: Loading from assets/data/flutter_characters.json');

    final jsonString = await rootBundle.loadString(
      'assets/data/flutter_characters.json',
    );
    final List<dynamic> jsonList = json.decode(jsonString);

    print(
      '✅ CharacterService: Asset loaded (${jsonList.length} items, ${jsonString.length} chars)',
    );

    return jsonList.map((json) => Character.fromJson(json)).toList();
  }

  /// Restore user state from browser local storage (web only)
  static Future<void> _restoreWebState() async {
    print('🌐 CharacterService: Restoring web state from local storage');

    final prefs = await SharedPreferences.getInstance();

    // Load saved state
    final bookmarkedIds = prefs.getStringList('bookmarked_characters') ?? [];

    final notesJson = prefs.getString('character_notes');
    final notesMap = notesJson != null
        ? Map<String, String>.from(json.decode(notesJson))
        : <String, String>{};

    // Convert lists to sets for O(1) lookup performance
    final bookmarkedSet = bookmarkedIds.toSet();

    // Apply saved state to characters (optimized with set lookups)
    for (var character in _cachedCharacters!) {
      character.isBookmarked = bookmarkedSet.contains(character.id);
      character.note = notesMap[character.id] ?? '';
    }

    print(
      '✅ CharacterService: Restored state - ${bookmarkedIds.length} bookmarks, ${notesMap.length} notes',
    );
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

  /// Clear all saved data from local storage (web only)
  static Future<void> clearLocalStorage() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('bookmarked_characters');
      await prefs.remove('character_notes');
      print(
        '🗑️ CharacterService: Cleared all data from browser local storage',
      );
    }
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
    final bookmarked = characters
        .where((character) => character.isBookmarked)
        .toList();
    print(
      '📑 CharacterService: Found ${bookmarked.length} bookmarked characters out of ${characters.length} total',
    );
    if (bookmarked.isNotEmpty) {
      print(
        '📑 CharacterService: Bookmarked character IDs: ${bookmarked.map((c) => c.id).join(', ')}',
      );
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
