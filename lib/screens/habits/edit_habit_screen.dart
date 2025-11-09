import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/habit_provider.dart';
import '../../models/habit.dart';
import '../../services/notification_service.dart';
import '../../widgets/animated_gradient_background.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/habit_icon_selector.dart';

class EditHabitScreen extends ConsumerStatefulWidget {
  final Habit habit;

  const EditHabitScreen({required this.habit, super.key});

  @override
  ConsumerState<EditHabitScreen> createState() => _EditHabitScreenState();
}

class _EditHabitScreenState extends ConsumerState<EditHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  bool _isSaving = false;

  late HabitFrequency _frequency;
  late List<int> _customDays;
  late String _selectedColor;
  String? _selectedIcon;
  late bool _isPublic;
  TimeOfDay? _selectedTime;

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

  @override
  void initState() {
    super.initState();
    // Initialize with existing habit data
    _titleController = TextEditingController(text: widget.habit.title);
    _descriptionController =
        TextEditingController(text: widget.habit.description ?? '');
    _frequency = widget.habit.frequency;
    _customDays = List.from(widget.habit.customDays);
    _selectedColor = widget.habit.color;
    _selectedIcon = widget.habit.icon;
    _isPublic = widget.habit.isPublic;

    // Convert DateTime to TimeOfDay if scheduled time exists
    if (widget.habit.scheduledTime != null) {
      final time = widget.habit.scheduledTime!;
      _selectedTime = TimeOfDay(hour: time.hour, minute: time.minute);
    }
  }

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

    // Convert TimeOfDay to DateTime if selected
    DateTime? scheduledTime;
    if (_selectedTime != null) {
      final now = DateTime.now();
      var tempTime = DateTime(
        now.year,
        now.month,
        now.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      // If the time has already passed today, schedule for tomorrow
      if (tempTime.isBefore(now)) {
        tempTime = tempTime.add(const Duration(days: 1));
      }

      scheduledTime = tempTime;

      // Check if notification time (30 min before) is also valid
      final notificationTime =
          scheduledTime.subtract(const Duration(minutes: 30));
      if (notificationTime.isBefore(now)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Note: Notification scheduled for tomorrow at ${_selectedTime!.format(context)}',
              ),
              duration: const Duration(seconds: 4),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    }

    // Create updated habit with new data
    final updatedHabit = widget.habit.copyWith(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      color: _selectedColor,
      icon: _selectedIcon,
      frequency: _frequency,
      customDays: _customDays,
      isPublic: _isPublic,
    );

    // Handle scheduled time separately since copyWith might not support nullable updates properly
    final habitWithTime = Habit(
      id: updatedHabit.id,
      userId: updatedHabit.userId,
      title: updatedHabit.title,
      description: updatedHabit.description,
      color: updatedHabit.color,
      icon: updatedHabit.icon,
      frequency: updatedHabit.frequency,
      customDays: updatedHabit.customDays,
      targetCount: updatedHabit.targetCount,
      createdAt: updatedHabit.createdAt,
      isPublic: updatedHabit.isPublic,
      scheduledTime: scheduledTime,
      accountabilityPartners: updatedHabit.accountabilityPartners,
      currentStreak: updatedHabit.currentStreak,
      longestStreak: updatedHabit.longestStreak,
      lastCompletedDate: updatedHabit.lastCompletedDate,
      totalCompletions: updatedHabit.totalCompletions,
    );

    // Update in database (this will also handle notification rescheduling)
    await ref.read(habitProvider.notifier).updateHabit(habitWithTime);

    // If scheduled time was removed (was set before, now null), cancel notification
    if (widget.habit.scheduledTime != null && scheduledTime == null) {
      try {
        await NotificationService().cancelHabitNotification(widget.habit.id);
      } catch (e) {
        // Silently fail - notification cancellation is optional
      }
    }

    if (mounted) {
      Navigator.of(context).pop(true); // Return true to indicate success
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
        title: const Text('Edit Habit'),
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
                  child: HabitIconSelector(
                    selectedIcon: _selectedIcon,
                    onIconSelected: (iconName) {
                      setState(() {
                        _selectedIcon = iconName;
                      });
                    },
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

                // Frequency (Read-only warning if changing would cause issues)
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
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.orange.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 20,
                              color: Colors.orange.shade700,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Changing frequency will reset your streak and completion history.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange.shade700,
                                ),
                              ),
                            ),
                          ],
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
                            // Clear custom days if switching away from custom
                            if (_frequency != HabitFrequency.custom) {
                              _customDays.clear();
                            }
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

                // Time picker
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Scheduled Time',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Optional',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Colors.grey.shade600,
                                    ),
                              ),
                            ],
                          ),
                          if (_selectedTime != null)
                            IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _selectedTime = null;
                                });
                              },
                              tooltip: 'Clear time',
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () async {
                          final TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: _selectedTime ?? TimeOfDay.now(),
                          );
                          if (picked != null) {
                            setState(() {
                              _selectedTime = picked;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _selectedTime != null
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey.shade300,
                              width: _selectedTime != null ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    color: _selectedTime != null
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    _selectedTime != null
                                        ? _selectedTime!.format(context)
                                        : 'Select time',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: _selectedTime != null
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                      color: _selectedTime != null
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                          : Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              Icon(
                                Icons.arrow_drop_down,
                                color: Colors.grey.shade600,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

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
