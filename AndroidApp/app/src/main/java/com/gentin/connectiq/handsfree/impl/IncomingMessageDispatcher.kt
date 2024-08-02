package com.gentin.connectiq.handsfree.impl

import android.util.Log
import kotlinx.serialization.json.Json
import org.json.JSONObject

class IncomingMessageDispatcher(
    private val phoneCallService: PhoneCallService,
    private val syncImp: () -> Unit,
    private val syncPhonesImp: (destination: IncomingMessageSource) -> Unit,
    private val openAppImp: (source: IncomingMessageSource) -> Unit
) {
    fun handleMessage(message: Any, source: IncomingMessageSource) {
        val pojo = message as Map<*, *>
        val string = JSONObject(pojo).toString()
        Log.d(TAG, "incomingMsg: $string, source: $source")
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

            "accept" -> {
                phoneCallService.acceptCall()
            }

            "syncMe" -> {
                syncImp()
            }

            "syncPhones" -> {
                syncPhonesImp(source)
            }

            "openMe" -> {
                openAppImp(source)
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