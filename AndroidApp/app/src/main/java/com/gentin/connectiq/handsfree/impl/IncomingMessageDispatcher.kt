package com.gentin.connectiq.handsfree.impl

import android.util.Log
import com.gentin.connectiq.handsfree.globals.simApp
import kotlinx.serialization.json.Json
import org.json.JSONObject

class IncomingMessageDispatcher(
    private val phoneCallService: PhoneCallService,
    private val queryImp: (source: IncomingMessageSource, args: QueryArgs) -> Unit,
    private val syncImp: () -> Unit,
    private val syncPhonesImp: (destination: IncomingMessageSource) -> Unit,
    private val didFirstLaunchImp: (destination: IncomingMessageSource) -> Unit,
    private val openAppImp: (source: IncomingMessageSource, args: OpenMeArgs) -> Unit,
    private val openAppInStoreImp: (source: IncomingMessageSource) -> Unit
) {
    fun handleMessage(message: Any, source: IncomingMessageSource) {
        val pojo = message as Map<*, *>
        val string = JSONObject(pojo).toString()
        Log.d(TAG, "incomingMsg: $string, source: $source")
        val json = Json { ignoreUnknownKeys = true }
        val obj = json.decodeFromString<CommonRequest>(string)
        simulateCommDelay(source)
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

            "query" -> {
                val queryRequest = json.decodeFromString<QueryRequest>(string)
                Log.d(TAG, "callRequest: $queryRequest")
                queryImp(source, queryRequest.args)
            }

            "openMe" -> {
                val openMeRequest = json.decodeFromString<OpenMeRequest>(string)
                Log.d(TAG, "openMeRequest: $openMeRequest")
                openAppImp(source, openMeRequest.args)
            }

            "openAppInStore" -> {
                openAppInStoreImp(source)
            }

            "didFirstLaunch" -> {
                didFirstLaunchImp(source)
            }

            else -> {
                Log.e(TAG, "unknownMsg: $string")
            }
        }
    }

    private fun simulateCommDelay(source: IncomingMessageSource) {
        if (commDelaySimulationEnabled(source)) {
            Thread.sleep(5000)
        }
    }

    private fun commDelaySimulationEnabled(source: IncomingMessageSource): Boolean {
        return source.app == simApp
    }

    companion object {
        private val TAG: String = IncomingMessageDispatcher::class.java.simpleName
    }
}