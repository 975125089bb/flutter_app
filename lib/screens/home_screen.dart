import 'package:date_app/constants/routes.dart';
import 'package:date_app/widgets/character_card.dart';
import 'package:date_app/widgets/page_indicator.dart';
import 'package:date_app/widgets/sliding_widget.dart';
import 'package:flutter/material.dart';
import '../data/character.dart';
import '../data/characters_data.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  bool _panelVisible = false;
  double _panelPosition =
      -0.7; // Starts hidden (0 = fully visible, -0.7 = hidden)

  void _togglePanel() {
    setState(() {
      _panelVisible = !_panelVisible;
      _panelPosition = _panelVisible ? 0 : -0.7;
    });
  }

  void _addCharacter() {
    setState(() {
      characters.add(
        Character(
          id: "id",
          name: "name",
          description: "description",
          imageUrl: "imageUrl",
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    var sidePanelWidth = screenWidth * 0.3;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Date app'),
        backgroundColor: Colors.green,
      ),
      body: Stack(
        children: [
          // Main content area
          Column(
            children: [
              // Swipeable area
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: characters.length,
                  onPageChanged: (index) {
                    setState(() => _currentIndex = index);
                  },
                  itemBuilder: (context, index) {
                    final character = characters[index];
                    return CharacterCard(character: character);
                  },
                ),
              ),

              // Page Indicator
              PageIndicator(currentIndex: _currentIndex),
            ],
          ),

          // Overlay Elements
          // Backdrop Dimming (only when panel is open)
          if (_panelVisible)
            GestureDetector(
              onTap: _togglePanel,
              child: Container(color: Colors.black54),
            ),

          // Left-Side Sliding Panel
          SlidingPanel(
            panelVisible: _panelVisible,
            onTogglePanel: _togglePanel,
            screenWidth: MediaQuery.of(context).size.width,
            sidePanelWidth: sidePanelWidth, // or whatever width you prefer
            routes: routes, // your routes list
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
    );
  }
}
