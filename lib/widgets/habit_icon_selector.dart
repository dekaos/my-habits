import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class HabitIconSelector extends StatelessWidget {
  final String? selectedIcon;
  final ValueChanged<String> onIconSelected;

  const HabitIconSelector({
    required this.selectedIcon,
    required this.onIconSelected,
    super.key,
  });

  static const List<Map<String, dynamic>> iconOptionsData = [
    {'name': 'fitness', 'icon': Icons.fitness_center},
    {'name': 'book', 'icon': Icons.book},
    {'name': 'water', 'icon': Icons.water_drop},
    {'name': 'sleep', 'icon': Icons.bedtime},
    {'name': 'restaurant', 'icon': Icons.restaurant},
    {'name': 'run', 'icon': Icons.directions_run},
    {'name': 'meditation', 'icon': Icons.spa},
    {'name': 'yoga', 'icon': Icons.self_improvement},
    {'name': 'art', 'icon': Icons.palette},
    {'name': 'music', 'icon': Icons.music_note},
    {'name': 'work', 'icon': Icons.work},
    {'name': 'school', 'icon': Icons.school},
    {'name': 'heart', 'icon': Icons.favorite},
    {'name': 'walk', 'icon': Icons.directions_walk},
    {'name': 'bike', 'icon': Icons.directions_bike},
    {'name': 'medication', 'icon': Icons.medication},
  ];

  List<Map<String, dynamic>> _getIconOptions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      {
        'name': 'fitness',
        'icon': Icons.fitness_center,
        'label': l10n.iconFitness
      },
      {'name': 'book', 'icon': Icons.book, 'label': l10n.iconReading},
      {'name': 'water', 'icon': Icons.water_drop, 'label': l10n.iconHydration},
      {'name': 'sleep', 'icon': Icons.bedtime, 'label': l10n.iconSleep},
      {
        'name': 'restaurant',
        'icon': Icons.restaurant,
        'label': l10n.iconEating
      },
      {'name': 'run', 'icon': Icons.directions_run, 'label': l10n.iconRunning},
      {'name': 'meditation', 'icon': Icons.spa, 'label': l10n.iconMeditation},
      {'name': 'yoga', 'icon': Icons.self_improvement, 'label': l10n.iconYoga},
      {'name': 'art', 'icon': Icons.palette, 'label': l10n.iconArt},
      {'name': 'music', 'icon': Icons.music_note, 'label': l10n.iconMusic},
      {'name': 'work', 'icon': Icons.work, 'label': l10n.iconWork},
      {'name': 'school', 'icon': Icons.school, 'label': l10n.iconStudy},
      {'name': 'heart', 'icon': Icons.favorite, 'label': l10n.iconHealth},
      {
        'name': 'walk',
        'icon': Icons.directions_walk,
        'label': l10n.iconWalking
      },
      {
        'name': 'bike',
        'icon': Icons.directions_bike,
        'label': l10n.iconCycling
      },
      {
        'name': 'medication',
        'icon': Icons.medication,
        'label': l10n.iconMedication
      },
    ];
  }

  /// Helper method to get icon data by name
  static IconData? getIconByName(String? name) {
    if (name == null) return null;
    final iconData = iconOptionsData.firstWhere(
      (option) => option['name'] == name,
      orElse: () => {},
    );
    return iconData['icon'] as IconData?;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final iconOptions = _getIconOptions(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.chooseAnIcon,
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
