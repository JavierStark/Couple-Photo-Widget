package dev.javiertorralbo.couple_photo_widget

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.widget.RemoteViews
import java.io.File

class MainWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.main_widget)

            // Load stored text
            val prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)

            val imagePath = prefs.getString("widgetImagePath", null)

            if (imagePath != null) {
                val file = File(imagePath)
                if (file.exists()) {
                    val bitmap = BitmapFactory.decodeFile(file.absolutePath)
                    val scaledBitmap = Bitmap.createScaledBitmap(bitmap, 300, 300, true)

                    views.setImageViewBitmap(R.id.widgetImage, scaledBitmap)
                } else {
                    println("\u001B[31mFile does not exist at: $imagePath\u001B[0m")
                }
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
