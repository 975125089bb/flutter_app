import 'package:flutter/material.dart';
import '../models/filter_options.dart';

class FilterDialog extends StatefulWidget {
  final FilterOptions currentOptions;
  final Function(FilterOptions) onApply;
  final List<String> allInterests;

  const FilterDialog({
    super.key,
    required this.currentOptions,
    required this.onApply,
    required this.allInterests,
  });

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  late FilterOptions _options;

  @override
  void initState() {
    super.initState();
    _options = widget.currentOptions;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxHeight: 700, maxWidth: 450),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Advanced Filters',
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

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Age Range
                    _buildSectionTitle('Age Range'),
                    _buildAgeRangeSelector(),

                    const SizedBox(height: 20),

                    // Height Range
                    _buildSectionTitle('Height Range'),
                    _buildHeightRangeSelector(),

                    const SizedBox(height: 20),

                    // BMI Range
                    _buildSectionTitle('BMI Range'),
                    _buildBMIRangeSelector(),

                    const SizedBox(height: 20),

                    // Distance
                    _buildSectionTitle('Distance'),
                    _buildDistanceSelector(),

                    const SizedBox(height: 20),

                    // Property Requirements
                    _buildSectionTitle('Property & Assets'),
                    _buildPropertyRequirements(),

                    const SizedBox(height: 20),

                    // Marital Status
                    _buildSectionTitle('Marital Status'),
                    _buildMaritalStatusSelector(),

                    const SizedBox(height: 20),

                    // Education Level
                    _buildSectionTitle('Education Level'),
                    _buildEducationSelector(),

                    const SizedBox(height: 20),

                    // Sort By
                    _buildSectionTitle('Sort By'),
                    _buildSortBySelector(),

                    const SizedBox(height: 20),

                    // Interests
                    _buildSectionTitle('Interests'),
                    _buildInterestsSelector(),

                    const SizedBox(height: 20),

                    // Other Options
                    _buildSectionTitle('Other Options'),
                    _buildOtherOptions(),
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
                    onPressed: _resetFilters,
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
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildAgeRangeSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: AgeRange.values.map((range) {
        return ChoiceChip(
          label: Text(range.label),
          selected: _options.ageRange == range,
          onSelected: (selected) {
            if (selected) {
              setState(() {
                _options = _options.copyWith(ageRange: range);
              });
            }
          },
        );
      }).toList(),
    );
  }

  Widget _buildHeightRangeSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: HeightRange.values.map((range) {
        return ChoiceChip(
          label: Text(range.label),
          selected: _options.heightRange == range,
          onSelected: (selected) {
            if (selected) {
              setState(() {
                _options = _options.copyWith(heightRange: range);
              });
            }
          },
        );
      }).toList(),
    );
  }

  Widget _buildBMIRangeSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: BMIRange.values.map((range) {
        return ChoiceChip(
          label: Text(range.label),
          selected: _options.bmiRange == range,
          onSelected: (selected) {
            if (selected) {
              setState(() {
                _options = _options.copyWith(bmiRange: range);
              });
            }
          },
        );
      }).toList(),
    );
  }

  Widget _buildDistanceSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: DistanceRange.values.map((range) {
        return ChoiceChip(
          label: Text(range.label),
          selected: _options.distanceRange == range,
          onSelected: (selected) {
            if (selected) {
              setState(() {
                _options = _options.copyWith(distanceRange: range);
              });
            }
          },
        );
      }).toList(),
    );
  }

  Widget _buildPropertyRequirements() {
    return Column(
      children: [
        CheckboxListTile(
          title: const Text('Must own house'),
          subtitle: const Text('Only show profiles with house ownership'),
          value: _options.requireHouse,
          onChanged: (value) {
            setState(() {
              _options = _options.copyWith(requireHouse: value);
            });
          },
          contentPadding: EdgeInsets.zero,
        ),
        CheckboxListTile(
          title: const Text('Must own car'),
          subtitle: const Text('Only show profiles with car ownership'),
          value: _options.requireCar,
          onChanged: (value) {
            setState(() {
              _options = _options.copyWith(requireCar: value);
            });
          },
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildMaritalStatusSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: MaritalStatusFilter.values.map((status) {
        return ChoiceChip(
          label: Text(status.label),
          selected: _options.maritalStatus == status,
          onSelected: (selected) {
            if (selected) {
              setState(() {
                _options = _options.copyWith(maritalStatus: status);
              });
            }
          },
        );
      }).toList(),
    );
  }

  Widget _buildEducationSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: EducationFilter.values.map((education) {
        return ChoiceChip(
          label: Text(education.label),
          selected: _options.education == education,
          onSelected: (selected) {
            if (selected) {
              setState(() {
                _options = _options.copyWith(education: education);
              });
            }
          },
        );
      }).toList(),
    );
  }

  Widget _buildSortBySelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: SortBy.values.map((sort) {
        String label;
        switch (sort) {
          case SortBy.distance:
            label = 'Distance';
            break;
          case SortBy.age:
            label = 'Age';
            break;
          case SortBy.name:
            label = 'Name';
            break;
          case SortBy.height:
            label = 'Height';
            break;
        }
        return ChoiceChip(
          label: Text(label),
          selected: _options.sortBy == sort,
          onSelected: (selected) {
            if (selected) {
              setState(() {
                _options = _options.copyWith(sortBy: sort);
              });
            }
          },
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
          children: widget.allInterests.map((interest) {
            return FilterChip(
              label: Text(interest),
              selected: _options.selectedInterests.contains(interest),
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

  Widget _buildOtherOptions() {
    return CheckboxListTile(
      title: const Text('Hide rejected profiles'),
      subtitle: const Text('Don\'t show profiles you\'ve already rejected'),
      value: _options.hideRejected,
      onChanged: (value) {
        setState(() {
          _options = _options.copyWith(hideRejected: value);
        });
      },
      contentPadding: EdgeInsets.zero,
    );
  }

  void _resetFilters() {
    setState(() {
      _options = const FilterOptions();
    });
  }
}
