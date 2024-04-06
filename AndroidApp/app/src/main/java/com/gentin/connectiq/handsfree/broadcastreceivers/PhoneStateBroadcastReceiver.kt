package com.gentin.connectiq.handsfree.broadcastreceivers

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import com.gentin.connectiq.handsfree.globals.essentialsAreOn
import com.gentin.connectiq.handsfree.helpers.goAsync
import com.gentin.connectiq.handsfree.impl.startConnector

class PhoneStateBroadcastReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) = goAsync {
        Log.d(TAG, "essentialsAreOn: ${essentialsAreOn(context)}")
        if (!essentialsAreOn(context)) {
            return@goAsync
        }
        when (intent.action) {
            "android.intent.action.PHONE_STATE" -> {
                Log.d(TAG, "intent: $intent")
                startConnector(context, intent)
            }

            else -> {
                Log.d(TAG, "spoofedIntent: $intent")
            }
        }
    }

    companion object {
        private val TAG: String = PhoneStateBroadcastReceiver::class.java.simpleName
    }
}

