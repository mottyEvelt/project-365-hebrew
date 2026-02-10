/// Hebrew Calendar Utilities
class HebrewCalendar {
  late int year;
  late int month;
  late int day;

  HebrewCalendar(this.year, this.month, this.day);

  /// Convert Gregorian date to Hebrew date
  factory HebrewCalendar.fromGregorian(int gYear, int gMonth, int gDay) {
    // Calculate Julian Day Number from Gregorian date
    int a = (14 - gMonth) ~/ 12;
    int y = gYear + 4800 - a;
    int m = gMonth + 12 * a - 3;
    int jdn = gDay + (153 * m + 2) ~/ 5 + 365 * y + y ~/ 4 - y ~/ 100 + y ~/ 400 - 32045;

    // Convert JDN to Hebrew date using standard formula
    // Based on Meeus algorithm for Hebrew calendar
    int c = (jdn * 98496 + 8171949) ~/ 35670624;
    int s = jdn - ((c * 35670624 - 8171949) ~/ 98496);
    int a2 = ((s * 98496 + 18092) ~/ 655381);
    int b = ((((s * 98496 + 18092) % 655381) * 19) + 18092) ~/ 655381;
    
    int hYear = c * 100 + a2 * 19 + b + 3744;
    
    // Adjust year if needed
    int nisan1Jdn = ((hYear * 35670624 - 8171949) ~/ 98496) + 1;
    if (jdn < nisan1Jdn) {
      hYear = hYear - 1;
      nisan1Jdn = ((hYear * 35670624 - 8171949) ~/ 98496) + 1;
    }
    
    // Find month and day
    int hMonth = 1;
    int dayCount = 0;
    
    // Start from Nisan (month 1)
    for (int m = 1; m <= 13; m++) {
      int daysInM = daysInMonth(hYear, m);
      if (jdn <= nisan1Jdn + dayCount + daysInM - 1) {
        hMonth = m;
        break;
      }
      dayCount += daysInM;
    }
    
    int hDay = jdn - nisan1Jdn - dayCount + 1;
    
    return HebrewCalendar(hYear, hMonth, hDay);
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
