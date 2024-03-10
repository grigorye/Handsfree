package com.gentin.connectiq.handsfree.impl

import android.util.Log
import kotlinx.serialization.json.Json
import org.json.JSONObject

class IncomingMessageDispatcher(
    private val phoneCallService: PhoneCallService,
    private val syncImp: () -> Unit,
    private val syncPhonesImp: () -> Unit
) {
    fun handleMessage(message: Any) {
        val pojo = message as Map<*, *>
        val string = JSONObject(pojo).toString()
        Log.d(TAG, "incomingMsg: $string")
        val json = Json { ignoreUnknownKeys = true }
        val obj = json.decodeFromString<CommonRequest>(string)
        when (obj.cmd) {
            "call" -> {
                val callRequest = json.decodeFromString<CallRequest>(string)
                Log.d(TAG, "callRequest: $callRequest")
                phoneCallService.makeCall(callRequest.args.number)
            }

            "hangup" -> {
                phoneCallService.hangupCall()
            }

            "syncMe" -> {
                syncImp()
            }

            "syncPhones" -> {
                syncPhonesImp()
            }

            else -> {
                Log.e(TAG, "unknownMsg: $string")
            }
        }
    }

    companion object {
        private val TAG: String = IncomingMessageDispatcher::class.java.simpleName
    }
}