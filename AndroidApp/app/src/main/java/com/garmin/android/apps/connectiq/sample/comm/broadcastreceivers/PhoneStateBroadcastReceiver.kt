package com.garmin.android.apps.connectiq.sample.comm.broadcastreceivers

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.telephony.TelephonyManager
import android.util.Log
import com.garmin.android.apps.connectiq.sample.comm.helpers.goAsync
import com.garmin.android.apps.connectiq.sample.comm.impl.accountPhoneState

class PhoneStateBroadcastReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) = goAsync {
        Log.d(TAG, "Intent: ${intent}")
        val stateExtra = intent.getStringExtra(TelephonyManager.EXTRA_STATE)!!
        val incomingNumber = intent.getStringExtra(TelephonyManager.EXTRA_INCOMING_NUMBER)
        Log.d(TAG, "stateExtra: ${stateExtra}")
        Log.d(TAG, "incomingNumber: ${incomingNumber}")

        accountPhoneState(incomingNumber, stateExtra)
    }

    companion object {
        private val TAG: String = PhoneStateBroadcastReceiver::class.java.simpleName
    }
}

