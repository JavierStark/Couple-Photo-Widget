package dev.javiertorralbo.couple_photo_widget

import android.appwidget.AppWidgetProvider
import android.appwidget.AppWidgetManager
import android.content.Context
import android.widget.RemoteViews
import android.graphics.BitmapFactory
import java.io.File
import androidx.core.content.FileProvider

class MainWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.main_widget)

            // Load stored text
            val prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)

            val imagePath = prefs.getString("widgetImagePath", null)
            //print in green the image path

            println("\u001B[32mImage path: $imagePath\u001B[0m")

            if (imagePath != null) {
                val file = File(imagePath)
                if (file.exists()) {
                    val bitmap = BitmapFactory.decodeFile(file.absolutePath)
                    views.setImageViewBitmap(R.id.widgetImage, bitmap)
                } else {
                    println("\u001B[31mFile does not exist at: $imagePath\u001B[0m")
                }
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
