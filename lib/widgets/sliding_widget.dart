import 'package:flutter/material.dart';

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
          duration: Duration(milliseconds: 500),
          curve: Curves.easeOutQuart,
          left: panelVisible ? 0 : -screenWidth,
          top: 0,
          bottom: 0,
          width: sidePanelWidth,
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
                            onTogglePanel();
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
    );
  }
}
