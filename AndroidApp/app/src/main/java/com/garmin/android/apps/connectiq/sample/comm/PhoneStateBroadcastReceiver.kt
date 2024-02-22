package com.garmin.android.apps.connectiq.sample.comm

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.telephony.PhoneStateListener
import android.telephony.TelephonyManager
import android.util.Log
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
    companion object {
        private var listener: CustomPhoneStateListener? = null
        private val TAG: String = PhoneStateBroadcastReceiver::class.java.simpleName
    }

    override fun onReceive(context: Context, intent: Intent) {
        Log.d(TAG, "Intent: ${intent}")
        val stateExtra = intent.getStringExtra(TelephonyManager.EXTRA_STATE)!!
        val incomingNumber = intent.getStringExtra(TelephonyManager.EXTRA_INCOMING_NUMBER)
        Log.d(TAG, "stateExtra: ${stateExtra}")
        Log.d(TAG, "incomingNumber: ${incomingNumber}")

        var lifecycleCoroutineScope: LifecycleCoroutineScope = globalLifecycleCoroutineScope!!
        var connectIQ: ConnectIQ = globalConnectIQ!!
        var device: IQDevice = globalDevice!!

        sendCallStateExtra(stateExtra, incomingNumber ?: "") { message, listener ->
            lifecycleCoroutineScope.launch {
                withContext(Dispatchers.IO) {
                    connectIQ.sendMessage(device, myApp, message, listener)
                }
            }
        }

        return;

        listener = CustomPhoneStateListener(context, globalLifecycleCoroutineScope!!, globalConnectIQ!!, globalDevice!!, myApp)
        val telephonyManager = context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
        telephonyManager.listen(
            listener,
            PhoneStateListener.LISTEN_CALL_STATE
        )
    }
}

var lastIncomingNumber: String = ""
var lastState: Int = -1

class CustomPhoneStateListener(//private static final String TAG = "PhoneStateChanged";
    var context: Context, //Context to make Toast if required
    var lifecycleCoroutineScope: LifecycleCoroutineScope,
    var connectIQ: ConnectIQ,
    var device: IQDevice,
    var app: IQApp,
) : PhoneStateListener() {
    companion object {
        private val TAG: String = CustomPhoneStateListener::class.java.simpleName
    }
    override fun onCallStateChanged(state: Int, incomingNumber: String) {
        super.onCallStateChanged(state, incomingNumber)
        val incomingNumberDidNotChange = incomingNumber == lastIncomingNumber
        val incomingNumberIsDummy = incomingNumber == ""
        Log.d(TAG, "state(old) = ${state}(${lastState}), incomingNumber(old)=${incomingNumber}(${lastIncomingNumber})")
        Log.d(TAG, "incomingNumberDidNotChange: ${incomingNumberDidNotChange}")
        Log.d(TAG, "incomingNumberIsDummy: ${incomingNumberIsDummy}")
        if (lastState == state && (incomingNumberDidNotChange || incomingNumberIsDummy)) {
            Log.d(TAG, "Ignoring lastState: ${lastState}, incomingNumber: ${lastIncomingNumber}")
            return;
        }
        lastState = state;
        lastIncomingNumber = incomingNumber;
        Log.d(TAG, "Sending state: ${state}, ")
        sendCallState(state, incomingNumber) { message, listener ->
            lifecycleCoroutineScope.launch {
                withContext(Dispatchers.IO) {
                    connectIQ.sendMessage(device, myApp, message, listener)
                }
            }
        }
    }
}

fun sendCallStateExtra(extra: String, incomingNumber: String, send: (message: Any, listener: ConnectIQ.IQSendMessageListener) -> Unit) {
    when (extra) {
        TelephonyManager.EXTRA_STATE_IDLE -> {
            val msg = mapOf(
                "cmd" to "noCallInProgress"
            )
            send(msg) { _, _, status ->
                print(status)
            }
        }

        TelephonyManager.EXTRA_STATE_OFFHOOK -> {
            val msg = mapOf(
                "cmd" to "callInProgress",
                "number" to incomingNumber
            )
            send(msg) { _, _, status ->
                print(status)
            }
        }

        TelephonyManager.EXTRA_STATE_RINGING -> {
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
