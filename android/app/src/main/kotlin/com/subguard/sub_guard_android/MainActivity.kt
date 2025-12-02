package com.subguard.sub_guard_android

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        createNotificationChannels()
    }

    private fun createNotificationChannels() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val notificationManager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager

            // Standard notification channel for H-7 and H-3 reminders
            val standardChannel = NotificationChannel(
                "subscription_reminders",
                "Subscription Reminders",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Standard reminders for upcoming subscriptions"
                enableVibration(true)
                enableLights(true)
            }

            // Critical alert channel for H-1 and Day-0 reminders
            val intenseChannel = NotificationChannel(
                "critical_alerts",
                "Critical Billing Alerts",
                NotificationManager.IMPORTANCE_MAX
            ).apply {
                description = "Critical alerts for imminent billing"
                enableVibration(true)
                enableLights(true)
                setBypassDnd(true)
            }

            notificationManager.createNotificationChannel(standardChannel)
            notificationManager.createNotificationChannel(intenseChannel)
        }
    }
}
