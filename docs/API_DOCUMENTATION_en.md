相亲小app
背景
鉴于使用github网页版直接查看相亲资料存在着诸如不方便移动端查看，无法搜索等问题，本app致力于提供一个更为方便的跨平台解决方案

# API and Data Models Documentation

## Overview
This document provides comprehensive documentation for all data models, APIs, and data structures used in the Modern Dating App. It covers the character data schema, service APIs, and data flow patterns.

## Core Data Models

### 1. Character Model

#### Schema Definition
```dart
class Character {
  // Identity Fields
  final String id;                    // Unique character identifier
  final String? gender;               // "male", "female", or null
  
  // Demographic Information
  final int age;                      // Age in years (18-100)
  final int? height;                  // Height in centimeters
  final double? bmi;                  // Body Mass Index
  
  // Personality Traits
  final String? zodiac;               // Zodiac sign
  final String? mbti;                 // Myers-Briggs Type Indicator
  
  // Location Information
  final String? hometown;             // Birth/origin location
  final String currentLocation;       // Current residence
  
  // Professional Information
  final String occupation;            // Job title/profession
  
  // Interests and Hobbies
  final List<String> interests;       // List of interests/hobbies
  
  // Lifestyle Information
  final bool? hasHouse;               // Home ownership status
  final bool? hasCar;                 // Car ownership status
  final String? maritalStatus;        // "single", "divorced", etc.
  
  // Content
  final String rawText;               // Original character description
  final String? image;                // Profile image URL/path
  
  // User Interaction State (Mutable)
  bool isBookmarked;                  // User bookmark status
  bool isLiked;                       // User like status
  bool isRejected;                    // User rejection status
  String note;                        // User-added notes
}
```

#### Data Validation Rules
```dart
// Age validation
assert(age >= 18 && age <= 100, 'Age must be between 18 and 100');

// Height validation (if provided)
if (height != null) {
  assert(height >= 140 && height <= 220, 'Height must be between 140-220 cm');
}

// Gender validation (if provided)
if (gender != null) {
  assert(['male', 'female'].contains(gender), 'Gender must be male or female');
}

// MBTI validation (if provided)
if (mbti != null) {
  final validMbti = RegExp(r'^[EI][NS][TF][JP]$');
  assert(validMbti.hasMatch(mbti), 'Invalid MBTI format');
}

// Interests validation
assert(interests.isNotEmpty, 'Interests list cannot be empty');
```

#### JSON Serialization
```dart
// From JSON
factory Character.fromJson(Map<String, dynamic> json) {
  return Character(
    id: json['id'] as String,
    gender: json['gender'] as String?,
    age: json['age'] as int,
    height: json['height'] as int?,
    zodiac: json['zodiac'] as String?,
    mbti: json['mbti'] as String?,
    rawText: json['rawText'] as String,
    image: json['image'] as String?,
    bmi: json['bmi']?.toDouble(),
    hometown: json['hometown'] as String?,
    currentLocation: json['currentLocation'] as String,
    occupation: json['occupation'] as String,
    interests: List<String>.from(json['interests'] ?? []),
    hasHouse: json['hasHouse'] as bool?,
    hasCar: json['hasCar'] as bool?,
    maritalStatus: json['maritalStatus'] as String?,
    // User interaction states default to false/empty
    isBookmarked: json['isBookmarked'] ?? false,
    isLiked: json['isLiked'] ?? false,
    isRejected: json['isRejected'] ?? false,
    note: json['note'] ?? '',
  );
}

// To JSON
Map<String, dynamic> toJson() {
  return {
    'id': id,
    'gender': gender,
    'age': age,
    'height': height,
    'zodiac': zodiac,
    'mbti': mbti,
    'rawText': rawText,
    'image': image,
    'bmi': bmi,
    'hometown': hometown,
    'currentLocation': currentLocation,
    'occupation': occupation,
    'interests': interests,
    'hasHouse': hasHouse,
    'hasCar': hasCar,
    'maritalStatus': maritalStatus,
    'isBookmarked': isBookmarked,
    'isLiked': isLiked,
    'isRejected': isRejected,
    'note': note,
  };
}
```

### 2. Filter Options Model

#### Schema Definition
```dart
class FilterOptions {
  // Age filtering
  final int minAge;                   // Minimum age (default: 18)
  final int maxAge;                   // Maximum age (default: 100)
  
  // Location filtering
  final List<String> selectedLocations; // Preferred locations
  final double? maxDistance;          // Maximum distance in km
  
  // Interest filtering
  final List<String> requiredInterests; // Must-have interests
  final List<String> preferredInterests; // Nice-to-have interests
  
  // Personality filtering
  final List<String> mbtiTypes;       // Preferred MBTI types
  final List<String> zodiacSigns;     // Preferred zodiac signs
  
  // Lifestyle filtering
  final bool? requiresHouse;          // Must own house
  final bool? requiresCar;            // Must own car
  final List<String> maritalStatuses; // Acceptable marital statuses
  
  // Physical attributes
  final int? minHeight;               // Minimum height in cm
  final int? maxHeight;               // Maximum height in cm
  final double? minBmi;               // Minimum BMI
  final double? maxBmi;               // Maximum BMI
  
  // Advanced filters
  final List<String> excludedOccupations; // Occupations to exclude
  final bool showBookmarkedOnly;      // Show only bookmarked profiles
  final bool hideRejected;            // Hide rejected profiles
}
```

#### Default Values
```dart
static FilterOptions get defaultOptions => FilterOptions(
  minAge: 18,
  maxAge: 100,
  selectedLocations: [],
  requiredInterests: [],
  preferredInterests: [],
  mbtiTypes: [],
  zodiacSigns: [],
  maritalStatuses: ['single', 'divorced'],
  showBookmarkedOnly: false,
  hideRejected: true,
);
```

### 3. Statistics Model

#### Schema Definition
```dart
class AppStatistics {
  // Profile counts
  final int totalProfiles;            // Total number of profiles
  final int maleProfiles;             // Number of male profiles
  final int femaleProfiles;           // Number of female profiles
  
  // User interaction stats
  final int bookmarkedCount;          // Number of bookmarked profiles
  final int likedCount;               // Number of liked profiles
  final int rejectedCount;            // Number of rejected profiles
  final int profilesWithNotes;       // Profiles with user notes
  
  // Age distribution
  final Map<String, int> ageGroups;   // Age group distribution
  
  // Location distribution
  final Map<String, int> locationStats; // Location popularity
  
  // Interest popularity
  final Map<String, int> interestStats; // Most popular interests
  
  // MBTI distribution
  final Map<String, int> mbtiStats;   // MBTI type distribution
  
  // Activity metrics
  final DateTime lastActivity;        // Last user activity
  final int dailyViews;              // Profiles viewed today
  final int weeklyViews;             // Profiles viewed this week
}
```

## Service APIs

### 1. Character Service API

#### Core Methods

##### `loadCharacters()`
```dart
/// Loads all character data from the data source
/// Returns: Future<List<Character>>
/// Throws: DataLoadException if loading fails
Future<List<Character>> loadCharacters() async {
  try {
    // Load from local data source
    final List<Map<String, dynamic>> rawData = await _loadRawData();
    
    // Convert to Character objects
    final characters = rawData.map((json) => Character.fromJson(json)).toList();
    
    // Apply validation
    characters.forEach(_validateCharacter);
    
    return characters;
  } catch (e) {
    throw DataLoadException('Failed to load characters: $e');
  }
}
```

##### `filterCharacters()`
```dart
/// Filters characters based on provided criteria
/// Parameters:
///   - characters: List of characters to filter
///   - options: FilterOptions containing filter criteria
/// Returns: List<Character> - Filtered character list
List<Character> filterCharacters(
  List<Character> characters, 
  FilterOptions options,
) {
  return characters.where((character) {
    // Age filter
    if (character.age < options.minAge || character.age > options.maxAge) {
      return false;
    }
    
    // Gender filter (if specified)
    if (options.genderPreference != null && 
        character.gender != options.genderPreference) {
      return false;
    }
    
    // Location filter
    if (options.selectedLocations.isNotEmpty && 
        !options.selectedLocations.contains(character.currentLocation)) {
      return false;
    }
    
    // Interest filter
    if (options.requiredInterests.isNotEmpty && 
        !_hasRequiredInterests(character.interests, options.requiredInterests)) {
      return false;
    }
    
    // Height filter
    if (character.height != null) {
      if (options.minHeight != null && character.height! < options.minHeight!) {
        return false;
      }
      if (options.maxHeight != null && character.height! > options.maxHeight!) {
        return false;
      }
    }
    
    // MBTI filter
    if (options.mbtiTypes.isNotEmpty && 
        (character.mbti == null || !options.mbtiTypes.contains(character.mbti))) {
      return false;
    }
    
    // Asset filters
    if (options.requiresHouse == true && character.hasHouse != true) {
      return false;
    }
    if (options.requiresCar == true && character.hasCar != true) {
      return false;
    }
    
    // User interaction filters
    if (options.showBookmarkedOnly && !character.isBookmarked) {
      return false;
    }
    if (options.hideRejected && character.isRejected) {
      return false;
    }
    
    return true;
  }).toList();
}
```

##### `searchCharacters()`
```dart
/// Searches characters based on text query
/// Parameters:
///   - query: Search query string
///   - characters: List of characters to search
/// Returns: List<Character> - Matching characters
List<Character> searchCharacters(String query, List<Character> characters) {
  if (query.isEmpty) return characters;
  
  final lowercaseQuery = query.toLowerCase();
  
  return characters.where((character) {
    // Search in multiple fields
    final searchableText = [
      character.occupation.toLowerCase(),
      character.currentLocation.toLowerCase(),
      character.hometown?.toLowerCase() ?? '',
      character.interests.join(' ').toLowerCase(),
      character.mbti?.toLowerCase() ?? '',
      character.zodiac?.toLowerCase() ?? '',
      character.rawText.toLowerCase(),
    ].join(' ');
    
    return searchableText.contains(lowercaseQuery);
  }).toList();
}
```

##### User Interaction Methods
```dart
/// Toggles bookmark status for a character
/// Parameters:
///   - characterId: ID of the character to bookmark/unbookmark
/// Returns: bool - New bookmark status
bool toggleBookmark(String characterId) {
  final character = _findCharacterById(characterId);
  if (character != null) {
    character.isBookmarked = !character.isBookmarked;
    _persistUserInteraction(characterId, 'bookmark', character.isBookmarked);
    return character.isBookmarked;
  }
  return false;
}

/// Marks a character as liked
/// Parameters:
///   - characterId: ID of the character to like
void likeCharacter(String characterId) {
  final character = _findCharacterById(characterId);
  if (character != null) {
    character.isLiked = true;
    character.isRejected = false; // Can't be both liked and rejected
    _persistUserInteraction(characterId, 'like', true);
  }
}

/// Marks a character as rejected
/// Parameters:
///   - characterId: ID of the character to reject
void rejectCharacter(String characterId) {
  final character = _findCharacterById(characterId);
  if (character != null) {
    character.isRejected = true;
    character.isLiked = false; // Can't be both liked and rejected
    _persistUserInteraction(characterId, 'reject', true);
  }
}

/// Adds or updates a note for a character
/// Parameters:
///   - characterId: ID of the character
///   - note: Note text to add
void addNote(String characterId, String note) {
  final character = _findCharacterById(characterId);
  if (character != null) {
    character.note = note;
    _persistUserInteraction(characterId, 'note', note);
  }
}
```

### 2. Statistics Service API

#### Methods
```dart
class StatisticsService {
  /// Generates comprehensive app statistics
  AppStatistics generateStatistics(List<Character> characters) {
    return AppStatistics(
      totalProfiles: characters.length,
      maleProfiles: characters.where((c) => c.gender == 'male').length,
      femaleProfiles: characters.where((c) => c.gender == 'female').length,
      bookmarkedCount: characters.where((c) => c.isBookmarked).length,
      likedCount: characters.where((c) => c.isLiked).length,
      rejectedCount: characters.where((c) => c.isRejected).length,
      profilesWithNotes: characters.where((c) => c.note.isNotEmpty).length,
      ageGroups: _calculateAgeGroups(characters),
      locationStats: _calculateLocationStats(characters),
      interestStats: _calculateInterestStats(characters),
      mbtiStats: _calculateMbtiStats(characters),
      lastActivity: DateTime.now(),
      dailyViews: _getDailyViews(),
      weeklyViews: _getWeeklyViews(),
    );
  }
}
```

## Data Flow Patterns

### 1. Character Loading Flow
```
App Initialization
        ↓
CharacterService.loadCharacters()
        ↓
Load from characters_data.dart
        ↓
Parse JSON to Character objects
        ↓
Apply data validation
        ↓
Load user interaction state
        ↓
Cache in memory
        ↓
Notify UI components
```

### 2. Filtering Flow
```
User Input (FilterDialog)
        ↓
Create FilterOptions object
        ↓
CharacterService.filterCharacters()
        ↓
Apply filter criteria sequentially
        ↓
Return filtered character list
        ↓
Update UI state
        ↓
Re-render character cards
```

### 3. User Interaction Flow
```
User Action (like/bookmark/note)
        ↓
Call appropriate service method
        ↓
Update character object state
        ↓
Persist to local storage
        ↓
Notify UI of state change
        ↓
Update visual feedback
        ↓
Optionally sync with remote service
```

## Error Handling

### Exception Types
```dart
class DataException implements Exception {
  final String message;
  const DataException(this.message);
}

class DataLoadException extends DataException {
  const DataLoadException(String message) : super(message);
}

class ValidationException extends DataException {
  const ValidationException(String message) : super(message);
}

class PersistenceException extends DataException {
  const PersistenceException(String message) : super(message);
}
```

### Error Handling Patterns
```dart
try {
  final characters = await characterService.loadCharacters();
  setState(() {
    _characters = characters;
    _isLoading = false;
  });
} on DataLoadException catch (e) {
  _showErrorDialog('Failed to load profiles: ${e.message}');
} on ValidationException catch (e) {
  _showErrorDialog('Data validation error: ${e.message}');
} catch (e) {
  _showErrorDialog('Unexpected error: $e');
} finally {
  setState(() => _isLoading = false);
}
```

## Data Persistence

### Local Storage Schema
```dart
// SharedPreferences keys
static const String keyBookmarkedIds = 'bookmarked_character_ids';
static const String keyLikedIds = 'liked_character_ids';
static const String keyRejectedIds = 'rejected_character_ids';
static const String keyCharacterNotes = 'character_notes';
static const String keyUserFilters = 'user_filter_preferences';
static const String keyLastActivity = 'last_activity_timestamp';
```

### Storage Operations
```dart
// Save user interactions
Future<void> _persistUserInteraction(
  String characterId, 
  String action, 
  dynamic value,
) async {
  final prefs = await SharedPreferences.getInstance();
  
  switch (action) {
    case 'bookmark':
      final bookmarked = prefs.getStringList(keyBookmarkedIds) ?? [];
      if (value as bool) {
        bookmarked.add(characterId);
      } else {
        bookmarked.remove(characterId);
      }
      await prefs.setStringList(keyBookmarkedIds, bookmarked);
      break;
      
    case 'note':
      final notes = prefs.getString(keyCharacterNotes);
      final notesMap = notes != null ? jsonDecode(notes) : <String, String>{};
      notesMap[characterId] = value as String;
      await prefs.setString(keyCharacterNotes, jsonEncode(notesMap));
      break;
  }
}
```

## Performance Considerations

### Caching Strategy
```dart
class DataCache {
  static final Map<String, List<Character>> _cache = {};
  static DateTime? _lastUpdated;
  static const Duration cacheTimeout = Duration(hours: 1);
  
  static bool get isValid => 
      _lastUpdated != null && 
      DateTime.now().difference(_lastUpdated!) < cacheTimeout;
      
  static List<Character>? get characters => 
      isValid ? _cache['characters'] : null;
      
  static void update(List<Character> characters) {
    _cache['characters'] = characters;
    _lastUpdated = DateTime.now();
  }
}
```

### Lazy Loading
```dart
// Load character images on demand
Widget _buildCharacterImage(Character character) {
  return FadeInImage(
    placeholder: AssetImage('assets/images/placeholder.png'),
    image: character.image != null 
        ? NetworkImage(character.image!) 
        : AssetImage('assets/images/default_avatar.png'),
    fadeInDuration: Duration(milliseconds: 300),
  );
}
```

### Memory Management
```dart
// Dispose of resources when not needed
@override
void dispose() {
  _characterController.dispose();
  _filteredCharacters.clear();
  super.dispose();
}
```

## API Integration (Future)

### REST API Endpoints (Planned)
```
GET    /api/characters              # Get all characters
GET    /api/characters/:id          # Get specific character
POST   /api/characters              # Create new character
PUT    /api/characters/:id          # Update character
DELETE /api/characters/:id          # Delete character

GET    /api/characters/search       # Search characters
POST   /api/characters/filter       # Filter characters

GET    /api/users/:id/bookmarks     # Get user bookmarks
POST   /api/users/:id/bookmarks     # Add bookmark
DELETE /api/users/:id/bookmarks/:id # Remove bookmark

GET    /api/statistics              # Get app statistics
```

### WebSocket Events (Planned)
```dart
// Real-time updates
socket.on('character_updated', (data) => _updateCharacter(data));
socket.on('new_character', (data) => _addCharacter(data));
socket.on('character_deleted', (data) => _removeCharacter(data));
```

---

*This API documentation provides complete coverage of all data models and service interfaces. For implementation examples, refer to the source code and unit tests.*

---
