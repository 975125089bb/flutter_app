import 'package:flutter_test/flutter_test.dart';
import 'package:date_app/services/character_service.dart';

void main() {
  group('Character Service Tests', () {
    test('should load characters from JSON', () async {
      // This test will help verify our JSON loading works
      try {
        final characters = await CharacterService.loadCharacters();

        expect(characters, isNotEmpty);
        expect(characters.length, 5); // We have 5 test characters

        final firstCharacter = characters.first;
        expect(firstCharacter.id, 'profile_1');
        expect(firstCharacter.age, 44);
        expect(firstCharacter.currentLocation, '松户');
        expect(firstCharacter.occupation, '软件');
        expect(firstCharacter.interests, contains('摄影'));

        print('✅ Successfully loaded ${characters.length} characters');
        for (var character in characters) {
          print(
            '  - ${character.name} (${character.age} years, ${character.currentLocation})',
          );
        }
      } catch (e) {
        print('❌ Error loading characters: $e');
        fail('Character loading failed: $e');
      }
    });
  });
}
