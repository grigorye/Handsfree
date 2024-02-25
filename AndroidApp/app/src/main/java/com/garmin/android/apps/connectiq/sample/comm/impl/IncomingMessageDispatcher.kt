package com.garmin.android.apps.connectiq.sample.comm.impl

import android.util.Log
import com.garmin.android.apps.connectiq.sample.comm.activities.CallRequest
import com.garmin.android.apps.connectiq.sample.comm.activities.CommonRequest
import kotlinx.serialization.json.Json
import org.json.JSONObject

class IncomingMessageDispatcher(
    private val phoneCallService: PhoneCallService,
    private val syncImp: () -> Unit
) {
    fun handleMessage(message: Any) {
        val pojo = message as Map<*, *>
        val string = JSONObject(pojo).toString()
        val json = Json { ignoreUnknownKeys = true }
        val obj = json.decodeFromString<CommonRequest>(string)
        Log.d(TAG, "Incoming: ${obj}")
        when (obj.cmd) {
            "call" -> {
                val callRequest = json.decodeFromString<CallRequest>(string)
                phoneCallService.makeCall(callRequest.args.number)
            }

            "hangup" -> {
                phoneCallService.hangupCall()
            }

            "syncMe" -> {
                syncImp()
            }

            else -> {
                Log.e(TAG, "Unknown cmd: ${obj}")
            }
        }
    }

    companion object {
        private val TAG: String = IncomingMessageDispatcher::class.java.simpleName
    }
}