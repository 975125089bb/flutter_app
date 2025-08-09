import 'package:flutter/material.dart';
import '../data/character.dart';

class StatsWidget extends StatelessWidget {
  final List<Character> allCharacters;
  final List<Character> filteredCharacters;

  const StatsWidget({
    super.key,
    required this.allCharacters,
    required this.filteredCharacters,
  });

  @override
  Widget build(BuildContext context) {
    final matches = allCharacters.where((c) => c.isMatched).length;
    final bookmarks = allCharacters.where((c) => c.isBookmarked).length;
    final likes = allCharacters.where((c) => c.isLiked).length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.pink.shade50,
            Colors.purple.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.pink.shade100,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat(
            icon: Icons.favorite,
            label: 'Matches',
            value: matches.toString(),
            color: Colors.red,
          ),
          _buildStat(
            icon: Icons.bookmark,
            label: 'Saved',
            value: bookmarks.toString(),
            color: Colors.orange,
          ),
          _buildStat(
            icon: Icons.thumb_up,
            label: 'Likes',
            value: likes.toString(),
            color: Colors.green,
          ),
          _buildStat(
            icon: Icons.people,
            label: 'Profiles',
            value: filteredCharacters.length.toString(),
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
