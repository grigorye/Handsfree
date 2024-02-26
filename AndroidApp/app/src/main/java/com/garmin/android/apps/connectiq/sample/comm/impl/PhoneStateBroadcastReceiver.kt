package com.garmin.android.apps.connectiq.sample.comm.impl

import android.telephony.TelephonyManager

data class PhoneState(
    val incomingNumber: String?,
    val stateExtra: String
)

var lastTrackedPhoneState: PhoneState? = null


fun sendPhoneState(
    phoneState: PhoneState,
    send: (message: Map<String, Any>) -> Unit
) {
    when (phoneState.stateExtra) {
        TelephonyManager.EXTRA_STATE_IDLE -> {
            val msg = mapOf(
                "cmd" to "noCallInProgress"
            )
            send(msg)
        }

        TelephonyManager.EXTRA_STATE_OFFHOOK -> {
            val msg = mapOf(
                "cmd" to "callInProgress",
                "args" to mapOf(
                    "number" to (phoneState.incomingNumber ?: "")
                )
            )
            send(msg)
        }

        TelephonyManager.EXTRA_STATE_RINGING -> {
            val msg = mapOf(
                "cmd" to "ringing",
                "args" to mapOf(
                    "number" to (phoneState.incomingNumber ?: "")
                )
            )
            send(msg)
        }

        else -> {}
    }
}
