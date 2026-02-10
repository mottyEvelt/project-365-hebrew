# Hebrew Calendar Implementation - Changes Summary

## Overview
The app has been converted from tracking Gregorian calendar days (365/366 days per year) to Hebrew calendar days (353-355 days per year).

## Key Changes

### 1. **pubspec.yaml**
- Added `hebrew: ^0.1.0` dependency for Hebrew calendar calculations in Flutter

### 2. **lib/main.dart**
- Added `import 'package:hebrew/hebrew.dart';` for Hebrew calendar support
- Updated `_getDayOfYear()` method to:
  - Use `HebrewCalendar.fromDate()` to convert current Gregorian date to Hebrew date
  - Calculate days from Tishrei 1st (Hebrew New Year, month 7)
  - Return the day number within the Hebrew year

- Updated `_isLeapYear()` method to:
  - Check if current Hebrew year is a leap year
  - Uses `HebrewCalendar.isLeapYear()` which implements the 19-year Metonic cycle
  - Leap years in Hebrew calendar: years 3, 6, 8, 11, 14, 17, 19 (in each 19-year cycle)

- Updated `_getFormattedDate()` method to:
  - Display current Hebrew date instead of Gregorian
  - Shows Hebrew month names (Tishrei, Cheshvan, Kislev, etc.)
  - Displays in format: "It's [day][suffix] [Hebrew Month]"

### 3. **android/app/src/main/kotlin/com/example/project_365/WidgetFactory.kt**
- Replaced Gregorian calendar logic with Hebrew calendar calculations
- Added helper methods:
  - `getDayOfHebrewYear()`: Calculates current day in Hebrew year
  - `isHebrewLeapYear()`: Checks if a Hebrew year is a leap year using the Metonic cycle
  - `getDaysInHebrewMonth()`: Returns days in each Hebrew month (28-30 days)
  - `getDaysInHebrewYear()`: Calculates total days in a Hebrew year (353-355 days)
  - `gregorianToHebrew()`: Converts Gregorian dates to Hebrew calendar
  - `getHebrewYearLength()`: Returns the length of a specific Hebrew year

## Hebrew Calendar Details

### Hebrew Year Structure
- Starts on Tishrei 1st (around September/October in Gregorian calendar)
- Contains 12 or 13 months (leap years have Adar I and Adar II)
- Total days: 353, 354, or 355 days per year (vs. 365/366 in Gregorian)

### Month Order and Days
1. **Nisan** - 30 days
2. **Iyar** - 29 days
3. **Sivan** - 30 days
4. **Tammuz** - 29 days
5. **Av** - 30 days
6. **Elul** - 29 days
7. **Tishrei** - 30 days (New Year begins)
8. **Cheshvan** - 29/30 days
9. **Kislev** - 29/30 days
10. **Tevet** - 29 days
11. **Shevat** - 30 days
12. **Adar** (or Adar I) - 30 days
13. **Adar II** (leap years only) - 29 days

## How to Use

1. **Update Flutter dependencies:**
   ```bash
   flutter pub get
   ```

2. **Run the app:**
   The app will now display:
   - Current Hebrew date (e.g., "It's 15th Tishrei")
   - Progress based on Hebrew year (not Gregorian year)
   - The widget will show days passed in the Hebrew year
   - Different number of total dots based on Hebrew year length (353-355 vs. 365-366)

## Testing Recommendations

1. Test date calculations around:
   - Hebrew New Year (Tishrei 1st - around Sept/Oct)
   - Leap years (years 3, 6, 8, 11, 14, 17, 19 of each 19-year cycle)
   - Month transitions

2. Verify widget updates correctly:
   - Widget should show correct number of dots (353-355)
   - Day counting should start from Tishrei 1st
   - Widget should update at midnight Hebrew time

## Future Enhancements

- Add Hebrew numbering for days (using Hebrew numerals ט״ו)
- Support for Hebrew holidays and special dates
- Option to switch between Gregorian and Hebrew calendar views
- Display both calendars simultaneously
