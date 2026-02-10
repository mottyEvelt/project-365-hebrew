/// Hebrew Calendar Utilities
class HebrewCalendar {
  late int year;
  late int month;
  late int day;

  HebrewCalendar(this.year, this.month, this.day);

  /// Convert Gregorian date to Hebrew date
  factory HebrewCalendar.fromGregorian(int gYear, int gMonth, int gDay) {
    // Calculate Julian Day Number
    int a = (14 - gMonth) ~/ 12;
    int y = gYear + 4800 - a;
    int m = gMonth + 12 * a - 3;
    int jdn = gDay + (153 * m + 2) ~/ 5 + 365 * y + y ~/ 4 - y ~/ 100 + y ~/ 400 - 32045;

    // Find Hebrew year by binary search
    int hYear = 5780; // Start around current year
    while (true) {
      int startJdn = hebrewYearStartJdn(hYear);
      int endJdn = hebrewYearStartJdn(hYear + 1);
      if (jdn >= startJdn && jdn < endJdn) {
        break;
      } else if (jdn < startJdn) {
        hYear--;
      } else {
        hYear++;
      }
    }

    // Find month and day
    int startOfYear = hebrewYearStartJdn(hYear);
    int dayOfYear = jdn - startOfYear;
    int hMonth = 7; // Start from Tishrei
    int daysInCurrentMonth = 0;

    for (int m = 7; m <= 13; m++) {
      int daysInM = daysInMonth(hYear, m);
      if (dayOfYear < daysInCurrentMonth + daysInM) {
        hMonth = m;
        break;
      }
      daysInCurrentMonth += daysInM;
    }

    for (int m = 1; m <= 6; m++) {
      int daysInM = daysInMonth(hYear, m);
      if (dayOfYear < daysInCurrentMonth + daysInM) {
        hMonth = m;
        break;
      }
      daysInCurrentMonth += daysInM;
    }

    int hDay = dayOfYear - daysInCurrentMonth + 1;

    return HebrewCalendar(hYear, hMonth, hDay);
  }

  // Helper: Calculate JDN for start of Hebrew year
  static int hebrewYearStartJdn(int hYear) {
    // Simplified calculation of Tishrei 1 (start of Hebrew year)
    // Based on the 19-year Metonic cycle and known epoch
    int months = hYear * 12 + (isLeapYear(hYear) ? 7 : 0);
    int days = (months * 765433) ~/ 25920;
    return 347997 + days;
  }

  /// Get current date in Hebrew calendar
  factory HebrewCalendar.now() {
    final now = DateTime.now();
    return HebrewCalendar.fromGregorian(now.year, now.month, now.day);
  }

  /// Check if Hebrew year is a leap year (has 13 months)
  static bool isLeapYear(int year) {
    return ((year * 12 + 12) % 19) < 7;
  }

  /// Get days in a Hebrew month
  static int daysInMonth(int year, int month) {
    switch (month) {
      case 1: return 30; // Nisan
      case 2: return isLeapYear(year) ? 30 : 29; // Iyar or Adar I
      case 3: return isLeapYear(year) ? 30 : 29; // Sivan or Adar II  
      case 4: return 29; // Tammuz
      case 5: return 30; // Av
      case 6: return 29; // Elul
      case 7: return 30; // Tishrei
      case 8: return 29; // Cheshvan (can be 30 but using 29)
      case 9: return 29; // Kislev (can be 30 but using 29)
      case 10: return 29; // Tevet
      case 11: return 30; // Shevat
      case 12: return isLeapYear(year) ? 30 : 29; // Adar
      case 13: return isLeapYear(year) ? 29 : 0; // Adar II (leap years only)
      default: return 0;
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
