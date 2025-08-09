import 'package:flutter/material.dart';
import '../screens/bookmarks_screen.dart';

class SlidingPanel extends StatelessWidget {
  final bool panelVisible;
  final VoidCallback onTogglePanel;
  final double screenWidth;
  final double sidePanelWidth;
  final List<Map<String, dynamic>> routes;

  const SlidingPanel({
    Key? key,
    required this.panelVisible,
    required this.onTogglePanel,
    required this.screenWidth,
    required this.sidePanelWidth,
    required this.routes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Backdrop Dimming (only when panel is open)
        if (panelVisible)
          GestureDetector(
            onTap: onTogglePanel,
            child: Container(color: Colors.black54),
          ),

        // Left-Side Sliding Panel
        AnimatedPositioned(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutQuart,
          left: panelVisible ? 0 : -screenWidth,
          top: 0,
          bottom: 0,
          width: sidePanelWidth,
          child: Material(
            elevation: 4,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Panel Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.pink.shade400, Colors.purple.shade400],
                      ),
                    ),
                    child: SafeArea(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.person,
                              size: 30,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Dating App",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Find your perfect match",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Route Buttons
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(8),
                      children: routes
                          .map(
                            (route) => _buildMenuItem(
                              context,
                              route["name"],
                              route["icon"],
                              route["color"],
                              route["route"],
                            ),
                          )
                          .toList(),
                    ),
                  ),

                  // App version
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    String? route,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () {
          onTogglePanel();
          _handleNavigation(context, route, title);
        },
      ),
    );
  }

  void _handleNavigation(BuildContext context, String? route, String title) {
    switch (route) {
      case '/bookmarks':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const BookmarksScreen()),
        );
        break;
      case '/profile':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile screen coming soon!'),
            duration: Duration(seconds: 2),
          ),
        );
        break;
      case '/settings':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings screen coming soon!'),
            duration: Duration(seconds: 2),
          ),
        );
        break;
      case '/':
        // Already on home screen
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$title screen not implemented yet'),
            duration: const Duration(seconds: 2),
          ),
        );
    }
  }
}
