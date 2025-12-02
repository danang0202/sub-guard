package com.subguard.sub_guard_android

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import dev.fluttercommunity.plus.androidalarmmanager.AlarmService

/**
 * BroadcastReceiver that listens for BOOT_COMPLETED events
 * Triggers rescheduleAllNotifications when device restarts
 * Validates: Requirements 9.2
 */
class BootReceiver : BroadcastReceiver() {
    companion object {
        private const val TAG = "SubGuardBootReceiver"
        private const val PREFS_NAME = "boot_receiver_prefs"
        private const val KEY_LAST_BOOT_TIME = "last_boot_time"
    }

    override fun onReceive(context: Context, intent: Intent) {
        // Only respond to actual boot events
        if (intent.action != Intent.ACTION_BOOT_COMPLETED && 
            intent.action != Intent.ACTION_LOCKED_BOOT_COMPLETED) {
            return
        }

        // Prevent duplicate calls by checking if we already handled this boot
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val currentBootTime = System.currentTimeMillis()
        val lastBootTime = prefs.getLong(KEY_LAST_BOOT_TIME, 0)
        
        // If we handled a boot in the last 5 minutes, skip
        if (currentBootTime - lastBootTime < 5 * 60 * 1000) {
            Log.d(TAG, "Boot already handled recently, skipping")
            return
        }
        
        Log.d(TAG, "Device boot completed, triggering notification rescheduling")
        
        try {
            // Save this boot time
            prefs.edit().putLong(KEY_LAST_BOOT_TIME, currentBootTime).apply()
            
            // Trigger the boot reschedule callback through AlarmService
            AlarmService.enqueueAlarmProcessing(context, intent)
            Log.d(TAG, "Boot reschedule callback enqueued successfully")
        } catch (e: Exception) {
            Log.e(TAG, "Error triggering boot reschedule callback", e)
        }
    }
}
