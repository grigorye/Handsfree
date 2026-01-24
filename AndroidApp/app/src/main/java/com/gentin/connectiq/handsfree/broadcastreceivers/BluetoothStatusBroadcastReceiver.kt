package com.gentin.connectiq.handsfree.broadcastreceivers

import android.bluetooth.BluetoothAdapter
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.util.Log
import androidx.core.content.ContextCompat
import com.gentin.connectiq.handsfree.impl.ACTIVATE_AND_RECONNECT
import com.gentin.connectiq.handsfree.impl.startConnector

class BluetoothStatusBroadcastReceiver : BroadcastReceiver() {

    fun registerIn(context: Context) {
        val filter = IntentFilter().apply {
            addAction(BluetoothAdapter.ACTION_STATE_CHANGED)
        }
        ContextCompat.registerReceiver(context, this, filter, ContextCompat.RECEIVER_EXPORTED)
    }

    fun unregisterIn(context: Context) {
        context.unregisterReceiver(this)
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == BluetoothAdapter.ACTION_STATE_CHANGED) {
            val state = intent.getIntExtra(BluetoothAdapter.EXTRA_STATE, BluetoothAdapter.ERROR)
            if (state == BluetoothAdapter.STATE_ON || state == BluetoothAdapter.STATE_OFF) {
                val stateStr = if (state == BluetoothAdapter.STATE_ON) "on" else "off"
                Log.i(TAG, "Bluetooth is $stateStr, reconnecting devices")
                startConnector(context, ACTIVATE_AND_RECONNECT)
            }
        }
    }

    companion object {
        private val TAG = BluetoothStatusBroadcastReceiver::class.java.simpleName
    }
}
