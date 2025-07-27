package com.gentin.connectiq.handsfree.impl

import android.Manifest
import android.content.Context
import android.content.ContextWrapper
import android.content.ContextWrapper.TELEPHONY_SERVICE
import android.content.Intent
import android.content.pm.PackageManager
import android.provider.Settings
import android.telecom.TelecomManager
import android.telephony.TelephonyManager
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.net.toUri
import com.gentin.connectiq.handsfree.globals.outgoingCallsShouldBeEnabled

interface PhoneCallService {
    fun makeCall(number: String, withSpeakerPhone: Boolean): Boolean
    fun hangupCall()
    fun acceptCall(withSpeakerPhone: Boolean)
    fun canMakeCalls(): Boolean
}

class DefaultPhoneCallService(
    base: Context?
) : ContextWrapper(base), PhoneCallService {
    override fun makeCall(number: String, withSpeakerPhone: Boolean): Boolean {
        Log.d(TAG, "outgoingCallsShouldBeEnabled: ${outgoingCallsShouldBeEnabled(this)}")
        if (!outgoingCallsShouldBeEnabled(this)) {
            return false
        }
        if (!canMakeCalls()) {
            return false
        }
        val intent = Intent(Intent.ACTION_CALL)
        intent.setData("tel:${number}".toUri())
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        intent.addFlags(Intent.FLAG_FROM_BACKGROUND)
        if (withSpeakerPhone) {
            intent.putExtra(TelecomManager.EXTRA_START_CALL_WITH_SPEAKERPHONE, true)
        }
        Log.d(TAG, "actionCallIntent: $intent")
        startActivity(intent)
        return true
    }

    override fun hangupCall() {
        val mgr = getSystemService(TELECOM_SERVICE) as TelecomManager
        if (ActivityCompat.checkSelfPermission(
                this,
                Manifest.permission.ANSWER_PHONE_CALLS
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            Log.i(TAG, "${Manifest.permission.ANSWER_PHONE_CALLS} is not there.")
            return
        }
        @Suppress("DEPRECATION")
        val succeeded = mgr.endCall()
        Log.i(TAG, "endCallSucceeded: $succeeded")
    }

    override fun acceptCall(withSpeakerPhone: Boolean) {
        val mgr = getSystemService(TELECOM_SERVICE) as TelecomManager
        if (ActivityCompat.checkSelfPermission(
                this,
                Manifest.permission.ANSWER_PHONE_CALLS
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            Log.i(TAG, "${Manifest.permission.ANSWER_PHONE_CALLS} is not there.")
            return
        }
        @Suppress("DEPRECATION")
        mgr.acceptRingingCall()
    }

    override fun canMakeCalls(): Boolean {
        if (!hasTelephony(this)) {
            Log.e(TAG, "noTelephony")
            return false
        }
        if (!hasCallPhonePermission(this)) {
            Log.e(TAG, "noCallPhonePermission")
            return false
        }
        if (!simIsReady(this)) {
            Log.e(TAG, "simIsNotReady")
            return false
        }
        if (isAirplaneModeOn(this)) {
            Log.e(TAG, "inAirplaneMode")
            return false
        }
        return true
    }

    companion object {
        private val TAG: String = DefaultPhoneCallService::class.java.simpleName
    }
}

private fun hasTelephony(context: Context): Boolean {
    return context.packageManager.hasSystemFeature(PackageManager.FEATURE_TELEPHONY)
}

private fun hasCallPhonePermission(context: Context): Boolean {
    return ActivityCompat.checkSelfPermission(
        context,
        Manifest.permission.CALL_PHONE
    ) == PackageManager.PERMISSION_GRANTED
}

private fun simIsReady(context: Context): Boolean {
    val telephonyManager = context.getSystemService(TELEPHONY_SERVICE) as TelephonyManager
    return telephonyManager.simState == TelephonyManager.SIM_STATE_READY
}

private fun isAirplaneModeOn(context: Context): Boolean {
    return Settings.Global.getInt(context.contentResolver, Settings.Global.AIRPLANE_MODE_ON, 0) != 0
}