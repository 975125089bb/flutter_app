# Flutter App Architecture Documentation

## Overview
The Modern Dating App follows a clean, scalable architecture based on Flutter best practices. The app is structured to separate concerns, promote reusability, and ensure maintainability.

## Architecture Pattern
The app uses a **Service-Oriented Architecture** with the following layers:
- **Presentation Layer**: Screens and Widgets (UI)
- **Business Logic Layer**: Services and Models
- **Data Layer**: Data models and providers

## Project Structure

### Root Level Structure
```
lib/
├── main.dart                    # Application entry point
├── constants/                   # App-wide constants
├── data/                        # Data models and providers
├── models/                      # Business logic models
├── screens/                     # Screen-level widgets
├── services/                    # Business logic services
└── widgets/                     # Reusable UI components
```

## Detailed Component Documentation

### 1. Application Entry Point

#### main.dart
**Purpose**: Application bootstrap and configuration

**Key Responsibilities**:
- Initialize the Flutter app
- Configure theme and styling
- Set up routing
- Define global app settings

**Code Structure**:
```dart
void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  // App configuration and theme setup
  // Material 3 theme with pink color scheme
  // Global app settings and navigation setup
}
```

**Theme Configuration**:
- **Primary Color**: Pink shade 400 (#EC407A)
- **Design System**: Material 3
- **Typography**: Modern, clean fonts with appropriate weights
- **Card Design**: Rounded corners (16px radius) with elevation
- **Button Styling**: Rounded buttons with consistent padding

### 2. Constants Layer

#### constants/routes.dart
**Purpose**: Centralized route management

**Features**:
- Named route definitions
- Route parameter handling
- Navigation utilities
- Deep linking support

### 3. Data Layer

#### data/character.dart
**Purpose**: Core character data model

**Properties**:
```dart
class Character {
  // Identity
  final String id;
  final String? gender;
  
  // Demographics
  final int age;
  final int? height;
  final double? bmi;
  
  // Personality
  final String? zodiac;
  final String? mbti;
  
  // Location
  final String? hometown;
  final String currentLocation;
  
  // Lifestyle
  final String occupation;
  final List<String> interests;
  final bool? hasHouse;
  final bool? hasCar;
  final String? maritalStatus;
  
  // Content
  final String rawText;
  final String? image;
  
  // User Interactions (mutable)
  bool isBookmarked;
  bool isLiked;
  bool isRejected;
  String note;
}
```

**Key Methods**:
- `fromJson()`: JSON deserialization
- `toJson()`: JSON serialization
- `copyWith()`: Immutable updates
- `toMap()`: Data persistence
- Utility methods for data formatting and validation

#### data/characters_data.dart
**Purpose**: Static character data provider

**Features**:
- Preloaded character dataset
- Data initialization and caching
- Multiple data source support
- Data validation and integrity checks

### 4. Models Layer

#### models/filter_options.dart
**Purpose**: Filtering and search configuration

**Classes**:
```dart
class FilterOptions {
  // Age filtering
  final int minAge;
  final int maxAge;
  
  // Location filtering
  final List<String> locations;
  final double? maxDistance;
  
  // Lifestyle filtering
  final List<String> interests;
  final List<String> mbtiTypes;
  final List<String> zodiacSigns;
  
  // Asset filtering
  final bool? requiresHouse;
  final bool? requiresCar;
  
  // Status filtering
  final List<String> maritalStatuses;
}
```

### 5. Services Layer

#### services/character_service.dart
**Purpose**: Business logic and data management

**Key Responsibilities**:
- Character data loading and caching
- Filtering and search operations
- User interaction management (bookmarks, likes)
- Data persistence and state management
- Business rule enforcement

**Main Methods**:
```dart
class CharacterService {
  // Data Management
  Future<List<Character>> loadCharacters();
  Future<void> saveCharacters(List<Character> characters);
  
  // Filtering
  List<Character> filterCharacters(List<Character> characters, FilterOptions options);
  List<Character> searchCharacters(String query);
  
  // User Interactions
  void toggleBookmark(String characterId);
  void likeCharacter(String characterId);
  void rejectCharacter(String characterId);
  void addNote(String characterId, String note);
  
  // Statistics
  int getBookmarkCount();
  int getLikeCount();
  Map<String, int> getInterestStatistics();
}
```

### 6. Screens Layer

#### screens/home_screen.dart
**Purpose**: Main character discovery interface

**Features**:
- Character card display
- Swipe gesture handling
- Filter integration
- Search functionality
- Navigation controls

**State Management**:
```dart
class _HomeScreenState extends State<HomeScreen> {
  List<Character> characters = [];
  List<Character> filteredCharacters = [];
  FilterOptions currentFilters = FilterOptions();
  int currentIndex = 0;
  bool isLoading = false;
}
```

**Key UI Components**:
- Character card stack
- Filter button and dialog
- Search bar
- Navigation drawer
- Statistics display

#### screens/bookmarks_screen.dart
**Purpose**: Saved profiles management

**Features**:
- Bookmarked character display
- Note editing functionality
- Removal capabilities
- Sorting and filtering options

### 7. Widgets Layer

#### widgets/character_card.dart
**Purpose**: Individual character profile display

**Features**:
- Responsive card layout
- Image display with fallbacks
- Comprehensive character information
- Interactive elements (bookmark, like buttons)
- Expandable sections for detailed info

**Layout Structure**:
```dart
Card(
  child: Column(
    children: [
      // Header with image and basic info
      CharacterHeader(),
      
      // Demographics section
      DemographicsSection(),
      
      // Interests and personality
      InterestsSection(),
      
      // Location and lifestyle
      LifestyleSection(),
      
      // Action buttons
      ActionButtonsSection(),
    ],
  ),
)
```

#### widgets/sliding_widget.dart
**Purpose**: Swipe interaction component

**Features**:
- Gesture detection (swipe left/right)
- Smooth animations and transitions
- Visual feedback for user actions
- Customizable swipe sensitivity
- Support for various swipe actions

**Animation System**:
```dart
class SlidingWidget extends StatefulWidget {
  // Animation controllers for smooth transitions
  late AnimationController _slideController;
  late AnimationController _scaleController;
  
  // Gesture handling for swipe detection
  void _handlePanUpdate(DragUpdateDetails details);
  void _handlePanEnd(DragEndDetails details);
}
```

#### widgets/filter_dialog_enhanced.dart
**Purpose**: Advanced filtering interface

**Features**:
- Multi-criteria filtering
- Range sliders for numerical values
- Multi-select options for categories
- Real-time filter preview
- Filter preset management

**Filter Categories**:
- Age range selection
- Location-based filtering
- Interest matching
- MBTI compatibility
- Zodiac sign preferences
- Asset requirements (house, car)
- Marital status options

#### widgets/expanding_widget.dart
**Purpose**: Expandable content sections

**Features**:
- Smooth expand/collapse animations
- Content overflow handling
- Customizable expansion triggers
- Performance optimization for large content

#### widgets/page_indicator.dart
**Purpose**: Visual navigation indicator

**Features**:
- Dot-based page indication
- Smooth transitions between pages
- Customizable styling and colors
- Touch interaction support

#### widgets/stats_widget.dart
**Purpose**: Statistics display component

**Features**:
- Data visualization
- Real-time statistics updates
- Interactive charts and graphs
- Export capabilities

## Data Flow Architecture

### Character Loading Flow
```
App Start
    ↓
CharacterService.loadCharacters()
    ↓
Load from characters_data.dart
    ↓
Apply data validation
    ↓
Initialize user interaction states
    ↓
Cache in memory
    ↓
Update UI (HomeScreen)
```

### Filtering Flow
```
User applies filter (FilterDialog)
    ↓
FilterOptions created
    ↓
CharacterService.filterCharacters()
    ↓
Apply filter criteria
    ↓
Return filtered list
    ↓
Update HomeScreen state
    ↓
Re-render character cards
```

### User Interaction Flow
```
User action (like, bookmark, note)
    ↓
CharacterService method called
    ↓
Update character state
    ↓
Persist changes locally
    ↓
Notify UI of state change
    ↓
Update visual feedback
```

## State Management

### Local State
Each screen and widget manages its own local state using `setState()`:
- UI-specific state (loading, error states)
- Form data and input validation
- Animation states and transitions

### Shared State
Character data and user interactions are managed through:
- **CharacterService**: Centralized business logic
- **Static Data**: Preloaded character information
- **Local Storage**: Persistent user preferences and interactions

### State Persistence
```dart
// Save user interactions
SharedPreferences prefs = await SharedPreferences.getInstance();
prefs.setStringList('bookmarked_ids', bookmarkedIds);
prefs.setString('user_filters', jsonEncode(filterOptions));
```

## Navigation Architecture

### Route Structure
```dart
// Main navigation routes
static const String home = '/';
static const String bookmarks = '/bookmarks';
static const String profile = '/profile';
static const String settings = '/settings';
```

### Navigation Pattern
The app uses a combination of:
- **Drawer Navigation**: Side menu for main sections
- **Bottom Navigation**: Quick access to core features
- **Stack Navigation**: Modal screens and detail views

## Theme and Styling

### Design System
```dart
ThemeData(
  // Color Scheme
  primarySwatch: Colors.pink,
  primaryColor: Colors.pink.shade400,
  
  // Typography
  textTheme: TextTheme(
    headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
  ),
  
  // Component Themes
  cardTheme: CardThemeData(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
)
```

### Responsive Design
- **Breakpoints**: Support for mobile, tablet, and desktop
- **Adaptive Layouts**: Responsive widgets that adapt to screen size
- **Platform Considerations**: iOS/Android specific UI adjustments

## Performance Optimization

### Lazy Loading
- Character images loaded on demand
- List virtualization for large datasets
- Pagination for character browsing

### Memory Management
- Efficient image caching
- Dispose of unused resources
- Optimize widget rebuilds

### Build Optimization
```dart
// Use const constructors where possible
const CharacterCard(character: character);

// Implement efficient shouldRebuild logic
@override
bool shouldRebuild(covariant CharacterCardDelegate oldDelegate) {
  return oldDelegate.character != character;
}
```

## Testing Architecture

### Unit Tests
- Business logic testing (CharacterService)
- Data model validation
- Utility function testing

### Widget Tests
- UI component testing
- User interaction simulation
- State management validation

### Integration Tests
- End-to-end user flows
- Navigation testing
- Data persistence verification

## Platform Considerations

### Android
- Material Design compliance
- Back button handling
- Android-specific permissions

### iOS
- Cupertino design elements where appropriate
- iOS navigation patterns
- App Store compliance

### Web
- Responsive web design
- URL routing support
- Web-specific optimizations

### Desktop (Windows/macOS/Linux)
- Keyboard navigation
- Window management
- Desktop-specific UI patterns

---

*This architecture documentation provides a comprehensive overview of the Flutter app structure. For implementation details, refer to the individual source files and inline documentation.*

---