package com.example.project_365_hebrew

import android.appwidget.AppWidgetManager
import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.util.Log
import java.util.Calendar

/**
 * BroadcastReceiver that listens for date/time changes to update the widget at midnight
 */
class DateChangeBroadcastReceiver : BroadcastReceiver() {
    
    companion object {
        private const val TAG = "DateChangeReceiver"
    }
    
    override fun onReceive(context: Context?, intent: Intent?) {
        if (context == null || intent == null) return
        
        val action = intent.action
        Log.d(TAG, "Received broadcast: $action")
        
        when (action) {
            Intent.ACTION_DATE_CHANGED,
            Intent.ACTION_TIME_CHANGED,
            Intent.ACTION_TIMEZONE_CHANGED,
            Intent.ACTION_BOOT_COMPLETED -> {
                Log.d(TAG, "Date/time changed or device rebooted - updating widgets")
                updateAllWidgets(context)
                
                // Schedule next midnight update
                MidnightUpdateScheduler.scheduleMidnightUpdate(context)
            }
        }
    }
    
    private fun updateAllWidgets(context: Context) {
        try {
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val componentName = ComponentName(context, HomeWidgetProvider::class.java)
            val appWidgetIds = appWidgetManager.getAppWidgetIds(componentName)
            
            Log.d(TAG, "Updating ${appWidgetIds.size} widgets")
            
            // Trigger update for all widgets
            for (appWidgetId in appWidgetIds) {
                HomeWidgetProvider.updateAppWidget(context, appWidgetManager, appWidgetId)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error updating widgets: ${e.message}", e)
        }
    }
}
