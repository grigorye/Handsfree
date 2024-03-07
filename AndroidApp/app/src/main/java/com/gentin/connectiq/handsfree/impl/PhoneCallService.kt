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

interface PhoneCallService {
    fun makeCall(number: String)
    fun hangupCall()
}

class DefaultPhoneCallService(base: Context?) : ContextWrapper(base), PhoneCallService {
    override fun makeCall(number: String) {
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

    companion object {
        private val TAG: String = DefaultPhoneCallService::class.java.simpleName
    }
}
