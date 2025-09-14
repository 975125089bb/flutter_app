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
          SnackBar(content: Text('加载用户数据时出错: $e'), backgroundColor: Colors.red),
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
                Text('数据重新加载成功！'),
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
            content: Text('重新加载用户数据时出错: $e'),
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
    final index = _allCharacters.indexWhere((c) => c.id == character.id);
    setState(() {
      if (index != -1) {
        _allCharacters[index] = _allCharacters[index].copyWith(
          isBookmarked: !_allCharacters[index].isBookmarked,
        );
      }
    });

    CharacterService.saveCharacters(_allCharacters);

    if (index != -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _allCharacters[index].isBookmarked
                ? '已将 ${character.name} 添加到收藏夹'
                : '已将 ${character.name} 从收藏夹移除',
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    }
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
          Expanded(child: Text('${character.name} 的备注')),
        ],
      ),
      content: TextField(
        controller: noteController,
        maxLines: 4,
        decoration: const InputDecoration(
          hintText: '为这个人添加备注...',
          border: OutlineInputBorder(),
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
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
                      ? '已删除 ${character.name} 的备注'
                      : '已保存 ${character.name} 的备注',
                ),
                duration: const Duration(seconds: 1),
              ),
            );
          },
          child: const Text('保存'),
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
            const Text('操作说明'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '键盘导航:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            _buildControlItem('→ / 空格', '下一个资料'),
            _buildControlItem('← ', '上一个资料'),
            _buildControlItem('回车', '收藏资料'),
            _buildControlItem('N', '添加/编辑备注'),
            _buildControlItem('F', '打开筛选'),
            _buildControlItem('H / F1', '显示帮助'),
            const SizedBox(height: 16),
            const Text(
              '鼠标操作:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            _buildControlItem('点击拖拽', '滑动资料'),
            _buildControlItem('鼠标滚轮', '导航资料'),
            _buildControlItem('按钮点击', '收藏/备注'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('明白了！'),
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
        title: const Text('没有更多资料了'),
        content: const Text('您已查看了符合当前筛选条件的所有资料。尝试调整筛选条件以查看更多人的资料。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showFilterDialog();
            },
            child: const Text('调整筛选'),
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
            '发现',
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
              tooltip: '重新加载数据',
            ),
            // Help button
            IconButton(
              onPressed: _showControlsHelp,
              icon: const Icon(Icons.help_outline),
              tooltip: '键盘快捷键 (H)',
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
                                  '清除',
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
          onPressed: _togglePanel,
          child: AnimatedIcon(
            icon: AnimatedIcons.menu_close,
            progress: AlwaysStoppedAnimation(_panelVisible ? 1 : 0),
          ),
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
            '未找到匹配的资料',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            '尝试调整筛选条件以查看更多人的资料',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showFilterDialog,
            icon: const Icon(Icons.tune),
            label: const Text('调整筛选'),
          ),
        ],
      ),
    );
  }

  bool _isFiltersActive() {
    return _filterOptions.ageRange != AgeRange.all ||
        _filterOptions.selectedInterests.isNotEmpty ||
        _filterOptions.showOnlineOnly ||
        !_filterOptions.hideRejected ||
        _filterOptions.sortBy != SortBy.random;
  }
}
