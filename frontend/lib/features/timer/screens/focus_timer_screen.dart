import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/components/aurora_card.dart';
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
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Focus Session Done! 🎉', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Great discipline. +50 XP and 25 minutes logged towards your daily target.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/celebration');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondaryFixed,
              foregroundColor: AppColors.secondary,
            ),
            child: const Text('Collect Reward'),
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
