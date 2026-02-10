package com.example.project_365

import android.app.Activity
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.widget.Button
import android.widget.RadioButton
import android.widget.RadioGroup
import android.util.Log

/**
 * Configuration activity for widget settings
 * Allows users to select light or dark theme for the widget
 */
class WidgetConfigActivity : Activity() {
    
    private var appWidgetId = AppWidgetManager.INVALID_APPWIDGET_ID
    private lateinit var radioGroup: RadioGroup
    private lateinit var radioLight: RadioButton
    private lateinit var radioDark: RadioButton
    private lateinit var btnSave: Button
    
    companion object {
        private const val TAG = "WidgetConfigActivity"
        private const val PREFS_NAME = "WidgetPreferences"
        private const val PREF_THEME_PREFIX = "widget_theme_"
        
        // Save theme for specific widget instance
        fun saveThemePref(context: Context, appWidgetId: Int, theme: String) {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            prefs.edit().putString(PREF_THEME_PREFIX + appWidgetId, theme).apply()
            Log.d(TAG, "Saved theme '$theme' for widget ID: $appWidgetId")
        }
        
        // Load theme for specific widget instance
        fun loadThemePref(context: Context, appWidgetId: Int): String {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val theme = prefs.getString(PREF_THEME_PREFIX + appWidgetId, "dark") ?: "dark"
            Log.d(TAG, "Loaded theme '$theme' for widget ID: $appWidgetId")
            return theme
        }
        
        // Delete theme preference when widget is removed
        fun deleteThemePref(context: Context, appWidgetId: Int) {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            prefs.edit().remove(PREF_THEME_PREFIX + appWidgetId).apply()
            Log.d(TAG, "Deleted theme preference for widget ID: $appWidgetId")
        }
    }
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Set result as canceled initially
        setResult(RESULT_CANCELED)
        
        setContentView(R.layout.widget_config_layout)
        
        // Get widget ID from intent
        appWidgetId = intent?.extras?.getInt(
            AppWidgetManager.EXTRA_APPWIDGET_ID,
            AppWidgetManager.INVALID_APPWIDGET_ID
        ) ?: AppWidgetManager.INVALID_APPWIDGET_ID
        
        // If invalid widget ID, finish activity
        if (appWidgetId == AppWidgetManager.INVALID_APPWIDGET_ID) {
            Log.e(TAG, "Invalid widget ID")
            finish()
            return
        }
        
        Log.d(TAG, "Configuration activity started for widget ID: $appWidgetId")
        
        // Initialize views
        radioGroup = findViewById(R.id.theme_radio_group)
        radioLight = findViewById(R.id.radio_light)
        radioDark = findViewById(R.id.radio_dark)
        btnSave = findViewById(R.id.btn_save)
        
        // Load current theme preference
        val currentTheme = loadThemePref(this, appWidgetId)
        if (currentTheme == "light") {
            radioLight.isChecked = true
        } else {
            radioDark.isChecked = true
        }
        
        // Save button click handler
        btnSave.setOnClickListener {
            val selectedTheme = if (radioLight.isChecked) "light" else "dark"
            
            // Save theme preference
            saveThemePref(this, appWidgetId, selectedTheme)
            
            // Update widget with new theme
            val appWidgetManager = AppWidgetManager.getInstance(this)
            HomeWidgetProvider.updateAppWidget(this, appWidgetManager, appWidgetId)
            
            // Return result
            val resultValue = Intent().apply {
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
            }
            setResult(RESULT_OK, resultValue)
            
            Log.d(TAG, "Configuration saved for widget ID: $appWidgetId with theme: $selectedTheme")
            finish()
        }
    }
}
