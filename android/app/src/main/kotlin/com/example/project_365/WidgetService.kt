package com.example.project_365

import android.content.Intent
import android.widget.RemoteViewsService

/**
 * RemoteViewsService for the widget GridView
 * Provides data to the GridView in the app widget
 */
class WidgetService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory {
        return WidgetFactory(this.applicationContext, intent)
    }
}
