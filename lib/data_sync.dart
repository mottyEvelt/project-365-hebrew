import 'package:home_widget/home_widget.dart';

/// Helper class to sync widget data with native Android SharedPreferences
class WidgetDataSync {
  static const String _dayPassedKey = 'widget_days_passed';
  static const String _totalDaysKey = 'widget_total_days';
  static const String _widgetThemeKey = 'widget_theme';
  static const String _androidWidgetProviderName = 'HomeWidgetProvider';

  /// Save widget data (days passed and total days) to SharedPreferences
  /// This data will be read by the Native Android Widget via SharedPreferences
  static Future<void> syncWidgetData({
    required int daysPassed,
    required int totalDays,
  }) async {
    try {
      // Use HomeWidget.saveWidgetData to save data properly for native widgets
      await HomeWidget.saveWidgetData<int>(_dayPassedKey, daysPassed);
      await HomeWidget.saveWidgetData<int>(_totalDaysKey, totalDays);

      // Trigger update for the Android Widget
      await HomeWidget.updateWidget(
        name: _androidWidgetProviderName,
        androidName: _androidWidgetProviderName,
      );

      print('Widget data synced: $daysPassed/$totalDays days');
    } catch (e) {
      print('Error syncing widget data: $e');
    }
  }

  /// Retrieve days passed from SharedPreferences (for debugging)
  static Future<int?> getDaysPassed() async {
    try {
      return await HomeWidget.getWidgetData<int>(_dayPassedKey);
    } catch (e) {
      print('Error retrieving days passed: $e');
      return null;
    }
  }

  /// Retrieve total days from SharedPreferences (for debugging)
  static Future<int?> getTotalDays() async {
    try {
      return await HomeWidget.getWidgetData<int>(_totalDaysKey);
    } catch (e) {
      print('Error retrieving total days: $e');
      return null;
    }
  }

  /// Save widget theme preference
  static Future<void> saveWidgetTheme(String theme) async {
    try {
      await HomeWidget.saveWidgetData<String>(_widgetThemeKey, theme);

      // Trigger widget update
      await HomeWidget.updateWidget(
        name: _androidWidgetProviderName,
        androidName: _androidWidgetProviderName,
      );

      print('Widget theme saved: $theme');
    } catch (e) {
      print('Error saving widget theme: $e');
    }
  }

  /// Get widget theme preference
  static Future<String?> getWidgetTheme() async {
    try {
      return await HomeWidget.getWidgetData<String>(_widgetThemeKey);
    } catch (e) {
      print('Error retrieving widget theme: $e');
      return null;
    }
  }
}
