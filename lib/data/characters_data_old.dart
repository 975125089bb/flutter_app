import 'character.dart';
import '../services/character_service.dart';

// Legacy compatibility - now loads from JSON
Future<List<Character>> getCharacters() async {
  return await CharacterService.loadCharacters();
}

// Keep the old variable name for backward compatibility, but it's now dynamic
List<Character> characters = [];

// Initialize characters when needed
Future<void> initializeCharacters() async {
  characters = await CharacterService.loadCharacters();
}
    imageUrl:
        'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400',
    age: 30,
    location: 'Miami, FL',
    interests: ['Fitness', 'Business', 'Food', 'Travel', 'Beach'],
    distanceKm: 45.3,
    profession: 'Entrepreneur',
  ),
  Character(
    id: '5',
    name: 'Olivia',
    description:
        'Medical student with a passion for helping others. Love dancing, cooking international cuisine, and weekend adventures.',
    imageUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400',
    age: 24,
    location: 'Boston, MA',
    interests: ['Medicine', 'Dancing', 'Cooking', 'Volunteering', 'Books'],
    distanceKm: 12.8,
    profession: 'Medical Student',
    isLiked: true,
  ),
  Character(
    id: '6',
    name: 'David',
    description:
        'Musician and teacher who loves live concerts, outdoor activities, and deep conversations over good wine.',
    imageUrl:
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400',
    age: 29,
    location: 'Austin, TX',
    interests: ['Music', 'Teaching', 'Wine', 'Concerts', 'Nature'],
    distanceKm: 23.1,
    profession: 'Music Teacher',
    isLiked: true,
  ),
];
