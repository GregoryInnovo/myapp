package com.example.myapp

import android.app.TaskStackBuilder
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetPlugin
import android.app.PendingIntent
import android.os.Build
import com.example.myapp.R

class MyAppWidget : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_layout)

             // Create an Intent to launch the app when the widget is tapped
            val pendingIntent: PendingIntent = HomeWidgetLaunchIntent.getActivity(
                context,
                MainActivity::class.java
            )
            views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)

            val intent = Intent(context, MyAppWidget::class.java)
            intent.action = "recordAudioAction"
            val pendingIntentFlag = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
            } else {
                PendingIntent.FLAG_UPDATE_CURRENT
            }
            val pendingRecordAudioIntent = PendingIntent.getBroadcast(context, 0, intent, pendingIntentFlag)
            views.setOnClickPendingIntent(R.id.microphone_button, pendingRecordAudioIntent)

            val galleryIntent = Intent(context, MyAppWidget::class.java).apply {
                action = "openGalleryAction"
            }
            val pendingGalleryIntent = PendingIntent.getBroadcast(context, 1, galleryIntent, pendingIntentFlag)
            views.setOnClickPendingIntent(R.id.gallery_button, pendingGalleryIntent)

            val cameraIntent = Intent(context, MyAppWidget::class.java).apply {
                action = "openCameraAction"
            }
            val pendingCameraIntent = PendingIntent.getBroadcast(context, 2, cameraIntent, pendingIntentFlag)
            views.setOnClickPendingIntent(R.id.camera_button, pendingCameraIntent)







            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }

    override fun onReceive(context: Context?, intent: Intent?) {
        super.onReceive(context, intent)
        if (context != null) {
            if (intent?.action == "recordAudioAction") {
                HomeWidgetPlugin.triggerCallback(context, "record_audio", null)
            } else if (intent?.action == "openGalleryAction") {
                HomeWidgetPlugin.triggerCallback(context, "open_gallery", null)
            } else if (intent?.action == "openCameraAction") {
                HomeWidgetPlugin.triggerCallback(context, "open_camera", null)
            } else {
                val appWidgetManager = AppWidgetManager.getInstance(context)
                val appWidgetIds = appWidgetManager.getAppWidgetIds(intent?.component)
                onUpdate(context, appWidgetManager, appWidgetIds)
                HomeWidgetPlugin.getDataAndViewIds().forEach { viewId -> HomeWidgetPlugin.sendIntent(context, viewId, intent) }
            }
        }
    }
}