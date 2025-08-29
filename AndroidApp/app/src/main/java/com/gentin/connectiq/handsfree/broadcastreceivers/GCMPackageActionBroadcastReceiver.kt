package com.gentin.connectiq.handsfree.broadcastreceivers

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.util.Log

class GCMPackageActionBroadcastReceiver(
    val handleAction: (String?) -> Unit,
) : BroadcastReceiver() {

    fun registerIn(context: Context) {
        val filter = IntentFilter().apply {
            addAction(Intent.ACTION_PACKAGE_ADDED)
            addAction(Intent.ACTION_PACKAGE_REMOVED)
            addAction(Intent.ACTION_PACKAGE_REPLACED)
            addDataScheme("package")
        }
        context.registerReceiver(this, filter)
    }

    fun unregisterIn(context: Context) {
        context.unregisterReceiver(this)
    }

    override fun onReceive(context: Context, intent: Intent) {
        val data = intent.data
        val packageName = data?.schemeSpecificPart
        if (packageName == "com.garmin.android.apps.connectmobile") {
            Log.i(TAG, "gcmPackageAction: ${intent.action}")
            handleAction(intent.action)
        }
    }

    companion object Companion {
        private val TAG = GCMPackageActionBroadcastReceiver::class.java.simpleName
    }
}