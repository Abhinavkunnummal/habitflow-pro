import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: HabitFlowProApp(),
    ),
  );
}

class HabitFlowProApp extends StatelessWidget {
  const HabitFlowProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HabitFlow Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5D3ADC),
          primary: const Color(0xFF5D3ADC),
          secondary: const Color(0xFF006C4B),
          tertiary: const Color(0xFF844D2A),
          surface: const Color(0xFFFCF8FF),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFFCF8FF),
      ),
      home: const CloudBuildVerificationScreen(),
    );
  }
}

class CloudBuildVerificationScreen extends ConsumerStatefulWidget {
  const CloudBuildVerificationScreen({super.key});

  @override
  ConsumerState<CloudBuildVerificationScreen> createState() =>
      _CloudBuildVerificationScreenState();
}

class _CloudBuildVerificationScreenState
    extends ConsumerState<CloudBuildVerificationScreen> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'HabitFlow Pro',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF5D3ADC),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFCF8FF), Color(0xFFEFE8F6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: const Color(0xFF5D3ADC),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF5D3ADC).withOpacity(0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.bolt_rounded,
                    size: 48,
                    color: Color(0xFF79FAC2),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'HabitFlow Pro',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF131317),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Phase 2: Cloud APK Build Verified Successfully!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF006C4B),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE6DEFF)),
                  ),
                  child: Column(
                    children: [
                      const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle, color: Color(0xFF006C4B), size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Built via GitHub Actions Cloud Runner',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Riverpod state & Material 3 initialized.\nTaps: $_counter',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _counter++;
                    });
                  },
                  icon: const Icon(Icons.touch_app),
                  label: const Text('Test Physical Tap Interaction'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5D3ADC),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9999),
                    ),
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
