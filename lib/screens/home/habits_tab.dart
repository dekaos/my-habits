import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/habit_provider.dart';
import '../../models/habit.dart';
import '../habits/add_habit_screen.dart';
import '../habits/habit_detail_screen.dart';
import '../../widgets/slidable_habit_card.dart';
import '../../widgets/glass_card.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/habit_icons.dart';

class HabitsTab extends ConsumerStatefulWidget {
  const HabitsTab({super.key});

  @override
  ConsumerState<HabitsTab> createState() => _HabitsTabState();
}

class _HabitsTabState extends ConsumerState<HabitsTab> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final habitState = ref.watch(habitProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: GlassAppBar(
          title: l10n.myHabits,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (authState.user != null) {
            await ref
                .read(habitProvider.notifier)
                .loadHabits(authState.user!.id);
          }
        },
        child: habitState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : habitState.habits.isEmpty
                ? _buildEmptyState(context)
                : _buildHabitsList(context, ref, habitState),
      ),
      floatingActionButton: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context)!;
          return Padding(
            padding: const EdgeInsets.only(bottom: 80),
            child: GlassButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AddHabitScreen(),
                  ),
                );
              },
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    l10n.newHabit,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: GlassCard(
        padding: const EdgeInsets.all(40),
        enableGlow: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.1),
                ),
                child: Icon(
                  Icons.trending_up,
                  size: 60,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.beginYourJourney,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.everyGreatJourney,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '🌱',
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.smallStepsBigChanges,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[500],
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitsList(
      BuildContext context, WidgetRef ref, HabitState habitState) {
    final l10n = AppLocalizations.of(context)!;
    final habitNotifier = ref.read(habitProvider.notifier);
    final todaysHabits = habitNotifier.getTodaysHabits();
    final otherHabits =
        habitState.habits.where((h) => !todaysHabits.contains(h)).toList();

    final completed =
        todaysHabits.where(habitNotifier.isHabitCompletedToday).length;

    final todaysGrouped = habitNotifier.getTodaysHabitsByCategory();
    final todaysCategories =
        habitNotifier.getCategoriesOrderedByStreak(todaysGrouped);

    final otherGrouped = habitNotifier.groupHabitsByCategory(otherHabits);
    final otherCategories =
        habitNotifier.getCategoriesOrderedByStreak(otherGrouped);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildProgressCard(
          context,
          ref,
          todaysHabits,
          key: ValueKey('progress-$completed-${todaysHabits.length}'),
        ),
        const SizedBox(height: 20),

        if (todaysHabits.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Row(
              children: [
                Icon(
                  Icons.wb_sunny_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.todaysJourney,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: .15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    l10n.habitCount(todaysHabits.length),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ..._buildCategorizedHabits(
            context,
            ref,
            todaysGrouped,
            todaysCategories,
            0,
          ),
          const SizedBox(height: 16),
        ],

        // Other habits by category
        if (otherHabits.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_month_outlined,
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: .7),
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.allHabits,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ..._buildCategorizedHabits(
            context,
            ref,
            otherGrouped,
            otherCategories,
            todaysHabits.length,
          ),
        ],

        const SizedBox(height: 100),
      ],
    );
  }

  List<Widget> _buildCategorizedHabits(
    BuildContext context,
    WidgetRef ref,
    Map<String, List<Habit>> grouped,
    List<String> categories,
    int startIndex,
  ) {
    final widgets = <Widget>[];
    int habitIndex = startIndex;

    for (final category in categories) {
      final categoryHabits = grouped[category]!;

      widgets.add(
        Padding(
          padding: const EdgeInsets.only(left: 4, right: 4, top: 8, bottom: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  HabitIcons.getIcon(category),
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                _getCategoryName(context, category),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: .8),
                      letterSpacing: -0.2,
                    ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: .3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

      // Category habits
      for (final habit in categoryHabits) {
        widgets.add(
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 600 + (habitIndex * 100)),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: child,
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SlidableHabitCard(
                key: ValueKey(
                    '${habit.id}-${habit.totalCompletions}-${habit.lastCompletedDate}'),
                habit: habit,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => HabitDetailScreen(habit: habit),
                    ),
                  );
                },
              ),
            ),
          ),
        );
        habitIndex++;
      }

      widgets.add(const SizedBox(height: 8));
    }

    return widgets;
  }

  String _getCategoryName(BuildContext context, String iconName) {
    final l10n = AppLocalizations.of(context)!;

    switch (iconName) {
      case 'fitness':
        return l10n.iconFitness;
      case 'book':
        return l10n.iconReading;
      case 'water':
        return l10n.iconHydration;
      case 'sleep':
        return l10n.iconSleep;
      case 'restaurant':
        return l10n.iconEating;
      case 'run':
        return l10n.iconRunning;
      case 'meditation':
        return l10n.iconMeditation;
      case 'yoga':
        return l10n.iconYoga;
      case 'art':
        return l10n.iconArt;
      case 'music':
        return l10n.iconMusic;
      case 'work':
        return l10n.iconWork;
      case 'school':
        return l10n.iconStudy;
      case 'heart':
        return l10n.iconHealth;
      case 'walk':
        return l10n.iconWalking;
      case 'bike':
        return l10n.iconCycling;
      case 'medication':
        return l10n.iconMedication;
      case 'other':
      default:
        return l10n.categoryOther;
    }
  }

  Widget _buildProgressCard(
    BuildContext context,
    WidgetRef ref,
    List<Habit> todaysHabits, {
    Key? key,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final habitNotifier = ref.read(habitProvider.notifier);
    final completed =
        todaysHabits.where(habitNotifier.isHabitCompletedToday).length;
    final total = todaysHabits.length;
    final progress = total > 0 ? completed / total : 0.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      key: key,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      child: GlassCard(
        padding: const EdgeInsets.all(24),
        enableGlow: false,
        color: isDark
            ? Theme.of(context).colorScheme.primary.withValues(alpha: .15)
            : Theme.of(context)
                .colorScheme
                .primaryContainer
                .withValues(alpha: .3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('💫', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text(
                      l10n.yourProgressToday,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.3,
                          ),
                    ),
                  ],
                ),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: child,
                    );
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: .2),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: .3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(
                          scale: animation,
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        );
                      },
                      child: Text(
                        '$completed / $total',
                        key: ValueKey('$completed-$total'),
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: progress),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOutCubic,
              builder: (context, animatedProgress, child) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Stack(
                    children: [
                      Container(
                        height: 10,
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: .1)
                              : Colors.black.withValues(alpha: .1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: animatedProgress,
                        child: Container(
                          height: 10,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: .7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: .5),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.3),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: Row(
                key: ValueKey(
                    '$progress-${total > 0 ? progress == 1.0 ? "perfect" : progress >= 0.5 ? "great" : "start" : "empty"}'),
                children: [
                  Text(
                    total > 0
                        ? progress == 1.0
                            ? '🎉'
                            : progress >= 0.5
                                ? '💪'
                                : '🌱'
                        : '📅',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      total > 0
                          ? progress == 1.0
                              ? l10n.perfectDay
                              : progress >= 0.5
                                  ? l10n.greatMomentum
                                  : l10n.everyStepCounts
                          : l10n.readyToBuildHabits,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
