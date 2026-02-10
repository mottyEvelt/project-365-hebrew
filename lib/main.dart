import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:project_365/data_sync.dart';
import 'package:project_365/hebrew_calendar.dart';

// Theme Provider
final themeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    return MaterialApp(
      title: '365.',
      themeMode: themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: const ColorScheme.light(
          primary: Colors.black,
          secondary: Colors.orange,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          secondary: Colors.orange,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const YearProgressScreen(),
    );
  }
}

class YearProgressScreen extends ConsumerStatefulWidget {
  const YearProgressScreen({super.key});

  @override
  ConsumerState<YearProgressScreen> createState() => _YearProgressScreenState();
}

class _YearProgressScreenState extends ConsumerState<YearProgressScreen> {
  final GlobalKey _gridKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncWidgetData();
    });
  }

  Future<void> _syncWidgetData() async {
    final dayOfYear = _getDayOfYear();
    final totalDays = _isLeapYear() ? 366 : 365;

    await WidgetDataSync.syncWidgetData(
      daysPassed: dayOfYear,
      totalDays: totalDays,
    );
  }

  int _getDayOfYear() {
    final hebrewDate = HebrewCalendar.now();
    return hebrewDate.getDayOfYear();
  }

  bool _isLeapYear() {
    final hebrewDate = HebrewCalendar.now();
    return HebrewCalendar.isLeapYear(hebrewDate.year);
  }

  String _getFormattedDate() {
    final hebrewDate = HebrewCalendar.now();
    final monthName = hebrewDate.getMonthName();
    final day = hebrewDate.day;
    String suffix = 'th';
    if (day >= 11 && day <= 13) {
      suffix = 'th';
    } else {
      switch (day % 10) {
        case 1:
          suffix = 'st';
          break;
        case 2:
          suffix = 'nd';
          break;
        case 3:
          suffix = 'rd';
          break;
        default:
          suffix = 'th';
          break;
      }
    }
    return "It's $day$suffix $monthName.";
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final textColor = Theme.of(context).colorScheme.primary;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.maxWidth;

            // Compact heights to give maximum space to the grid
            const headerHeight = 60.0;
            const dateHeight = 30.0;
            const statsHeight = 40.0;
            const footerHeight = 80.0;

            // Grid Configuration
            const columns = 13;
            const spacingFactor = 0.6;

            // Layout Padding (Space in x and y)
            const hPadding = 24.0;
            const vPadding = 72.0;

            // Calculate precise sizes
            final horizontalUnits = columns + (columns - 1) * spacingFactor;

            // Calculate max width considering the new padding
            final maxDotWidth =
                (availableWidth - (hPadding * 2)) / horizontalUnits;

            // Apply slight reduction (0.92) to make dots visually "little bit smaller"
            final dotSize = maxDotWidth * 0.92;
            final spacing = dotSize * spacingFactor;

            final dayOfYear = _getDayOfYear();
            final totalDays = _isLeapYear() ? 366 : 365;
            final daysLeft = totalDays - dayOfYear;
            final percentPassed = (dayOfYear / totalDays * 100).toStringAsFixed(
              1,
            );

            return Column(
              children: [
                // Header with Theme Toggle
                SizedBox(
                  height: headerHeight,
                  child: Stack(
                    children: [
                      Center(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '365',
                                style: GoogleFonts.inter(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w300,
                                  color: textColor,
                                  letterSpacing: 2,
                                ),
                              ),
                              TextSpan(
                                text: '.',
                                style: GoogleFonts.inter(
                                  fontSize: 42,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        right: 16,
                        top: 0,
                        bottom: 0,
                        child: IconButton(
                          icon: Icon(
                            themeMode == ThemeMode.system
                                ? Icons.brightness_auto
                                : themeMode == ThemeMode.light
                                ? Icons.light_mode
                                : Icons.dark_mode,
                            color: textColor,
                          ),
                          onPressed: () {
                            // Cycle: System -> Light -> Dark -> System
                            if (themeMode == ThemeMode.system) {
                              ref.read(themeProvider.notifier).state =
                                  ThemeMode.light;
                            } else if (themeMode == ThemeMode.light) {
                              ref.read(themeProvider.notifier).state =
                                  ThemeMode.dark;
                            } else {
                              ref.read(themeProvider.notifier).state =
                                  ThemeMode.system;
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Date Display
                SizedBox(
                  height: dateHeight,
                  child: Center(
                    child: Text(
                      _getFormattedDate(),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: textColor.withOpacity(0.6),
                      ),
                    ),
                  ),
                ),

                // Grid
                Expanded(
                  child: Center(
                    child: RepaintBoundary(
                      key: _gridKey,
                      child: Container(
                        color: bgColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: hPadding,
                          vertical: vPadding,
                        ),
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: availableWidth - (hPadding * 2),
                            ),
                            child: Center(
                              child: Wrap(
                                spacing: spacing,
                                runSpacing: spacing,
                                alignment: WrapAlignment.center,
                                children: List.generate(totalDays, (index) {
                                  final day = index + 1;
                                  final isPast = day < dayOfYear;
                                  final isToday = day == dayOfYear;
                                  final isFuture = day > dayOfYear;

                                  return Container(
                                    width: dotSize,
                                    height: dotSize,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isPast
                                          ? textColor.withOpacity(0.3)
                                          : isToday
                                          ? Colors.orange
                                          : Colors.transparent,
                                      border: isFuture
                                          ? Border.all(
                                              color: textColor.withOpacity(0.2),
                                              width: 1,
                                            )
                                          : null,
                                      boxShadow: isToday
                                          ? [
                                              BoxShadow(
                                                color: Colors.orange
                                                    .withOpacity(0.6),
                                                blurRadius: 8,
                                                spreadRadius: 2,
                                              ),
                                            ]
                                          : null,
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Stats Row
                SizedBox(
                  height: statsHeight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$daysLeft days left',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: textColor.withOpacity(0.8),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          '|',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: textColor.withOpacity(0.4),
                          ),
                        ),
                      ),
                      Text(
                        '$percentPassed% passed',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: textColor.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),

                // Footer
                SizedBox(
                  height: footerHeight,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Developed by Varad Patil',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: textColor.withOpacity(0.6),
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.code,
                              color: textColor.withOpacity(0.7),
                              size: 20,
                            ),
                            onPressed: () async {
                              final uri = Uri.parse(
                                'https://github.com/devVaradPatil/',
                              );
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(
                                  uri,
                                  mode: LaunchMode.externalApplication,
                                );
                              }
                            },
                            tooltip: 'GitHub',
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: Icon(
                              Icons.business,
                              color: textColor.withOpacity(0.7),
                              size: 20,
                            ),
                            onPressed: () async {
                              final uri = Uri.parse(
                                'https://www.linkedin.com/in/varad-patil-web-dev/',
                              );
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(
                                  uri,
                                  mode: LaunchMode.externalApplication,
                                );
                              }
                            },
                            tooltip: 'LinkedIn',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
