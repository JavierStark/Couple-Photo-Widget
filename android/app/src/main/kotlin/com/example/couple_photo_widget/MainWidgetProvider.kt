package com.example.couple_photo_widget

import android.appwidget.AppWidgetProvider
import android.appwidget.AppWidgetManager
import android.content.Context
import android.widget.RemoteViews
import android.graphics.BitmapFactory

class MainWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.main_widget)

            // Load stored text
            val prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
            val text = prefs.getString("widgetText", "Default text")
            // views.setTextViewText(R.id.widgetText, text)

            // Load stored image
            val imagePath = prefs.getString("widgetImagePath", null)
            if (imagePath != null) {
                val bitmap = BitmapFactory.decodeFile(imagePath)
                // views.setImageViewBitmap(R.id.widgetImage, bitmap)
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
