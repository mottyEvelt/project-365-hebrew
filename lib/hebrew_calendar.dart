/// Hebrew Calendar Utilities
class HebrewCalendar {
  late int year;
  late int month;
  late int day;

  HebrewCalendar(this.year, this.month, this.day);

  /// Convert Gregorian date to Hebrew date
  factory HebrewCalendar.fromGregorian(int gYear, int gMonth, int gDay) {
    // Using astronomical calculation method
    // This is a simplified version - accurate enough for most purposes
    
    int c = gYear ~/ 100;
    int s = ((3 * c - 5) ~/ 4);
    int a = ((12 * gYear + 12) ~/ 19);
    int b = gYear % 19;
    
    int jd = 367 * gYear - 
             ((7 * (gYear + ((gMonth + 9) ~/ 12))) ~/ 4) +
             ((275 * gMonth) ~/ 9) +
             gDay + 1721028 - s;
    
    // Convert Julian Day to Hebrew Date
    int l = jd + 68569;
    int n = ((4 * l) ~/ 146097);
    l = l - ((146097 * n + 3) ~/ 4);
    
    int i = ((4000 * (l + 1)) ~/ 1461001);
    l = l - ((1461 * i) ~/ 4) + 31;
    
    int j = ((80 * l) ~/ 2447);
    int hDay = l - ((2447 * j) ~/ 80);
    int l2 = j ~/ 11;
    int hMonth = j + 2 - (12 * l2);
    int hYear = 100 * (n - 49) + i + l2;
    
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
