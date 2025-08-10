import 'package:date_app/data/character.dart';
import 'package:flutter/material.dart';

class CharacterCard extends StatelessWidget {
  final Character character;
  final VoidCallback? onBookmark;
  final VoidCallback? onNote;

  const CharacterCard({
    super.key,
    required this.character,
    this.onBookmark,
    this.onNote,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        elevation: 8,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          children: [
            // Main profile image
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: character.imageUrl != null
                          ? DecorationImage(
                              image: NetworkImage(character.imageUrl!),
                              fit: BoxFit.cover,
                              onError: (error, stackTrace) {},
                            )
                          : null,
                      gradient: character.imageUrl == null
                          ? LinearGradient(
                              colors: [
                                Colors.blue.shade300,
                                Colors.purple.shade300,
                              ],
                            )
                          : null,
                    ),
                    child: character.imageUrl == null
                        ? Center(
                            child: Icon(
                              Icons.person,
                              size: 80,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),

                  // Bookmark button
                  Positioned(
                    top: 16,
                    left: 16,
                    child: IconButton(
                      onPressed: onBookmark,
                      icon: Icon(
                        character.isBookmarked
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                        color: Colors.white,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black26,
                        shape: const CircleBorder(),
                      ),
                    ),
                  ),

                  // Note button
                  Positioned(
                    top: 16,
                    left: 64, // Position next to bookmark button
                    child: IconButton(
                      onPressed: onNote,
                      icon: Icon(
                        character.note.isNotEmpty ? Icons.note : Icons.note_add,
                        color: Colors.white,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black26,
                        shape: const CircleBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Profile information
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name, age, and distance
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${character.name}, ${character.age}',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${character.distanceKm.toStringAsFixed(1)} km',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Location and profession
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            character.location,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Icon(Icons.work, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          character.profession,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Description
                    Expanded(
                      child: Text(
                        character.description,
                        style: const TextStyle(fontSize: 14),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Interests
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: character.interests.take(4).map((interest) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).primaryColor.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            interest,
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
