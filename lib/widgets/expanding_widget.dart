import 'package:flutter/material.dart';

class ExpandingFab extends StatefulWidget {
  @override
  _ExpandingFabState createState() => _ExpandingFabState();
}

class _ExpandingFabState extends State<ExpandingFab>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _translateAnimation;
  final List<Widget> _actionButtons = [
    FloatingActionButton(onPressed: () {}, child: Icon(Icons.share)),
    FloatingActionButton(onPressed: () {}, child: Icon(Icons.favorite)),
    FloatingActionButton(onPressed: () {}, child: Icon(Icons.email)),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    _translateAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        ..._buildExpandedActions(),
        FloatingActionButton(
          onPressed: _toggleExpansion,
          child: AnimatedIcon(
            icon: AnimatedIcons.menu_close,
            progress: _controller,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildExpandedActions() {
    return _actionButtons.asMap().entries.map((entry) {
      int index = entry.key;
      Widget button = entry.value;

      return Positioned(
        right: 16,
        bottom: 16 + (index + 1) * 70 * _translateAnimation.value,
        child: Opacity(opacity: _translateAnimation.value, child: button),
      );
    }).toList();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      _isExpanded ? _controller.forward() : _controller.reverse();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
