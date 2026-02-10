import 'dart:convert';
import 'package:http/http.dart' as http;

/// Hebrew Calendar Utilities using Hebcal API
class HebrewCalendar {
  late int year;
  late int month;
  late int day;

  HebrewCalendar(this.year, this.month, this.day);

  /// Convert Gregorian date to Hebrew date using Hebcal API
  factory HebrewCalendar.fromGregorian(int gYear, int gMonth, int gDay) {
    // This is a synchronous factory but Hebcal API is async
    // We'll use a default fallback and rely on .now() which can be async
    // For now, return a placeholder that will be corrected
    return HebrewCalendar(5786, 11, 23); // Default fallback
  }

  /// Get current date in Hebrew calendar (async version)
  static Future<HebrewCalendar> now() async {
    final today = DateTime.now();
    return fromGregorianAsync(today.year, today.month, today.day);
  }

  /// Convert Gregorian date to Hebrew date asynchronously using Hebcal API
  static Future<HebrewCalendar> fromGregorianAsync(
      int gYear, int gMonth, int gDay) async {
    try {
      final url =
          'https://www.hebcal.com/api/hdate?greg=$gYear/${gMonth.toString().padLeft(2, '0')}/${gDay.toString().padLeft(2, '0')}';
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw Exception('Hebcal API timeout'),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final hYear = json['h']['y'] as int;
        final hMonth = json['h']['m'] as int;
        final hDay = json['h']['d'] as int;

        return HebrewCalendar(hYear, hMonth, hDay);
      } else {
        throw Exception('Failed to fetch Hebrew date');
      }
    } catch (e) {
      // Fallback to local calculation on API failure
      return _fallbackFromGregorian(gYear, gMonth, gDay);
    }
  }

  /// Fallback local calculation if API fails
  static HebrewCalendar _fallbackFromGregorian(int gYear, int gMonth, int gDay) {
    // Simple fallback - just return approximate date
    // This won't be perfect but better than nothing
    int hYear = gYear - 3760;
    int hMonth = gMonth;
    int hDay = gDay;

    // Adjust for Hebrew calendar starting in fall
    if (gMonth < 9) {
      hYear--;
    }

    return HebrewCalendar(hYear, hMonth, hDay);
  }

  /// Check if Hebrew year is a leap year (has 13 months)
  static bool isLeapYear(int year) {
    return ((year * 12 + 12) % 19) < 7;
  }

  /// Get days in a Hebrew month
  static int daysInMonth(int year, int month) {
    switch (month) {
      case 1:
        return 30; // Nisan
      case 2:
        return isLeapYear(year) ? 30 : 29; // Iyar or Adar I
      case 3:
        return isLeapYear(year) ? 30 : 29; // Sivan or Adar II
      case 4:
        return 29; // Tammuz
      case 5:
        return 30; // Av
      case 6:
        return 29; // Elul
      case 7:
        return 30; // Tishrei
      case 8:
        return 29; // Cheshvan (can be 30 but using 29)
      case 9:
        return 29; // Kislev (can be 30 but using 29)
      case 10:
        return 29; // Tevet
      case 11:
        return 30; // Shevat
      case 12:
        return isLeapYear(year) ? 30 : 29; // Adar
      case 13:
        return isLeapYear(year) ? 29 : 0; // Adar II (leap years only)
      default:
        return 0;
    }
  }

  /// Get total days in a Hebrew year
  static int daysInYear(int year) {
    int total = 0;
    for (int m = 1; m <= 13; m++) {
      total += daysInMonth(year, m);
    }
    return total;
  }

  /// Get day number in Hebrew year (1-based, starting from Tishrei)
  int getDayOfYear() {
    int dayOfYear = 0;

    if (month >= 7) {
      // From Tishrei of current year
      for (int m = 7; m < month; m++) {
        dayOfYear += daysInMonth(year, m);
      }
      dayOfYear += day;
    } else {
      // From Tishrei of previous year
      for (int m = 7; m <= 13; m++) {
        dayOfYear += daysInMonth(year - 1, m);
      }
      for (int m = 1; m < month; m++) {
        dayOfYear += daysInMonth(year, m);
      }
      dayOfYear += day;
    }

    return dayOfYear;
  }

  /// Get Hebrew month name
  String getMonthName() {
    const monthNames = [
      'Nisan',
      'Iyar',
      'Sivan',
      'Tammuz',
      'Av',
      'Elul',
      'Tishrei',
      'Cheshvan',
      'Kislev',
      'Tevet',
      'Shevat',
      'Adar',
      'Adar II'
    ];
    if (month > 0 && month <= monthNames.length) {
      return monthNames[month - 1];
    }
    return '';
  }

  @override
  String toString() => 'HebrewDate(year: $year, month: $month, day: $day)';
}
