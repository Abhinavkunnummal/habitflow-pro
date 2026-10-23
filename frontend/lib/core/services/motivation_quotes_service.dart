import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class MotivationQuote {
  final String quote;
  final String author;
  final String tip;
  final IconData icon;
  final Color accentColor;

  const MotivationQuote({
    required this.quote,
    required this.author,
    required this.tip,
    required this.icon,
    required this.accentColor,
  });
}

class MotivationQuotesService {
  MotivationQuotesService._();

  static final Random _random = Random();

  static const List<MotivationQuote> quotes = [
    MotivationQuote(
      quote: "Success isn't always about greatness. It's about consistency. Consistent hard work leads to success.",
      author: "Dwayne Johnson",
      tip: "Study Hack: Use the 25-minute Pomodoro method to beat procrastination and build momentum.",
      icon: Icons.timer_outlined,
      accentColor: AppColors.secondaryFixed,
    ),
    MotivationQuote(
      quote: "You do not rise to the level of your goals. You fall to the level of your systems.",
      author: "James Clear, Atomic Habits",
      tip: "Study Hack: Focus on opening your textbook or code editor for just 2 minutes every single day.",
      icon: Icons.psychology_rounded,
      accentColor: AppColors.primaryContainer,
    ),
    MotivationQuote(
      quote: "Deep work is the ability to focus without distraction on a cognitively demanding task.",
      author: "Cal Newport",
      tip: "Study Hack: Put your phone in another room during 50-minute study sprints to double retention.",
      icon: Icons.bolt_rounded,
      accentColor: Color(0xFFFFD54F),
    ),
    MotivationQuote(
      quote: "Small disciplines repeated with consistency every day lead to great achievements gained slowly over time.",
      author: "John C. Maxwell",
      tip: "Study Hack: Teach the concept out loud to an imaginary listener (Feynman Technique).",
      icon: Icons.menu_book_rounded,
      accentColor: Color(0xFF3898EC),
    ),
    MotivationQuote(
      quote: "The secret of getting ahead is getting started. Break complex tasks into small manageable steps.",
      author: "Mark Twain",
      tip: "Study Hack: Active recall testing produces 50% higher exam retention than passive re-reading.",
      icon: Icons.auto_awesome_rounded,
      accentColor: AppColors.streakFire,
    ),
    MotivationQuote(
      quote: "We are what we repeatedly do. Excellence, then, is not an act, but a habit.",
      author: "Will Durant",
      tip: "Study Hack: Anchor difficult studying immediately after your morning cup of coffee or tea.",
      icon: Icons.track_changes_rounded,
      accentColor: AppColors.secondaryFixed,
    ),
    MotivationQuote(
      quote: "It always seems impossible until it is done.",
      author: "Nelson Mandela",
      tip: "Study Hack: Write down your single most important study task the night before.",
      icon: Icons.emoji_events_rounded,
      accentColor: Color(0xFFFFD700),
    ),
    MotivationQuote(
      quote: "Do not wait to strike till the iron is hot; but make it hot by striking.",
      author: "William Butler Yeats",
      tip: "Study Hack: Begin with the easiest 5 problems to enter effortless state of flow.",
      icon: Icons.local_fire_department_rounded,
      accentColor: AppColors.streakFire,
    ),
    MotivationQuote(
      quote: "The mind is not a vessel to be filled, but a fire to be kindled.",
      author: "Plutarch",
      tip: "Study Hack: Turn chapter headings into test questions before reading the chapter.",
      icon: Icons.lightbulb_rounded,
      accentColor: Color(0xFF7657F6),
    ),
    MotivationQuote(
      quote: "Discipline is choosing between what you want now and what you want most.",
      author: "Abraham Lincoln",
      tip: "Study Hack: When tempted to give up, study for just 5 more minutes. Momentum usually follows.",
      icon: Icons.military_tech_rounded,
      accentColor: AppColors.secondary,
    ),
    MotivationQuote(
      quote: "Action is the foundational key to all success.",
      author: "Pablo Picasso",
      tip: "Study Hack: Use spaced repetition flashcards for 10 minutes before bed.",
      icon: Icons.flash_on_rounded,
      accentColor: Color(0xFFFF844B),
    ),
    MotivationQuote(
      quote: "I am not what happened to me, I am what I choose to become.",
      author: "Carl Jung",
      tip: "Study Hack: Clear your desk completely of everything except the material you are actively studying.",
      icon: Icons.spa_rounded,
      accentColor: AppColors.secondaryFixed,
    ),
  ];

  /// Get a random quote every time (e.g. on every refresh or screen load)
  static MotivationQuote getRandomQuote() {
    return quotes[_random.nextInt(quotes.length)];
  }

  /// Get a different quote from the current one
  static MotivationQuote getNextQuote(int currentIndex) {
    if (quotes.length <= 1) return quotes.first;
    int nextIdx;
    do {
      nextIdx = _random.nextInt(quotes.length);
    } while (nextIdx == currentIndex);
    return quotes[nextIdx];
  }
}
