package com.example.home_widget

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import es.antonborri.home_widget.HomeWidgetBackgroundIntent

class HomeScreenWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            val widgetData = HomeWidgetPlugin.getData(context)
            val counter = widgetData.getInt("counter", 0)

            val views = RemoteViews(context.packageName, R.layout.widget_layout).apply {
                setTextViewText(R.id.widget_counter_text, counter.toString())
                
                val intent = Intent(context, HomeScreenWidgetProvider::class.java).apply {
                    action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                    putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, appWidgetIds)
                }
                
                val pendingIntent = PendingIntent.getBroadcast(
                    context,
                    appWidgetId,
                    intent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                
                setOnClickPendingIntent(R.id.widget_increment_button, pendingIntent)
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }

    override fun onReceive(context: Context?, intent: Intent?) {
        super.onReceive(context, intent)
        
        if (context != null && intent?.action == AppWidgetManager.ACTION_APPWIDGET_UPDATE) {
            val widgetData = HomeWidgetPlugin.getData(context)
            var counter = widgetData.getInt("counter", 0)
            
            counter++
            
            val prefs = HomeWidgetPlugin.getData(context)
            prefs.edit().putInt("counter", counter).apply()
            
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val appWidgetIds = intent.getIntArrayExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS)
            if (appWidgetIds != null) {
                onUpdate(context, appWidgetManager, appWidgetIds)
            }
        }
    }
}