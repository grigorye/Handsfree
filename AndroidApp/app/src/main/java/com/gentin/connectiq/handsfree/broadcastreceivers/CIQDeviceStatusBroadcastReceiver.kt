package com.gentin.connectiq.handsfree.broadcastreceivers

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Parcelable
import android.util.Log
import androidx.core.content.ContextCompat
import com.garmin.android.connectiq.ConnectIQ
import com.garmin.android.connectiq.IQDevice
import com.garmin.android.connectiq.IQDevice.IQDeviceStatus

class CIQDeviceStatusBroadcastReceiver(
    val handleDeviceStatus: (IQDevice?, IQDeviceStatus) -> Unit,
) : BroadcastReceiver() {

    fun registerIn(context: Context) {
        val filter = IntentFilter().apply {
            addAction(ConnectIQ.DEVICE_STATUS)
        }
        ContextCompat.registerReceiver(context, this, filter, ContextCompat.RECEIVER_EXPORTED)
    }

    fun unregisterIn(context: Context) {
        context.unregisterReceiver(this)
    }

    override fun onReceive(context: Context, intent: Intent) {
        Log.i(TAG, "received: $intent")
        @Suppress("DEPRECATION") val device =
            intent.getParcelableExtra<Parcelable?>("com.garmin.android.connectiq.EXTRA_REMOTE_DEVICE") as IQDevice?
        val statusIntValue = intent.getIntExtra(
            "com.garmin.android.connectiq.EXTRA_STATUS",
            IQDeviceStatus.UNKNOWN.ordinal
        )
        val status = IQDeviceStatus.entries[statusIntValue]
        handleDeviceStatus(device, status)
    }

    companion object Companion {
        private val TAG = CIQDeviceStatusBroadcastReceiver::class.java.simpleName
    }
}