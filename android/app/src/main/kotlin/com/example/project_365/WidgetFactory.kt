package com.example.project_365

import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import android.util.Log
import es.antonborri.home_widget.HomeWidgetPlugin
import java.util.Calendar
import java.util.Date

/**
 * RemoteViewsFactory implementation
 * Provides individual views for each dot in the GridView
 * Supports aggregation where 1 dot can represent multiple days
 */
class WidgetFactory(
    private val context: Context,
    private val intent: Intent
) : RemoteViewsService.RemoteViewsFactory {

    private var daysPassed: Int = 0
    private var totalDays: Int = 353  // Average Hebrew year length
    private var daysPerDot: Int = 1  // How many days each dot represents
    private var totalDots: Int = 353 // Total number of dots to display
    private var theme: String = "dark" // Widget theme: "dark" or "light"
    
    companion object {
        private const val TAG = "WidgetFactory"
        
        // Hebrew calendar calculation methods
        private fun getDayOfHebrewYear(): Int {
            val today = Date()
            val calendar = Calendar.getInstance()
            calendar.time = today
            
            val gregorianYear = calendar.get(Calendar.YEAR)
            val gregorianMonth = calendar.get(Calendar.MONTH) + 1
            val gregorianDay = calendar.get(Calendar.DAY_OF_MONTH)
            
            // Convert Gregorian to Hebrew date
            val hebrewDate = gregorianToHebrew(gregorianYear, gregorianMonth, gregorianDay)
            val hebrewYear = hebrewDate[0]
            val hebrewMonth = hebrewDate[1]
            val hebrewDay = hebrewDate[2]
            
            // Calculate days from Tishrei 1 (Hebrew New Year, month 7)
            val dayOfYear: Int
            dayOfYear = if (hebrewMonth >= 7) {
                // From Tishrei 1 of current Hebrew year
                var days = 0
                for (m in 7..hebrewMonth - 1) {
                    days += getDaysInHebrewMonth(hebrewYear, m)
                }
                days += hebrewDay
            } else {
                // From Tishrei 1 of previous Hebrew year to current date
                var days = 0
                for (m in 7..13) {
                    days += getDaysInHebrewMonth(hebrewYear - 1, m)
                }
                for (m in 1..hebrewMonth - 1) {
                    days += getDaysInHebrewMonth(hebrewYear, m)
                }
                days += hebrewDay
            }
            
            return dayOfYear
        }
        
        private fun isHebrewLeapYear(year: Int): Boolean {
            return ((year * 12 + 12) % 19) < 7
        }
        
        private fun getDaysInHebrewMonth(year: Int, month: Int): Int {
            return when {
                month == 2 && !isHebrewLeapYear(year) -> 29
                month == 3 && isHebrewLeapYear(year) -> 30
                month == 6 || month == 10 || month == 13 -> 29
                month == 12 && (year % 3 == 0) -> 29
                month in listOf(1, 4, 5, 7, 8, 9, 11) -> 30
                else -> 29
            }
        }
        
        private fun getDaysInHebrewYear(year: Int): Int {
            var days = 0
            for (month in 1..13) {
                days += getDaysInHebrewMonth(year, month)
            }
            return days
        }
        
        private fun gregorianToHebrew(year: Int, month: Int, day: Int): IntArray {
            // Simplified Gregorian to Hebrew conversion
            // Using astronomical calculations
            val c = year / 100
            val s = ((3 * c - 5) / 4).toInt()
            val jd = 367 * year - ((7 * (year + ((month + 9) / 12).toInt())) / 4).toInt() + 
                    ((275 * month) / 9).toInt() + day + 1721028 - s
            
            var l = jd + 68569
            val n = ((4 * l) / 146097).toInt()
            l = l - ((146097 * n + 3) / 4).toInt()
            
            val i = ((4000 * (l + 1)) / 1461001).toInt()
            l = l - ((1461 * i) / 4).toInt() + 31
            val j = ((80 * l) / 2447).toInt()
            val day_h = l - ((2447 * j) / 80).toInt()
            val l2 = j / 11
            val month_h = j + 2 - 12 * l2
            val year_h = 100 * (n - 49) + i + l2
            
            return intArrayOf(year_h, month_h, day_h)
        }
        
        private fun getHebrewYearLength(year: Int): Int {
            return getDaysInHebrewYear(year)
        }
    }
    
    private fun loadData() {
        // First try to get from intent extras
        val intentDaysPassed = intent.getIntExtra("daysPassed", -1)
        val intentTotalDays = intent.getIntExtra("totalDays", -1)
        val intentDaysPerDot = intent.getIntExtra("daysPerDot", 1)
        theme = intent.getStringExtra("theme") ?: "dark"
        
        if (intentDaysPassed > 0 && intentTotalDays > 0) {
            daysPassed = intentDaysPassed
            totalDays = intentTotalDays
            daysPerDot = intentDaysPerDot
            Log.d(TAG, "loadData: Using intent data - daysPassed=$daysPassed, totalDays=$totalDays, daysPerDot=$daysPerDot, theme=$theme")
        } else {
            // Fallback to SharedPreferences (via HomeWidget)
            try {
                val widgetData = HomeWidgetPlugin.getData(context)
                daysPassed = widgetData.getInt("widget_days_passed", getDayOfHebrewYear())
                val calendar = Calendar.getInstance()
                val hebrewYear = gregorianToHebrew(calendar.get(Calendar.YEAR), calendar.get(Calendar.MONTH) + 1, calendar.get(Calendar.DAY_OF_MONTH))[0]
                totalDays = widgetData.getInt("widget_total_days", getHebrewYearLength(hebrewYear))
                daysPerDot = 1 // Default to 1 day per dot
                Log.d(TAG, "loadData: Using SharedPreferences - daysPassed=$daysPassed, totalDays=$totalDays")
            } catch (e: Exception) {
                // Final fallback to calculated Hebrew values
                daysPassed = getDayOfHebrewYear()
                val calendar = Calendar.getInstance()
                val hebrewYear = gregorianToHebrew(calendar.get(Calendar.YEAR), calendar.get(Calendar.MONTH) + 1, calendar.get(Calendar.DAY_OF_MONTH))[0]
                totalDays = getHebrewYearLength(hebrewYear)
                daysPerDot = 1
                Log.d(TAG, "loadData: Using calculated Hebrew fallback - daysPassed=$daysPassed, totalDays=$totalDays")
            }
        }
        
        // Calculate total dots needed
        totalDots = (totalDays + daysPerDot - 1) / daysPerDot
        Log.d(TAG, "Total dots to display: $totalDots")
    }

    override fun onCreate() {
        Log.d(TAG, "onCreate called")
        loadData()
    }

    override fun onDataSetChanged() {
        Log.d(TAG, "onDataSetChanged called")
        loadData()
    }

    override fun onDestroy() {
        Log.d(TAG, "onDestroy called")
        // Cleanup if needed
    }

    override fun getCount(): Int {
        Log.d(TAG, "getCount: returning $totalDots dots")
        return totalDots
    }

    override fun getViewAt(position: Int): RemoteViews {
        try {
            val views = RemoteViews(context.packageName, R.layout.widget_item_dot)
            
            // Calculate which day range this dot represents
            val dotStartDay = position * daysPerDot + 1
            val dotEndDay = ((position + 1) * daysPerDot).coerceAtMost(totalDays)
            
            // Determine the state of this dot
            // daysPassed is the current day (1-based), so:
            // - If current day is beyond this dot's range: past
            // - If current day is within this dot's range: today
            // - If current day is before this dot's range: future
            val isLightTheme = theme == "light"
            val drawableId = when {
                daysPassed > dotEndDay -> {
                    // Current day is past this dot's range - this dot is in the past
                    if (isLightTheme) R.drawable.dot_past_light else R.drawable.dot_past
                }
                daysPassed >= dotStartDay && daysPassed <= dotEndDay -> {
                    // Current day is within this dot's range - this is today's dot
                    R.drawable.dot_today
                }
                else -> {
                    // Current day hasn't reached this dot yet - this dot is in the future
                    if (isLightTheme) R.drawable.dot_future_light else R.drawable.dot_future
                }
            }
            
            // Set the drawable to the ImageView
            views.setImageViewResource(R.id.widget_dot, drawableId)
            
            return views
        } catch (e: Exception) {
            Log.e(TAG, "Error creating view at position $position: ${e.message}", e)
            // Return a simple fallback view
            val fallbackViews = RemoteViews(context.packageName, R.layout.widget_item_dot)
            fallbackViews.setImageViewResource(R.id.widget_dot, R.drawable.dot_future)
            return fallbackViews
        }
    }

    override fun getLoadingView(): RemoteViews? {
        return null
    }

    override fun getViewTypeCount(): Int {
        return 1
    }

    override fun getItemId(position: Int): Long {
        return position.toLong()
    }

    override fun hasStableIds(): Boolean {
        return true
    }
}
