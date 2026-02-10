package com.example.project_365_hebrew

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.util.Log
import java.util.Calendar

/**
 * Scheduler to set up exact alarms for midnight widget updates
 */
object MidnightUpdateScheduler {
    
    private const val TAG = "MidnightScheduler"
    private const val REQUEST_CODE = 12345
    
    /**
     * Schedule an exact alarm for the next midnight (00:00:00)
     */
    fun scheduleMidnightUpdate(context: Context) {
        try {
            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager
            if (alarmManager == null) {
                Log.e(TAG, "AlarmManager not available")
                return
            }
            
            // Create intent for the broadcast receiver
            val intent = Intent(context, DateChangeBroadcastReceiver::class.java).apply {
                action = Intent.ACTION_DATE_CHANGED
            }
            
            val pendingIntent = PendingIntent.getBroadcast(
                context,
                REQUEST_CODE,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            
            // Calculate time until next midnight
            val now = Calendar.getInstance()
            val midnight = Calendar.getInstance().apply {
                timeInMillis = now.timeInMillis
                add(Calendar.DAY_OF_MONTH, 1)
                set(Calendar.HOUR_OF_DAY, 0)
                set(Calendar.MINUTE, 0)
                set(Calendar.SECOND, 0)
                set(Calendar.MILLISECOND, 0)
            }
            
            val triggerTime = midnight.timeInMillis
            
            Log.d(TAG, "Scheduling midnight update at ${midnight.time}")
            
            // Use setExactAndAllowWhileIdle for better reliability
            // This works even in Doze mode
            alarmManager.setExactAndAllowWhileIdle(
                AlarmManager.RTC_WAKEUP,
                triggerTime,
                pendingIntent
            )
            
            Log.d(TAG, "Midnight alarm scheduled successfully")
        } catch (e: Exception) {
            Log.e(TAG, "Error scheduling midnight update: ${e.message}", e)
        }
    }
    
    /**
     * Cancel the scheduled midnight update
     */
    fun cancelMidnightUpdate(context: Context) {
        try {
            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager
            if (alarmManager == null) {
                Log.e(TAG, "AlarmManager not available")
                return
            }
            
            val intent = Intent(context, DateChangeBroadcastReceiver::class.java).apply {
                action = Intent.ACTION_DATE_CHANGED
            }
            
            val pendingIntent = PendingIntent.getBroadcast(
                context,
                REQUEST_CODE,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            
            alarmManager.cancel(pendingIntent)
            Log.d(TAG, "Midnight alarm cancelled")
        } catch (e: Exception) {
            Log.e(TAG, "Error cancelling midnight update: ${e.message}", e)
        }
    }
}
