import 'package:date_app/constants/routes.dart';
import 'package:date_app/widgets/character_card.dart';
import 'package:date_app/widgets/sliding_widget.dart';
import 'package:date_app/widgets/filter_dialog_enhanced.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/character.dart';
import '../models/filter_options.dart';
import '../services/character_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  bool _panelVisible = false;
  FilterOptions _filterOptions = const FilterOptions();
  List<Character> _filteredCharacters = [];
  List<Character> _allCharacters = [];
  bool _isLoading = true;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadCharacters();

    // Show keyboard shortcuts hint after the first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.keyboard, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    '💡 Tip: Use keyboard shortcuts for easier navigation!',
                  ),
                ),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    _showControlsHelp();
                  },
                  child: const Text(
                    'Show All',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 4),
            backgroundColor: Colors.blue.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // Keyboard navigation handler
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent && _filteredCharacters.isNotEmpty) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowRight:
        case LogicalKeyboardKey.space:
          _nextCard();
          return KeyEventResult.handled;
        case LogicalKeyboardKey.arrowLeft:
          _previousCard();
          return KeyEventResult.handled;
        case LogicalKeyboardKey.enter:
          _handleBookmark(_filteredCharacters[_currentIndex]);
          return KeyEventResult.handled;
        case LogicalKeyboardKey.keyN:
          _handleNote(_filteredCharacters[_currentIndex]);
          return KeyEventResult.handled;
        case LogicalKeyboardKey.keyF:
          _showFilterDialog();
          return KeyEventResult.handled;
        case LogicalKeyboardKey.keyH:
        case LogicalKeyboardKey.f1:
          _showControlsHelp();
          return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  Future<void> _loadCharacters() async {
    try {
      final loadedCharacters = await CharacterService.loadCharacters();
      setState(() {
        _allCharacters = loadedCharacters;
        _isLoading = false;
        _applyFilters();
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading characters: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _reloadCharacters() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final loadedCharacters = await CharacterService.reloadCharacters();
      setState(() {
        _allCharacters = loadedCharacters;
        _isLoading = false;
        _applyFilters();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.refresh, color: Colors.white),
                SizedBox(width: 8),
                Text('Data reloaded successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error reloading characters: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _applyFilters() {
    if (_allCharacters.isEmpty) return;

    setState(() {
      _filteredCharacters = CharacterService.filterAndSort(
        _allCharacters,
        _filterOptions,
      );
      _currentIndex = 0;
    });
  }

  void _applyFiltersWithAnimation() {
    if (_allCharacters.isEmpty) return;

    setState(() {
      _filteredCharacters = CharacterService.filterAndSort(
        _allCharacters,
        _filterOptions,
      );
      _currentIndex = 0;
    });

    // Only animate when called from user actions (not during init)
    if (_filteredCharacters.isNotEmpty && _pageController.hasClients) {
      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _togglePanel() {
    setState(() {
      _panelVisible = !_panelVisible;
    });
  }

  void _showFilterDialog() {
    final allInterests = CharacterService.getAllInterests(_allCharacters);
    showDialog(
      context: context,
      builder: (context) => FilterDialog(
        currentOptions: _filterOptions,
        allInterests: allInterests,
        onApply: (newOptions) {
          setState(() {
            _filterOptions = newOptions;
          });
          _applyFiltersWithAnimation();
        },
      ),
    );
  }

  void _handleBookmark(Character character) {
    setState(() {
      final index = _allCharacters.indexWhere((c) => c.id == character.id);
      if (index != -1) {
        _allCharacters[index] = _allCharacters[index].copyWith(
          isBookmarked: !_allCharacters[index].isBookmarked,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _allCharacters[index].isBookmarked
                  ? 'Added ${character.name} to bookmarks'
                  : 'Removed ${character.name} from bookmarks',
            ),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    });
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

  void _nextCard() {
    if (_currentIndex < _filteredCharacters.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _showNoMoreCardsDialog();
    }
  }

  void _previousCard() {
    if (_currentIndex > 0) {
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
            const Text('Computer Controls'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Keyboard Navigation:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            _buildControlItem('→ / Space', 'Next profile'),
            _buildControlItem('← ', 'Previous profile'),
            _buildControlItem('Enter', 'Bookmark profile'),
            _buildControlItem('N', 'Add/edit note'),
            _buildControlItem('F', 'Open filters'),
            _buildControlItem('H / F1', 'Show this help'),
            const SizedBox(height: 16),
            const Text(
              'Mouse Controls:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            _buildControlItem('Click & Drag', 'Swipe profiles'),
            _buildControlItem('Mouse Wheel', 'Navigate profiles'),
            _buildControlItem('Button Clicks', 'Bookmark/Note'),
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

  void _showNoMoreCardsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('No more profiles'),
        content: const Text(
          'You\'ve seen all profiles that match your current filters. Try adjusting your filters to see more people.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showFilterDialog();
            },
            child: const Text('Adjust Filters'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    var sidePanelWidth = screenWidth * 0.75;

    return Focus(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      autofocus: true,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Discover',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          actions: [
            // Refresh button
            IconButton(
              onPressed: _reloadCharacters,
              icon: const Icon(Icons.refresh),
              tooltip: 'Reload data from file',
            ),
            // Help button
            IconButton(
              onPressed: _showControlsHelp,
              icon: const Icon(Icons.help_outline),
              tooltip: 'Keyboard shortcuts (H)',
            ),
            // Filter button
            IconButton(
              onPressed: _showFilterDialog,
              icon: Stack(
                children: [
                  const Icon(Icons.tune),
                  if (_isFiltersActive())
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
          ),
        ),
        body: _isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Loading profiles...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            : Stack(
                children: [
                  // Main content area
                  Column(
                    children: [
                      // Filter info bar
                      if (_isFiltersActive())
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          color: Colors.blue.shade50,
                          child: Row(
                            children: [
                              Icon(
                                Icons.info,
                                size: 16,
                                color: Colors.blue.shade700,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Showing ${_filteredCharacters.length} profiles with active filters',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _filterOptions = const FilterOptions();
                                  });
                                  _applyFiltersWithAnimation();
                                },
                                child: const Text(
                                  'Clear',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Swipeable area
                      Expanded(
                        child: _filteredCharacters.isEmpty
                            ? _buildEmptyState()
                            : PageView.builder(
                                controller: _pageController,
                                itemCount: _filteredCharacters.length,
                                onPageChanged: (index) {
                                  setState(() => _currentIndex = index);
                                },
                                itemBuilder: (context, index) {
                                  final character = _filteredCharacters[index];
                                  return CharacterCard(
                                    character: character,
                                    onBookmark: () =>
                                        _handleBookmark(character),
                                    onNote: () => _handleNote(character),
                                  );
                                },
                              ),
                      ), // Page Indicator
                      if (_filteredCharacters.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${_currentIndex + 1} of ${_filteredCharacters.length}',
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
                                  widthFactor:
                                      (_currentIndex + 1) /
                                      _filteredCharacters.length,
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

                  SlidingPanel(
                    panelVisible: _panelVisible,
                    onTogglePanel: _togglePanel,
                    screenWidth: MediaQuery.of(context).size.width,
                    sidePanelWidth: sidePanelWidth,
                    routes: routes,
                  ),
                ],
              ),
        floatingActionButton: FloatingActionButton(
          child: AnimatedIcon(
            icon: AnimatedIcons.menu_close,
            progress: AlwaysStoppedAnimation(_panelVisible ? 1 : 0),
          ),
          onPressed: _togglePanel,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No profiles found',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters to see more people',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showFilterDialog,
            icon: const Icon(Icons.tune),
            label: const Text('Adjust Filters'),
          ),
        ],
      ),
    );
  }

  bool _isFiltersActive() {
    return _filterOptions.ageRange != AgeRange.all ||
        _filterOptions.distanceRange != DistanceRange.anywhere ||
        _filterOptions.selectedInterests.isNotEmpty ||
        _filterOptions.showOnlineOnly ||
        !_filterOptions.hideRejected ||
        _filterOptions.sortBy != SortBy.distance;
  }
}
