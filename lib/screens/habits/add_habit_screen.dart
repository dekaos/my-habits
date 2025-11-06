import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../providers/auth_provider.dart';
import '../../providers/habit_provider.dart';
import '../../models/habit.dart';
import '../../widgets/animated_gradient_background.dart';
import '../../widgets/glass_card.dart';

class AddHabitScreen extends ConsumerStatefulWidget {
  const AddHabitScreen({super.key});

  @override
  ConsumerState<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends ConsumerState<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isSaving = false;

  HabitFrequency _frequency = HabitFrequency.daily;
  final List<int> _customDays = [];
  String _selectedColor = '#6366F1';
  String? _selectedIcon;
  bool _isPublic = false;
  final int _targetCount = 1;

  final List<String> _colorOptions = [
    '#6366F1', // Indigo
    '#EF4444', // Red
    '#10B981', // Green
    '#F59E0B', // Amber
    '#8B5CF6', // Purple
    '#EC4899', // Pink
    '#06B6D4', // Cyan
    '#F97316', // Orange
  ];

  final List<IconData> _iconOptions = [
    Icons.fitness_center,
    Icons.book,
    Icons.water_drop,
    Icons.bedtime,
    Icons.restaurant,
    Icons.directions_run,
    Icons.spa,
    Icons.self_improvement,
    Icons.brush,
    Icons.music_note,
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveHabit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    final authState = ref.read(authProvider);

    if (authState.user == null) {
      setState(() {
        _isSaving = false;
      });
      return;
    }

    final habit = Habit(
      id: const Uuid().v4(),
      userId: authState.user!.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      color: _selectedColor,
      icon: _selectedIcon,
      frequency: _frequency,
      customDays: _customDays,
      targetCount: _targetCount,
      createdAt: DateTime.now(),
      isPublic: _isPublic,
    );

    await ref.read(habitProvider.notifier).addHabit(habit);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('New Habit'),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _saveHabit,
              child: const Text('Save'),
            ),
        ],
      ),
      body: AnimatedGradientBackground(
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Title
                GlassCard(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  enableGlow: false,
                  child: TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Habit Title',
                      hintText: 'e.g., Morning Exercise',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a habit title';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Description
                GlassCard(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  enableGlow: false,
                  child: TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description (optional)',
                      hintText: 'Add more details...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
                const SizedBox(height: 16),

                // Icon selection
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Choose an Icon',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _iconOptions.map((icon) {
                          final isSelected =
                              _selectedIcon == icon.codePoint.toString();
                          return InkWell(
                            onTap: () {
                              setState(() {
                                _selectedIcon = icon.codePoint.toString();
                              });
                            },
                            child: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Theme.of(context)
                                        .colorScheme
                                        .primaryContainer
                                    : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(12),
                                border: isSelected
                                    ? Border.all(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        width: 2,
                                      )
                                    : null,
                              ),
                              child: Icon(
                                icon,
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey.shade600,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Color selection
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Choose a Color',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _colorOptions.map((color) {
                          final isSelected = _selectedColor == color;
                          return InkWell(
                            onTap: () {
                              setState(() {
                                _selectedColor = color;
                              });
                            },
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Color(
                                    int.parse(color.substring(1), radix: 16) +
                                        0xFF000000),
                                shape: BoxShape.circle,
                                border: isSelected
                                    ? Border.all(color: Colors.black, width: 3)
                                    : null,
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check, color: Colors.white)
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Frequency
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Frequency',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 16),
                      SegmentedButton<HabitFrequency>(
                        segments: const [
                          ButtonSegment(
                            value: HabitFrequency.daily,
                            label: Text('Daily'),
                            icon: Icon(Icons.calendar_today),
                          ),
                          ButtonSegment(
                            value: HabitFrequency.weekly,
                            label: Text('Weekly'),
                            icon: Icon(Icons.calendar_view_week),
                          ),
                          ButtonSegment(
                            value: HabitFrequency.custom,
                            label: Text('Custom'),
                            icon: Icon(Icons.edit_calendar),
                          ),
                        ],
                        selected: {_frequency},
                        onSelectionChanged: (Set<HabitFrequency> newSelection) {
                          setState(() {
                            _frequency = newSelection.first;
                          });
                        },
                      ),
                    ],
                  ),
                ),

                // Custom days selector
                if (_frequency == HabitFrequency.custom) ...[
                  const SizedBox(height: 16),
                  GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Wrap(
                      spacing: 8,
                      children: List.generate(7, (index) {
                        final days = [
                          'Mon',
                          'Tue',
                          'Wed',
                          'Thu',
                          'Fri',
                          'Sat',
                          'Sun'
                        ];
                        final isSelected = _customDays.contains(index);
                        return FilterChip(
                          label: Text(days[index]),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _customDays.add(index);
                              } else {
                                _customDays.remove(index);
                              }
                            });
                          },
                        );
                      }),
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Public toggle
                GlassCard(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  enableGlow: false,
                  child: SwitchListTile(
                    title: Text(
                      'Share with friends',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    subtitle: Text(
                      'Let your friends see your progress',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    value: _isPublic,
                    onChanged: (value) {
                      setState(() {
                        _isPublic = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
