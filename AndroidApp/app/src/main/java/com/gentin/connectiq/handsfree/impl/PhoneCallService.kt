package com.gentin.connectiq.handsfree.impl

import android.Manifest
import android.content.Context
import android.content.ContextWrapper
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.telecom.TelecomManager
import android.util.Log
import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.ActivityCompat
import com.gentin.connectiq.handsfree.globals.outgoingCallsShouldBeEnabled

interface PhoneCallService {
    fun makeCall(number: String)
    fun hangupCall()
    fun acceptCall()
}

class DefaultPhoneCallService(base: Context?) : ContextWrapper(base), PhoneCallService {
    override fun makeCall(number: String) {
        Log.d(TAG, "outgoingCallsShouldBeEnabled: ${outgoingCallsShouldBeEnabled(this)}")
        if (!outgoingCallsShouldBeEnabled(this)) {
            return
        }
        if (ActivityCompat.checkSelfPermission(
                this,
                Manifest.permission.CALL_PHONE
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            Log.e(TAG, "${Manifest.permission.CALL_PHONE} is not there.")
            return
        }
        val intent = Intent(Intent.ACTION_CALL)
        intent.setData(Uri.parse("tel:${number}"))
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        intent.addFlags(Intent.FLAG_FROM_BACKGROUND)
        Log.d(TAG, "actionCallIntent: $intent")
        startActivity(intent)
    }

    override fun hangupCall() {
        val mgr = getSystemService(AppCompatActivity.TELECOM_SERVICE) as TelecomManager
        if (ActivityCompat.checkSelfPermission(
                this,
                Manifest.permission.ANSWER_PHONE_CALLS
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            Log.i(TAG, "${Manifest.permission.ANSWER_PHONE_CALLS} is not there.")
            return
        }
        @Suppress("DEPRECATION")
        mgr.endCall()
    }

    override fun acceptCall() {
        val mgr = getSystemService(AppCompatActivity.TELECOM_SERVICE) as TelecomManager
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

    companion object {
        private val TAG: String = DefaultPhoneCallService::class.java.simpleName
    }
}
