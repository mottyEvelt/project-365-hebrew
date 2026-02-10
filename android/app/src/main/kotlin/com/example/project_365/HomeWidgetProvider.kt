package com.example.project_365_hebrew

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews
import android.app.PendingIntent
import android.util.Log
import android.os.Bundle
import es.antonborri.home_widget.HomeWidgetPlugin
import java.util.Calendar
import java.text.SimpleDateFormat
import java.util.Locale
import kotlin.math.sqrt
import kotlin.math.roundToInt

class HomeWidgetProvider : AppWidgetProvider() {

    companion object {
        private const val TAG = "HomeWidgetProvider"
        
        /**
         * Calculate optimal grid layout based on widget size
         * Returns Pair(columns, daysPerDot)
         */
        private fun calculateGridLayout(widthDp: Int, heightDp: Int, totalDays: Int): Pair<Int, Int> {
            Log.d(TAG, "calculateGridLayout: widthDp=$widthDp, heightDp=$heightDp, totalDays=$totalDays")
            
            // Account for padding and header/footer space (approximations in dp)
            // Layout padding: 12dp * 2 = 24dp
            // Header height + padding: ~30dp
            // Footer height + padding: ~30dp
            // Grid padding bottom: 8dp
            // Total vertical chrome: ~90dp
            // Total horizontal chrome: 24dp
            
            val validWidth = (widthDp - 24).coerceAtLeast(100)
            val validHeight = (heightDp - 90).coerceAtLeast(50)
            
            // Reduce minimum dot size slightly to allow fitting more dots
            val minDotSize = 6f // Reduced from 8f
            val spacing = 2f // Spacing between dots
            val totalDotSize = minDotSize + spacing
            
            // Calculate available cells based on widget dimensions
            val maxColumns = (validWidth / totalDotSize).toInt().coerceAtLeast(5)
            val maxRows = (validHeight / totalDotSize).toInt().coerceAtLeast(2)
            val maxCells = maxColumns * maxRows
            
            Log.d(TAG, "Max cells available: $maxCells (${maxColumns}x$maxRows) in area ${validWidth}x${validHeight}")
            
            // If we can fit all days (1 dot = 1 day)
            if (maxCells >= totalDays) {
                // Calculate optimal aspect ratio close to golden ratio or widget ratio
                val targetRatio = validWidth.toFloat() / validHeight.toFloat()
                
                // Calculate columns needed to fit totalDays with the given ratio
                // columns / rows = ratio  => rows = columns / ratio
                // columns * rows >= totalDays => columns * (columns / ratio) >= totalDays
                // columns^2 >= totalDays * ratio => columns >= sqrt(totalDays * ratio)
                
                val optimalColumns = sqrt(totalDays.toFloat() * targetRatio).roundToInt().coerceIn(5, maxColumns)
                
                // Verify that with these columns, the rows fit
                // If not, increase columns (making rows fewer) until it fits or hits maxColumns
                var finalColumns = optimalColumns
                var rowsNeeded = (totalDays + finalColumns - 1) / finalColumns
                
                // If rows needed exceed maxRows, we must increase columns
                while (rowsNeeded > maxRows && finalColumns < maxColumns) {
                    finalColumns++
                    rowsNeeded = (totalDays + finalColumns - 1) / finalColumns
                }
                
                Log.d(TAG, "Using 1 dot per day with $finalColumns columns (rows: $rowsNeeded, max: $maxRows)")
                return Pair(finalColumns, 1)
            }
            
            // For smaller widgets, aggregate days per dot
            val daysPerDot = when {
                maxCells >= totalDays / 2 -> 2  // 1 dot = 2 days
                maxCells >= totalDays / 3 -> 3  // 1 dot = 3 days
                maxCells >= totalDays / 4 -> 4  // 1 dot = 4 days
                maxCells >= totalDays / 5 -> 5  // 1 dot = 5 days
                maxCells >= totalDays / 7 -> 7  // 1 dot = 1 week
                else -> 10  // 1 dot = ~10 days
            }
            
            val requiredDots = (totalDays + daysPerDot - 1) / daysPerDot
            val targetRatio = validWidth.toFloat() / validHeight.toFloat()
            
            var optimalColumns = sqrt(requiredDots.toFloat() * targetRatio).roundToInt().coerceIn(5, maxColumns)
            
            // Verify fit for aggregated dots too
            var rowsNeeded = (requiredDots + optimalColumns - 1) / optimalColumns
            while (rowsNeeded > maxRows && optimalColumns < maxColumns) {
                optimalColumns++
                rowsNeeded = (requiredDots + optimalColumns - 1) / optimalColumns
            }
            
            Log.d(TAG, "Using $daysPerDot days per dot with $optimalColumns columns (total dots: $requiredDots)")
            return Pair(optimalColumns, daysPerDot)
        }
        
        fun updateAppWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            try {
                Log.d(TAG, "updateAppWidget called for widget ID: $appWidgetId")
                
                // Get widget data from SharedPreferences (saved by Flutter via HomeWidget)
                val widgetData = HomeWidgetPlugin.getData(context)
                val daysPassed = widgetData.getInt("widget_days_passed", getDayOfYear())
                val totalDays = widgetData.getInt("widget_total_days", if (isLeapYear()) 366 else 365)
                
                Log.d(TAG, "Widget data: daysPassed=$daysPassed, totalDays=$totalDays")
                
                // Get theme preference
                val theme = WidgetConfigActivity.loadThemePref(context, appWidgetId)
                val isDarkTheme = theme == "dark"
                Log.d(TAG, "Widget theme: $theme")
                
                // Get widget size
                val options = appWidgetManager.getAppWidgetOptions(appWidgetId)
                val widthDp = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH, 250)
                val heightDp = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT, 110)
                
                // Calculate optimal grid layout
                val (columns, daysPerDot) = calculateGridLayout(widthDp, heightDp, totalDays)
                
                // Create RemoteViews
                val views = RemoteViews(context.packageName, R.layout.widget_layout)
                
                // Set background color based on theme
                val bgColor = if (isDarkTheme) android.graphics.Color.BLACK else android.graphics.Color.WHITE
                views.setInt(R.id.widget_root, "setBackgroundColor", bgColor)
                
                // Set text colors based on theme
                val textColor = if (isDarkTheme) android.graphics.Color.WHITE else android.graphics.Color.BLACK
                views.setTextColor(R.id.widget_date, textColor)
                views.setTextColor(R.id.widget_days_left, textColor)
                views.setTextColor(R.id.widget_percent_passed, textColor)
                
                // Set date text
                val dateText = getFormattedDate()
                views.setTextViewText(R.id.widget_date, dateText)
                
                // Set days left and percentage
                val daysLeft = totalDays - daysPassed
                views.setTextViewText(R.id.widget_days_left, "$daysLeft days left")
                
                val percentPassed = (daysPassed.toFloat() / totalDays * 100)
                val percentText = String.format("%.1f%% passed", percentPassed)
                views.setTextViewText(R.id.widget_percent_passed, percentText)
                
                // Set up the RemoteViews adapter for the GridView
                val serviceIntent = Intent(context, WidgetService::class.java).apply {
                    putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
                    putExtra("daysPassed", daysPassed)
                    putExtra("totalDays", totalDays)
                    putExtra("columns", columns)
                    putExtra("daysPerDot", daysPerDot)
                    putExtra("theme", theme)
                    // This unique data ensures the PendingIntent is unique per update
                    data = Uri.parse(toUri(Intent.URI_INTENT_SCHEME))
                }
                views.setRemoteAdapter(R.id.widget_grid, serviceIntent)
                
                // Set the number of columns dynamically
                views.setInt(R.id.widget_grid, "setNumColumns", columns)
                
                // Set empty view for GridView (optional)
                views.setEmptyView(R.id.widget_grid, android.R.id.empty)
                
                // Set click intent to open app
                val intent = Intent(context, MainActivity::class.java)
                val pendingIntent = PendingIntent.getActivity(
                    context, 
                    0, 
                    intent, 
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)
                
                // Update widget
                appWidgetManager.updateAppWidget(appWidgetId, views)
                
                // Notify the GridView that data has changed
                appWidgetManager.notifyAppWidgetViewDataChanged(appWidgetId, R.id.widget_grid)
                
                Log.d(TAG, "Widget updated successfully with ${columns} columns, $daysPerDot days/dot")
                
            } catch (e: Exception) {
                Log.e(TAG, "Error updating widget: ${e.message}", e)
            }
        }
        
        private fun getDayOfYear(): Int {
            val calendar = Calendar.getInstance()
            return calendar.get(Calendar.DAY_OF_YEAR)
        }
        
        private fun isLeapYear(): Boolean {
            val year = Calendar.getInstance().get(Calendar.YEAR)
            return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)
        }
        
        private fun getFormattedDate(): String {
            val calendar = Calendar.getInstance()
            val day = calendar.get(Calendar.DAY_OF_MONTH)
            val suffix = when {
                day in 11..13 -> "th"
                day % 10 == 1 -> "st"
                day % 10 == 2 -> "nd"
                day % 10 == 3 -> "rd"
                else -> "th"
            }
            val monthFormat = SimpleDateFormat("MMM", Locale.getDefault())
            val month = monthFormat.format(calendar.time)
            return "It's $day$suffix $month."
        }
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        Log.d(TAG, "onUpdate called for ${appWidgetIds.size} widgets")
        
        // Schedule midnight update alarm
        MidnightUpdateScheduler.scheduleMidnightUpdate(context)
        
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }
    
    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle
    ) {
        super.onAppWidgetOptionsChanged(context, appWidgetManager, appWidgetId, newOptions)
        // Widget was resized, recalculate layout
        Log.d(TAG, "Widget $appWidgetId was resized")
        updateAppWidget(context, appWidgetManager, appWidgetId)
    }

    override fun onReceive(context: Context?, intent: Intent?) {
        super.onReceive(context, intent)
        if (context != null && intent != null) {
            Log.d(TAG, "onReceive: action=${intent.action}")
            if (intent.action == AppWidgetManager.ACTION_APPWIDGET_UPDATE) {
                val appWidgetManager = AppWidgetManager.getInstance(context)
                val appWidgetIds = appWidgetManager.getAppWidgetIds(
                    android.content.ComponentName(context, HomeWidgetProvider::class.java)
                )
                onUpdate(context, appWidgetManager, appWidgetIds)
            }
        }
    }
    
    override fun onEnabled(context: Context?) {
        super.onEnabled(context)
        if (context != null) {
            Log.d(TAG, "First widget added - scheduling midnight updates")
            MidnightUpdateScheduler.scheduleMidnightUpdate(context)
        }
    }
    
    override fun onDeleted(context: Context?, appWidgetIds: IntArray?) {
        super.onDeleted(context, appWidgetIds)
        // Clean up preferences when widget is deleted
        if (context != null && appWidgetIds != null) {
            for (appWidgetId in appWidgetIds) {
                WidgetConfigActivity.deleteThemePref(context, appWidgetId)
            }
        }
    }
    
    override fun onDisabled(context: Context?) {
        super.onDisabled(context)
        if (context != null) {
            Log.d(TAG, "All widgets removed - canceling midnight updates")
            MidnightUpdateScheduler.cancelMidnightUpdate(context)
        }
    }
}
