import 'package:flutter/material.dart';
import '../character.dart';
import '../characters_data.dart';

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

  final List<Map<String, dynamic>> routes = [
    {"name": "Home", "icon": Icons.home, "color": Colors.blue},
    {"name": "Profile", "icon": Icons.person, "color": Colors.green},
    {"name": "Settings", "icon": Icons.settings, "color": Colors.orange},
  ];

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
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    characters.length,
                    (i) => Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentIndex == i ? Colors.blue : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
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
          AnimatedPositioned(
            duration: Duration(milliseconds: 500),
            curve: Curves.easeOutQuart,
            left: _panelVisible ? 0 : -screenWidth * 0.7,
            top: 0,
            bottom: 0,
            width: screenWidth * 0.7,
            child: Material(
              elevation: 4,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    // Panel Header
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        "Menu",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Divider(),
                    // Route Buttons
                    ...routes
                        .map(
                          (route) => ListTile(
                            leading: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: route["color"].withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(route["icon"], color: route["color"]),
                            ),
                            title: Text(route["name"]),
                            onTap: () {
                              _togglePanel();
                              // Add navigation logic here
                            },
                          ),
                        )
                        .toList(),
                  ],
                ),
              ),
            ),
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

class CharacterCard extends StatelessWidget {
  final Character character;

  const CharacterCard({super.key, required this.character});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Image.network(character.imageUrl, height: 200),
            // const SizedBox(height: 16),
            Text(
              character.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(character.description, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
