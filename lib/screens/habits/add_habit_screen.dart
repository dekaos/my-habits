import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../providers/auth_provider.dart';
import '../../providers/habit_provider.dart';
import '../../models/habit.dart';
import '../../l10n/app_localizations.dart';
import '../../services/notification_service.dart';
import '../../widgets/animated_gradient_background.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/habit_icon_selector.dart';

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
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n.notificationScheduledTomorrow(
                    _selectedTime!.format(context)),
              ),
              duration: const Duration(seconds: 4),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
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
      scheduledTime: scheduledTime,
    );

    await ref.read(habitProvider.notifier).addHabit(habit);

    if (habit.scheduledTime != null) {
      try {
        final notificationService = NotificationService();
        await notificationService.initialize();

        final permissionGranted =
            await notificationService.requestPermissions();

        if (permissionGranted) {
          await notificationService.scheduleHabitNotification(habit);
        } else if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.notificationPermissionsDenied),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } catch (e) {
        // Silently fail - notification scheduling is optional
      }
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(l10n.newHabit),
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
              child: Text(l10n.save),
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
                    decoration: InputDecoration(
                      labelText: l10n.habitTitle,
                      hintText: l10n.habitTitlePlaceholder,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.pleaseEnterHabitTitle;
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
                    decoration: InputDecoration(
                      labelText: l10n.descriptionOptional,
                      hintText: l10n.descriptionPlaceholder,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
                const SizedBox(height: 16),

                // Icon selection
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  enableGlow: false,
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
                  enableGlow: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.chooseColor,
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
                  enableGlow: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.frequency,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: SegmentedButton<HabitFrequency>(
                          segments: [
                            ButtonSegment(
                              value: HabitFrequency.daily,
                              label: Text(l10n.daily),
                              icon: const Icon(Icons.calendar_today),
                            ),
                            ButtonSegment(
                              value: HabitFrequency.custom,
                              label: Text(l10n.custom),
                              icon: const Icon(Icons.edit_calendar),
                            ),
                          ],
                          selected: {_frequency},
                          onSelectionChanged:
                              (Set<HabitFrequency> newSelection) {
                            setState(() {
                              _frequency = newSelection.first;
                            });
                          },
                        ),
                      )
                    ],
                  ),
                ),

                // Custom days selector
                if (_frequency == HabitFrequency.custom) ...[
                  const SizedBox(height: 16),
                  GlassCard(
                    padding: const EdgeInsets.all(20),
                    enableGlow: false,
                    child: Wrap(
                      spacing: 8,
                      children: List.generate(7, (index) {
                        final days = [
                          l10n.mon,
                          l10n.tue,
                          l10n.wed,
                          l10n.thu,
                          l10n.fri,
                          l10n.sat,
                          l10n.sun
                        ];
                        final isSelected = _customDays.contains(index);
                        return FilterChip(
                          label: Text(days[index]),
                          selected: isSelected,
                          showCheckmark: false,
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
                  enableGlow: false,
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
                                l10n.scheduledTimeOptional,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.optional,
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
                              icon:
                                  const Icon(Icons.clear, color: Colors.white),
                              onPressed: () {
                                setState(() {
                                  _selectedTime = null;
                                });
                              },
                              tooltip: l10n.clearTime,
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
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white.withValues(alpha: 0.05)
                                    : Colors.white.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _selectedTime != null
                                  ? Theme.of(context).colorScheme.primary
                                  : (Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white.withValues(alpha: 0.2)
                                      : Colors.grey.withValues(alpha: 0.3)),
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
                                        : Colors.white,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    _selectedTime != null
                                        ? _selectedTime!.format(context)
                                        : l10n.selectTime,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: _selectedTime != null
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                      color: _selectedTime != null
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                          : Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const Icon(
                                Icons.arrow_drop_down,
                                color: Colors.white,
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
                      l10n.shareWithFriends,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    subtitle: Text(
                      l10n.letFriendsSeeProgress,
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
