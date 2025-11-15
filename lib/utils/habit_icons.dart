import 'package:flutter/material.dart';

/// Predefined habit icons map for tree-shaking support
/// All IconData instances are compile-time constants
class HabitIcons {
  // Private constructor to prevent instantiation
  HabitIcons._();

  /// Map of icon names to IconData constants
  /// This allows tree-shaking to work properly
  static const Map<String, IconData> icons = {
    // Health & Fitness
    'fitness': Icons.fitness_center,
    'run': Icons.directions_run,
    'walk': Icons.directions_walk,
    'bike': Icons.directions_bike,
    'yoga': Icons.self_improvement,
    'meditation': Icons.spa,
    'sleep': Icons.bedtime,
    'water': Icons.water_drop,
    'heart': Icons.favorite,
    'health': Icons.health_and_safety,
    'medication': Icons.medication,

    // Food & Nutrition
    'restaurant': Icons.restaurant,
    'food': Icons.fastfood,
    'apple': Icons.apple,
    'coffee': Icons.coffee,
    'local_cafe': Icons.local_cafe,

    // Productivity
    'work': Icons.work,
    'book': Icons.book,
    'school': Icons.school,
    'code': Icons.code,
    'create': Icons.create,
    'edit': Icons.edit_note,
    'check': Icons.check_circle,
    'task': Icons.task_alt,
    'calendar': Icons.calendar_today,
    'timer': Icons.timer,

    // Lifestyle
    'home': Icons.home,
    'clean': Icons.cleaning_services,
    'music': Icons.music_note,
    'photo': Icons.photo_camera,
    'art': Icons.palette,
    'game': Icons.sports_esports,
    'movie': Icons.movie,
    'language': Icons.language,
    'travel': Icons.flight,

    // Social & Communication
    'people': Icons.people,
    'family': Icons.family_restroom,
    'chat': Icons.chat,
    'phone': Icons.phone,
    'email': Icons.email,

    // Nature & Environment
    'eco': Icons.eco,
    'nature': Icons.nature,
    'park': Icons.park,
    'pets': Icons.pets,
    'flower': Icons.local_florist,

    // Finance
    'money': Icons.attach_money,
    'savings': Icons.savings,
    'shopping': Icons.shopping_cart,

    // Mental & Emotional
    'mood': Icons.mood,
    'psychology': Icons.psychology,
    'lightbulb': Icons.lightbulb,
    'celebration': Icons.celebration,

    // Default
    'star': Icons.star,
    'trending': Icons.trending_up,
    'flag': Icons.flag,
    'bolt': Icons.bolt,
  };

  /// Get icon by name, returns star icon if not found
  static IconData getIcon(String? iconName) {
    if (iconName == null || iconName.isEmpty) {
      return Icons.star;
    }
    return icons[iconName] ?? Icons.star;
  }

  /// Get icon name from IconData (for reverse lookup)
  static String? getIconName(IconData iconData) {
    for (final entry in icons.entries) {
      if (entry.value.codePoint == iconData.codePoint) {
        return entry.key;
      }
    }
    return null;
  }

  /// Get all available icon names
  static List<String> get availableIcons => icons.keys.toList();

  /// Check if an icon name exists
  static bool hasIcon(String iconName) => icons.containsKey(iconName);
}
