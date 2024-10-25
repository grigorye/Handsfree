package com.gentin.connectiq.handsfree.impl

import android.content.Context
import android.telephony.TelephonyManager
import android.util.Log
import com.gentin.connectiq.handsfree.helpers.normalizePhoneNumber

data class PhoneState(
    val stateId: PhoneStateId,
    val number: String? = null,
    val name: String? = null
)

enum class PhoneStateId {
    Unknown,
    Idle,
    OffHook,
    Ringing
}

fun phoneState(
    context: Context,
    stateExtra: String,
    incomingNumber: String?,
    incomingDisplayNames: List<String>
): PhoneState {
    val tag = object {}.javaClass.enclosingMethod?.name

    return when (stateExtra) {
        TelephonyManager.EXTRA_STATE_IDLE -> {
            PhoneState(PhoneStateId.Idle)
        }

        TelephonyManager.EXTRA_STATE_OFFHOOK -> {
            PhoneState(
                PhoneStateId.OffHook,
                dispatchedPhoneNumber(context, incomingNumber),
                incomingDisplayNames.firstOrNull()
            )
        }

        TelephonyManager.EXTRA_STATE_RINGING -> {
            PhoneState(
                PhoneStateId.Ringing,
                dispatchedPhoneNumber(context, incomingNumber),
                incomingDisplayNames.firstOrNull()
            )
        }

        else -> {
            Log.e(tag, "unknownPhoneStateExtra: $stateExtra")
            PhoneState(
                PhoneStateId.Unknown,
                dispatchedPhoneNumber(context, incomingNumber),
                incomingDisplayNames.firstOrNull()
            )
        }
    }
}

private fun dispatchedPhoneNumber(context: Context, incomingNumber: String?): String? {
    return incomingNumber?.let { normalizePhoneNumber(context, it) }
}
