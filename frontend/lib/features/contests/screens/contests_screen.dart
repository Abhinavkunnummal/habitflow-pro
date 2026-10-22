import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/components/aurora_card.dart';
import '../../../core/components/habit_button.dart';
import '../../../core/components/habit_text_field.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../models/contest_model.dart';
import '../providers/contests_provider.dart';

class ContestsScreen extends ConsumerStatefulWidget {
  const ContestsScreen({super.key});

  @override
  ConsumerState<ContestsScreen> createState() => _ContestsScreenState();
}

class _ContestsScreenState extends ConsumerState<ContestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showCreateContestDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    String selectedCategory = 'all';
    int durationDays = 14;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.emoji_events_rounded, color: AppColors.streakFire),
              SizedBox(width: 8),
              Text('Create Contest'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Launch a challenge to compete with friends and track consistency.',
                  style: TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 16),
                HabitTextField(
                  controller: titleController,
                  label: 'Contest Title',
                  hintText: 'e.g. 14-Day Focus Sprint',
                ),
                const SizedBox(height: 12),
                HabitTextField(
                  controller: descController,
                  label: 'Description & Rules',
                  hintText: 'e.g. Complete 2+ habits daily to win',
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                const Text('Category:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  children: ['all', 'wellness', 'productivity', 'fitness', 'mindfulness'].map((cat) {
                    final isSel = selectedCategory == cat;
                    return ChoiceChip(
                      label: Text(cat.toUpperCase()),
                      selected: isSel,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSel ? Colors.white : AppColors.textPrimary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (_) => setDialogState(() => selectedCategory = cat),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                const Text('Duration:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                Row(
                  children: [7, 14, 30].map((d) {
                    final isSel = durationDays == d;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: Text('$d Days'),
                        selected: isSel,
                        onSelected: (_) => setDialogState(() => durationDays = d),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final title = titleController.text.trim();
                final desc = descController.text.trim();
                if (title.isNotEmpty) {
                  ref.read(contestsProvider.notifier).createContest(
                        title: title,
                        description: desc.isEmpty ? 'Compete for consistency' : desc,
                        category: selectedCategory,
                        durationDays: durationDays,
                      );
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Contest "$title" launched!')),
                  );
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(contestsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Community Contests',
          style: AppTypography.headline(
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh Leaderboard',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.read(contestsProvider.notifier).loadContestsAndLeaderboard(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(icon: Icon(Icons.emoji_events_rounded, size: 20), text: 'Active Contests'),
            Tab(icon: Icon(Icons.leaderboard_rounded, size: 20), text: 'Leaderboard'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildContestsTab(isDark, state),
          _buildLeaderboardTab(isDark, state),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Create Contest'),
        onPressed: _showCreateContestDialog,
      ),
    );
  }

  Widget _buildContestsTab(bool isDark, ContestsState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.contests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emoji_events_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 12),
            const Text('No active contests right now.'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _showCreateContestDialog,
              child: const Text('Launch First Contest'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: state.contests.length,
      itemBuilder: (context, index) {
        final contest = state.contests[index];
        return _buildContestCard(isDark, contest);
      },
    );
  }

  Widget _buildContestCard(bool isDark, ContestModel contest) {
    Color accentColor = AppColors.primary;
    if (contest.bannerGradient == 'amber') accentColor = AppColors.streakFire;
    if (contest.bannerGradient == 'emerald') accentColor = AppColors.secondary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: AuroraCard(
        hasAuroraBorder: true,
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Category Badge & Days Left
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(9999),
                    border: Border.all(color: accentColor.withOpacity(0.25)),
                  ),
                  child: Text(
                    contest.category.toUpperCase(),
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.timer_outlined, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${contest.daysRemaining} days left',
                      style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Title & Description
            Text(
              contest.title,
              style: AppTypography.titleLarge(
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ).copyWith(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              contest.description,
              style: AppTypography.bodyMedium(
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ).copyWith(fontSize: 13),
            ),
            const SizedBox(height: 14),

            // Reward & Competitors Row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceContainer : AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.military_tech_rounded, size: 18, color: AppColors.streakFire),
                      const SizedBox(width: 6),
                      Text(
                        contest.rewardBadge,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  Text(
                    '+${contest.xpReward} XP',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Footer Action: Joined Status or Join CTA
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.group_outlined, size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      '${contest.participantCount} competitors',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                if (contest.isJoined)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle_rounded, size: 14, color: AppColors.secondary),
                        SizedBox(width: 4),
                        Text(
                          'Competing',
                          style: TextStyle(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  FilledButton.tonal(
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    onPressed: () {
                      ref.read(contestsProvider.notifier).joinContest(contest.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Joined "${contest.title}"!')),
                      );
                    },
                    child: const Text('Join Challenge'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardTab(bool isDark, ContestsState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final leaderboard = state.leaderboard;
    if (leaderboard.isEmpty) {
      return const Center(child: Text('No leaderboard data yet.'));
    }

    final top3 = leaderboard.take(3).toList();
    final remaining = leaderboard.skip(3).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      children: [
        // Podium Header for Top 3
        if (top3.length >= 3) _buildPodium(isDark, top3),
        const SizedBox(height: 20),

        // Section Title
        Text(
          'COMMUNITY RANKINGS',
          style: AppTypography.labelMedium(
            color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
          ).copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.8),
        ),
        const SizedBox(height: 8),

        // Rest of the participants
        ...remaining.map((user) => _buildLeaderboardTile(isDark, user)),

        const SizedBox(height: 12),
        Center(
          child: Text(
            'Rankings sync live from MongoDB Atlas as habits are logged.',
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPodium(bool isDark, List<GlobalLeaderboardUser> top3) {
    final first = top3[0];
    final second = top3.length > 1 ? top3[1] : null;
    final third = top3.length > 2 ? top3[2] : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceContainer : AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text(
            '🏆 Leaderboard Champions',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (second != null) _buildPodiumCol(isDark, second, 2, 70, Colors.grey.shade400, '🥈'),
              _buildPodiumCol(isDark, first, 1, 95, const Color(0xFFFFD700), '🥇'),
              if (third != null) _buildPodiumCol(isDark, third, 3, 55, const Color(0xFFCD7F32), '🥉'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumCol(
    bool isDark,
    GlobalLeaderboardUser user,
    int rank,
    double height,
    Color medalColor,
    String medalEmoji,
  ) {
    return Column(
      children: [
        Text(medalEmoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 4),
        CircleAvatar(
          radius: rank == 1 ? 26 : 22,
          backgroundColor: medalColor.withOpacity(0.3),
          child: Text(
            user.name.split(' ').first.substring(0, 1),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          user.name.split(' ').first,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        Text(
          '${user.xp} XP',
          style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          width: 70,
          height: height,
          decoration: BoxDecoration(
            color: medalColor.withOpacity(0.2),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            border: Border.all(color: medalColor.withOpacity(0.5)),
          ),
          child: Center(
            child: Text(
              '#$rank',
              style: TextStyle(fontWeight: FontWeight.w900, color: medalColor, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardTile(bool isDark, GlobalLeaderboardUser user) {
    final isMe = user.isCurrentUser;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isMe
            ? AppColors.primary.withOpacity(0.12)
            : (isDark ? AppColors.darkSurfaceContainer : AppColors.surfaceContainerLow),
        borderRadius: BorderRadius.circular(14),
        border: isMe ? Border.all(color: AppColors.primary, width: 1.5) : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '#${user.rank}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isMe ? AppColors.primary : Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 18,
            backgroundColor: isDark ? AppColors.darkSurfaceContainerHigh : AppColors.surfaceContainerHigh,
            child: Text(
              user.name.isNotEmpty ? user.name[0] : 'U',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.name,
                        style: TextStyle(
                          fontWeight: isMe ? FontWeight.bold : FontWeight.w600,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'YOU',
                          style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  'Lvl ${user.level} • ${user.currentStreak} day streak 🔥',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          Text(
            '${user.xp} XP',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
