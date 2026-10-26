import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/components/aurora_card.dart';
import '../../../core/components/tree_growth_animation.dart';
import '../../../core/services/audio_feedback_service.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class FocusTimerScreen extends StatefulWidget {
  const FocusTimerScreen({super.key});

  @override
  State<FocusTimerScreen> createState() => _FocusTimerScreenState();
}

class _FocusTimerScreenState extends State<FocusTimerScreen>
    with WidgetsBindingObserver {
  int _initialSeconds = 25 * 60;
  int _remainingSeconds = 25 * 60;
  bool _isRunning = false;
  Timer? _timer;
  String _selectedSoundscape = 'Forest Breeze';
  bool _retentionCheckEnabled = true;
  int _secondsSinceLastCheck = 0;
  LocalStorage? _storage;
  bool _isInitialized = false;

  final List<int> _presetMinutes = [15, 25, 30, 45, 60];
  final List<({String name, IconData icon})> _soundscapes = [
    (name: 'Forest Breeze', icon: Icons.forest_rounded),
    (name: 'Gentle Rain', icon: Icons.water_drop_rounded),
    (name: 'Lo-fi Beats', icon: Icons.headphones_rounded),
    (name: 'Ocean Waves', icon: Icons.waves_rounded),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initStorageAndRestoreState();
  }

  Future<void> _initStorageAndRestoreState() async {
    _storage = await LocalStorage.create();
    final saved = _storage?.getFocusTimerState();

    if (saved != null && saved.remainingSeconds > 0) {
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      final elapsedSec = (nowMs - saved.timestamp) ~/ 1000;

      setState(() {
        _initialSeconds = saved.initialSeconds;
        if (saved.isRunning) {
          final adjusted = saved.remainingSeconds - elapsedSec;
          if (adjusted <= 0) {
            _remainingSeconds = 0;
            _isRunning = false;
            _storage?.clearFocusTimerState();
            _isInitialized = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              AudioFeedbackService.playTimerAlarm();
              _showSessionCompleteModal();
            });
            return;
          } else {
            _remainingSeconds = adjusted;
            _isRunning = true;
            _startTimerTicker();
          }
        } else {
          // Paused state preserved exactly (e.g. at 23 minutes remaining)
          _remainingSeconds = saved.remainingSeconds;
          _isRunning = false;
        }
        _isInitialized = true;
      });
    } else {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _persistCurrentTimerState();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _persistCurrentTimerState();
    super.dispose();
  }

  void _persistCurrentTimerState() {
    if (_storage == null) return;
    if (_remainingSeconds > 0 && _remainingSeconds < _initialSeconds) {
      _storage?.saveFocusTimerState(
        initialSeconds: _initialSeconds,
        remainingSeconds: _remainingSeconds,
        isRunning: _isRunning,
      );
    } else if (_remainingSeconds <= 0) {
      _storage?.clearFocusTimerState();
    }
  }

  void _startTimerTicker() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
          _secondsSinceLastCheck++;
        });

        // Save state to disk every 5 seconds
        if (_remainingSeconds % 5 == 0) {
          _persistCurrentTimerState();
        }

        // Periodic Focus Retention Check-In (Every 10 minutes = 600 seconds)
        if (_retentionCheckEnabled &&
            _secondsSinceLastCheck >= 600 &&
            _remainingSeconds > 60) {
          _timer?.cancel();
          setState(() {
            _isRunning = false;
            _secondsSinceLastCheck = 0;
          });
          _persistCurrentTimerState();
          _showFocusRetentionCheckInModal();
        }
      } else {
        _timer?.cancel();
        setState(() => _isRunning = false);
        _storage?.clearFocusTimerState();
        // Record focus minutes into learning analytics
        final completedMins = _initialSeconds ~/ 60;
        _storage?.recordFocusSession(completedMins);
        AudioFeedbackService.playTimerAlarm();
        _showSessionCompleteModal();
      }
    });
  }

  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() => _isRunning = false);
      _persistCurrentTimerState();
    } else {
      setState(() => _isRunning = true);
      _persistCurrentTimerState();
      _startTimerTicker();
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _remainingSeconds = _initialSeconds;
      _secondsSinceLastCheck = 0;
    });
    _storage?.clearFocusTimerState();
  }

  void _setPreset(int minutes) {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _initialSeconds = minutes * 60;
      _remainingSeconds = minutes * 60;
      _secondsSinceLastCheck = 0;
    });
    _storage?.clearFocusTimerState();
  }

  void _showFocusRetentionCheckInModal() {
    String selectedChoice = '🎯 Deeply immersed & making progress';
    final choices = [
      '🎯 Deeply immersed & making progress',
      '📚 Reviewing notes & solving problems',
      '🧘 Quick breath taken, ready for next sprint',
    ];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.darkSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.psychology_rounded, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Focus Retention Check',
                  style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '10 unbroken minutes completed! Confirm you are retaining focus on your core task:',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 16),
              ...choices.map((c) {
                final isSelected = selectedChoice == c;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => setDialogState(() => selectedChoice = c),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withOpacity(0.2)
                            : AppColors.darkSurfaceContainer,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                            color: isSelected ? AppColors.primary : Colors.white38,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              c,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.white70,
                                fontSize: 12.5,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _resetTimer();
              },
              child: const Text('End Session', style: TextStyle(color: Colors.white54)),
            ),
            FilledButton.icon(
              icon: const Icon(Icons.play_arrow_rounded, size: 18),
              label: const Text('Verify & Resume Flow'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                AudioFeedbackService.playTaskComplete();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Focus verified! +15 Focus Momentum points 🎯'),
                    duration: Duration(seconds: 2),
                  ),
                );
                setState(() => _isRunning = true);
                _persistCurrentTimerState();
                _startTimerTicker();
              },
            ),
          ],
        ),
      ),
    );
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
              child: const Icon(Icons.celebration_rounded, color: AppColors.secondaryFixed, size: 26),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Deep Work Completed! 🌸',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 6),
            // Fully Bloomed Majestic Tree Animation
            const Center(
              child: TreeGrowthAnimation(
                progress: 1.0,
                size: 150,
                isCompleted: true,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Unbroken flow session logged. +50 XP and consistency recorded.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 13.5),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.darkSurfaceContainer,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.secondaryFixed.withOpacity(0.25)),
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
    if (!_isInitialized) {
      return const Scaffold(
        backgroundColor: AppColors.darkBackground,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final progress = _initialSeconds > 0
        ? ((_initialSeconds - _remainingSeconds) / _initialSeconds).clamp(0.0, 1.0)
        : 0.0;

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
        actions: [
          IconButton(
            tooltip: _retentionCheckEnabled ? 'Disable Focus Check-Ins' : 'Enable Focus Check-Ins',
            icon: Icon(
              _retentionCheckEnabled ? Icons.psychology_rounded : Icons.psychology_outlined,
              color: _retentionCheckEnabled ? AppColors.secondaryFixed : Colors.white38,
            ),
            onPressed: () {
              setState(() => _retentionCheckEnabled = !_retentionCheckEnabled);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_retentionCheckEnabled
                      ? 'Periodic 10m Focus Check-Ins Enabled 🧠'
                      : 'Focus Check-Ins Paused'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Column(
            children: [
              // Presets
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _presetMinutes.map((mins) {
                  final isSelected = _initialSeconds == mins * 60;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3.0),
                    child: ChoiceChip(
                      label: Text('${mins}m'),
                      selected: isSelected,
                      selectedColor: AppColors.primaryContainer,
                      backgroundColor: AppColors.darkSurfaceContainer,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5,
                      ),
                      shape: const StadiumBorder(),
                      onSelected: (_) => _setPreset(mins),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Animated Focus Tree Growing Component
              TreeGrowthAnimation(
                progress: progress,
                size: 150,
                isCompleted: _remainingSeconds == 0,
              ),
              const SizedBox(height: 12),

              // Circular Countdown Timer Indicator
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: CircularProgressIndicator(
                      value: 1.0 - progress,
                      strokeWidth: 10,
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
                          fontSize: 44,
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
              const SizedBox(height: 20),

              // Ambient Soundscapes
              AuroraCard(
                backgroundColor: AppColors.darkSurface,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Ambient Soundscape',
                          style: AppTypography.labelMedium(color: Colors.white70),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.check_circle_outline, size: 14, color: AppColors.secondaryFixed),
                            const SizedBox(width: 4),
                            Text(
                              _retentionCheckEnabled ? '10m Check-ins Active' : 'Check-ins Off',
                              style: const TextStyle(fontSize: 10, color: AppColors.secondaryFixed),
                            ),
                          ],
                        ),
                      ],
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
              const SizedBox(height: 20),

              // Control Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    tooltip: 'Reset Session',
                    onPressed: _resetTimer,
                    icon: const Icon(Icons.refresh_rounded, color: Colors.white70, size: 28),
                  ),
                  const SizedBox(width: 24),
                  GestureDetector(
                    onTap: _toggleTimer,
                    child: Container(
                      width: 68,
                      height: 68,
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
                        size: 36,
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  IconButton(
                    tooltip: 'Quick Complete Flow',
                    onPressed: () {
                      _storage?.clearFocusTimerState();
                      _storage?.recordFocusSession(_initialSeconds ~/ 60);
                      context.go('/celebration');
                    },
                    icon: const Icon(Icons.skip_next_rounded, color: Colors.white70, size: 28),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
