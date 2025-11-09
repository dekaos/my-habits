import 'package:flutter/material.dart';

class HabitIconSelector extends StatelessWidget {
  final String? selectedIcon;
  final ValueChanged<String> onIconSelected;

  const HabitIconSelector({
    required this.selectedIcon,
    required this.onIconSelected,
    super.key,
  });

  static const List<Map<String, dynamic>> iconOptions = [
    {'name': 'fitness', 'icon': Icons.fitness_center, 'label': 'Fitness'},
    {'name': 'book', 'icon': Icons.book, 'label': 'Reading'},
    {'name': 'water', 'icon': Icons.water_drop, 'label': 'Hydration'},
    {'name': 'sleep', 'icon': Icons.bedtime, 'label': 'Sleep'},
    {'name': 'restaurant', 'icon': Icons.restaurant, 'label': 'Eating'},
    {'name': 'run', 'icon': Icons.directions_run, 'label': 'Running'},
    {'name': 'meditation', 'icon': Icons.spa, 'label': 'Meditation'},
    {'name': 'yoga', 'icon': Icons.self_improvement, 'label': 'Yoga'},
    {'name': 'art', 'icon': Icons.palette, 'label': 'Art'},
    {'name': 'music', 'icon': Icons.music_note, 'label': 'Music'},
    {'name': 'work', 'icon': Icons.work, 'label': 'Work'},
    {'name': 'school', 'icon': Icons.school, 'label': 'Study'},
    {'name': 'heart', 'icon': Icons.favorite, 'label': 'Health'},
    {'name': 'walk', 'icon': Icons.directions_walk, 'label': 'Walking'},
    {'name': 'bike', 'icon': Icons.directions_bike, 'label': 'Cycling'},
  ];

  /// Helper method to get icon data by name
  static IconData? getIconByName(String? name) {
    if (name == null) return null;
    final iconData = iconOptions.firstWhere(
      (option) => option['name'] == name,
      orElse: () => {},
    );
    return iconData['icon'] as IconData?;
  }

  /// Helper method to get label by name
  static String? getLabelByName(String? name) {
    if (name == null) return null;
    final iconData = iconOptions.firstWhere(
      (option) => option['name'] == name,
      orElse: () => {},
    );
    return iconData['label'] as String?;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose an Icon',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: iconOptions.map((iconData) {
            final iconName = iconData['name'] as String;
            final icon = iconData['icon'] as IconData;
            final label = iconData['label'] as String;
            final isSelected = selectedIcon == iconName;

            return InkWell(
              onTap: () => onIconSelected(iconName),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 72,
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 4,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected
                      ? Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        )
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 28,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.shade600,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey.shade700,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
