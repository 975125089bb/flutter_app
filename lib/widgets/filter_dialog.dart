import 'package:flutter/material.dart';
import '../models/filter_options.dart';
import '../services/character_service.dart';
import '../data/characters_data.dart';

class FilterDialog extends StatefulWidget {
  final FilterOptions currentOptions;
  final Function(FilterOptions) onApply;

  const FilterDialog({
    super.key,
    required this.currentOptions,
    required this.onApply,
  });

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  late FilterOptions _options;
  late List<String> _allInterests;

  @override
  void initState() {
    super.initState();
    _options = widget.currentOptions;
    _allInterests = CharacterService.getAllInterests(characters);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filters',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Age Range
                    _buildSectionTitle('Age Range'),
                    _buildAgeRangeSelector(),

                    const SizedBox(height: 20),

                    // Distance
                    _buildSectionTitle('Distance'),
                    _buildDistanceSelector(),

                    const SizedBox(height: 20),

                    // Sort By
                    _buildSectionTitle('Sort By'),
                    _buildSortBySelector(),

                    const SizedBox(height: 20),

                    // Interests
                    _buildSectionTitle('Interests'),
                    _buildInterestsSelector(),

                    const SizedBox(height: 20),

                    // Additional Filters
                    _buildSectionTitle('Additional'),
                    _buildAdditionalFilters(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _options = const FilterOptions();
                      });
                    },
                    child: const Text('Reset'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onApply(_options);
                      Navigator.of(context).pop();
                    },
                    child: const Text('Apply Filters'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    );
  }

  Widget _buildAgeRangeSelector() {
    return Column(
      children: AgeRange.values.map((range) {
        return RadioListTile<AgeRange>(
          title: Text(range.label),
          value: range,
          groupValue: _options.ageRange,
          onChanged: (value) {
            setState(() {
              _options = _options.copyWith(ageRange: value);
            });
          },
          contentPadding: EdgeInsets.zero,
        );
      }).toList(),
    );
  }

  Widget _buildDistanceSelector() {
    return Column(
      children: DistanceRange.values.map((range) {
        return RadioListTile<DistanceRange>(
          title: Text(range.label),
          value: range,
          groupValue: _options.distanceRange,
          onChanged: (value) {
            setState(() {
              _options = _options.copyWith(distanceRange: value);
            });
          },
          contentPadding: EdgeInsets.zero,
        );
      }).toList(),
    );
  }

  Widget _buildSortBySelector() {
    final sortOptions = {
      SortBy.distance: 'Distance',
      SortBy.age: 'Age',
      SortBy.recentActivity: 'Recent Activity',
      SortBy.name: 'Name',
    };

    return Column(
      children: sortOptions.entries.map((entry) {
        return RadioListTile<SortBy>(
          title: Text(entry.value),
          value: entry.key,
          groupValue: _options.sortBy,
          onChanged: (value) {
            setState(() {
              _options = _options.copyWith(sortBy: value);
            });
          },
          contentPadding: EdgeInsets.zero,
        );
      }).toList(),
    );
  }

  Widget _buildInterestsSelector() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      child: SingleChildScrollView(
        child: Wrap(
          spacing: 8,
          runSpacing: 4,
          children: _allInterests.map((interest) {
            final isSelected = _options.selectedInterests.contains(interest);
            return FilterChip(
              label: Text(interest),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  final newInterests = List<String>.from(
                    _options.selectedInterests,
                  );
                  if (selected) {
                    newInterests.add(interest);
                  } else {
                    newInterests.remove(interest);
                  }
                  _options = _options.copyWith(selectedInterests: newInterests);
                });
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildAdditionalFilters() {
    return Column(
      children: [
        SwitchListTile(
          title: const Text('Show online only'),
          value: _options.showOnlineOnly,
          onChanged: (value) {
            setState(() {
              _options = _options.copyWith(showOnlineOnly: value);
            });
          },
          contentPadding: EdgeInsets.zero,
        ),
        SwitchListTile(
          title: const Text('Hide rejected profiles'),
          value: _options.hideRejected,
          onChanged: (value) {
            setState(() {
              _options = _options.copyWith(hideRejected: value);
            });
          },
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }
}
