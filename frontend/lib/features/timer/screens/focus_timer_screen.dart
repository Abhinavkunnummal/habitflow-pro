import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/components/aurora_card.dart';
import '../../../core/services/audio_feedback_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class FocusTimerScreen extends StatefulWidget {
  const FocusTimerScreen({super.key});

  @override
  State<FocusTimerScreen> createState() => _FocusTimerScreenState();
}

class _FocusTimerScreenState extends State<FocusTimerScreen> {
  int _initialSeconds = 25 * 60;
  int _remainingSeconds = 25 * 60;
  bool _isRunning = false;
  Timer? _timer;
  String _selectedSoundscape = 'Forest Breeze';

  final List<int> _presetMinutes = [15, 25, 45, 60];
  final List<({String name, IconData icon})> _soundscapes = [
    (name: 'Forest Breeze', icon: Icons.forest_rounded),
    (name: 'Gentle Rain', icon: Icons.water_drop_rounded),
    (name: 'Lo-fi Beats', icon: Icons.headphones_rounded),
    (name: 'Ocean Waves', icon: Icons.waves_rounded),
  ];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() => _isRunning = false);
    } else {
      setState(() => _isRunning = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remainingSeconds > 0) {
          setState(() => _remainingSeconds--);
        } else {
          _timer?.cancel();
          setState(() => _isRunning = false);
          AudioFeedbackService.playTimerAlarm();
          _showSessionCompleteModal();
        }
      });
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _remainingSeconds = _initialSeconds;
    });
  }

  void _setPreset(int minutes) {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _initialSeconds = minutes * 60;
      _remainingSeconds = minutes * 60;
    });
  }

  void _showSessionCompleteModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.secondaryFixed.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.notifications_active_rounded, color: AppColors.secondaryFixed, size: 24),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Session Complete! 🔔',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Unbroken flow session logged. +50 XP and consistency recorded.',
              style: TextStyle(color: Colors.white70, fontSize: 13.5),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.darkSurfaceContainer,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.secondaryFixed.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.alarm_rounded, color: AppColors.secondaryFixed, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Scheduled Next Step Reminder',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Rest your eyes for 5 minutes before your next deep work sprint.',
                    style: TextStyle(color: Colors.white60, fontSize: 11.5),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () {
                      AudioFeedbackService.playReminderChime();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('5-minute rest reminder scheduled! ☕')),
                      );
                      Navigator.pop(context);
                      _setPreset(5);
                      _toggleTimer();
                    },
                    icon: const Icon(Icons.snooze_rounded, size: 16, color: AppColors.secondaryFixed),
                    label: const Text('Start 5m Break Reminder', style: TextStyle(color: AppColors.secondaryFixed, fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.secondaryFixed.withOpacity(0.5)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Dismiss', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/celebration');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondaryFixed,
              foregroundColor: AppColors.secondary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Collect +50 XP Reward', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_initialSeconds - _remainingSeconds) / _initialSeconds;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => context.go('/today'),
        ),
        title: Text(
          'Focus Session',
          style: AppTypography.headline(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            children: [
              // Presets
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _presetMinutes.map((mins) {
                  final isSelected = _initialSeconds == mins * 60;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Text('${mins}m'),
                      selected: isSelected,
                      selectedColor: AppColors.primaryContainer,
                      backgroundColor: AppColors.darkSurfaceContainer,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: const StadiumBorder(),
                      onSelected: (_) => _setPreset(mins),
                    ),
                  );
                }).toList(),
              ),
              const Spacer(),

              // Circular Countdown Timer
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 230,
                    height: 230,
                    child: CircularProgressIndicator(
                      value: 1.0 - progress,
                      strokeWidth: 12,
                      backgroundColor: AppColors.darkSurfaceContainerHigh,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.secondaryFixed,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(_remainingSeconds),
                        style: AppTypography.displayLarge(color: Colors.white).copyWith(
                          fontSize: 48,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isRunning ? 'FLOW ACTIVE' : 'PAUSED',
                        style: AppTypography.labelMedium(
                          color: _isRunning
                              ? AppColors.secondaryFixed
                              : Colors.white54,
                        ).copyWith(
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),

              // Ambient Soundscapes
              AuroraCard(
                backgroundColor: AppColors.darkSurface,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ambient Soundscape',
                      style: AppTypography.labelMedium(color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 38,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _soundscapes.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final item = _soundscapes[index];
                          final isSelected = _selectedSoundscape == item.name;

                          return ChoiceChip(
                            avatar: Icon(
                              item.icon,
                              size: 16,
                              color: isSelected
                                  ? AppColors.secondary
                                  : Colors.white60,
                            ),
                            label: Text(item.name),
                            selected: isSelected,
                            selectedColor: AppColors.secondaryFixed,
                            backgroundColor: AppColors.darkSurfaceContainer,
                            labelStyle: TextStyle(
                              fontSize: 12,
                              color: isSelected ? AppColors.secondary : Colors.white70,
                              fontWeight: FontWeight.w600,
                            ),
                            shape: const StadiumBorder(),
                            onSelected: (_) {
                              setState(() => _selectedSoundscape = item.name);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Control Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: _resetTimer,
                    icon: const Icon(Icons.refresh_rounded, color: Colors.white70, size: 30),
                  ),
                  const SizedBox(width: 24),
                  GestureDetector(
                    onTap: _toggleTimer,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryContainer],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryContainer.withOpacity(0.5),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Icon(
                        _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 38,
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  IconButton(
                    onPressed: () => context.go('/celebration'),
                    icon: const Icon(Icons.skip_next_rounded, color: Colors.white70, size: 30),
                  ),
                ],
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}
