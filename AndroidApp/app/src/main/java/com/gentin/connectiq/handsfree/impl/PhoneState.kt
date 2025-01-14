package com.gentin.connectiq.handsfree.impl

import android.content.Context
import android.telephony.TelephonyManager
import android.util.Log
import com.gentin.connectiq.handsfree.helpers.normalizePhoneNumber
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class PhoneState(
    @SerialName("d") val stateId: PhoneStateId,
    @SerialName("n") val number: String? = null,
    @SerialName("m") val name: String? = null
)

@Serializable
enum class PhoneStateId {
    @SerialName("u") Unknown,
    @SerialName("i") Idle,
    @SerialName("h") OffHook,
    @SerialName("r") Ringing
}

fun phoneStateId(stateExtra: String): PhoneStateId {
    return when (stateExtra) {
        TelephonyManager.EXTRA_STATE_IDLE -> PhoneStateId.Idle
        TelephonyManager.EXTRA_STATE_OFFHOOK -> PhoneStateId.OffHook
        TelephonyManager.EXTRA_STATE_RINGING -> PhoneStateId.Ringing

        else -> {
            val tag = object {}.javaClass.enclosingMethod?.name
            Log.e(tag, "unknownPhoneStateExtra: $stateExtra")
            PhoneStateId.Unknown
        }
    }
}

fun phoneState(
    context: Context,
    stateExtra: String,
    incomingNumber: String?,
    incomingDisplayNames: List<String>
): PhoneState {
    val tag = object {}.javaClass.enclosingMethod?.name

    val stateId = phoneStateId(stateExtra)
    return when (stateExtra) {
        TelephonyManager.EXTRA_STATE_IDLE -> {
            PhoneState(stateId)
        }

        TelephonyManager.EXTRA_STATE_OFFHOOK -> {
            PhoneState(
                stateId,
                dispatchedPhoneNumber(context, incomingNumber),
                incomingDisplayNames.firstOrNull()
            )
        }

        TelephonyManager.EXTRA_STATE_RINGING -> {
            PhoneState(
                stateId,
                dispatchedPhoneNumber(context, incomingNumber),
                incomingDisplayNames.firstOrNull()
            )
        }

        else -> {
            Log.e(tag, "unknownPhoneStateExtra: $stateExtra")
            PhoneState(
                stateId,
                dispatchedPhoneNumber(context, incomingNumber),
                incomingDisplayNames.firstOrNull()
            )
        }
    }
}

private fun dispatchedPhoneNumber(context: Context, incomingNumber: String?): String? {
    return incomingNumber?.let { normalizePhoneNumber(context, it) }
}
