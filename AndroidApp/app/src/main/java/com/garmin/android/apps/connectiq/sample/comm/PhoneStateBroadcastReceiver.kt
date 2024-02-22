package com.garmin.android.apps.connectiq.sample.comm

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.telephony.PhoneStateListener
import android.telephony.TelephonyManager
import android.widget.Toast
import androidx.lifecycle.LifecycleCoroutineScope
import com.garmin.android.apps.connectiq.sample.comm.activities.globalConnectIQ
import com.garmin.android.apps.connectiq.sample.comm.activities.globalDevice
import com.garmin.android.apps.connectiq.sample.comm.activities.globalLifecycleCoroutineScope
import com.garmin.android.apps.connectiq.sample.comm.activities.myApp
import com.garmin.android.connectiq.ConnectIQ
import com.garmin.android.connectiq.IQApp
import com.garmin.android.connectiq.IQDevice
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext


class PhoneStateBroadcastReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val telephonyManager = context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
        telephonyManager.listen(
            CustomPhoneStateListener(context, globalLifecycleCoroutineScope!!, globalConnectIQ!!, globalDevice!!, myApp),
            PhoneStateListener.LISTEN_CALL_STATE
        )
    }
}

class CustomPhoneStateListener(//private static final String TAG = "PhoneStateChanged";
    var context: Context, //Context to make Toast if required
    var lifecycleCoroutineScope: LifecycleCoroutineScope,
    var connectIQ: ConnectIQ,
    var device: IQDevice,
    var app: IQApp
) : PhoneStateListener() {
    override fun onCallStateChanged(state: Int, incomingNumber: String) {
        super.onCallStateChanged(state, incomingNumber)
        sendCallState(state, incomingNumber) { message, listener ->
            lifecycleCoroutineScope.launch {
                withContext(Dispatchers.IO) {
                    connectIQ.sendMessage(device, myApp, message, listener)
                }
            }
        }
    }
}

fun sendCallState(state: Int, incomingNumber: String, send: (message: Any, listener: ConnectIQ.IQSendMessageListener) -> Unit) {
    when (state) {
        TelephonyManager.CALL_STATE_IDLE -> { //when Idle i.e no call
            val msg = mapOf(
                "cmd" to "noCallInProgress"
            )
            send(msg) { _, _, status ->
                print(status)
            }
        }

        TelephonyManager.CALL_STATE_OFFHOOK -> { //when Off hook i.e in call
            val msg = mapOf(
                "cmd" to "callInProgress",
                "number" to incomingNumber
            )
            send(msg) { _, _, status ->
                print(status)
            }
        }

        TelephonyManager.CALL_STATE_RINGING -> { //when Ringing
            val msg = mapOf(
                "cmd" to "ringing"
            )
            send(msg) { _, _, status ->
                print(status)
            }
        }

        else -> {}
    }
}
