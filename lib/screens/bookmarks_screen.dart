import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  int _currentPageIndex = 0;
  final PageController _pageController = PageController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadCharacters();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _pageController.dispose();
    super.dispose();
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent && _bookmarkedCharacters.isNotEmpty) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowRight:
        case LogicalKeyboardKey.space:
          _nextBookmark();
          return KeyEventResult.handled;
        case LogicalKeyboardKey.arrowLeft:
          _previousBookmark();
          return KeyEventResult.handled;
        case LogicalKeyboardKey.enter:
          if (_bookmarkedCharacters.isNotEmpty) {
            _toggleBookmark(_bookmarkedCharacters[_currentPageIndex]);
          }
          return KeyEventResult.handled;
        case LogicalKeyboardKey.keyN:
          if (_bookmarkedCharacters.isNotEmpty) {
            _handleNote(_bookmarkedCharacters[_currentPageIndex]);
          }
          return KeyEventResult.handled;
        case LogicalKeyboardKey.keyH:
        case LogicalKeyboardKey.f1:
          _showControlsHelp();
          return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  void _nextBookmark() {
    if (_currentPageIndex < _bookmarkedCharacters.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousBookmark() {
    if (_currentPageIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showControlsHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.keyboard, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            const Text('Keyboard Shortcuts'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Navigation:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            _buildControlItem('→ / Space', 'Next bookmark'),
            _buildControlItem('←', 'Previous bookmark'),
            _buildControlItem('Enter', 'Toggle bookmark'),
            _buildControlItem('N', 'Add/edit note'),
            _buildControlItem('H / F1', 'Show help'),
            const SizedBox(height: 16),
            const Text(
              'Mouse/Touch:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            _buildControlItem('Swipe/Drag', 'Navigate bookmarks'),
            _buildControlItem('Tap buttons', 'Bookmark/Note actions'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  Widget _buildControlItem(String key, String action) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              key,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(action)),
        ],
      ),
    );
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
      
      // Reset page index if it's out of bounds
      if (_currentPageIndex >= _bookmarkedCharacters.length) {
        _currentPageIndex = _bookmarkedCharacters.isEmpty ? 0 : _bookmarkedCharacters.length - 1;
      }
    });
    
    // Ensure the PageController is in sync
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pageController.hasClients && _bookmarkedCharacters.isNotEmpty) {
        if (_currentPageIndex < _bookmarkedCharacters.length) {
          _pageController.animateToPage(
            _currentPageIndex,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  void _toggleBookmark(Character character) {
    final wasBookmarked = character.isBookmarked;
    
    setState(() {
      final index = _allCharacters.indexWhere((c) => c.id == character.id);
      if (index != -1) {
        _allCharacters[index] = _allCharacters[index].copyWith(
          isBookmarked: !_allCharacters[index].isBookmarked,
        );
        
        // Update bookmarks list
        final oldBookmarkCount = _bookmarkedCharacters.length;
        _loadBookmarks();
        
        // If we removed a bookmark, adjust page index
        if (wasBookmarked && _bookmarkedCharacters.length < oldBookmarkCount) {
          // If we removed the last item and there are still items, go to previous page
          if (_currentPageIndex >= _bookmarkedCharacters.length && _bookmarkedCharacters.isNotEmpty) {
            _currentPageIndex = _bookmarkedCharacters.length - 1;
          }
          // If no bookmarks left, reset to 0
          else if (_bookmarkedCharacters.isEmpty) {
            _currentPageIndex = 0;
          }
        }
      }
    });

    CharacterService.saveCharacters(_allCharacters);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          wasBookmarked
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
            CharacterService.saveCharacters(_allCharacters);
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
    return Focus(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      autofocus: true,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bookmarks'),
          backgroundColor: Colors.pink.shade100,
          elevation: 0,
          actions: [
            // Help button
            IconButton(
              onPressed: _showControlsHelp,
              icon: const Icon(Icons.help_outline),
              tooltip: 'Keyboard shortcuts (H)',
            ),
          ],
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
          : Column(
              children: [
                // Swipeable area - exactly like home screen
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _bookmarkedCharacters.length,
                    onPageChanged: (index) {
                      setState(() => _currentPageIndex = index);
                    },
                    itemBuilder: (context, index) {
                      final character = _bookmarkedCharacters[index];
                      return CharacterCard(
                        character: character,
                        onBookmark: () => _toggleBookmark(character),
                        onNote: () => _handleNote(character),
                      );
                    },
                  ),
                ),
                // Page Indicator - exactly like home screen
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${_currentPageIndex + 1} of ${_bookmarkedCharacters.length}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        width: 100,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: (_currentPageIndex + 1) / _bookmarkedCharacters.length,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
