import 'package:flutter/material.dart';
import '../data/character.dart';
import '../services/character_service.dart';
import '../widgets/character_card.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  List<Character> _bookmarkedCharacters = [];
  List<Character> _allCharacters = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCharacters();
  }

  Future<void> _loadCharacters() async {
    try {
      final loadedCharacters = await CharacterService.loadCharacters();
      setState(() {
        _allCharacters = loadedCharacters;
        _loadBookmarks();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _loadBookmarks() {
    setState(() {
      _bookmarkedCharacters = CharacterService.getBookmarkedCharacters(
        _allCharacters,
      );
    });
  }

  void _toggleBookmark(Character character) {
    setState(() {
      final index = _allCharacters.indexWhere((c) => c.id == character.id);
      if (index != -1) {
        _allCharacters[index] = _allCharacters[index].copyWith(
          isBookmarked: !_allCharacters[index].isBookmarked,
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

  void _handleNote(Character character) {
    showDialog(
      context: context,
      builder: (context) => _buildNoteDialog(character),
    );
  }

  Widget _buildNoteDialog(Character character) {
    final TextEditingController noteController = TextEditingController();
    noteController.text = character.note;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.note_alt, color: Theme.of(context).primaryColor),
          const SizedBox(width: 8),
          Expanded(child: Text('Note for ${character.name}')),
        ],
      ),
      content: TextField(
        controller: noteController,
        maxLines: 4,
        decoration: const InputDecoration(
          hintText: 'Add a note about this person...',
          border: OutlineInputBorder(),
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              final index = _allCharacters.indexWhere(
                (c) => c.id == character.id,
              );
              if (index != -1) {
                _allCharacters[index] = _allCharacters[index].copyWith(
                  note: noteController.text.trim(),
                );
              }
            });
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  noteController.text.trim().isEmpty
                      ? 'Note removed for ${character.name}'
                      : 'Note saved for ${character.name}',
                ),
                duration: const Duration(seconds: 1),
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
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
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Loading bookmarks...',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            )
          : _bookmarkedCharacters.isEmpty
          ? _buildEmptyState()
          : PageView.builder(
              itemCount: _bookmarkedCharacters.length,
              itemBuilder: (context, index) {
                final character = _bookmarkedCharacters[index];
                return CharacterCard(
                  character: character,
                  onBookmark: () => _toggleBookmark(character),
                  onNote: () => _handleNote(character),
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
          Icon(Icons.bookmark_border, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No bookmarks yet',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'Bookmark profiles you want to revisit',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
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
