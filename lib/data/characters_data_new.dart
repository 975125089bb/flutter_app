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
