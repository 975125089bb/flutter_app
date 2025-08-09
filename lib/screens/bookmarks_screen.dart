import 'package:flutter/material.dart';
import '../data/character.dart';
import '../data/characters_data.dart';
import '../services/character_service.dart';
import '../widgets/character_card.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  List<Character> _bookmarkedCharacters = [];

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  void _loadBookmarks() {
    setState(() {
      _bookmarkedCharacters = CharacterService.getBookmarkedCharacters(characters);
    });
  }

  void _toggleBookmark(Character character) {
    setState(() {
      final index = characters.indexWhere((c) => c.id == character.id);
      if (index != -1) {
        characters[index] = characters[index].copyWith(
          isBookmarked: !characters[index].isBookmarked,
        );
        _loadBookmarks();
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          character.isBookmarked 
              ? 'Removed ${character.name} from bookmarks'
              : 'Added ${character.name} to bookmarks',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks'),
        backgroundColor: Colors.pink.shade100,
        elevation: 0,
      ),
      body: _bookmarkedCharacters.isEmpty
          ? _buildEmptyState()
          : PageView.builder(
              itemCount: _bookmarkedCharacters.length,
              itemBuilder: (context, index) {
                final character = _bookmarkedCharacters[index];
                return CharacterCard(
                  character: character,
                  onBookmark: () => _toggleBookmark(character),
                  onLike: () {
                    // Handle like action
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Liked ${character.name}!'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  onReject: () {
                    // Handle reject action
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Passed on ${character.name}'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_border,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No bookmarks yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bookmark profiles you want to revisit',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.explore),
            label: const Text('Explore Profiles'),
          ),
        ],
      ),
    );
  }
}
