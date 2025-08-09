import 'package:date_app/constants/routes.dart';
import 'package:date_app/widgets/character_card.dart';
import 'package:date_app/widgets/sliding_widget.dart';
import 'package:date_app/widgets/filter_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import '../data/character.dart';
import '../data/characters_data.dart';
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
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _applyFilters();

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
        case LogicalKeyboardKey.arrowUp:
          _handleLike(_filteredCharacters[_currentIndex]);
          return KeyEventResult.handled;
        case LogicalKeyboardKey.arrowDown:
          _handleReject(_filteredCharacters[_currentIndex]);
          return KeyEventResult.handled;
        case LogicalKeyboardKey.enter:
          _handleBookmark(_filteredCharacters[_currentIndex]);
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

  void _applyFilters() {
    setState(() {
      _filteredCharacters = CharacterService.filterAndSort(
        characters,
        _filterOptions,
      );
      _currentIndex = 0;
    });
  }

  void _applyFiltersWithAnimation() {
    setState(() {
      _filteredCharacters = CharacterService.filterAndSort(
        characters,
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
    showDialog(
      context: context,
      builder: (context) => FilterDialog(
        currentOptions: _filterOptions,
        onApply: (newOptions) {
          setState(() {
            _filterOptions = newOptions;
          });
          _applyFiltersWithAnimation();
        },
      ),
    );
  }

  void _handleLike(Character character) {
    setState(() {
      final index = characters.indexWhere((c) => c.id == character.id);
      if (index != -1) {
        characters[index] = characters[index].copyWith(isLiked: true);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You liked ${character.name}!'),
            duration: const Duration(seconds: 1),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
    _nextCard();
  }

  void _handleReject(Character character) {
    setState(() {
      final index = characters.indexWhere((c) => c.id == character.id);
      if (index != -1) {
        characters[index] = characters[index].copyWith(isRejected: true);
      }
    });
    _nextCard();
  }

  void _handleBookmark(Character character) {
    setState(() {
      final index = characters.indexWhere((c) => c.id == character.id);
      if (index != -1) {
        characters[index] = characters[index].copyWith(
          isBookmarked: !characters[index].isBookmarked,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              characters[index].isBookmarked
                  ? 'Added ${character.name} to bookmarks'
                  : 'Removed ${character.name} from bookmarks',
            ),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    });
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
            _buildControlItem('↑ ', 'Like profile'),
            _buildControlItem('↓ ', 'Reject profile'),
            _buildControlItem('Enter', 'Bookmark profile'),
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
            _buildControlItem('Button Clicks', 'Like/Reject/Chat'),
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
        body: Stack(
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
                        Icon(Icons.info, size: 16, color: Colors.blue.shade700),
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
                      : Listener(
                          onPointerSignal: (pointerSignal) {
                            if (pointerSignal is PointerScrollEvent) {
                              if (pointerSignal.scrollDelta.dy > 0) {
                                // Scroll down = next card
                                _nextCard();
                              } else if (pointerSignal.scrollDelta.dy < 0) {
                                // Scroll up = previous card
                                _previousCard();
                              }
                            }
                          },
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: _filteredCharacters.length,
                            onPageChanged: (index) {
                              setState(() => _currentIndex = index);
                            },
                            itemBuilder: (context, index) {
                              final character = _filteredCharacters[index];
                              return CharacterCard(
                                character: character,
                                onLike: () => _handleLike(character),
                                onReject: () => _handleReject(character),
                                onBookmark: () => _handleBookmark(character),
                              );
                            },
                          ),
                        ),
                ),

                // Page Indicator
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
